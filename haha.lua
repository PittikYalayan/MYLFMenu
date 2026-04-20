local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local BRAND_LOGO_ASSET = "rbxassetid://117157050075928"

local TOP_BRAND_POSITION_X = 100
local TOP_BRAND_POSITION_Y = -300
local TOP_BRAND_SIZE_X = 900
local TOP_BRAND_SIZE_Y = 140
local TOP_BRAND_CONTAINER_SIZE_X = 900
local TOP_BRAND_CONTAINER_SIZE_Y = 120
local TOP_BRAND_IMAGE_GAP = -120
local BRAND1_SIZE_X = 276
local BRAND1_SIZE_Y = 276
local BRAND1_ZINDEX = 202
local CENTER_BRAND_SIZE_X = 276
local CENTER_BRAND_SIZE_Y = 276
local CENTER_BRAND_ZINDEX = 203
local BRAND2_SIZE_X = 276
local BRAND2_SIZE_Y = 276
local BRAND2_ZINDEX = 202

local CONFIG_FOLDER = "MYLFHUB_CONFIGS"
local CONFIG_EXTENSION = ".json"
local CONFIG_DB_FILE = CONFIG_FOLDER .. "/configs_db.json"

pcall(function()
    local old = CoreGui:FindFirstChild("MYLF_HUB")
    if old then
        old:Destroy()
    end
end)

pcall(function()
    local oldBlur = Lighting:FindFirstChild("MYLF_HUB_BLUR")
    if oldBlur then
        oldBlur:Destroy()
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "MYLF_HUB"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    end
end)

gui.Parent = CoreGui

local menuVisible = true

local loadingFrame = Instance.new("Frame")
loadingFrame.Parent = gui
loadingFrame.Name = "LoadingScreen"
loadingFrame.Size = UDim2.new(1,0,1,0)
loadingFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
loadingFrame.BackgroundTransparency = 1
loadingFrame.BorderSizePixel = 0
loadingFrame.ZIndex = 999

local loadingLogo = Instance.new("ImageLabel")
loadingLogo.Parent = loadingFrame
loadingLogo.AnchorPoint = Vector2.new(0.5,0.5)
loadingLogo.Position = UDim2.new(0.5,0,0.5,0)
loadingLogo.Size = UDim2.new(0,1024,0,1024)
loadingLogo.BackgroundTransparency = 1
loadingLogo.Image = "rbxassetid://75873229469943"
loadingLogo.ImageTransparency = 1
loadingLogo.ScaleType = Enum.ScaleType.Fit
loadingLogo.ZIndex = 1000

-- 🎵 CINEMATIC SOUND (LOGO ÖNCESİ)

local sound = Instance.new("Sound")
sound.Parent = gui

local file = "mylf_intro.mp3"

if not isfile(file) then
    writefile(file, game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/Want%20To%20Love%20(Just%20Raw).mp3"))
end

sound.SoundId = getcustomasset(file)
sound.Volume = 0
sound.Looped = false

sound:Play()

-- 🔊 FADE IN
TweenService:Create(sound, TweenInfo.new(2), {
    Volume = 1
}):Play()


-- 🎬 LOGO DELAY (SES ÖNCE)
-- 0 → 5 saniye: fade OUT (kaybolma)
TweenService:Create(loadingLogo, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
    ImageTransparency = 1
}):Play()


-- ⏳ 10 SN SONRA FADE OUT
task.delay(10, function()
    local fadeOut = TweenService:Create(sound, TweenInfo.new(2), {
        Volume = 0
    })
    fadeOut:Play()

    fadeOut.Completed:Connect(function()
        sound:Stop()
        sound:Destroy()
    end)
end)

task.delay(0.7, function()
    TweenService:Create(loadingLogo, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageTransparency = 0
    }):Play()
end)
-- 5. saniye: SOLUK (kaybol)
task.delay(3, function()
    TweenService:Create(loadingLogo, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        ImageTransparency = 1
    }):Play()
end)
task.delay(5, function()
    TweenService:Create(loadingLogo, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageTransparency = 0
    }):Play()
end)

local loadingFinished = false
task.spawn(function()
    task.wait(10)
    TweenService:Create(loadingLogo, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageTransparency = 1
    }):Play()
    task.wait(0.4)
    if loadingFrame then
        loadingFrame:Destroy()
    end
    loadingFinished = true
end)
repeat task.wait() until loadingFinished


local blur = Instance.new("BlurEffect")
blur.Name = "MYLF_HUB_BLUR"
blur.Size = 0
blur.Parent = Lighting

TweenService:Create(blur, TweenInfo.new(0.4), {
    Size = 12
}):Play()

local main = Instance.new("Frame")
main.Parent = gui
main.Name = "Main"
main.Size = UDim2.new(0, 0, 0, 0)
main.Position = UDim2.new(0.5, -175, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(35,10,15)
main.BackgroundTransparency = 0.10
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.ZIndex = 1
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 640, 0, 410)
}):Play()

local stroke = Instance.new("UIStroke")
stroke.Parent = main
stroke.Color = Color3.fromRGB(255,60,90)
stroke.Thickness = 2
stroke.Transparency = 0.25

local inner = Instance.new("Frame")
inner.Parent = main
inner.Size = UDim2.new(1,-6,1,-6)
inner.Position = UDim2.new(0,3,0,3)
inner.BackgroundTransparency = 1
inner.ZIndex = 2
Instance.new("UICorner", inner).CornerRadius = UDim.new(0,9)

local innerStroke = Instance.new("UIStroke")
innerStroke.Parent = inner
innerStroke.Color = Color3.fromRGB(255,100,120)
innerStroke.Transparency = 0.6

local texture = Instance.new("ImageLabel")
texture.Parent = main
texture.Size = UDim2.new(1,0,1,0)
texture.BackgroundTransparency = 1
texture.Image = "rbxassetid://2151741365"
texture.ImageTransparency = 0.85
texture.ZIndex = 1
Instance.new("UICorner", texture).CornerRadius = UDim.new(0,12)

local scan = Instance.new("Frame")
scan.Parent = main
scan.Size = UDim2.new(1,0,1,0)
scan.BackgroundTransparency = 1
scan.ClipsDescendants = true
scan.ZIndex = 1
Instance.new("UICorner", scan).CornerRadius = UDim.new(0,12)

local lines = Instance.new("ImageLabel")
lines.Parent = scan
lines.Size = UDim2.new(1,0,1,0)
lines.Position = UDim2.new(0,0,-1,0)
lines.BackgroundTransparency = 1
lines.Image = "rbxassetid://269100847"
lines.ImageTransparency = 0.94
lines.ZIndex = 1
Instance.new("UICorner", lines).CornerRadius = UDim.new(0,12)

local logo = Instance.new("ImageLabel")
logo.Parent = main
logo.Name = "Logo"
logo.Size = UDim2.new(0, 56, 0, 56)
logo.Position = UDim2.new(0, 14, 0, 10)
logo.BackgroundTransparency = 1
logo.Image = BRAND_LOGO_ASSET
logo.ScaleType = Enum.ScaleType.Fit
logo.ZIndex = 10

local topBrand = Instance.new("Frame")
topBrand.Parent = gui
topBrand.Name = "TopBrand"
topBrand.AnchorPoint = Vector2.new(0.5, 0)
topBrand.Position = UDim2.new(0.5, TOP_BRAND_POSITION_X, 0.5, TOP_BRAND_POSITION_Y)
topBrand.Size = UDim2.new(0, TOP_BRAND_SIZE_X, 0, TOP_BRAND_SIZE_Y)
topBrand.BackgroundTransparency = 1
topBrand.BorderSizePixel = 0
topBrand.ZIndex = 200

local topBrandContainer = Instance.new("Frame")
topBrandContainer.Parent = topBrand
topBrandContainer.AnchorPoint = Vector2.new(0.5, 0.5)
topBrandContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
topBrandContainer.Size = UDim2.new(0, TOP_BRAND_CONTAINER_SIZE_X, 0, TOP_BRAND_CONTAINER_SIZE_Y)
topBrandContainer.BackgroundTransparency = 1
topBrandContainer.BorderSizePixel = 0
topBrandContainer.ZIndex = 201

local topBrandLayout = Instance.new("UIListLayout")
topBrandLayout.Parent = topBrandContainer
topBrandLayout.FillDirection = Enum.FillDirection.Horizontal
topBrandLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topBrandLayout.VerticalAlignment = Enum.VerticalAlignment.Center
topBrandLayout.Padding = UDim.new(0, TOP_BRAND_IMAGE_GAP)
topBrandLayout.SortOrder = Enum.SortOrder.LayoutOrder

local brandImage1 = Instance.new("ImageLabel")
brandImage1.Parent = topBrandContainer
brandImage1.LayoutOrder = 1
brandImage1.Size = UDim2.new(0, BRAND1_SIZE_X, 0, BRAND1_SIZE_Y)
brandImage1.BackgroundTransparency = 1
brandImage1.BorderSizePixel = 0
brandImage1.Image = "rbxassetid://126564887562875"
brandImage1.ScaleType = Enum.ScaleType.Fit
brandImage1.ZIndex = BRAND1_ZINDEX

local centerBrandImage = Instance.new("ImageLabel")
centerBrandImage.Parent = topBrandContainer
centerBrandImage.LayoutOrder = 2
centerBrandImage.Size = UDim2.new(0, CENTER_BRAND_SIZE_X, 0, CENTER_BRAND_SIZE_Y)
centerBrandImage.BackgroundTransparency = 1
centerBrandImage.BorderSizePixel = 0
centerBrandImage.Image = "rbxassetid://115797801204430"
centerBrandImage.ScaleType = Enum.ScaleType.Fit
centerBrandImage.ZIndex = CENTER_BRAND_ZINDEX

local brandImage2 = Instance.new("ImageLabel")
brandImage2.Parent = topBrandContainer
brandImage2.LayoutOrder = 3
brandImage2.Size = UDim2.new(0, BRAND2_SIZE_X, 0, BRAND2_SIZE_Y)
brandImage2.BackgroundTransparency = 1
brandImage2.BorderSizePixel = 0
brandImage2.Image = "rbxassetid://136411269839531"
brandImage2.ScaleType = Enum.ScaleType.Fit
brandImage2.ZIndex = BRAND2_ZINDEX

local mouseFxLayer = Instance.new("Frame")
mouseFxLayer.Parent = main
mouseFxLayer.Size = UDim2.new(1,0,1,0)
mouseFxLayer.BackgroundTransparency = 1
mouseFxLayer.ZIndex = 40
mouseFxLayer.ClipsDescendants = true
Instance.new("UICorner", mouseFxLayer).CornerRadius = UDim.new(0,12)

local themes = {
    ["Elma Yeşili"] = {
        stroke = Color3.fromRGB(132,255,85),
        inner = Color3.fromRGB(185,255,155),
        g1 = Color3.fromRGB(44,90,28),
        g2 = Color3.fromRGB(24,45,18),
        g3 = Color3.fromRGB(10,22,8),
    },
    ["Cherry"] = {
        stroke = Color3.fromRGB(255,55,95),
        inner = Color3.fromRGB(255,120,150),
        g1 = Color3.fromRGB(95,15,30),
        g2 = Color3.fromRGB(45,10,18),
        g3 = Color3.fromRGB(20,5,8),
    },
    ["Elma Kırmızısı"] = {
        stroke = Color3.fromRGB(255,70,40),
        inner = Color3.fromRGB(255,130,110),
        g1 = Color3.fromRGB(110,25,15),
        g2 = Color3.fromRGB(55,15,10),
        g3 = Color3.fromRGB(22,8,6),
    },
    ["Okyanus Mavisi"] = {
        stroke = Color3.fromRGB(55,170,255),
        inner = Color3.fromRGB(120,210,255),
        g1 = Color3.fromRGB(15,60,95),
        g2 = Color3.fromRGB(10,28,50),
        g3 = Color3.fromRGB(6,12,22),
    },
    ["Deep Neon Mavi"] = {
        stroke = Color3.fromRGB(0,140,255),
        inner = Color3.fromRGB(90,200,255),
        g1 = Color3.fromRGB(5,30,110),
        g2 = Color3.fromRGB(8,18,60),
        g3 = Color3.fromRGB(4,8,24),
    },
    ["Turkuaz Şöleni"] = {
        stroke = Color3.fromRGB(0,255,210),
        inner = Color3.fromRGB(120,255,235),
        g1 = Color3.fromRGB(10,85,75),
        g2 = Color3.fromRGB(8,42,38),
        g3 = Color3.fromRGB(4,18,16),
    },
}

local themeOrder = {
    "Elma Yeşili",
    "Cherry",
    "Elma Kırmızısı",
    "Okyanus Mavisi",
    "Deep Neon Mavi",
    "Turkuaz Şöleni"
}

local grad = Instance.new("UIGradient")
grad.Parent = main
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80,10,20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35,10,15)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15,5,8))
})
grad.Rotation = 90

local currentThemeIndex = 2
local currentThemeColor = themes["Cherry"].stroke

brandImage1.ImageColor3 = currentThemeColor
centerBrandImage.ImageColor3 = currentThemeColor
brandImage2.ImageColor3 = currentThemeColor

brandImage1.ImageTransparency = 0.1
centerBrandImage.ImageTransparency = 0.1
brandImage2.ImageTransparency = 0.1

local themeableStrokes = {}
local themeableFills = {}
local themeableGlows = {}
local pulsingObjects = {}
local listeningHotkeyRef = nil
local hotkeyBindings = {}

local function addThemeStroke(obj)
    if obj then
        table.insert(themeableStrokes, obj)
    end
end

local function addThemeFill(obj)
    if obj then
        table.insert(themeableFills, obj)
    end
end

local function addThemeGlow(obj)
    if obj then
        table.insert(themeableGlows, obj)
    end
end

local function registerPulseObject(obj)
    if obj then
        table.insert(pulsingObjects, obj)
    end
end

local function unregisterPulseObject(obj)
    for i = #pulsingObjects, 1, -1 do
        if pulsingObjects[i] == obj then
            table.remove(pulsingObjects, i)
        end
    end
end

local function setSequence(obj, t)
    obj.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, t.g1),
        ColorSequenceKeypoint.new(0.5, t.g2),
        ColorSequenceKeypoint.new(1, t.g3)
    })
end

local function formatInputObject(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        return input.KeyCode.Name
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        return "Mouse1"
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        return "Mouse2"
    elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
        return "Mouse3"
    elseif input.UserInputType == Enum.UserInputType.MouseWheel then
        return "MouseWheel"
    end
    return nil
end

local function formatMultiSelection(selectionMap)
    local selected = {}
    for name, enabled in pairs(selectionMap) do
        if enabled then
            table.insert(selected, name)
        end
    end
    table.sort(selected)
    if #selected == 0 then
        return "NONE"
    end
    return table.concat(selected, ", ")
end

local themeSwitch = Instance.new("TextButton")
themeSwitch.Parent = main
themeSwitch.Name = "ThemeSwitch"
themeSwitch.Size = UDim2.new(0, 138, 0, 26)
themeSwitch.Position = UDim2.new(1, -150, 0, 12)
themeSwitch.BackgroundTransparency = 1
themeSwitch.BorderSizePixel = 0
themeSwitch.Text = ""
themeSwitch.AutoButtonColor = false
themeSwitch.ZIndex = 20
Instance.new("UICorner", themeSwitch).CornerRadius = UDim.new(0,8)

local themeSwitchGradient = Instance.new("UIGradient")
themeSwitchGradient.Name = "ThemeSwitchGradient"
themeSwitchGradient.Parent = themeSwitch
themeSwitchGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(95,15,30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(45,10,18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20,5,8))
})
themeSwitchGradient.Rotation = 90

local themeButtonStroke = Instance.new("UIStroke")
themeButtonStroke.Parent = themeSwitch
themeButtonStroke.Color = currentThemeColor
themeButtonStroke.Transparency = 0.55
themeButtonStroke.Thickness = 1

local themeSwitchNoise = Instance.new("ImageLabel")
themeSwitchNoise.Parent = themeSwitch
themeSwitchNoise.Size = UDim2.new(1,0,1,0)
themeSwitchNoise.BackgroundTransparency = 1
themeSwitchNoise.Image = "rbxassetid://2151741365"
themeSwitchNoise.ImageTransparency = 0.97
themeSwitchNoise.ZIndex = 22
Instance.new("UICorner", themeSwitchNoise).CornerRadius = UDim.new(0,8)

local themeContent = Instance.new("Frame")
themeContent.Parent = themeSwitch
themeContent.BackgroundTransparency = 1
themeContent.Size = UDim2.new(1,0,1,0)
themeContent.ZIndex = 25

local themeDot = Instance.new("Frame")
themeDot.Parent = themeContent
themeDot.Size = UDim2.new(0,8,0,8)
themeDot.Position = UDim2.new(0,8,0.5,-4)
themeDot.BackgroundColor3 = currentThemeColor
themeDot.BorderSizePixel = 0
themeDot.ZIndex = 26
Instance.new("UICorner", themeDot).CornerRadius = UDim.new(1,0)

local themeDotStroke = Instance.new("UIStroke")
themeDotStroke.Parent = themeDot
themeDotStroke.Color = Color3.fromRGB(255,255,255)
themeDotStroke.Transparency = 0.45
themeDotStroke.Thickness = 1

local themeText = Instance.new("TextLabel")
themeText.Parent = themeContent
themeText.BackgroundTransparency = 1
themeText.Position = UDim2.new(0,20,0,0)
themeText.Size = UDim2.new(1,-42,1,0)
themeText.TextXAlignment = Enum.TextXAlignment.Left
themeText.Text = "Cherry"
themeText.TextColor3 = Color3.fromRGB(255,255,255)
themeText.TextStrokeTransparency = 0.86
themeText.TextSize = 11
themeText.Font = Enum.Font.GothamSemibold
themeText.ZIndex = 26

local wheelHint = Instance.new("TextLabel")
wheelHint.Parent = themeContent
wheelHint.BackgroundTransparency = 1
wheelHint.AnchorPoint = Vector2.new(1,0.5)
wheelHint.Position = UDim2.new(1,-7,0.5,0)
wheelHint.Size = UDim2.new(0,30,0,12)
wheelHint.Text = "↕"
wheelHint.TextColor3 = Color3.fromRGB(255,255,255)
wheelHint.TextStrokeTransparency = 1
wheelHint.TextSize = 11
wheelHint.Font = Enum.Font.GothamBold
wheelHint.ZIndex = 26

themeSwitch.MouseEnter:Connect(function()
    TweenService:Create(themeButtonStroke, TweenInfo.new(0.12), {Transparency = 0.18}):Play()
end)

themeSwitch.MouseLeave:Connect(function()
    TweenService:Create(themeButtonStroke, TweenInfo.new(0.12), {Transparency = 0.55}):Play()
end)

local sidePanel = Instance.new("Frame")
sidePanel.Parent = gui
sidePanel.Name = "ProfilePanel"
sidePanel.Size = UDim2.new(0, 0, 0, 0)
sidePanel.Position = UDim2.new(
    main.Position.X.Scale,
    main.Position.X.Offset - 205,
    main.Position.Y.Scale,
    main.Position.Y.Offset
)
sidePanel.BackgroundColor3 = Color3.fromRGB(35,10,15)
sidePanel.BackgroundTransparency = 0.10
sidePanel.BorderSizePixel = 0
sidePanel.ClipsDescendants = true
sidePanel.ZIndex = 1
Instance.new("UICorner", sidePanel).CornerRadius = UDim.new(0,12)

TweenService:Create(sidePanel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 190, 0, 410)
}):Play()

local sideBrand = Instance.new("Frame")
sideBrand.Parent = gui
sideBrand.Name = "SideBrand"
sideBrand.AnchorPoint = Vector2.new(0.5, 0)
sideBrand.Position = UDim2.new(
    sidePanel.Position.X.Scale,
    sidePanel.Position.X.Offset + 95,
    sidePanel.Position.Y.Scale,
    sidePanel.Position.Y.Offset - 53
)
sideBrand.Size = UDim2.new(0, 70, 0, 58)
sideBrand.BackgroundTransparency = 1
sideBrand.BorderSizePixel = 0
sideBrand.ZIndex = 210

local sideBrandLogo = Instance.new("ImageLabel")
sideBrandLogo.Parent = sideBrand
sideBrandLogo.AnchorPoint = Vector2.new(0.5, 0.5)
sideBrandLogo.Position = UDim2.new(0.5, 0, 0.5, 0)
sideBrandLogo.Size = UDim2.new(0, 46, 0, 46)
sideBrandLogo.BackgroundTransparency = 1
sideBrandLogo.Image = BRAND_LOGO_ASSET
sideBrandLogo.ScaleType = Enum.ScaleType.Fit
sideBrandLogo.ZIndex = 211

local sideGrad = Instance.new("UIGradient")
sideGrad.Parent = sidePanel
sideGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80,10,20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35,10,15)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15,5,8))
})
sideGrad.Rotation = 90

local sideStroke = Instance.new("UIStroke")
sideStroke.Parent = sidePanel
sideStroke.Color = currentThemeColor
sideStroke.Thickness = 2
sideStroke.Transparency = 0.25

local sideInner = Instance.new("Frame")
sideInner.Parent = sidePanel
sideInner.Size = UDim2.new(1,-6,1,-6)
sideInner.Position = UDim2.new(0,3,0,3)
sideInner.BackgroundTransparency = 1
sideInner.ZIndex = 2
Instance.new("UICorner", sideInner).CornerRadius = UDim.new(0,9)

local sideInnerStroke = Instance.new("UIStroke")
sideInnerStroke.Parent = sideInner
sideInnerStroke.Color = Color3.fromRGB(255,100,120)
sideInnerStroke.Transparency = 0.6

local sideTexture = Instance.new("ImageLabel")
sideTexture.Parent = sidePanel
sideTexture.Size = UDim2.new(1,0,1,0)
sideTexture.BackgroundTransparency = 1
sideTexture.Image = "rbxassetid://2151741365"
sideTexture.ImageTransparency = 0.87
sideTexture.ZIndex = 1
Instance.new("UICorner", sideTexture).CornerRadius = UDim.new(0,12)

local sideScan = Instance.new("Frame")
sideScan.Parent = sidePanel
sideScan.Size = UDim2.new(1,0,1,0)
sideScan.BackgroundTransparency = 1
sideScan.ClipsDescendants = true
sideScan.ZIndex = 1
Instance.new("UICorner", sideScan).CornerRadius = UDim.new(0,12)

local sideLines = Instance.new("ImageLabel")
sideLines.Parent = sideScan
sideLines.Size = UDim2.new(1,0,1,0)
sideLines.Position = UDim2.new(0,0,-1,0)
sideLines.BackgroundTransparency = 1
sideLines.Image = "rbxassetid://269100847"
sideLines.ImageTransparency = 0.94
sideLines.ZIndex = 1
Instance.new("UICorner", sideLines).CornerRadius = UDim.new(0,12)

local viewportHolder = Instance.new("Frame")
viewportHolder.Parent = sidePanel
viewportHolder.Size = UDim2.new(1,-24,0,220)
viewportHolder.Position = UDim2.new(0,12,0,14)
viewportHolder.BackgroundColor3 = Color3.fromRGB(255,255,255)
viewportHolder.BackgroundTransparency = 0.94
viewportHolder.BorderSizePixel = 0
viewportHolder.ZIndex = 4
Instance.new("UICorner", viewportHolder).CornerRadius = UDim.new(0,10)

local viewportHolderStroke = Instance.new("UIStroke")
viewportHolderStroke.Parent = viewportHolder
viewportHolderStroke.Color = Color3.fromRGB(255,255,255)
viewportHolderStroke.Transparency = 0.75
viewportHolderStroke.Thickness = 1

local viewport = Instance.new("ViewportFrame")
viewport.Parent = viewportHolder
viewport.Size = UDim2.new(1,-12,1,-12)
viewport.Position = UDim2.new(0,6,0,6)
viewport.BackgroundTransparency = 1
viewport.BorderSizePixel = 0
viewport.LightColor = Color3.fromRGB(255,255,255)
viewport.LightDirection = Vector3.new(-1, -1, -1)
viewport.Ambient = Color3.fromRGB(190,190,190)
viewport.ZIndex = 5

local camera = Instance.new("Camera")
camera.FieldOfView = 30
camera.Parent = viewport
viewport.CurrentCamera = camera

local worldModel = Instance.new("WorldModel")
worldModel.Parent = viewport

previewOverlay = Instance.new("Frame")
previewOverlay.Parent = viewportHolder
previewOverlay.Name = "PreviewOverlay"
previewOverlay.Size = UDim2.new(1,-12,1,-12)
previewOverlay.Position = UDim2.new(0,6,0,6)
previewOverlay.BackgroundTransparency = 1
previewOverlay.BorderSizePixel = 0
previewOverlay.ZIndex = 9
previewOverlay.ClipsDescendants = true
Instance.new("UICorner", previewOverlay).CornerRadius = UDim.new(0,8)

local displayName = Instance.new("TextLabel")
displayName.Parent = sidePanel
displayName.BackgroundTransparency = 1
displayName.Position = UDim2.new(0,14,0,245)
displayName.Size = UDim2.new(1,-28,0,28)
displayName.Text = LocalPlayer.DisplayName
displayName.TextColor3 = Color3.fromRGB(255,255,255)
displayName.TextStrokeTransparency = 0.82
displayName.TextSize = 20
displayName.Font = Enum.Font.GothamBold
displayName.TextXAlignment = Enum.TextXAlignment.Center
displayName.ZIndex = 6

local userName = Instance.new("TextLabel")
userName.Parent = sidePanel
userName.BackgroundTransparency = 1
userName.Position = UDim2.new(0,14,0,273)
userName.Size = UDim2.new(1,-28,0,22)
userName.Text = "@" .. LocalPlayer.Name
userName.TextColor3 = Color3.fromRGB(220,220,220)
userName.TextStrokeTransparency = 0.88
userName.TextSize = 13
userName.Font = Enum.Font.GothamSemibold
userName.TextXAlignment = Enum.TextXAlignment.Center
userName.ZIndex = 6

local subName = Instance.new("TextLabel")
subName.Parent = sidePanel
subName.BackgroundTransparency = 1
subName.Position = UDim2.new(0,14,0,298)
subName.Size = UDim2.new(1,-28,0,18)
subName.Text = "Dev By : PittikYalayan"
subName.TextColor3 = Color3.fromRGB(180,180,180)
subName.TextStrokeTransparency = 0.92
subName.TextSize = 10
subName.Font = Enum.Font.GothamBold
subName.TextXAlignment = Enum.TextXAlignment.Center
subName.ZIndex = 6

-- ================= STREAM + CHAT BUTTON INTEGRATION =================

task.spawn(function()

    local requestFn =
        (syn and syn.request)
        or (http and http.request)
        or http_request
        or request

    local CHAT_ENDPOINT = "https://mylf-chat.bythekyol.workers.dev"
    local CHAT_ROOM = "global"

    local function safeJsonDecode(str)
        local ok, data = pcall(function()
            return HttpService:JSONDecode(str)
        end)
        return ok and data or nil
    end

    local function chatRequest(path, method, bodyTable)
        if not requestFn then
            return nil
        end

        local headers = {
            ["Content-Type"] = "application/json"
        }

        local body = nil
        if bodyTable then
            body = HttpService:JSONEncode(bodyTable)
        end

        local ok, res = pcall(function()
            return requestFn({
                Url = CHAT_ENDPOINT .. path,
                Method = method,
                Headers = headers,
                Body = body
            })
        end)

        if not ok or not res then
            return nil
        end

        return res
    end

    local function fetchChatMessages()

        local res = chatRequest("/messages?room=" .. CHAT_ROOM, "GET")
        if not res or not res.Body then
            return {}
        end

        local data = safeJsonDecode(res.Body)
        if data and type(data.messages) == "table" then
            return data.messages
        end

        return {}
    end

	local function sendHeartbeat()
    local res = chatRequest("/heartbeat", "POST", {
        username = LocalPlayer.Name,
        displayName = LocalPlayer.DisplayName,
        userId = tostring(LocalPlayer.UserId)
    })

    if not res or not res.Body then
        return false
    end

    local data = safeJsonDecode(res.Body)
    return data and data.ok == true
end

    local function sendChatMessage(text)
    text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then
        return false, "empty"
    end

    local res = chatRequest("/send", "POST", {
        room = CHAT_ROOM,
        username = LocalPlayer.Name,
        displayName = LocalPlayer.DisplayName,
        userId = tostring(LocalPlayer.UserId),
        message = text
    })

    if not res then
        return false, "no response"
    end

    print("STATUS:", res.StatusCode)
    print("BODY:", res.Body)

    if not res.Body then
        return false, "no body"
    end

    local data = safeJsonDecode(res.Body)

    if data and data.ok == true then
        return true
    end

    return false, res.Body
end

    local function createSideActionButton(parent, yPos, labelText)
        local data = { state = false }

        local button = Instance.new("TextButton")
        button.Parent = parent
        button.Size = UDim2.new(1, -24, 0, 34)
        button.Position = UDim2.new(0, 12, 0, yPos)
        button.BackgroundTransparency = 1
        button.Text = ""
        button.AutoButtonColor = false
        button.ZIndex = 6
        Instance.new("UICorner", button).CornerRadius = UDim.new(0,8)

        local fill = Instance.new("Frame")
        fill.Parent = button
        fill.Size = UDim2.new(1,0,1,0)
        fill.BackgroundColor3 = currentThemeColor
        fill.BackgroundTransparency = 0.96
        fill.BorderSizePixel = 0
        fill.ZIndex = 5
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0,8)
        addThemeFill(fill)

        local fillGradient = Instance.new("UIGradient")
        fillGradient.Parent = fill
        fillGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(1, 0.7)
        })

        local strokeObj = Instance.new("UIStroke")
        strokeObj.Parent = button
        strokeObj.Color = currentThemeColor
        strokeObj.Thickness = 1
        strokeObj.Transparency = 0.18
        addThemeStroke(strokeObj)

        local text = Instance.new("TextLabel")
        text.Parent = button
        text.BackgroundTransparency = 1
        text.Size = UDim2.new(1,0,1,0)
        text.Text = labelText
        text.TextColor3 = Color3.fromRGB(255,255,255)
        text.TextStrokeTransparency = 1
        text.TextSize = 11
        text.Font = Enum.Font.GothamBold
        text.ZIndex = 6

        function data:setState(on)
            self.state = on and true or false
            if self.state then
                registerPulseObject(fill)
            else
                unregisterPulseObject(fill)
            end

            TweenService:Create(fill, TweenInfo.new(0.14), {
                BackgroundTransparency = self.state and 0.16 or 0.96
            }):Play()

            TweenService:Create(strokeObj, TweenInfo.new(0.14), {
                Transparency = self.state and 0.04 or 0.18
            }):Play()
        end

        button.MouseEnter:Connect(function()
            TweenService:Create(strokeObj, TweenInfo.new(0.12), {
                Transparency = data.state and 0.04 or 0.08
            }):Play()

            if not data.state then
                TweenService:Create(fill, TweenInfo.new(0.12), {
                    BackgroundTransparency = 0.9
                }):Play()
            end
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(fill, TweenInfo.new(0.12), {
                BackgroundTransparency = data.state and 0.16 or 0.96
            }):Play()

            TweenService:Create(strokeObj, TweenInfo.new(0.12), {
                Transparency = data.state and 0.04 or 0.18
            }):Play()
        end)

        data.button = button
        data.fill = fill
        data.stroke = strokeObj
        data.text = text
        return data
    end

    -- STREAM BUTTON
    local streamToggle = createSideActionButton(sidePanel, 330, "STREAM")

    local spoofName = "MYLFHUB.com"
    local realName = LocalPlayer.Name
    local realDisplay = LocalPlayer.DisplayName

    local tracked = {}
    local connections = {}
    local spoofActive = false

    local function applySpoof(obj)
        if not obj or not tracked[obj] then return end
        local txt = obj.Text
        if not txt or txt == "" then return end

        local new = txt

        if string.find(new, realName, 1, true) then
            new = string.gsub(new, realName, spoofName)
        end

        if string.find(new, realDisplay, 1, true) then
            new = string.gsub(new, realDisplay, spoofName)
        end

        if string.find(new, "@" .. realName, 1, true) then
            new = string.gsub(new, "@" .. realName, "@" .. spoofName)
        end

        if new ~= txt then
            obj.Text = new
        end
    end

    local function register(obj)
        if not obj then return end
        if tracked[obj] then return end

        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            tracked[obj] = true
            applySpoof(obj)

            connections[obj] = obj:GetPropertyChangedSignal("Text"):Connect(function()
                applySpoof(obj)
            end)
        end
    end

    local function startSpoof()
        if spoofActive then return end
        spoofActive = true

        for _, v in ipairs(game:GetDescendants()) do
            register(v)
        end

        connections.added = game.DescendantAdded:Connect(function(obj)
            register(obj)
        end)

        pcall(function()
            LocalPlayer.DisplayName = spoofName
        end)

        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.DisplayName = spoofName
            end
        end

        local TextChatService = game:FindService("TextChatService")
        if TextChatService then
            pcall(function()
                connections.chat = TextChatService.OnIncomingMessage:Connect(function(msg)
                    if msg.TextSource and msg.TextSource.UserId == LocalPlayer.UserId then
                        msg.PrefixText = spoofName
                    end
                end)
            end)
        end
    end

    local function stopSpoof()
        spoofActive = false

        for k, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
            connections[k] = nil
        end

        for k in pairs(tracked) do
            tracked[k] = nil
        end
    end

    streamToggle.button.MouseButton1Click:Connect(function()
        streamToggle:setState(not streamToggle.state)

        if streamToggle.state then
            startSpoof()
        else
            stopSpoof()
        end
    end)

    -- CHAT BUTTON
    local chatToggle = createSideActionButton(sidePanel, 368, "CHAT")

    -- CHAT WINDOW
    local chatWindow = Instance.new("Frame")
    chatWindow.Parent = gui
    chatWindow.Name = "MYLF_CHAT_WINDOW"
    chatWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    chatWindow.Position = UDim2.new(0.5, 120, 0.5, 16)
    chatWindow.Size = UDim2.new(0, 0, 0, 0)
    chatWindow.BackgroundColor3 = Color3.fromRGB(35,10,15)
    chatWindow.BackgroundTransparency = 0.08
    chatWindow.BorderSizePixel = 0
    chatWindow.ClipsDescendants = true
    chatWindow.Visible = false
    chatWindow.ZIndex = 60
    Instance.new("UICorner", chatWindow).CornerRadius = UDim.new(0,12)

    local chatGradient = Instance.new("UIGradient")
    chatGradient.Parent = chatWindow
    chatGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80,10,20)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35,10,15)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15,5,8))
    })
    chatGradient.Rotation = 90

    local chatStroke = Instance.new("UIStroke")
    chatStroke.Parent = chatWindow
    chatStroke.Color = currentThemeColor
    chatStroke.Thickness = 1.6
    chatStroke.Transparency = 0.16
    addThemeStroke(chatStroke)

    local chatNoise = Instance.new("ImageLabel")
    chatNoise.Parent = chatWindow
    chatNoise.Size = UDim2.new(1,0,1,0)
    chatNoise.BackgroundTransparency = 1
    chatNoise.Image = "rbxassetid://2151741365"
    chatNoise.ImageTransparency = 0.96
    chatNoise.ZIndex = 61
    Instance.new("UICorner", chatNoise).CornerRadius = UDim.new(0,12)

    local chatTopLine = Instance.new("Frame")
    chatTopLine.Parent = chatWindow
    chatTopLine.Size = UDim2.new(1,0,0,1)
    chatTopLine.BackgroundColor3 = currentThemeColor
    chatTopLine.BackgroundTransparency = 0.10
    chatTopLine.BorderSizePixel = 0
    chatTopLine.ZIndex = 62
    addThemeFill(chatTopLine)

    local chatTitle = Instance.new("TextLabel")
    chatTitle.Parent = chatWindow
    chatTitle.BackgroundTransparency = 1
    chatTitle.Position = UDim2.new(0, 14, 0, 10)
    chatTitle.Size = UDim2.new(1, -58, 0, 24)
    chatTitle.Text = "GLOBAL CHAT"
    chatTitle.TextColor3 = Color3.fromRGB(255,255,255)
    chatTitle.TextStrokeTransparency = 1
    chatTitle.TextSize = 14
    chatTitle.Font = Enum.Font.GothamBold
    chatTitle.TextXAlignment = Enum.TextXAlignment.Left
    chatTitle.ZIndex = 63

    local closeChat = Instance.new("TextButton")
    closeChat.Parent = chatWindow
    closeChat.AnchorPoint = Vector2.new(1, 0)
    closeChat.Position = UDim2.new(1, -10, 0, 10)
    closeChat.Size = UDim2.new(0, 30, 0, 22)
    closeChat.BackgroundTransparency = 1
    closeChat.Text = "×"
    closeChat.TextColor3 = Color3.fromRGB(255,255,255)
    closeChat.TextSize = 18
    closeChat.Font = Enum.Font.GothamBold
    closeChat.AutoButtonColor = false
    closeChat.ZIndex = 63

    local chatListShell = Instance.new("Frame")
    chatListShell.Parent = chatWindow
    chatListShell.Position = UDim2.new(0, 12, 0, 42)
    chatListShell.Size = UDim2.new(1, -24, 1, -104)
    chatListShell.BackgroundColor3 = Color3.fromRGB(255,255,255)
    chatListShell.BackgroundTransparency = 0.965
    chatListShell.BorderSizePixel = 0
    chatListShell.ZIndex = 62
    Instance.new("UICorner", chatListShell).CornerRadius = UDim.new(0,10)

    local chatListStroke = Instance.new("UIStroke")
    chatListStroke.Parent = chatListShell
    chatListStroke.Color = currentThemeColor
    chatListStroke.Thickness = 1
    chatListStroke.Transparency = 0.22
    addThemeStroke(chatListStroke)

    local chatMessages = Instance.new("ScrollingFrame")
    chatMessages.Parent = chatListShell
    chatMessages.Position = UDim2.new(0, 8, 0, 3)
    chatMessages.Size = UDim2.new(1, -16, 1.03, -12)
    chatMessages.BackgroundTransparency = 1
    chatMessages.BorderSizePixel = 0
    chatMessages.CanvasSize = UDim2.new(0,0,0,0)
    chatMessages.AutomaticCanvasSize = Enum.AutomaticSize.Y
    chatMessages.ScrollBarThickness = 3
    chatMessages.ScrollBarImageTransparency = 0.35
    chatMessages.ZIndex = 63

    local chatListLayout = Instance.new("UIListLayout")
    chatListLayout.Parent = chatMessages
    chatListLayout.Padding = UDim.new(0, 6)
    chatListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local chatInputShell = Instance.new("Frame")
    chatInputShell.Parent = chatWindow
    chatInputShell.Position = UDim2.new(0, 12, 1, -54)
    chatInputShell.Size = UDim2.new(1, -110, 0, 36)
    chatInputShell.BackgroundColor3 = Color3.fromRGB(255,255,255)
    chatInputShell.BackgroundTransparency = 0.965
    chatInputShell.BorderSizePixel = 0
    chatInputShell.ZIndex = 62
    Instance.new("UICorner", chatInputShell).CornerRadius = UDim.new(0,8)

    local chatInputStroke = Instance.new("UIStroke")
    chatInputStroke.Parent = chatInputShell
    chatInputStroke.Color = currentThemeColor
    chatInputStroke.Thickness = 1
    chatInputStroke.Transparency = 0.22
    addThemeStroke(chatInputStroke)

    local chatBox = Instance.new("TextBox")
    chatBox.Parent = chatInputShell
    chatBox.Position = UDim2.new(0, 10, 0, 0)
    chatBox.Size = UDim2.new(1, -20, 1, 0)
    chatBox.BackgroundTransparency = 1
    chatBox.ClearTextOnFocus = false
    chatBox.PlaceholderText = "Mesaj yaz..."
    chatBox.Text = ""
    chatBox.TextColor3 = Color3.fromRGB(255,255,255)
    chatBox.PlaceholderColor3 = Color3.fromRGB(170,170,170)
    chatBox.TextSize = 12
    chatBox.Font = Enum.Font.GothamSemibold
    chatBox.TextXAlignment = Enum.TextXAlignment.Left
    chatBox.ZIndex = 63

    local sendButton = Instance.new("TextButton")
    sendButton.Parent = chatWindow
    sendButton.AnchorPoint = Vector2.new(1, 1)
    sendButton.Position = UDim2.new(1, -12, 1, -18)
    sendButton.Size = UDim2.new(0, 86, 0, 36)
    sendButton.BackgroundTransparency = 1
    sendButton.Text = ""
    sendButton.AutoButtonColor = false
    sendButton.ZIndex = 62
    Instance.new("UICorner", sendButton).CornerRadius = UDim.new(0,8)

    local sendFill = Instance.new("Frame")
    sendFill.Parent = sendButton
    sendFill.Size = UDim2.new(1,0,1,0)
    sendFill.BackgroundColor3 = currentThemeColor
    sendFill.BackgroundTransparency = 0.92
    sendFill.BorderSizePixel = 0
    sendFill.ZIndex = 62
    Instance.new("UICorner", sendFill).CornerRadius = UDim.new(0,8)
    addThemeFill(sendFill)

    local sendStroke = Instance.new("UIStroke")
    sendStroke.Parent = sendButton
    sendStroke.Color = currentThemeColor
    sendStroke.Thickness = 1
    sendStroke.Transparency = 0.12
    addThemeStroke(sendStroke)

    local sendText = Instance.new("TextLabel")
    sendText.Parent = sendButton
    sendText.BackgroundTransparency = 1
    sendText.Size = UDim2.new(1,0,1,0)
    sendText.Text = "GÖNDER"
    sendText.TextColor3 = Color3.fromRGB(255,255,255)
    sendText.TextSize = 11
    sendText.Font = Enum.Font.GothamBold
    sendText.ZIndex = 63

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Parent = chatWindow
    statusLabel.BackgroundTransparency = 1
    statusLabel.Position = UDim2.new(0, 14, 1, -18)
    statusLabel.Size = UDim2.new(1, -120, 0, 14)
    statusLabel.Text = "Bağlı"
    statusLabel.TextColor3 = Color3.fromRGB(175,175,175)
    statusLabel.TextSize = 10
    statusLabel.Font = Enum.Font.GothamSemibold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.ZIndex = 63
	local chatDragging = false
local chatDragStart = nil
local chatStartPos = nil

local function makeChatDraggable(dragObject)
    dragObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            chatDragging = true
            chatDragStart = input.Position
            chatStartPos = chatWindow.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    chatDragging = false
                end
            end)
        end
    end)

    dragObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            -- sadece mouse move algılansın yeter
        end
    end)
end

UIS.InputChanged:Connect(function(input)
    if chatDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - chatDragStart
        chatWindow.Position = UDim2.new(
            chatStartPos.X.Scale,
            chatStartPos.X.Offset + delta.X,
            chatStartPos.Y.Scale,
            chatStartPos.Y.Offset + delta.Y
        )
    end
end)

makeChatDraggable(chatTitle)
makeChatDraggable(chatTopLine)

    local chatOpen = false
    local refreshToken = 0

    local function clearMessageItems()
        for _, child in ipairs(chatMessages:GetChildren()) do
            if not child:IsA("UIListLayout") then
                child:Destroy()
            end
        end
    end

    local function addMessageBubble(entry)
    local username = tostring(entry.username or entry.displayName or "unknown")
    local message = tostring(entry.message or "")
    local dateText = tostring(entry.date or "")
    local liveState = entry.live == true and "LIVE" or "OFFLINE"

    local holder = Instance.new("Frame")
    holder.Parent = chatMessages
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Size = UDim2.new(1, -2, 0, 68)
    holder.ZIndex = 64

    local bubble = Instance.new("Frame")
    bubble.Parent = holder
    bubble.Size = UDim2.new(1, 0, 1, 0)
    bubble.BackgroundColor3 = Color3.fromRGB(255,255,255)
    bubble.BackgroundTransparency = 0.965
    bubble.BorderSizePixel = 0
    bubble.ZIndex = 64
    Instance.new("UICorner", bubble).CornerRadius = UDim.new(0,8)

    local bubbleStroke = Instance.new("UIStroke")
    bubbleStroke.Parent = bubble
    bubbleStroke.Color = currentThemeColor
    bubbleStroke.Thickness = 1
    bubbleStroke.Transparency = 0.24
    bubbleStroke.ZIndex = 64
    addThemeStroke(bubbleStroke)

    local bubbleNoise = Instance.new("ImageLabel")
    bubbleNoise.Parent = bubble
    bubbleNoise.Size = UDim2.new(1,0,1,0)
    bubbleNoise.BackgroundTransparency = 1
    bubbleNoise.Image = "rbxassetid://2151741365"
    bubbleNoise.ImageTransparency = 0.975
    bubbleNoise.ZIndex = 64
    Instance.new("UICorner", bubbleNoise).CornerRadius = UDim.new(0,8)

    local nameText = Instance.new("TextLabel")
    nameText.Parent = bubble
    nameText.BackgroundTransparency = 1
    nameText.Position = UDim2.new(0, 10, 0, 5)
    nameText.Size = UDim2.new(1, -110, 0, 14)
    nameText.Text = username
    nameText.TextColor3 = currentThemeColor
    nameText.TextSize = 10
    nameText.Font = Enum.Font.GothamBold
    nameText.TextXAlignment = Enum.TextXAlignment.Left
    nameText.ZIndex = 65

    local liveBadge = Instance.new("TextLabel")
    liveBadge.Parent = bubble
    liveBadge.AnchorPoint = Vector2.new(1, 0)
    liveBadge.Position = UDim2.new(1, -10, 0, 6)
    liveBadge.Size = UDim2.new(0, 62, 0, 14)
    liveBadge.BackgroundTransparency = 1
    liveBadge.Text = liveState
    liveBadge.TextColor3 = entry.live == true and currentThemeColor or Color3.fromRGB(170,170,170)
    liveBadge.TextSize = 9
    liveBadge.Font = Enum.Font.GothamBold
    liveBadge.TextXAlignment = Enum.TextXAlignment.Right
    liveBadge.ZIndex = 65

    local msgText = Instance.new("TextLabel")
    msgText.Parent = bubble
    msgText.BackgroundTransparency = 1
    msgText.Position = UDim2.new(0, 10, 0, 22)
    msgText.Size = UDim2.new(1, -20, 0, 24)
    msgText.Text = message
    msgText.TextWrapped = true
    msgText.TextYAlignment = Enum.TextYAlignment.Top
    msgText.TextColor3 = Color3.fromRGB(235,235,235)
    msgText.TextSize = 11
    msgText.Font = Enum.Font.GothamSemibold
    msgText.TextXAlignment = Enum.TextXAlignment.Left
    msgText.ZIndex = 65

    local metaText = Instance.new("TextLabel")
    metaText.Parent = bubble
    metaText.BackgroundTransparency = 1
    metaText.AnchorPoint = Vector2.new(1, 1)
    metaText.Position = UDim2.new(1, -10, 1, -6)
    metaText.Size = UDim2.new(1, -20, 0, 12)
    metaText.Text = dateText
    metaText.TextColor3 = Color3.fromRGB(160,160,160)
    metaText.TextSize = 9
    metaText.Font = Enum.Font.GothamSemibold
    metaText.TextXAlignment = Enum.TextXAlignment.Right
    metaText.ZIndex = 65
end

    local function refreshChat()
    statusLabel.Text = "Mesajlar yenileniyor..."

    local oldCanvasY = chatMessages.CanvasPosition.Y
    local oldAbsY = chatMessages.AbsoluteCanvasSize.Y
    local viewHeight = chatMessages.AbsoluteWindowSize.Y

    local wasNearBottom = (oldAbsY - (oldCanvasY + viewHeight)) <= 35

    local messages = fetchChatMessages()
    clearMessageItems()

    for _, entry in ipairs(messages) do
        addMessageBubble(entry)
    end

    statusLabel.Text = "Bağlı • " .. tostring(#messages) .. " mesaj"

    task.defer(function()
        local newAbsY = chatMessages.AbsoluteCanvasSize.Y

        if wasNearBottom then
            chatMessages.CanvasPosition = Vector2.new(
                0,
                math.max(0, newAbsY - viewHeight)
            )
        else
            chatMessages.CanvasPosition = Vector2.new(
                0,
                math.min(oldCanvasY, math.max(0, newAbsY - viewHeight))
            )
        end
    end)
end

    local function setChatWindowVisible(on)
        chatOpen = on and true or false
        chatToggle:setState(chatOpen)

       if chatOpen then
    chatWindow.Visible = true
    TweenService:Create(chatWindow, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 360, 0, 320)
    }):Play()
    refreshChat()
    sendHeartbeat()

    refreshToken += 1
    local myToken = refreshToken

    task.spawn(function()
        while chatOpen and myToken == refreshToken do
            task.wait(15)
            if chatOpen and myToken == refreshToken then
                sendHeartbeat()
            end
        end
    end)

    task.spawn(function()
        while chatOpen and myToken == refreshToken do
            task.wait(3)
            if chatOpen and myToken == refreshToken then
                refreshChat()
            end
        end
    end)
else
    refreshToken += 1
    local tween = TweenService:Create(chatWindow, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    tween:Play()
    tween.Completed:Connect(function()
        if not chatOpen then
            chatWindow.Visible = false
        end
    end)
end
    end

    sendButton.MouseEnter:Connect(function()
        TweenService:Create(sendFill, TweenInfo.new(0.12), {BackgroundTransparency = 0.82}):Play()
        TweenService:Create(sendStroke, TweenInfo.new(0.12), {Transparency = 0.04}):Play()
    end)

    sendButton.MouseLeave:Connect(function()
        TweenService:Create(sendFill, TweenInfo.new(0.12), {BackgroundTransparency = 0.92}):Play()
        TweenService:Create(sendStroke, TweenInfo.new(0.12), {Transparency = 0.12}):Play()
    end)

    local function doSend()
        local msg = chatBox.Text
        if msg == nil or msg:gsub("%s+", "") == "" then
            statusLabel.Text = "Boş mesaj gönderilemez"
            return
        end

        statusLabel.Text = "Gönderiliyor..."

        local success, reason = sendChatMessage(msg)
        if success then
            chatBox.Text = ""
            statusLabel.Text = "Mesaj gönderildi"
            refreshChat()
        else
               statusLabel.Text = "Hata: " .. tostring(reason)
        end
    end

    sendButton.MouseButton1Click:Connect(doSend)

    chatBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            doSend()
        end
    end)

    chatToggle.button.MouseButton1Click:Connect(function()
        setChatWindowVisible(not chatOpen)
    end)

    closeChat.MouseButton1Click:Connect(function()
        setChatWindowVisible(false)
    end)

end)


local viewportClone
local viewportSyncConnection
local appearanceConns = {}
local sourceParts = {}
local cloneParts = {}
local rootOffsetCFrame = CFrame.new()
local rebuildQueued = false
local poseAccumulator = 0
local poseStep = 1/12

local function disconnectAppearance()
    for _, c in ipairs(appearanceConns) do
        c:Disconnect()
    end
    table.clear(appearanceConns)
end

local function disconnectViewportSync()
    if viewportSyncConnection then
        viewportSyncConnection:Disconnect()
        viewportSyncConnection = nil
    end
end

local function clearViewport()
    disconnectViewportSync()
    viewportClone = nil
    sourceParts = {}
    cloneParts = {}
    worldModel:ClearAllChildren()
end

local function getRelativePath(instance, root)
    local parts = {}
    local current = instance
    while current and current ~= root do
        table.insert(parts, 1, current.Name)
        current = current.Parent
    end
    return table.concat(parts, "/")
end

local function prepareClone(clone)
    for _, obj in ipairs(clone:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") or obj:IsA("Animator") then
            obj:Destroy()
        elseif obj:IsA("BasePart") then
            obj.Anchored = true
            obj.CanCollide = false
            obj.Massless = true
        elseif obj:IsA("Humanoid") then
            obj.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            obj.AutoRotate = false
        end
    end
end

local function buildPartMaps(sourceChar, cloneChar)
    sourceParts = {}
    cloneParts = {}

    for _, obj in ipairs(sourceChar:GetDescendants()) do
        if obj:IsA("BasePart") then
            sourceParts[getRelativePath(obj, sourceChar)] = obj
        end
    end

    for _, obj in ipairs(cloneChar:GetDescendants()) do
        if obj:IsA("BasePart") then
            cloneParts[getRelativePath(obj, cloneChar)] = obj
        end
    end
end

local function computeViewportPose(sourceChar)
    local sourceRoot = sourceChar:FindFirstChild("HumanoidRootPart")
    if not sourceRoot then
        return false
    end

    local bboxCF, bboxSize = sourceChar:GetBoundingBox()
    local relCenter = sourceRoot.CFrame:PointToObjectSpace(bboxCF.Position)
    local bottomY = relCenter.Y - (bboxSize.Y / 2)

    local rootY = -bottomY + 2.45
    rootOffsetCFrame = CFrame.new(0, rootY, 0)

    local camDistance = math.clamp(
        math.max(bboxSize.Y * 1.95, bboxSize.X * 3.15, 10.8),
        10.8,
        15.0
    )

    local focusY = rootY + (bboxSize.Y * 0.05)

    camera.CFrame = CFrame.new(
        Vector3.new(0, focusY, -camDistance),
        Vector3.new(0, focusY, 0)
    )

    return true
end

local function syncViewportFromCharacter(sourceChar)
    local sourceRoot = sourceChar and sourceChar:FindFirstChild("HumanoidRootPart")
    if not sourceRoot or not viewportClone then
        return
    end

    for path, srcPart in pairs(sourceParts) do
        local clonePart = cloneParts[path]
        if srcPart and clonePart then
            local relativeCF = sourceRoot.CFrame:ToObjectSpace(srcPart.CFrame)
            clonePart.CFrame = rootOffsetCFrame * relativeCF
        end
    end
end

local buildViewportCharacter

local function queueRebuild()
    if rebuildQueued then return end
    rebuildQueued = true
    task.delay(0.25, function()
        rebuildQueued = false
        buildViewportCharacter()
    end)
end

local function watchCharacterAppearance(character)
    disconnectAppearance()

    table.insert(appearanceConns, character.ChildAdded:Connect(function(obj)
        if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("CharacterMesh")
        or obj:IsA("BodyColors") or obj:IsA("HumanoidDescription") or obj:IsA("MeshPart") then
            queueRebuild()
        end
    end))

    table.insert(appearanceConns, character.ChildRemoved:Connect(function(obj)
        if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("CharacterMesh")
        or obj:IsA("BodyColors") or obj:IsA("HumanoidDescription") or obj:IsA("MeshPart") then
            queueRebuild()
        end
    end))
end

function buildViewportCharacter()
    clearViewport()

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local sourceRoot = character:FindFirstChild("HumanoidRootPart")
    if not sourceRoot then
        return
    end

    watchCharacterAppearance(character)

    local oldArchivable = character.Archivable
    character.Archivable = true
    local ok, clone = pcall(function()
        return character:Clone()
    end)
    character.Archivable = oldArchivable

    if not ok or not clone then
        return
    end

    viewportClone = clone
    viewportClone.Parent = worldModel

    prepareClone(viewportClone)
    buildPartMaps(character, viewportClone)

    if not computeViewportPose(character) then
        return
    end

    syncViewportFromCharacter(character)

    if refreshActivePreviewBindings then
        task.defer(refreshActivePreviewBindings)
    end

    poseAccumulator = 0
    viewportSyncConnection = RunService.RenderStepped:Connect(function(dt)
        if not menuVisible then return end

        local liveChar = LocalPlayer.Character
        if not liveChar or not viewportClone or not viewportClone.Parent then
            return
        end

        local liveRoot = liveChar:FindFirstChild("HumanoidRootPart")
        if not liveRoot then
            return
        end

        poseAccumulator += dt
        if poseAccumulator >= poseStep then
            poseAccumulator = 0
            computeViewportPose(liveChar)
        end

        syncViewportFromCharacter(liveChar)
    end)
end

buildViewportCharacter()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    displayName.Text = LocalPlayer.DisplayName
    userName.Text = "@" .. LocalPlayer.Name
    buildViewportCharacter()
end)

local leftHeader = Instance.new("Frame")
leftHeader.Parent = main
leftHeader.BackgroundTransparency = 1
leftHeader.Position = UDim2.new(0, 14, 0, 58)
leftHeader.Size = UDim2.new(0, 160, 0, 58)
leftHeader.ZIndex = 12

local leftHeaderTitle = Instance.new("TextLabel")
leftHeaderTitle.Parent = leftHeader
leftHeaderTitle.BackgroundTransparency = 1
leftHeaderTitle.Size = UDim2.new(1,0,0,10)
leftHeaderTitle.Text = "TEAM"
leftHeaderTitle.TextColor3 = Color3.fromRGB(255,255,255)
leftHeaderTitle.TextStrokeTransparency = 1
leftHeaderTitle.TextSize = 59
leftHeaderTitle.Font = Enum.Font.GothamBold
leftHeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
leftHeaderTitle.ZIndex = 13

local leftHeaderSub = Instance.new("TextLabel")
leftHeaderSub.Parent = leftHeader
leftHeaderSub.BackgroundTransparency = 1
leftHeaderSub.Position = UDim2.new(0,0,0,28)
leftHeaderSub.Size = UDim2.new(1,0,0,18)
leftHeaderSub.Text = "MYLF HUB TEAM PANEL"
leftHeaderSub.TextColor3 = Color3.fromRGB(180,180,180)
leftHeaderSub.TextStrokeTransparency = 1
leftHeaderSub.TextSize = 10
leftHeaderSub.Font = Enum.Font.GothamSemibold
leftHeaderSub.TextXAlignment = Enum.TextXAlignment.Left
leftHeaderSub.ZIndex = 13

local tabsHolder = Instance.new("Frame")
tabsHolder.Parent = main
tabsHolder.Name = "TabsHolder"
tabsHolder.BackgroundTransparency = 1
tabsHolder.BorderSizePixel = 0
tabsHolder.Position = UDim2.new(0, 14, 0, 126)
tabsHolder.Size = UDim2.new(0, 110, 0, 260)
tabsHolder.ZIndex = 12

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.Parent = tabsHolder
tabsLayout.FillDirection = Enum.FillDirection.Vertical
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
tabsLayout.Padding = UDim.new(0, 6)
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder

local sectionsHolder = Instance.new("Frame")
sectionsHolder.Parent = main
sectionsHolder.BackgroundTransparency = 1
sectionsHolder.Position = UDim2.new(0, 168, 0, 72)
sectionsHolder.Size = UDim2.new(1, -182, 1, -86)
sectionsHolder.ZIndex = 11

local sections = {}
local tabButtons = {}
local tabHoverFills = {}
local tabStrokes = {}
local tabPulseFrames = {}
local tabGlowBars = {}
local activeTabIndex = 1

local tabMeta = {
    [1] = {name = "TEAM", sub = "MYLF HUB TEAM"},
    [2] = {name = "AIM", sub = "MYLF HUB Aimbot"},
    [3] = {name = "ESP", sub = "MYLF HUB ESP"},
    [4] = {name = "PLAY", sub = "MYLF HUB PLAYER"},
    [5] = {name = "MISC", sub = "MYLF HUB MISC"},
    [6] = {name = "CFG", sub = "MYLF HUB CONFIG"},
}

local function setActiveTab(index)
    activeTabIndex = index

    for i, section in ipairs(sections) do
        section.Visible = (i == index)
    end

    local meta = tabMeta[index]
    leftHeaderTitle.Text = meta.name
    leftHeaderSub.Text = meta.sub

    for i, strokeObj in ipairs(tabStrokes) do
        if strokeObj then
            TweenService:Create(strokeObj, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Transparency = (i == index) and 0.18 or 0.64,
                Thickness = (i == index) and 1.25 or 1
            }):Play()
        end
    end

    for i, hoverFill in ipairs(tabHoverFills) do
        if hoverFill then
            TweenService:Create(hoverFill, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = (i == index) and 0.84 or 1
            }):Play()
        end
    end

    for i, pulseFrame in ipairs(tabPulseFrames) do
        if pulseFrame then
            if i == index then
                registerPulseObject(pulseFrame)
            else
                unregisterPulseObject(pulseFrame)
            end

            TweenService:Create(pulseFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = (i == index) and 0.18 or 1
            }):Play()
        end
    end

    for i, glowBar in ipairs(tabGlowBars) do
        if glowBar then
            TweenService:Create(glowBar, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = (i == index) and 0.38 or 1
            }):Play()
        end
    end
end

for i = 1, 6 do
    local tabButton = Instance.new("TextButton")
    tabButton.Parent = tabsHolder
    tabButton.Size = UDim2.new(1, 0, 0, 36)
    tabButton.BackgroundTransparency = 1
    tabButton.BorderSizePixel = 0
    tabButton.AutoButtonColor = false
    tabButton.Text = ""
    tabButton.ZIndex = 14
    tabButton.LayoutOrder = i
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 8)

    local hoverFill = Instance.new("Frame")
    hoverFill.Parent = tabButton
    hoverFill.BackgroundColor3 = currentThemeColor
    hoverFill.BackgroundTransparency = 1
    hoverFill.BorderSizePixel = 0
    hoverFill.Size = UDim2.new(1, 0, 1, 0)
    hoverFill.ZIndex = 13
    Instance.new("UICorner", hoverFill).CornerRadius = UDim.new(0, 8)

    local hoverGradient = Instance.new("UIGradient")
    hoverGradient.Parent = hoverFill
    hoverGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.55),
        NumberSequenceKeypoint.new(1, 0.95)
    })
    hoverGradient.Rotation = 0

    local pulseFrame = Instance.new("Frame")
    pulseFrame.Parent = tabButton
    pulseFrame.BackgroundColor3 = currentThemeColor
    pulseFrame.BackgroundTransparency = 1
    pulseFrame.BorderSizePixel = 0
    pulseFrame.Size = UDim2.new(1, 0, 1, 0)
    pulseFrame.Position = UDim2.new(0, 0, 0, 0)
    pulseFrame.ZIndex = 12
    Instance.new("UICorner", pulseFrame).CornerRadius = UDim.new(0, 8)
    addThemeFill(pulseFrame)

    local pulseGradient = Instance.new("UIGradient")
    pulseGradient.Parent = pulseFrame
    pulseGradient.Rotation = 0
    pulseGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.78),
        NumberSequenceKeypoint.new(0.35, 0.9),
        NumberSequenceKeypoint.new(1, 1)
    })

    local glowBar = Instance.new("Frame")
    glowBar.Parent = tabButton
    glowBar.BackgroundColor3 = currentThemeColor
    glowBar.BackgroundTransparency = 1
    glowBar.BorderSizePixel = 0
    glowBar.Size = UDim2.new(0, 3, 1, -8)
    glowBar.Position = UDim2.new(0, 4, 0, 4)
    glowBar.ZIndex = 15
    Instance.new("UICorner", glowBar).CornerRadius = UDim.new(1, 0)
    addThemeFill(glowBar)

    local tabText = Instance.new("TextLabel")
    tabText.Parent = tabButton
    tabText.BackgroundTransparency = 1
    tabText.Size = UDim2.new(1, -14, 1, 0)
    tabText.Position = UDim2.new(0, 12, 0, 0)
    tabText.Text = tabMeta[i].name
    tabText.TextColor3 = Color3.fromRGB(255,255,255)
    tabText.TextStrokeTransparency = 1
    tabText.TextSize = 11
    tabText.Font = Enum.Font.GothamBold
    tabText.TextXAlignment = Enum.TextXAlignment.Left
    tabText.ZIndex = 16

    local tabStroke = Instance.new("UIStroke")
    tabStroke.Parent = tabButton
    tabStroke.Color = currentThemeColor
    tabStroke.Thickness = 1
    tabStroke.Transparency = 0.64

    addThemeStroke(tabStroke)

    tabButton.MouseEnter:Connect(function()
        TweenService:Create(tabStroke, TweenInfo.new(0.14), {
            Transparency = (activeTabIndex == i) and 0.18 or 0.42
        }):Play()

        if activeTabIndex ~= i then
            TweenService:Create(hoverFill, TweenInfo.new(0.14), {
                BackgroundTransparency = 0.9
            }):Play()
        else
            TweenService:Create(pulseFrame, TweenInfo.new(0.14), {
                BackgroundTransparency = 0.12
            }):Play()

            TweenService:Create(glowBar, TweenInfo.new(0.14), {
                BackgroundTransparency = 0.24
            }):Play()
        end
   end)


    tabButton.MouseLeave:Connect(function()
        TweenService:Create(tabStroke, TweenInfo.new(0.14), {
            Transparency = (activeTabIndex == i) and 0.18 or 0.64
        }):Play()

        if activeTabIndex ~= i then
            TweenService:Create(hoverFill, TweenInfo.new(0.14), {
                BackgroundTransparency = 1
            }):Play()
        else
            TweenService:Create(pulseFrame, TweenInfo.new(0.14), {
                BackgroundTransparency = 0.18
            }):Play()

            TweenService:Create(glowBar, TweenInfo.new(0.14), {
                BackgroundTransparency = 0.38
            }):Play()
        end
    end)

    tabButton.MouseButton1Click:Connect(function()
        setActiveTab(i)
    end)

    local section = Instance.new("ScrollingFrame")
    section.Parent = sectionsHolder
    section.BackgroundTransparency = 1
    section.BorderSizePixel = 0
    section.Size = UDim2.new(1,0,1,0)
    section.Position = UDim2.new(0,0,0,0)
    section.Visible = (i == 1)
    section.ClipsDescendants = false
    section.ZIndex = 11
    section.ScrollBarThickness = 0
    section.CanvasSize = UDim2.new(0,0,0,0)
    section.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local sectionList = Instance.new("UIListLayout")
    sectionList.Parent = section
    sectionList.Padding = UDim.new(0, 8)
    sectionList.SortOrder = Enum.SortOrder.LayoutOrder

    local sectionPadding = Instance.new("UIPadding")
    sectionPadding.Parent = section
    sectionPadding.PaddingTop = UDim.new(0, 6)
    sectionPadding.PaddingBottom = UDim.new(0, 12)

    table.insert(tabButtons, tabButton)
    table.insert(tabHoverFills, hoverFill)
    table.insert(tabStrokes, tabStroke)
    table.insert(tabPulseFrames, pulseFrame)
    table.insert(tabGlowBars, glowBar)
    table.insert(sections, section)
end

addThemeStroke(themeButtonStroke)
addThemeStroke(sideStroke)

local TARGET_PART_ALIASES = {
    ["HEAD"] = {"Head"},
    ["TORSO"] = {"Torso", "UpperTorso", "LowerTorso"},
    ["LEFT ARM"] = {"Left Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand"},
    ["RIGHT ARM"] = {"Right Arm", "RightUpperArm", "RightLowerArm", "RightHand"},
    ["LEFT LEG"] = {"Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
    ["RIGHT LEG"] = {"Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"},
    ["LEFT HAND"] = {"LeftHand", "Left Hand"},
    ["RIGHT HAND"] = {"RightHand", "Right Hand"},
    ["LEFT FOOT"] = {"LeftFoot", "Left Foot"},
    ["RIGHT FOOT"] = {"RightFoot", "Right Foot"},
    ["HUMANOIDROOTPART"] = {"HumanoidRootPart"},
}

local Aim = {
    Enabled = false,
    Mode = "CAMERA",
    FakeCamera = false,
    VisibleOnly = true,
    FOV = 150,
    Smooth = 5,
    TargetPart = "Head"
}
local uiState = {
    teamDropdown = {},
    teamSectionEnabled = false,
    targetZones = {},
    targetToggle = false,
    targetHotkey = "NONE",
    aimVisibleOnly = true,
    aimFov = 45,
    aimHitpart = "Head",
    aimSmooth = 0,
    flyToggle = false,
    flySpeed = 60,
    speedToggle = false,
    walkSpeed = 16,
    infiniteJump = false,
    jumpPower = 100,
    esp = {
        ["ESP BOX"] = {enabled = false, hotkey = "NONE"},
        ["ESP NAME"] = {enabled = false, hotkey = "NONE"},
        ["ESP HEALTH"] = {enabled = false, hotkey = "NONE"},
        ["ESP DISTANCE"] = {enabled = false, hotkey = "NONE"},
        ["ESP TRACER"] = {enabled = false, hotkey = "NONE"},
        ["ESP GLOW"] = {enabled = false, hotkey = "NONE"},
    },
    distance = 150,
    currentConfigName = "default"
}
	


local Camera = workspace.CurrentCamera


local features = rawget(getgenv(), "MYLF_FEATURES") or {}
getgenv().MYLF_FEATURES = features
getgenv().AimbotEnabled = false
getgenv().AimbotHitpart = uiState.aimHitpart or "Head"
getgenv().AimbotSmooth = uiState.aimSmooth or 0

features._flyState = features._flyState or {
    enabled = false,
    speed = uiState.flySpeed or 60,
    loop = nil,
    respawn = nil,
}

features._speedState = features._speedState or {
    enabled = false,
    value = uiState.walkSpeed or 16,
    original = nil,
    loop = nil,
    respawn = nil,
}

features._infJumpState = features._infJumpState or {
    enabled = false,
    jumpPower = uiState.jumpPower or 100,
    defaultJumpPower = 50,
    conn = nil,
    respawn = nil,
}

local function getCharacterHumanoid()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getCharacterRoot()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function isVisible(part)
    if not part then return false end
    local cam = workspace.CurrentCamera
    if not cam then return false end

    local origin = cam.CFrame.Position
    local direction = part.Position - origin
    local distance = direction.Magnitude
    if distance <= 0 then return false end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character}

    local hit = workspace:Raycast(origin, direction.Unit * distance, params)
    return (not hit) or (hit.Instance and hit.Instance:IsDescendantOf(part.Parent))
end

function features.ToggleAimbot(on)
    local state = on and true or false
    getgenv().AimbotEnabled = state
    Aim.Enabled = state
    uiState.targetToggle = state
end

function features.ToggleFly(on)
    local state = on and true or false
    local fly = features._flyState
    fly.enabled = state
    uiState.flyToggle = state

    if fly.loop then
        fly.loop:Disconnect()
        fly.loop = nil
    end

    local function clearVelocity()
        local hrp = getCharacterRoot()
        if hrp then
            local bv = hrp:FindFirstChild("MYLF_FLY_VELOCITY")
            if bv then bv:Destroy() end
        end
    end

    if not state then
        clearVelocity()
        return
    end

    fly.loop = RunService.RenderStepped:Connect(function()
        local hrp = getCharacterRoot()
        if not hrp then return end

        local bv = hrp:FindFirstChild("MYLF_FLY_VELOCITY")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "MYLF_FLY_VELOCITY"
            bv.Parent = hrp
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Velocity = Vector3.zero
        end

        local cam = workspace.CurrentCamera
        if not cam then return end

        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end

        bv.Velocity = dir * (fly.speed or 60)
    end)

    if not fly.respawn then
        fly.respawn = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if fly.enabled then
                features.ToggleFly(true)
            end
        end)
    end
end

function features.SetFlySpeed(val)
    local speed = tonumber(val) or 60
    features._flyState.speed = speed
    uiState.flySpeed = speed
end

function features.ToggleSpeed(on)
    local speed = features._speedState
    local state = on and true or false
    speed.enabled = state
    uiState.speedToggle = state

    local function apply()
        local h = getCharacterHumanoid()
        if not h then return end
        h.WalkSpeed = speed.enabled and (speed.value or 16) or (speed.original or 16)
    end

    if state then
        local h = getCharacterHumanoid()
        if h and speed.original == nil then
            speed.original = h.WalkSpeed
        end
        if speed.loop then speed.loop:Disconnect() end
        speed.loop = RunService.Heartbeat:Connect(apply)

        if not speed.respawn then
            speed.respawn = LocalPlayer.CharacterAdded:Connect(function()
                task.wait(0.5)
                local nh = getCharacterHumanoid()
                if nh and speed.original == nil then
                    speed.original = nh.WalkSpeed
                end
                if speed.enabled then apply() end
            end)
        end
        apply()
    else
        if speed.loop then
            speed.loop:Disconnect()
            speed.loop = nil
        end
        apply()
    end
end

function features.SetWalkSpeed(val)
    local speed = tonumber(val) or 16
    features._speedState.value = speed
    uiState.walkSpeed = speed
end

function features.ToggleInfiniteJump(on, jumpPower)
    local ij = features._infJumpState
    local state = on and true or false
    ij.enabled = state
    ij.jumpPower = tonumber(jumpPower) or ij.jumpPower or 100
    uiState.infiniteJump = state
    uiState.jumpPower = ij.jumpPower

    if ij.conn then
        ij.conn:Disconnect()
        ij.conn = nil
    end

    if not state then
        local h = getCharacterHumanoid()
        if h then h.JumpPower = ij.defaultJumpPower or 50 end
        return
    end

    local h = getCharacterHumanoid()
    if h then h.JumpPower = ij.jumpPower end

    ij.conn = UIS.JumpRequest:Connect(function()
        local hum = getCharacterHumanoid()
        if hum then
            hum.JumpPower = ij.jumpPower
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    if not ij.respawn then
        ij.respawn = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if ij.enabled then
                features.ToggleInfiniteJump(true, ij.jumpPower)
            end
        end)
    end
end

local lastAimCFrame = workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new()
RunService.Heartbeat:Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end

    if getgenv().AimbotEnabled then
        Aim.TargetPart = getgenv().AimbotHitpart or Aim.TargetPart or "Head"
        Aim.Smooth = tonumber(getgenv().AimbotSmooth) or 0

        local target = getClosestTarget()
        if target and target.Parent then
            local part = target.Parent:FindFirstChild(getgenv().AimbotHitpart or "Head") or target
            if part and isVisible(part) then
                local newCFrame = CFrame.new(cam.CFrame.Position, part.Position)
                local smooth = tonumber(getgenv().AimbotSmooth) or 0
                if smooth > 0 then
                    cam.CFrame = cam.CFrame:Lerp(newCFrame, smooth)
                else
                    cam.CFrame = newCFrame
                end
                lastAimCFrame = cam.CFrame
            else
                cam.CFrame = lastAimCFrame
            end
        end
    end
end)
local Mouse

task.spawn(function()
    repeat task.wait() until Players.LocalPlayer
    Mouse = Players.LocalPlayer:GetMouse()
end)
local MAX_AIM_DISTANCE = 650
local function getClosestTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end

    local origin = cam.CFrame.Position
    local look = cam.CFrame.LookVector

    local bestTarget = nil
    local bestScore = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local part = plr.Character:FindFirstChild(Aim.TargetPart)

            if hum and hum.Health > 0 and part then
                local offset = part.Position - origin
                local distance = offset.Magnitude

                if distance <= MAX_AIM_DISTANCE then
                    local dir = offset.Unit
                    local dot = math.clamp(look:Dot(dir), -1, 1)
                    local angle = math.deg(math.acos(dot))

                    if angle <= Aim.FOV then
                        local visiblePass = true

                        if Aim.VisibleOnly then
                            local params = RaycastParams.new()
                            params.FilterType = Enum.RaycastFilterType.Blacklist
                            params.FilterDescendantsInstances = {LocalPlayer.Character}

                            local hit = workspace:Raycast(origin, dir * distance, params)
                            visiblePass = (not hit) or (hit.Instance and hit.Instance:IsDescendantOf(plr.Character))
                        end

                        if visiblePass and angle < bestScore then
                            bestScore = angle
                            bestTarget = part
                        end
                    end
                end
            end
        end
    end

    return bestTarget
end

  

local dropdownRegistry = {}
local toggleRegistry = {}
local sliderRegistry = {}
local configDropdownApi = nil
local configNameInput = nil
local configStatusLabel = nil
local previewBindings = {}
local previewStates = {}
local previewObjects = {}
local previewOverlay = nil
local refreshActivePreviewBindings

local function getPreviewCharacter()
    return viewportClone
end

local function getPreviewPart(names)
    local character = getPreviewCharacter()
    if not character then
        return nil
    end

    if type(names) == "string" then
        names = {names}
    end

    for _, name in ipairs(names or {}) do
        for _, obj in ipairs(character:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == name then
                return obj
            end
        end
    end

    return nil
end

local function clearPreviewObjects(key)
    local bucket = previewObjects[key]
    if bucket then
        for _, obj in ipairs(bucket) do
            pcall(function()
                if obj then
                    obj:Destroy()
                end
            end)
        end
    end
    previewObjects[key] = {}
end

local function clearAllPreviewObjects()
    for key in pairs(previewObjects) do
        clearPreviewObjects(key)
    end
end

local function makePreviewContext(key)
    local ctx = {}

    function ctx:GetCharacter()
        return getPreviewCharacter()
    end

    function ctx:GetPart(names)
        return getPreviewPart(names)
    end

    function ctx:GetOverlay()
        return previewOverlay
    end

    function ctx:GetThemeColor()
        return currentThemeColor
    end

    function ctx:IsEnabled()
        return previewStates[key] == true
    end

    function ctx:AddObject(obj)
        if not obj then
            return obj
        end
        previewObjects[key] = previewObjects[key] or {}
        table.insert(previewObjects[key], obj)
        return obj
    end

    function ctx:Clear()
        clearPreviewObjects(key)
    end

    function ctx:MakeText(textValue, pos, size)
        if not previewOverlay then
            return nil
        end
        local lbl = Instance.new("TextLabel")
        lbl.Parent = previewOverlay
        lbl.BackgroundTransparency = 1
        lbl.Text = textValue or ""
        lbl.TextColor3 = currentThemeColor
        lbl.TextStrokeTransparency = 0.35
        lbl.TextSize = 12
        lbl.Font = Enum.Font.GothamBold
        lbl.ZIndex = 10
        lbl.AnchorPoint = Vector2.new(0.5, 0.5)
        lbl.Position = pos or UDim2.new(0.5,0,0.1,0)
        lbl.Size = size or UDim2.new(0.7,0,0,20)
        return self:AddObject(lbl)
    end

    function ctx:MakeBox(pos, size)
        if not previewOverlay then
            return nil
        end
        local frame = Instance.new("Frame")
        frame.Parent = previewOverlay
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.Position = pos or UDim2.new(0.5,0,0.5,0)
        frame.Size = size or UDim2.new(0,70,0,120)
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.ZIndex = 10

        local strokeObj = Instance.new("UIStroke")
        strokeObj.Parent = frame
        strokeObj.Color = currentThemeColor
        strokeObj.Thickness = 1.5
        strokeObj.Transparency = 0.08
        return self:AddObject(frame)
    end

    function ctx:MakeLine(fromPos, toPos, thickness)
        if not previewOverlay then
            return nil
        end
        local a = Vector2.new(fromPos.X.Offset, fromPos.Y.Offset)
        local b = Vector2.new(toPos.X.Offset, toPos.Y.Offset)
        local delta = b - a
        local dist = delta.Magnitude

        local line = Instance.new("Frame")
        line.Parent = previewOverlay
        line.AnchorPoint = Vector2.new(0, 0.5)
        line.Position = UDim2.new(0, a.X, 0, a.Y)
        line.Size = UDim2.new(0, dist, 0, thickness or 2)
        line.BackgroundColor3 = currentThemeColor
        line.BackgroundTransparency = 0.1
        line.BorderSizePixel = 0
        line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
        line.ZIndex = 10
        return self:AddObject(line)
    end

    return ctx
end

refreshActivePreviewBindings = function()
    clearAllPreviewObjects()
    for key, enabled in pairs(previewStates) do
        if enabled then
            local callback = previewBindings[key]
            if callback then
                local ok, err = pcall(function()
                    callback(makePreviewContext(key))
                end)
                if not ok then
                    warn("MYLF HUB preview bind error for " .. tostring(key) .. ": " .. tostring(err))
                end
            end
        end
    end
end

_G.MYLFHUB_LOCALPLAYER_PREVIEW = {
    Bind = function(key, callback)
        previewBindings[key] = callback
        if previewStates[key] then
            refreshActivePreviewBindings()
        end
    end,
    Unbind = function(key)
        previewBindings[key] = nil
        clearPreviewObjects(key)
    end,
    Set = function(key, state)
        previewStates[key] = state and true or false
        refreshActivePreviewBindings()
    end,
    IsEnabled = function(key)
        return previewStates[key] == true
    end,
    Refresh = function()
        refreshActivePreviewBindings()
    end,
    Clear = function(key)
        if key then
            clearPreviewObjects(key)
        else
            clearAllPreviewObjects()
        end
    end,
    GetCharacter = getPreviewCharacter,
    GetPart = getPreviewPart,
    GetOverlay = function()
        return previewOverlay
    end,
    GetThemeColor = function()
        return currentThemeColor
    end,
}

-- ESP PREVIEW (menüdeki local player için)
_G.MYLFHUB_LOCALPLAYER_PREVIEW.Bind("ESP BOX", function(ctx)
    ctx:Clear()
    if not ctx:IsEnabled() then return end
    local box = ctx:MakeBox(UDim2.new(0.5, 0, 0.48, 0), UDim2.new(0, 92, 0, 182))
    if box then
        local s = box:FindFirstChildWhichIsA("UIStroke")
        if s then s.Thickness = 1.8 s.Transparency = 0.05 end
    end
end)

_G.MYLFHUB_LOCALPLAYER_PREVIEW.Bind("ESP NAME", function(ctx)
    ctx:Clear()
    if not ctx:IsEnabled() then return end
    ctx:MakeText(LocalPlayer.DisplayName, UDim2.new(0.5, 0, 0.29, 0), UDim2.new(0, 140, 0, 22))
end)

_G.MYLFHUB_LOCALPLAYER_PREVIEW.Bind("ESP HEALTH", function(ctx)
    ctx:Clear()
    if not ctx:IsEnabled() then return end
    local barBg = Instance.new("Frame")
    barBg.Parent = ctx:GetOverlay()
    barBg.Size = UDim2.new(0, 88, 0, 9)
    barBg.Position = UDim2.new(0.5, -44, 0.26, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    barBg.BackgroundTransparency = 0.65
    barBg.BorderSizePixel = 0
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1,0)
    ctx:AddObject(barBg)

    local barFill = Instance.new("Frame")
    barFill.Parent = barBg
    barFill.Size = UDim2.new(0.95, 0, 1, 0)
    barFill.BackgroundColor3 = ctx:GetThemeColor()
    barFill.BackgroundTransparency = 0.15
    barFill.BorderSizePixel = 0
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1,0)
    ctx:AddObject(barFill)

    ctx:MakeText("100%", UDim2.new(0.5, 0, 0.235, 0), UDim2.new(0, 50, 0, 16))
end)

_G.MYLFHUB_LOCALPLAYER_PREVIEW.Bind("ESP DISTANCE", function(ctx)
    ctx:Clear()
    if not ctx:IsEnabled() then return end
    ctx:MakeText("DIST: 42m", UDim2.new(0.5, 0, 0.71, 0), UDim2.new(0, 100, 0, 20))
end)

_G.MYLFHUB_LOCALPLAYER_PREVIEW.Bind("ESP TRACER", function(ctx)
    ctx:Clear()
    if not ctx:IsEnabled() then return end
    ctx:MakeLine(UDim2.new(0.5, 0, 0.96, 0), UDim2.new(0.5, 0, 0.55, 0), 2.5)
end)

_G.MYLFHUB_LOCALPLAYER_PREVIEW.Bind("ESP GLOW", function(ctx)
    ctx:Clear()
    if not ctx:IsEnabled() then return end
    local glowBox = ctx:MakeBox(UDim2.new(0.5, 0, 0.48, 0), UDim2.new(0, 118, 0, 208))
    if glowBox then
        local s = glowBox:FindFirstChildWhichIsA("UIStroke")
        if s then s.Thickness = 4.5 s.Transparency = 0.72 end
    end
end)

local function createPreviewMini(parent, xPos, previewKey)
    local data = { state = false, key = previewKey }

    local button = Instance.new("TextButton")
    button.Parent = parent
    button.AnchorPoint = Vector2.new(0,0.5)
    button.Position = UDim2.new(0, xPos or 0, 0.5, 0)
    button.Size = UDim2.new(0, 48, 0, 24)
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = 15
    Instance.new("UICorner", button).CornerRadius = UDim.new(0,6)

    local fill = Instance.new("Frame")
    fill.Parent = button
    fill.Size = UDim2.new(1,0,1,0)
    fill.BackgroundColor3 = currentThemeColor
    fill.BackgroundTransparency = 0.96
    fill.BorderSizePixel = 0
    fill.ZIndex = 14
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,6)
    addThemeFill(fill)

    local fillGradient = Instance.new("UIGradient")
    fillGradient.Parent = fill
    fillGradient.Rotation = 0
    fillGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0.7)})

    local strokeObj = Instance.new("UIStroke")
    strokeObj.Parent = button
    strokeObj.Color = currentThemeColor
    strokeObj.Thickness = 1
    strokeObj.Transparency = 0.18
    addThemeStroke(strokeObj)

    local txt = Instance.new("TextLabel")
    txt.Parent = button
    txt.BackgroundTransparency = 1
    txt.Size = UDim2.new(1,0,1,0)
    txt.Text = "PREV"
    txt.TextColor3 = Color3.fromRGB(255,255,255)
    txt.TextStrokeTransparency = 1
    txt.TextSize = 9
    txt.Font = Enum.Font.GothamBold
    txt.ZIndex = 15

    function data:setState(state, silent)
        self.state = state and true or false
        if self.state then registerPulseObject(fill) else unregisterPulseObject(fill) end

        TweenService:Create(fill, TweenInfo.new(0.14), {BackgroundTransparency = self.state and 0.16 or 0.96}):Play()
        TweenService:Create(strokeObj, TweenInfo.new(0.14), {Transparency = self.state and 0.04 or 0.18}):Play()

        if not silent and self.key then
            previewStates[self.key] = self.state
            refreshActivePreviewBindings()
        end
    end

    button.MouseEnter:Connect(function()
        TweenService:Create(strokeObj, TweenInfo.new(0.12), {Transparency = data.state and 0.04 or 0.08}):Play()
        if not data.state then TweenService:Create(fill, TweenInfo.new(0.12), {BackgroundTransparency = 0.9}):Play() end
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(fill, TweenInfo.new(0.12), {BackgroundTransparency = data.state and 0.16 or 0.96}):Play()
        TweenService:Create(strokeObj, TweenInfo.new(0.12), {Transparency = data.state and 0.04 or 0.18}):Play()
    end)

    button.MouseButton1Click:Connect(function()
        data:setState(not data.state)
    end)

    data.button = button
    data.fill = fill
    data.stroke = strokeObj
    return data
end

local function createLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(215,215,215)
    label.TextStrokeTransparency = 1
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 12
    return label
end

local function createCard(parent, height)
    local card = Instance.new("Frame")
    card.Parent = parent
    card.Size = UDim2.new(1, -8, 0, height)
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.ZIndex = 12
    card.ClipsDescendants = true

    local fill = Instance.new("Frame")
    fill.Parent = card
    fill.Size = UDim2.new(1,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(255,255,255)
    fill.BackgroundTransparency = 0.965
    fill.BorderSizePixel = 0
    fill.ZIndex = 12
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,8)

    local noise = Instance.new("ImageLabel")
    noise.Parent = card
    noise.Size = UDim2.new(1,0,1,0)
    noise.BackgroundTransparency = 1
    noise.Image = "rbxassetid://2151741365"
    noise.ImageTransparency = 0.97
    noise.ZIndex = 13
    Instance.new("UICorner", noise).CornerRadius = UDim.new(0,8)

    local strokeObj = Instance.new("UIStroke")
    strokeObj.Parent = card
    strokeObj.Color = currentThemeColor
    strokeObj.Thickness = 1.1
    strokeObj.Transparency = 0.18
    addThemeStroke(strokeObj)

    local topLine = Instance.new("Frame")
    topLine.Parent = card
    topLine.Name = "TopThemeLine"
    topLine.Size = UDim2.new(1, 0, 0, 1)
    topLine.Position = UDim2.new(0, 0, 0, 0)
    topLine.BackgroundColor3 = currentThemeColor
    topLine.BackgroundTransparency = 0.10
    topLine.BorderSizePixel = 0
    topLine.ZIndex = 15

    local bottomLine = Instance.new("Frame")
    bottomLine.Parent = card
    bottomLine.Name = "BottomThemeLine"
    bottomLine.Size = UDim2.new(1, 0, 0, 1)
    bottomLine.Position = UDim2.new(0, 0, 1, -1)
    bottomLine.BackgroundColor3 = currentThemeColor
    bottomLine.BackgroundTransparency = 0.10
    bottomLine.BorderSizePixel = 0
    bottomLine.ZIndex = 15

    local leftLine = Instance.new("Frame")
    leftLine.Parent = card
    leftLine.Name = "LeftThemeLine"
    leftLine.Size = UDim2.new(0, 1, 1, -8)
    leftLine.Position = UDim2.new(0, 0, 0, 4)
    leftLine.BackgroundColor3 = currentThemeColor
    leftLine.BackgroundTransparency = 0.18
    leftLine.BorderSizePixel = 0
    leftLine.ZIndex = 15

    local rightLine = Instance.new("Frame")
    rightLine.Parent = card
    rightLine.Name = "RightThemeLine"
    rightLine.Size = UDim2.new(0, 1, 1, -8)
    rightLine.Position = UDim2.new(1, -1, 0, 4)
    rightLine.BackgroundColor3 = currentThemeColor
    rightLine.BackgroundTransparency = 0.18
    rightLine.BorderSizePixel = 0
    rightLine.ZIndex = 15

    addThemeFill(topLine)
    addThemeFill(bottomLine)
    addThemeFill(leftLine)
    addThemeFill(rightLine)

    return card, fill, strokeObj
end

local function bindHotkeyToToggle(keyName, toggleRow)
    if not keyName or keyName == "" or keyName == "NONE" then return end
    hotkeyBindings[string.lower(keyName)] = toggleRow
end

local function unbindHotkeyFromToggle(keyName, toggleRow)
    if not keyName or keyName == "" or keyName == "NONE" then return end
    local lowered = string.lower(keyName)
    if hotkeyBindings[lowered] == toggleRow then
        hotkeyBindings[lowered] = nil
    end
end

local function createHotkeyMini(parent, xPos, defaultValue, onChanged)
    local hotkeyData = { value = defaultValue or "NONE", listening = false, onChanged = onChanged }

    local hotkeyButton = Instance.new("TextButton")
    hotkeyButton.Parent = parent
    hotkeyButton.AnchorPoint = Vector2.new(1,0.5)
    hotkeyButton.Position = UDim2.new(1, xPos or 0, 0.5, 0)
    hotkeyButton.Size = UDim2.new(0, 78, 0, 24)
    hotkeyButton.BackgroundTransparency = 1
    hotkeyButton.BorderSizePixel = 0
    hotkeyButton.Text = ""
    hotkeyButton.AutoButtonColor = false
    hotkeyButton.ZIndex = 15
    Instance.new("UICorner", hotkeyButton).CornerRadius = UDim.new(0,6)

    local hotkeyFill = Instance.new("Frame")
    hotkeyFill.Parent = hotkeyButton
    hotkeyFill.Size = UDim2.new(1,0,1,0)
    hotkeyFill.BackgroundColor3 = Color3.fromRGB(255,255,255)
    hotkeyFill.BackgroundTransparency = 0.96
    hotkeyFill.BorderSizePixel = 0
    hotkeyFill.ZIndex = 14
    Instance.new("UICorner", hotkeyFill).CornerRadius = UDim.new(0,6)

    local hotkeyStroke = Instance.new("UIStroke")
    hotkeyStroke.Parent = hotkeyButton
    hotkeyStroke.Color = currentThemeColor
    hotkeyStroke.Thickness = 1
    hotkeyStroke.Transparency = 0.18
    addThemeStroke(hotkeyStroke)

    local hotkeyText = Instance.new("TextLabel")
    hotkeyText.Parent = hotkeyButton
    hotkeyText.BackgroundTransparency = 1
    hotkeyText.Size = UDim2.new(1,0,1,0)
    hotkeyText.Text = hotkeyData.value
    hotkeyText.TextColor3 = Color3.fromRGB(255,255,255)
    hotkeyText.TextStrokeTransparency = 1
    hotkeyText.TextSize = 10
    hotkeyText.Font = Enum.Font.GothamBold
    hotkeyText.ZIndex = 15

    hotkeyButton.MouseEnter:Connect(function()
        TweenService:Create(hotkeyStroke, TweenInfo.new(0.12), {Transparency = hotkeyData.listening and 0.05 or 0.08}):Play()
    end)

    hotkeyButton.MouseLeave:Connect(function()
        TweenService:Create(hotkeyStroke, TweenInfo.new(0.12), {Transparency = hotkeyData.listening and 0.05 or 0.18}):Play()
    end)

    hotkeyButton.MouseButton1Click:Connect(function()
        if listeningHotkeyRef and listeningHotkeyRef ~= hotkeyData then
            listeningHotkeyRef.listening = false
            if listeningHotkeyRef.label then listeningHotkeyRef.label.Text = listeningHotkeyRef.value end
            if listeningHotkeyRef.stroke then TweenService:Create(listeningHotkeyRef.stroke, TweenInfo.new(0.12), {Transparency = 0.18}):Play() end
        end
        listeningHotkeyRef = hotkeyData
        hotkeyData.listening = true
        hotkeyText.Text = "PRESS..."
        TweenService:Create(hotkeyStroke, TweenInfo.new(0.12), {Transparency = 0.05}):Play()
    end)

    hotkeyData.button = hotkeyButton
    hotkeyData.stroke = hotkeyStroke
    hotkeyData.label = hotkeyText

    function hotkeyData:setValue(newValue, silent)
        self.value = newValue or "NONE"
        self.label.Text = self.value
        if not silent and self.onChanged then self.onChanged(self.value) end
    end

    return hotkeyData
end

local function createToggleRow(parent, text, withHotkey, onChanged, previewKey)
    local row = {}
    local card = createCard(parent, 36)
    row.card = card

    row.button = Instance.new("TextButton")
    row.button.Parent = card
    row.button.Size = UDim2.new(1,0,1,0)
    row.button.BackgroundTransparency = 1
    row.button.BorderSizePixel = 0
    row.button.AutoButtonColor = false
    row.button.Text = ""
    row.button.ZIndex = 14

    local rightControlsWidth = (previewKey and (withHotkey and 180 or 104)) or (withHotkey and 128 or 52)

    row.label = Instance.new("TextLabel")
    row.label.Parent = card
    row.label.BackgroundTransparency = 1
    row.label.Position = UDim2.new(0, 12, 0, 0)
    row.label.Size = UDim2.new(1, -(rightControlsWidth + 22), 1, 0)
    row.label.Text = text .. " : OFF"
    row.label.TextColor3 = Color3.fromRGB(255,255,255)
    row.label.TextStrokeTransparency = 1
    row.label.TextSize = 11
    row.label.Font = Enum.Font.GothamSemibold
    row.label.TextXAlignment = Enum.TextXAlignment.Left
    row.label.ZIndex = 15

    row.rightControls = Instance.new("Frame")
    row.rightControls.Parent = card
    row.rightControls.Name = "RightControls"
    row.rightControls.AnchorPoint = Vector2.new(1, 0.5)
    row.rightControls.Position = UDim2.new(1, -10, 0.5, 0)
    row.rightControls.Size = UDim2.new(0, rightControlsWidth, 0, 24)
    row.rightControls.BackgroundTransparency = 1
    row.rightControls.BorderSizePixel = 0
    row.rightControls.ZIndex = 15

    if previewKey then
        row.preview = createPreviewMini(row.rightControls, 0, previewKey)
    end

    row.track = Instance.new("Frame")
    row.track.Parent = row.rightControls
    row.track.AnchorPoint = Vector2.new(0, 0.5)
    row.track.Position = UDim2.new(0, previewKey and 54 or 0, 0.5, 0)
    row.track.Size = UDim2.new(0, 42, 0, 18)
    row.track.BackgroundColor3 = Color3.fromRGB(255,255,255)
    row.track.BackgroundTransparency = 0.88
    row.track.BorderSizePixel = 0
    row.track.ZIndex = 15
    Instance.new("UICorner", row.track).CornerRadius = UDim.new(1,0)

    row.fill = Instance.new("Frame")
    row.fill.Parent = row.track
    row.fill.Size = UDim2.new(1,0,1,0)
    row.fill.BackgroundColor3 = currentThemeColor
    row.fill.BackgroundTransparency = 0.88
    row.fill.BorderSizePixel = 0
    row.fill.ZIndex = 16
    Instance.new("UICorner", row.fill).CornerRadius = UDim.new(1,0)
    addThemeFill(row.fill)

    row.glow = Instance.new("UIStroke")
    row.glow.Parent = row.track
    row.glow.Color = currentThemeColor
    row.glow.Thickness = 1
    row.glow.Transparency = 0.55
    addThemeGlow(row.glow)

    row.knob = Instance.new("Frame")
    row.knob.Parent = row.track
    row.knob.Size = UDim2.new(0, 14, 0, 14)
    row.knob.Position = UDim2.new(0, 2, 0.5, -7)
    row.knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    row.knob.BorderSizePixel = 0
    row.knob.ZIndex = 17
    Instance.new("UICorner", row.knob).CornerRadius = UDim.new(1,0)

    local knobStroke = Instance.new("UIStroke")
    knobStroke.Parent = row.knob
    knobStroke.Color = Color3.fromRGB(255,255,255)
    knobStroke.Transparency = 0.6
    knobStroke.Thickness = 1

    row.state = false
    row.title = text
    row.onChanged = onChanged

    function row:setState(state, silent)
        self.state = state
        self.label.Text = self.title .. " : " .. (state and "ON" or "OFF")

        TweenService:Create(self.knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()

        TweenService:Create(self.fill, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = state and 0.18 or 0.88
        }):Play()

        TweenService:Create(self.glow, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Transparency = state and 0.12 or 0.55
        }):Play()

        if state then registerPulseObject(self.fill) else unregisterPulseObject(self.fill) end

        if not silent and self.onChanged then self.onChanged(state) end
    end

    row.button.MouseButton1Click:Connect(function()
        row:setState(not row.state)
    end)

    if withHotkey then
        row.hotkey = createHotkeyMini(row.rightControls, 0, "NONE", function(newValue)
            if row.boundHotkey then unbindHotkeyFromToggle(row.boundHotkey, row) end
            row.boundHotkey = newValue
            bindHotkeyToToggle(newValue, row)
        end)
        row.hotkey.button.AnchorPoint = Vector2.new(1, 0.5)
        row.hotkey.button.Position = UDim2.new(1, 0, 0.5, 0)
        row.hotkey.button.Size = UDim2.new(0, 78, 0, 24)
        row.boundHotkey = "NONE"
    end

    return row
end

local function createDropdown(parent, titleText, options, multiSelect, onChanged)
    local data = {
        open = false,
        selectedText = "NONE",
        selectionMap = {},
        options = {},
        optionButtons = {},
        multiSelect = multiSelect,
        onChanged = onChanged,
        baseHeight = 34,
        rowHeight = 30,
        listPadding = 16,
    }

    local container = createCard(parent, data.baseHeight)
    container.ClipsDescendants = false
    container.ZIndex = 18

    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Parent = container
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Position = UDim2.new(0, 12, 0, 0)
    selectedLabel.Size = UDim2.new(1, -40, 0, data.baseHeight)
    selectedLabel.Text = titleText .. " : NONE"
    selectedLabel.TextColor3 = Color3.fromRGB(255,255,255)
    selectedLabel.TextStrokeTransparency = 1
    selectedLabel.TextSize = 11
    selectedLabel.Font = Enum.Font.GothamSemibold
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
    selectedLabel.ZIndex = 20

    local arrow = Instance.new("TextLabel")
    arrow.Parent = container
    arrow.BackgroundTransparency = 1
    arrow.AnchorPoint = Vector2.new(1,0.5)
    arrow.Position = UDim2.new(1,-10,0, data.baseHeight / 2)
    arrow.Size = UDim2.new(0,18,0,18)
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(255,255,255)
    arrow.TextStrokeTransparency = 1
    arrow.TextSize = 11
    arrow.Font = Enum.Font.GothamBold
    arrow.ZIndex = 20

    local listFrame = Instance.new("Frame")
    listFrame.Parent = container
    listFrame.Name = "DropdownList"
    listFrame.Position = UDim2.new(0, 0, 0, data.baseHeight)
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.BackgroundTransparency = 1
    listFrame.BorderSizePixel = 0
    listFrame.ClipsDescendants = true
    listFrame.ZIndex = 21

    local listShell = Instance.new("Frame")
    listShell.Parent = listFrame
    listShell.Size = UDim2.new(1,0,1,0)
    listShell.BackgroundColor3 = Color3.fromRGB(255,255,255)
    listShell.BackgroundTransparency = 0.965
    listShell.BorderSizePixel = 0
    listShell.ZIndex = 21
    Instance.new("UICorner", listShell).CornerRadius = UDim.new(0,8)

    local listStroke = Instance.new("UIStroke")
    listStroke.Parent = listShell
    listStroke.Color = currentThemeColor
    listStroke.Thickness = 1
    listStroke.Transparency = 0.22
    addThemeStroke(listStroke)

    local listTopLine = Instance.new("Frame")
    listTopLine.Parent = listShell
    listTopLine.Size = UDim2.new(1, 0, 0, 1)
    listTopLine.Position = UDim2.new(0, 0, 0, 0)
    listTopLine.BackgroundColor3 = currentThemeColor
    listTopLine.BackgroundTransparency = 0.10
    listTopLine.BorderSizePixel = 0
    listTopLine.ZIndex = 22

    local listBottomLine = Instance.new("Frame")
    listBottomLine.Parent = listShell
    listBottomLine.Size = UDim2.new(1, 0, 0, 1)
    listBottomLine.Position = UDim2.new(0, 0, 1, -1)
    listBottomLine.BackgroundColor3 = currentThemeColor
    listBottomLine.BackgroundTransparency = 0.10
    listBottomLine.BorderSizePixel = 0
    listBottomLine.ZIndex = 22

    local listLeftLine = Instance.new("Frame")
    listLeftLine.Parent = listShell
    listLeftLine.Size = UDim2.new(0, 1, 1, -8)
    listLeftLine.Position = UDim2.new(0, 0, 0, 4)
    listLeftLine.BackgroundColor3 = currentThemeColor
    listLeftLine.BackgroundTransparency = 0.18
    listLeftLine.BorderSizePixel = 0
    listLeftLine.ZIndex = 22

    local listRightLine = Instance.new("Frame")
    listRightLine.Parent = listShell
    listRightLine.Size = UDim2.new(0, 1, 1, -8)
    listRightLine.Position = UDim2.new(1, -1, 0, 4)
    listRightLine.BackgroundColor3 = currentThemeColor
    listRightLine.BackgroundTransparency = 0.18
    listRightLine.BorderSizePixel = 0
    listRightLine.ZIndex = 22

    addThemeFill(listTopLine)
    addThemeFill(listBottomLine)
    addThemeFill(listLeftLine)
    addThemeFill(listRightLine)

    local optionContainer = Instance.new("Frame")
    optionContainer.Parent = listShell
    optionContainer.BackgroundTransparency = 1
    optionContainer.BorderSizePixel = 0
    optionContainer.Position = UDim2.new(0, 0, 0, 0)
    optionContainer.Size = UDim2.new(1, 0, 1, 0)
    optionContainer.ZIndex = 23

    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = optionContainer
    listLayout.Padding = UDim.new(0,4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    local listPadding = Instance.new("UIPadding")
    listPadding.Parent = optionContainer
    listPadding.PaddingTop = UDim.new(0,8)
    listPadding.PaddingBottom = UDim.new(0,8)

    local clickButton = Instance.new("TextButton")
    clickButton.Parent = container
    clickButton.Size = UDim2.new(1,0,0,data.baseHeight)
    clickButton.BackgroundTransparency = 1
    clickButton.BorderSizePixel = 0
    clickButton.AutoButtonColor = false
    clickButton.Text = ""
    clickButton.ZIndex = 23

    local function refreshText()
        if multiSelect then
            selectedLabel.Text = titleText .. " : " .. formatMultiSelection(data.selectionMap)
        else
            selectedLabel.Text = titleText .. " : " .. data.selectedText
        end
    end

    local function getListHeight()
        return (#data.options > 0) and (#data.options * data.rowHeight + data.listPadding) or 0
    end

    local function updateContainerHeight(listHeight)
        container.Size = UDim2.new(1, -8, 0, data.baseHeight + listHeight)
    end

    local function closeOtherDropdowns()
        for _, dropdown in pairs(dropdownRegistry) do
            if dropdown and dropdown ~= data and dropdown.setOpen and dropdown.open then
                dropdown:setOpen(false)
            end
        end
    end

    local function setOpen(state)
        if state then closeOtherDropdowns() end
        data.open = state
        local targetHeight = state and getListHeight() or 0

        TweenService:Create(listFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, targetHeight)
        }):Play()

        TweenService:Create(arrow, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Rotation = state and 180 or 0
        }):Play()

        updateContainerHeight(targetHeight)
    end

    clickButton.MouseButton1Click:Connect(function()
        setOpen(not data.open)
    end)

    function data:clearOptions()
        for _, obj in ipairs(self.optionButtons) do
            if obj.button then obj.button:Destroy() end
        end
        self.optionButtons = {}
        self.options = {}
        self.selectionMap = {}
        if not self.multiSelect then self.selectedText = "NONE" end
        refreshText()
        setOpen(false)
    end

    function data:setOptions(newOptions)
        local previousSingle = self.selectedText
        local previousMap = self.selectionMap
        self:clearOptions()
        self.options = newOptions or {}

        for _, optionName in ipairs(self.options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Parent = optionContainer
            optionButton.Size = UDim2.new(1, -12, 0, 26)
            optionButton.BackgroundTransparency = 1
            optionButton.BorderSizePixel = 0
            optionButton.AutoButtonColor = false
            optionButton.Text = ""
            optionButton.ZIndex = 24
            Instance.new("UICorner", optionButton).CornerRadius = UDim.new(0,6)

            local optionHover = Instance.new("Frame")
            optionHover.Parent = optionButton
            optionHover.Size = UDim2.new(1,0,1,0)
            optionHover.BackgroundColor3 = currentThemeColor
            optionHover.BackgroundTransparency = 1
            optionHover.BorderSizePixel = 0
            optionHover.ZIndex = 23
            Instance.new("UICorner", optionHover).CornerRadius = UDim.new(0,6)
            addThemeFill(optionHover)

            local optionStroke = Instance.new("UIStroke")
            optionStroke.Parent = optionButton
            optionStroke.Color = currentThemeColor
            optionStroke.Thickness = 1
            optionStroke.Transparency = 0.5
            addThemeStroke(optionStroke)

            local optionText = Instance.new("TextLabel")
            optionText.Parent = optionButton
            optionText.BackgroundTransparency = 1
            optionText.Size = UDim2.new(1, -12, 1, 0)
            optionText.Position = UDim2.new(0, 6, 0, 0)
            optionText.Text = optionName
            optionText.TextColor3 = Color3.fromRGB(255,255,255)
            optionText.TextStrokeTransparency = 1
            optionText.TextSize = 10
            optionText.Font = Enum.Font.GothamBold
            optionText.TextTruncate = Enum.TextTruncate.AtEnd
            optionText.TextXAlignment = Enum.TextXAlignment.Left
            optionText.ZIndex = 25

            local function refreshOptionVisual()
                if multiSelect then
                    local selected = data.selectionMap[optionName]
                    TweenService:Create(optionStroke, TweenInfo.new(0.12), {Transparency = selected and 0.08 or 0.5}):Play()
                    TweenService:Create(optionHover, TweenInfo.new(0.12), {BackgroundTransparency = selected and 0.86 or 1}):Play()
                else
                    local selected = data.selectedText == optionName
                    TweenService:Create(optionStroke, TweenInfo.new(0.12), {Transparency = selected and 0.08 or 0.5}):Play()
                    TweenService:Create(optionHover, TweenInfo.new(0.12), {BackgroundTransparency = selected and 0.86 or 1}):Play()
                end
            end

            optionButton.MouseEnter:Connect(function()
                TweenService:Create(optionStroke, TweenInfo.new(0.12), {Transparency = 0.14}):Play()
                TweenService:Create(optionHover, TweenInfo.new(0.12), {BackgroundTransparency = 0.9}):Play()
            end)

            optionButton.MouseLeave:Connect(function()
                refreshOptionVisual()
            end)

            optionButton.MouseButton1Click:Connect(function()
                if multiSelect then
                    data.selectionMap[optionName] = not data.selectionMap[optionName]
                    refreshText()
                    refreshOptionVisual()
                    if data.onChanged then data.onChanged(data.selectionMap) end
                else
                    data.selectedText = optionName
                    refreshText()
                    for _, item in ipairs(data.optionButtons) do
                        if item and item.refreshOptionVisual then item.refreshOptionVisual() end
                    end
                    setOpen(false)
                    if data.onChanged then data.onChanged(optionName) end
                end
            end)

            table.insert(self.optionButtons, {button = optionButton, refreshOptionVisual = refreshOptionVisual, name = optionName})
        end

        if multiSelect then
            self.selectionMap = {}
            for _, optionName in ipairs(self.options) do
                self.selectionMap[optionName] = previousMap and previousMap[optionName] or false
            end
        else
            if table.find(self.options, previousSingle) then
                self.selectedText = previousSingle
            else
                self.selectedText = "NONE"
            end
        end

        for _, item in ipairs(self.optionButtons) do
            if item and item.refreshOptionVisual then item.refreshOptionVisual() end
        end

        refreshText()
        updateContainerHeight(self.open and getListHeight() or 0)
    end

    function data:setSingleValue(value, silent)
        self.selectedText = value or "NONE"
        refreshText()
        for _, item in ipairs(self.optionButtons) do
            if item and item.refreshOptionVisual then item.refreshOptionVisual() end
        end
        if not silent and self.onChanged then self.onChanged(self.selectedText) end
    end

    function data:setMultiValues(map, silent)
        self.selectionMap = {}
        for _, optionName in ipairs(self.options) do
            self.selectionMap[optionName] = map and map[optionName] or false
        end
        for _, item in ipairs(self.optionButtons) do
            if item and item.refreshOptionVisual then item.refreshOptionVisual() end
        end
        refreshText()
        if not silent and self.onChanged then self.onChanged(self.selectionMap) end
    end

    data.setOpen = setOpen
    data.listFrame = listFrame
    data.button = container
    data.container = container
    data.refreshText = refreshText

    if options then data:setOptions(options) else updateContainerHeight(0) end

    return data
end

local function createSlider(parent, titleText, minValue, maxValue, startValue, onChanged)
    local data = { min = minValue, max = maxValue, value = startValue, dragging = false, onChanged = onChanged }

    local card = createCard(parent, 52)
    data.card = card

    local title = Instance.new("TextLabel")
    title.Parent = card
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 12, 0, 0)
    title.Size = UDim2.new(1, -24, 0, 18)
    title.Text = titleText
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextStrokeTransparency = 1
    title.TextSize = 11
    title.Font = Enum.Font.GothamSemibold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 15

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = card
    valueLabel.BackgroundTransparency = 1
    valueLabel.AnchorPoint = Vector2.new(1,0)
    valueLabel.Position = UDim2.new(1, -12, 0, 0)
    valueLabel.Size = UDim2.new(0, 80, 0, 18)
    valueLabel.Text = tostring(startValue)
    valueLabel.TextColor3 = Color3.fromRGB(255,255,255)
    valueLabel.TextStrokeTransparency = 1
    valueLabel.TextSize = 10
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 15

    local track = Instance.new("Frame")
    track.Parent = card
    track.Position = UDim2.new(0, 12, 0, 28)
    track.Size = UDim2.new(1, -24, 0, 10)
    track.BackgroundColor3 = Color3.fromRGB(255,255,255)
    track.BackgroundTransparency = 0.88
    track.BorderSizePixel = 0
    track.ZIndex = 15
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame")
    fill.Parent = track
    fill.Size = UDim2.new((startValue - minValue) / (maxValue - minValue), 0, 1, 0)
    fill.BackgroundColor3 = currentThemeColor
    fill.BackgroundTransparency = 0.22
    fill.BorderSizePixel = 0
    fill.ZIndex = 16
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    addThemeFill(fill)
    registerPulseObject(fill)

    local glow = Instance.new("UIStroke")
    glow.Parent = track
    glow.Color = currentThemeColor
    glow.Thickness = 1
    glow.Transparency = 0.25
    addThemeGlow(glow)

    local knob = Instance.new("Frame")
    knob.Parent = track
    knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.Position = UDim2.new((startValue - minValue) / (maxValue - minValue), 0, 0.5, 0)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 17
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local knobStroke = Instance.new("UIStroke")
    knobStroke.Parent = knob
    knobStroke.Color = Color3.fromRGB(255,255,255)
    knobStroke.Transparency = 0.6
    knobStroke.Thickness = 1

    local sliderButton = Instance.new("TextButton")
    sliderButton.Parent = track
    sliderButton.Size = UDim2.new(1,0,1,0)
    sliderButton.BackgroundTransparency = 1
    sliderButton.Text = ""
    sliderButton.ZIndex = 18
    sliderButton.AutoButtonColor = false

    function data:setValue(value, silent)
        local clamped = math.clamp(value, minValue, maxValue)
        self.value = clamped
        local alpha = (clamped - minValue) / (maxValue - minValue)
        valueLabel.Text = tostring(clamped)

        TweenService:Create(fill, TweenInfo.new(0.06), {Size = UDim2.new(alpha, 0, 1, 0)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.06), {Position = UDim2.new(alpha, 0, 0.5, 0)}):Play()

        if not silent and self.onChanged then self.onChanged(clamped) end
    end

    local function setValueFromX(mouseX)
        local absPos = track.AbsolutePosition.X
        local absSize = track.AbsoluteSize.X
        local alpha = math.clamp((mouseX - absPos) / absSize, 0, 1)
        local value = math.floor((minValue + (maxValue - minValue) * alpha) + 0.5)
        data:setValue(value)
    end

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            data.dragging = true
            setValueFromX(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if data.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setValueFromX(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            data.dragging = false
        end
    end)

    return data
end

local function createInputBox(parent, placeholder, defaultText)
    local card = createCard(parent, 34)

    local box = Instance.new("TextBox")
    box.Parent = card
    box.Size = UDim2.new(1, -20, 1, 0)
    box.Position = UDim2.new(0, 10, 0, 0)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.Text = defaultText or ""
    box.PlaceholderText = placeholder or ""
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.PlaceholderColor3 = Color3.fromRGB(170,170,170)
    box.TextStrokeTransparency = 1
    box.TextSize = 11
    box.Font = Enum.Font.GothamSemibold
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ZIndex = 15

    return box
end

local function createActionButton(parent, text, callback)
    local card = createCard(parent, 34)

    local btn = Instance.new("TextButton")
    btn.Parent = card
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextStrokeTransparency = 1
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 15

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return btn
end

local function notifyConfig(text)
    if configStatusLabel then configStatusLabel.Text = text end
end

local function ensureConfigFolder()
    pcall(function()
        if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
    end)
end

local function sanitizeConfigName(name)
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    name = name:gsub("[\\/:*?\"<>|]", "_")
    return name
end

local function getConfigPath(name)
    return CONFIG_FOLDER .. "/" .. name .. CONFIG_EXTENSION
end

local function readConfigDb()
    ensureConfigFolder()
    local ok, decoded = pcall(function()
        if isfile(CONFIG_DB_FILE) then
            local raw = readfile(CONFIG_DB_FILE)
            return HttpService:JSONDecode(raw)
        end
        return {}
    end)
    if ok and type(decoded) == "table" then return decoded end
    return {}
end

local function writeConfigDb(names)
    ensureConfigFolder()
    pcall(function()
        writefile(CONFIG_DB_FILE, HttpService:JSONEncode(names))
    end)
end

local function rebuildConfigDbFromFiles()
    local names = {}
    local ok, files = pcall(function()
        ensureConfigFolder()
        return listfiles(CONFIG_FOLDER)
    end)
    if ok and files then
        for _, filePath in ipairs(files) do
            local normalized = tostring(filePath):gsub("\\", "/")
            local fileName = normalized:match("([^/]+)$")
            if fileName and fileName:sub(-#CONFIG_EXTENSION) == CONFIG_EXTENSION and fileName ~= "configs_db.json" then
                local baseName = fileName:sub(1, #fileName - #CONFIG_EXTENSION)
                if baseName ~= "configs_db" then table.insert(names, baseName) end
            end
        end
    end
    table.sort(names)
    writeConfigDb(names)
    return names
end

local function listConfigNames()
    local names = readConfigDb()
    if type(names) ~= "table" or #names == 0 then names = rebuildConfigDbFromFiles() end

    local validNames = {}
    for _, name in ipairs(names) do
        local clean = sanitizeConfigName(name)
        if clean ~= "" and pcall(function() return isfile(getConfigPath(clean)) end) and isfile(getConfigPath(clean)) then
            table.insert(validNames, clean)
        end
    end

    if #validNames == 0 then
        validNames = rebuildConfigDbFromFiles()
    else
        table.sort(validNames)
        writeConfigDb(validNames)
    end
    return validNames
end

local function refreshConfigDropdown()
    if configDropdownApi then
        local names = listConfigNames()
        if #names == 0 then names = {"NO CONFIGS"} end
        configDropdownApi:setOptions(names)

        local selected = sanitizeConfigName(uiState.currentConfigName)
        if selected ~= "" and table.find(names, selected) then
            configDropdownApi:setSingleValue(selected, true)
        else
            configDropdownApi:setSingleValue(names[1] or "NO CONFIGS", true)
            if names[1] and names[1] ~= "NO CONFIGS" then uiState.currentConfigName = names[1] end
        end
    end
end

local function serializeState()
    return {
        teamDropdown = uiState.teamDropdown,
        teamSectionEnabled = uiState.teamSectionEnabled,
        targetZones = uiState.targetZones,
        targetToggle = uiState.targetToggle,
        targetHotkey = uiState.targetHotkey,
        aimVisibleOnly = uiState.aimVisibleOnly,
        aimFov = uiState.aimFov,
        aimHitpart = uiState.aimHitpart,
        aimSmooth = uiState.aimSmooth,
        flyToggle = uiState.flyToggle,
        flySpeed = uiState.flySpeed,
        speedToggle = uiState.speedToggle,
        walkSpeed = uiState.walkSpeed,
        infiniteJump = uiState.infiniteJump,
        jumpPower = uiState.jumpPower,
        esp = uiState.esp,
        distance = uiState.distance,
        currentConfigName = uiState.currentConfigName,
    }
end

local function applyLoadedState(data)
    if type(data) ~= "table" then return end

    uiState.teamDropdown = type(data.teamDropdown) == "table" and data.teamDropdown or {}
    uiState.teamSectionEnabled = data.teamSectionEnabled == true
    uiState.targetZones = data.targetZones or {}
    uiState.targetToggle = data.targetToggle or false
    uiState.targetHotkey = data.targetHotkey or "NONE"
    uiState.aimVisibleOnly = data.aimVisibleOnly ~= false
    uiState.aimFov = tonumber(data.aimFov) or 45
    uiState.aimHitpart = tostring(data.aimHitpart or "Head")
    uiState.aimSmooth = tonumber(data.aimSmooth) or 0
    uiState.flyToggle = data.flyToggle == true
    uiState.flySpeed = tonumber(data.flySpeed) or 60
    uiState.speedToggle = data.speedToggle == true
    uiState.walkSpeed = tonumber(data.walkSpeed) or 16
    uiState.infiniteJump = data.infiniteJump == true
    uiState.jumpPower = tonumber(data.jumpPower) or 100
    uiState.distance = data.distance or 150
    uiState.currentConfigName = data.currentConfigName or uiState.currentConfigName

    if type(data.esp) == "table" then
        for name, entry in pairs(uiState.esp) do
            local loaded = data.esp[name]
            if type(loaded) == "table" then
                entry.enabled = loaded.enabled == true
                entry.hotkey = tostring(loaded.hotkey or "NONE")
            end
        end
    end

    if dropdownRegistry.team then dropdownRegistry.team:setMultiValues(uiState.teamDropdown, true) end
    if dropdownRegistry.targetZones then dropdownRegistry.targetZones:setMultiValues(uiState.targetZones, true) end

    if toggleRegistry.teamSection then
        toggleRegistry.teamSection:setState(uiState.teamSectionEnabled, true)
    end

    if toggleRegistry.target then
        toggleRegistry.target:setState(uiState.targetToggle, true)
        if toggleRegistry.target.hotkey then
            unbindHotkeyFromToggle(toggleRegistry.target.boundHotkey, toggleRegistry.target)
            toggleRegistry.target.hotkey:setValue(uiState.targetHotkey, true)
            toggleRegistry.target.boundHotkey = uiState.targetHotkey
            bindHotkeyToToggle(uiState.targetHotkey, toggleRegistry.target)
        end
    end

    if toggleRegistry.aimVisible then
        toggleRegistry.aimVisible:setState(uiState.aimVisibleOnly, true)
    end

    if dropdownRegistry.aimHitpart then dropdownRegistry.aimHitpart:setSingleValue(uiState.aimHitpart, true) end
    if sliderRegistry.aimSmooth then sliderRegistry.aimSmooth:setValue(math.floor((uiState.aimSmooth or 0) * 100), true) end
    if sliderRegistry.flySpeed then sliderRegistry.flySpeed:setValue(uiState.flySpeed, true) end
    if sliderRegistry.walkSpeed then sliderRegistry.walkSpeed:setValue(uiState.walkSpeed, true) end
    if sliderRegistry.jumpPower then sliderRegistry.jumpPower:setValue(uiState.jumpPower, true) end
    if sliderRegistry.aimFov then sliderRegistry.aimFov:setValue(uiState.aimFov, true) end
    if sliderRegistry.distance then sliderRegistry.distance:setValue(uiState.distance, true) end

    Aim.TargetPart = uiState.aimHitpart or "Head"
    Aim.Smooth = uiState.aimSmooth or 0
    getgenv().AimbotHitpart = uiState.aimHitpart or "Head"
    getgenv().AimbotSmooth = uiState.aimSmooth or 0
    features.SetFlySpeed(uiState.flySpeed)
    features.SetWalkSpeed(uiState.walkSpeed)

    for name, row in pairs(toggleRegistry.espRows or {}) do
        if uiState.esp[name] then
            row:setState(uiState.esp[name].enabled, true)
            if row.hotkey then
                unbindHotkeyFromToggle(row.boundHotkey, row)
                row.hotkey:setValue(uiState.esp[name].hotkey, true)
                row.boundHotkey = uiState.esp[name].hotkey
                bindHotkeyToToggle(row.boundHotkey, row)
            end
        end
    end

    if toggleRegistry.fly then
        toggleRegistry.fly:setState(uiState.flyToggle, true)
        features.ToggleFly(uiState.flyToggle)
    end
    if toggleRegistry.speed then
        toggleRegistry.speed:setState(uiState.speedToggle, true)
        features.ToggleSpeed(uiState.speedToggle)
    end
    if toggleRegistry.infiniteJump then
        toggleRegistry.infiniteJump:setState(uiState.infiniteJump, true)
        features.ToggleInfiniteJump(uiState.infiniteJump, uiState.jumpPower)
    end
    if toggleRegistry.target then
        features.ToggleAimbot(uiState.targetToggle)
    end

    if configNameInput then configNameInput.Text = uiState.currentConfigName end
    refreshConfigDropdown()
end

local function saveConfig(name)
    name = sanitizeConfigName(name)
    if not name or name == "" then notifyConfig("CONFIG NAME EMPTY") return end

    local ok = pcall(function()
        ensureConfigFolder()
        uiState.currentConfigName = name
        local encoded = HttpService:JSONEncode(serializeState())
        writefile(getConfigPath(name), encoded)

        local names = listConfigNames()
        if not table.find(names, name) then table.insert(names, name) table.sort(names) end
        writeConfigDb(names)
    end)

    if ok then
        if configNameInput then configNameInput.Text = name end
        notifyConfig("SAVED : " .. name)
        refreshConfigDropdown()
    else
        notifyConfig("SAVE FAILED")
    end
end

local function loadConfig(name)
    name = sanitizeConfigName(name)
    if not name or name == "" or name == "NO CONFIGS" then notifyConfig("NO CONFIG SELECTED") return end

    local ok, decoded = pcall(function()
        local raw = readfile(getConfigPath(name))
        return HttpService:JSONDecode(raw)
    end)

    if ok and decoded then
        decoded.currentConfigName = name
        applyLoadedState(decoded)
        notifyConfig("LOADED : " .. name)
    else
        notifyConfig("LOAD FAILED")
    end
end

local function deleteConfig(name)
    name = sanitizeConfigName(name)
    if not name or name == "" or name == "NO CONFIGS" then notifyConfig("NO CONFIG SELECTED") return end

    local ok = pcall(function()
        ensureConfigFolder()
        if isfile(getConfigPath(name)) then delfile(getConfigPath(name)) end

        local names = listConfigNames()
        for i = #names, 1, -1 do
            if names[i] == name then table.remove(names, i) end
        end
        writeConfigDb(names)
    end)

    if ok then
        if uiState.currentConfigName == name then
            uiState.currentConfigName = "default"
            if configNameInput then configNameInput.Text = "default" end
        end
        refreshConfigDropdown()
        notifyConfig("DELETED : " .. name)
    else
        notifyConfig("DELETE FAILED")
    end
end

local function newConfig()
    local base = "config_" .. tostring(os.time())
    uiState.currentConfigName = base
    uiState.teamDropdown = {}
    uiState.targetZones = {}
    uiState.targetToggle = false
    uiState.targetHotkey = "NONE"
    uiState.distance = 150

    for _, entry in pairs(uiState.esp) do
        entry.enabled = false
        entry.hotkey = "NONE"
    end

    applyLoadedState(serializeState())
    if configNameInput then configNameInput.Text = base end
    notifyConfig("NEW CONFIG READY")
end

local function getLiveTeamOptions()
    local options = {}
    for _, team in ipairs(Teams:GetTeams()) do
        if team and team.Name and team.Name ~= "" then
            table.insert(options, team.Name)
        end
    end
    table.sort(options, function(a, b) return string.lower(a) < string.lower(b) end)
    if #options == 0 then options = {"NO TEAMS"} end
    return options
end

local function sanitizeSelectedTeams(selectionMap)
    local cleaned = {}
    local liveOptions = getLiveTeamOptions()
    local valid = {}
    for _, name in ipairs(liveOptions) do valid[name] = true end

    for name, enabled in pairs(selectionMap or {}) do
        if enabled and valid[name] and name ~= "NO TEAMS" then
            cleaned[name] = true
        end
    end
    return cleaned
end

local function refreshTeamDropdownOptions()
    if dropdownRegistry.team then
        local currentSelection = sanitizeSelectedTeams(uiState.teamDropdown)
        dropdownRegistry.team:setOptions(getLiveTeamOptions())
        dropdownRegistry.team:setMultiValues(currentSelection, true)
        uiState.teamDropdown = currentSelection
    end
end

-- ==================== ESP SYSTEM (Tam çalışan) ====================
local espObjects = {} -- [player] = {chams, box, name, health, distance, tracer}

local function createChams(character, color)
    if not character then return nil end
    local highlight = Instance.new("Highlight")
    highlight.Name = "MYLF_ESP_Chams"
    highlight.Adornee = character
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0.15
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    return highlight
end

local function hideESPObjects(objs)
    if not objs then return end
    if objs.box then objs.box.Visible = false end
    if objs.name then objs.name.Visible = false end
    if objs.health then objs.health.Visible = false end
    if objs.distance then objs.distance.Visible = false end
    if objs.tracer then objs.tracer.Visible = false end
end

local function removeESPObjects(objs)
    if not objs then return end
    for _, obj in pairs(objs) do
        pcall(function()
            if obj.Remove then
                obj:Remove()
            else
                obj:Destroy()
            end
        end)
    end
end

local function isFinite(n)
    return typeof(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end

local function updateESP()
    local themeColor = currentThemeColor
    local enemyTeams = uiState.teamDropdown or {}
    local hasTeamFilter = next(enemyTeams) ~= nil

    for player, objs in pairs(espObjects) do
        if not player.Parent or not player.Character then
            removeESPObjects(objs)
            espObjects[player] = nil
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            continue
        end

        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if not character or not humanoid or not rootPart or humanoid.Health <= 0 then
            if espObjects[player] then
                removeESPObjects(espObjects[player])
                espObjects[player] = nil
            end
            continue
        end

        local pTeamName = (player.Team and player.Team.Name) or "None"
        local isEnemy = true

        if hasTeamFilter then
            isEnemy = enemyTeams[pTeamName] == true
        end

        if not isEnemy then
            if espObjects[player] then
                removeESPObjects(espObjects[player])
                espObjects[player] = nil
            end
            continue
        end

        if not espObjects[player] then
            espObjects[player] = {}
        end

        local objs = espObjects[player]

        local function createOrUpdateDrawing(key, class)
            if not objs[key] then
                objs[key] = Drawing.new(class)
            end
            return objs[key]
        end

        -- CHAMS
        if uiState.esp["ESP GLOW"].enabled then
            if not objs.chams or not objs.chams.Parent then
                objs.chams = createChams(character, themeColor)
            else
                objs.chams.Adornee = character
                objs.chams.FillColor = themeColor
                objs.chams.OutlineColor = themeColor
            end
        else
            if objs.chams then
                objs.chams:Destroy()
                objs.chams = nil
            end
        end

        -- BOX
        if uiState.esp["ESP BOX"].enabled then
            local box = createOrUpdateDrawing("box", "Square")
            box.Visible = false
            box.Thickness = 2
            box.Color = themeColor
            box.Transparency = 1
            box.Filled = false
        else
            if objs.box then
                objs.box:Remove()
                objs.box = nil
            end
        end

        -- NAME
        if uiState.esp["ESP NAME"].enabled then
            local name = createOrUpdateDrawing("name", "Text")
            name.Visible = false
            name.Size = 14
            name.Color = themeColor
            name.Outline = true
            name.Center = true
            name.Font = 2
        else
            if objs.name then
                objs.name:Remove()
                objs.name = nil
            end
        end

        -- HEALTH
        if uiState.esp["ESP HEALTH"].enabled then
            local health = createOrUpdateDrawing("health", "Text")
            health.Visible = false
            health.Size = 13
            health.Outline = true
            health.Center = true
            health.Font = 2
        else
            if objs.health then
                objs.health:Remove()
                objs.health = nil
            end
        end

        -- DISTANCE
        if uiState.esp["ESP DISTANCE"].enabled then
            local distance = createOrUpdateDrawing("distance", "Text")
            distance.Visible = false
            distance.Size = 12
            distance.Color = themeColor
            distance.Outline = true
            distance.Center = true
            distance.Font = 2
        else
            if objs.distance then
                objs.distance:Remove()
                objs.distance = nil
            end
        end

        -- TRACER
        if uiState.esp["ESP TRACER"].enabled then
            local tracer = createOrUpdateDrawing("tracer", "Line")
            tracer.Visible = false
            tracer.Thickness = 1.5
            tracer.Color = themeColor
            tracer.Transparency = 1
        else
            if objs.tracer then
                objs.tracer:Remove()
                objs.tracer = nil
            end
        end
    end
end

local function espRenderStep()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local themeColor = currentThemeColor

    for player, objs in pairs(espObjects) do
        local character = player.Character
        if not character then
            hideESPObjects(objs)
            continue
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")

        if not humanoid or not rootPart or humanoid.Health <= 0 then
            hideESPObjects(objs)
            continue
        end

        local rootPos3, rootVisible = camera:WorldToViewportPoint(rootPart.Position)
        if not rootVisible then
            hideESPObjects(objs)
            continue
        end

        local ok, cf, size = pcall(function()
            return character:GetBoundingBox()
        end)

        if not ok or not cf or not size then
            hideESPObjects(objs)
            continue
        end

        if not isFinite(size.X) or not isFinite(size.Y) or not isFinite(size.Z) then
            hideESPObjects(objs)
            continue
        end

        local top3D = cf.Position + Vector3.new(0, size.Y / 2, 0)
        local bottom3D = cf.Position - Vector3.new(0, size.Y / 2, 0)

        local topPos3, topVisible = camera:WorldToViewportPoint(top3D)
        local bottomPos3, bottomVisible = camera:WorldToViewportPoint(bottom3D)

        if not topVisible or not bottomVisible then
            hideESPObjects(objs)
            continue
        end

        if not (
            isFinite(topPos3.X) and isFinite(topPos3.Y) and
            isFinite(bottomPos3.X) and isFinite(bottomPos3.Y) and
            isFinite(rootPos3.X) and isFinite(rootPos3.Y)
        ) then
            hideESPObjects(objs)
            continue
        end

        local height = math.abs(bottomPos3.Y - topPos3.Y)
        local width = height * 0.60

        if not isFinite(height) or not isFinite(width) or height <= 2 or width <= 2 then
            hideESPObjects(objs)
            continue
        end

        local top = Vector2.new(topPos3.X, topPos3.Y)
        local bottom = Vector2.new(bottomPos3.X, bottomPos3.Y)
        local root2D = Vector2.new(rootPos3.X, rootPos3.Y)

        -- BOX
        if objs.box then
            objs.box.Visible = true
            objs.box.Size = Vector2.new(
                math.floor(width),
                math.floor(height)
            )
            objs.box.Position = Vector2.new(
                math.floor(top.X - width / 2),
                math.floor(top.Y)
            )
            objs.box.Color = themeColor
            objs.box.Thickness = 2
            objs.box.Transparency = 1
            objs.box.Filled = false
        end

        -- NAME
        if objs.name then
            objs.name.Visible = true
            objs.name.Text = player.DisplayName
            objs.name.Position = Vector2.new(
                math.floor(top.X),
                math.floor(top.Y - 20)
            )
            objs.name.Color = themeColor
        end

        -- HEALTH
        if objs.health then
            local hp = math.floor(humanoid.Health)
            local maxhp = math.max(1, math.floor(humanoid.MaxHealth))
            local ratio = math.clamp(hp / maxhp, 0, 1)

            objs.health.Visible = true
            objs.health.Text = tostring(hp) .. "/" .. tostring(maxhp)
            objs.health.Position = Vector2.new(
                math.floor(top.X),
                math.floor(top.Y - 8)
            )
            objs.health.Color = Color3.fromRGB(
                math.floor(255 * (1 - ratio)),
                math.floor(255 * ratio),
                0
            )
        end

        -- DISTANCE
        if objs.distance then
            local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local dist = localRoot and math.floor((localRoot.Position - rootPart.Position).Magnitude) or 0

            objs.distance.Visible = true
            objs.distance.Text = tostring(dist) .. "m"
            objs.distance.Position = Vector2.new(
                math.floor(bottom.X),
                math.floor(bottom.Y + 8)
            )
            objs.distance.Color = themeColor
        end

        -- TRACER
        if objs.tracer then
            objs.tracer.Visible = true
            objs.tracer.From = Vector2.new(
                math.floor(camera.ViewportSize.X / 2),
                math.floor(camera.ViewportSize.Y)
            )
            objs.tracer.To = Vector2.new(
                math.floor(root2D.X),
                math.floor(root2D.Y)
            )
            objs.tracer.Color = themeColor
            objs.tracer.Thickness = 1.5
            objs.tracer.Transparency = 1
        end

        -- CHAMS
        if objs.chams then
            objs.chams.Adornee = character
            objs.chams.FillColor = themeColor
            objs.chams.OutlineColor = themeColor
        end
    end
end

local espConnection

local function startESP()
    if espConnection then return end

    espConnection = RunService.RenderStepped:Connect(function()
        local ok1, err1 = pcall(updateESP)
        if not ok1 then
            warn("updateESP error:", err1)
        end

        local ok2, err2 = pcall(espRenderStep)
        if not ok2 then
            warn("espRenderStep error:", err2)
        end
    end)
end

local function stopESP()
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end

    for _, objs in pairs(espObjects) do
        hideESPObjects(objs)
    end
end

local function refreshAllESP()
    for _, objs in pairs(espObjects) do
        for k, obj in pairs(objs) do
            if k == "chams" and obj then
                obj.FillColor = currentThemeColor
                obj.OutlineColor = currentThemeColor
            elseif obj and obj.Color then
                obj.Color = currentThemeColor
            end
        end
    end
end

local oldApplyThemeByIndex = applyThemeByIndex
applyThemeByIndex = function(index)
    oldApplyThemeByIndex(index)
    refreshAllESP()
end

startESP()

-- ==================== SECTIONS ====================
do
    local teamSection = sections[1]

    createLabel(teamSection, "TEAM DROPDOWN")
    local teamDropdown = createDropdown(teamSection, "TEAM", getLiveTeamOptions(), true, function(value)
        uiState.teamDropdown = sanitizeSelectedTeams(value)
    end)
    dropdownRegistry.team = teamDropdown
    teamDropdown:setMultiValues(sanitizeSelectedTeams(uiState.teamDropdown), true)

    createLabel(teamSection, "TEAM TOGGLE")
    local teamToggle = createToggleRow(teamSection, "TEAM SECTION", false, function(state)
        uiState.teamSectionEnabled = state
    end)
    teamToggle:setState(false, true)
    toggleRegistry.teamSection = teamToggle

end

do
    local targetSection = sections[2]

    createLabel(targetSection, "AIMBOT + ON/OFF HOTKEY")
    local aimToggle = createToggleRow(targetSection, "AIMBOT", true, function(state)
        features.ToggleAimbot(state)
    end)
    aimToggle:setState(uiState.targetToggle, true)
    toggleRegistry.target = aimToggle

    if aimToggle.hotkey then
        aimToggle.hotkey.onChanged = function(value)
            uiState.targetHotkey = value
            if aimToggle.boundHotkey then unbindHotkeyFromToggle(aimToggle.boundHotkey, aimToggle) end
            aimToggle.boundHotkey = value
            bindHotkeyToToggle(value, aimToggle)
        end
        aimToggle.hotkey:setValue(uiState.targetHotkey or "NONE", true)
        aimToggle.boundHotkey = uiState.targetHotkey or "NONE"
        bindHotkeyToToggle(aimToggle.boundHotkey, aimToggle)
    end

    createLabel(targetSection, "AIM HITPART")
    local hitpartDropdown = createDropdown(targetSection, "HITPART", {
        "Head", "UpperTorso", "HumanoidRootPart", "Torso", "LowerTorso"
    }, false, function(value)
        local selected = value or "Head"
        uiState.aimHitpart = selected
        Aim.TargetPart = selected
        getgenv().AimbotHitpart = selected
    end)
    dropdownRegistry.aimHitpart = hitpartDropdown
    hitpartDropdown:setSingleValue(uiState.aimHitpart or "Head", true)
    Aim.TargetPart = uiState.aimHitpart or "Head"
    getgenv().AimbotHitpart = uiState.aimHitpart or "Head"

    createLabel(targetSection, "AIM SMOOTH")
    local smoothSlider = createSlider(targetSection, "SMOOTH", 0, 100, math.floor((uiState.aimSmooth or 0) * 100), function(value)
        local smooth = tonumber(value) / 100
        uiState.aimSmooth = smooth
        Aim.Smooth = smooth
        getgenv().AimbotSmooth = smooth
    end)
    sliderRegistry.aimSmooth = smoothSlider
    smoothSlider:setValue(math.floor((uiState.aimSmooth or 0) * 100), true)
    Aim.Smooth = uiState.aimSmooth or 0
    getgenv().AimbotSmooth = uiState.aimSmooth or 0

    features.ToggleAimbot(uiState.targetToggle)
end
do
    local espSection = sections[3]
    toggleRegistry.espRows = {}

    local espNames = {"ESP BOX", "ESP NAME", "ESP HEALTH", "ESP DISTANCE", "ESP TRACER", "ESP GLOW"}

    for _, name in ipairs(espNames) do
        createLabel(espSection, name .. " TOGGLE")
        local row = createToggleRow(espSection, name, true, function(state)
            if uiState.esp[name] then
                uiState.esp[name].enabled = state
            end
        end, name)
        row:setState(false, true)
        if row.hotkey then
            row.hotkey.onChanged = function(value)
                if uiState.esp[name] then uiState.esp[name].hotkey = value end
                unbindHotkeyFromToggle(row.boundHotkey, row)
                row.boundHotkey = value
                bindHotkeyToToggle(value, row)
            end
        end
        toggleRegistry.espRows[name] = row
    end

    createLabel(espSection, "MESAFE")
    local slider = createSlider(espSection, "MESAFE", 0, 500, 150, function(value)
        uiState.distance = value
    end)
    sliderRegistry.distance = slider
end

do
    local s = sections[4]

    createLabel(s, "FLY")
    local flyToggle = createToggleRow(s, "FLY", false, function(state)
        uiState.flyToggle = state
        features.ToggleFly(state)
    end)
    flyToggle:setState(uiState.flyToggle, true)
    toggleRegistry.fly = flyToggle

    local flySpeedLabel = createLabel(s, "FLY SPEED")
    local flySlider = createSlider(s, "VALUE", 10, 200, uiState.flySpeed or 60, function(value)
        uiState.flySpeed = value
        features.SetFlySpeed(value)
    end)
    flySlider:setValue(uiState.flySpeed or 60, true)
    sliderRegistry.flySpeed = flySlider
    features.SetFlySpeed(uiState.flySpeed or 60)

    createLabel(s, "WALK")
    local walkToggle = createToggleRow(s, "WALK SPEED", false, function(state)
        uiState.speedToggle = state
        features.ToggleSpeed(state)
    end)
    walkToggle:setState(uiState.speedToggle, true)
    toggleRegistry.speed = walkToggle

    local walkSpeedLabel = createLabel(s, "WALK SPEED")
    local walkSlider = createSlider(s, "VALUE", 1, 200, uiState.walkSpeed or 16, function(value)
        uiState.walkSpeed = value
        features.SetWalkSpeed(value)
        if uiState.speedToggle then
            features.ToggleSpeed(true)
        end
    end)
    walkSlider:setValue(uiState.walkSpeed or 16, true)
    sliderRegistry.walkSpeed = walkSlider
    features.SetWalkSpeed(uiState.walkSpeed or 16)

    createLabel(s, "INFINITE JUMP")
    local infJumpToggle = createToggleRow(s, "INFINITE JUMP", false, function(state)
        uiState.infiniteJump = state
        features.ToggleInfiniteJump(state, uiState.jumpPower or 100)
    end)
    infJumpToggle:setState(uiState.infiniteJump, true)
    toggleRegistry.infiniteJump = infJumpToggle

    local jumpPowerLabel = createLabel(s, "JUMP POWER")
    local jumpSlider = createSlider(s, "VALUE", 25, 200, uiState.jumpPower or 100, function(value)
        uiState.jumpPower = value
        if uiState.infiniteJump then
            features.ToggleInfiniteJump(true, value)
        end
    end)
    jumpSlider:setValue(uiState.jumpPower or 100, true)
    sliderRegistry.jumpPower = jumpSlider

    features.ToggleFly(uiState.flyToggle)
    features.ToggleSpeed(uiState.speedToggle)
    features.ToggleInfiniteJump(uiState.infiniteJump, uiState.jumpPower or 100)

    _G.MYLF_TP = _G.MYLF_TP or {}
    _G.MYLF_TP.on = false
    _G.MYLF_TP.c = _G.MYLF_TP.c or nil
    _G.MYLF_TP.m = _G.MYLF_TP.m or LocalPlayer:GetMouse()

    createLabel(sections[4], "TELEPORT")

    createToggleRow(sections[4], "TP [T] Button", false, function(state)
        _G.MYLF_TP.on = state and true or false

        if _G.MYLF_TP.c then
            _G.MYLF_TP.c:Disconnect()
            _G.MYLF_TP.c = nil
        end

        if _G.MYLF_TP.on then
            _G.MYLF_TP.c = UIS.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.KeyCode ~= Enum.KeyCode.T then return end

                if LocalPlayer.Character
                and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character:MoveTo(
                        _G.MYLF_TP.m.Hit.Position + Vector3.new(0,3,0)
                    )
                end
            end)
        end
    end):setState(false, true)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)

        if _G.MYLF_TP.on and _G.MYLF_TP.c == nil then
            _G.MYLF_TP.c = UIS.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.KeyCode ~= Enum.KeyCode.T then return end

                if LocalPlayer.Character
                and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character:MoveTo(
                        _G.MYLF_TP.m.Hit.Position + Vector3.new(0,3,0)
                    )
                end
            end)
        end
    end)


    _G.MYLF_NC = _G.MYLF_NC or {}
    _G.MYLF_NC.on = false
    _G.MYLF_NC.c = _G.MYLF_NC.c or nil
    _G.MYLF_NC.r = _G.MYLF_NC.r or {}

    createLabel(sections[4], "NOCLIP")

    createToggleRow(sections[4], "NOCLIP", false, function(state)
        _G.MYLF_NC.on = state and true or false

        if _G.MYLF_NC.c then
            _G.MYLF_NC.c:Disconnect()
            _G.MYLF_NC.c = nil
        end

        if _G.MYLF_NC.on then
            _G.MYLF_NC.c = RunService.Stepped:Connect(function()
                if not LocalPlayer.Character then return end

                for _,v in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        if _G.MYLF_NC.r[v] == nil then
                            _G.MYLF_NC.r[v] = v.CanCollide
                        end
                        v.CanCollide = false
                    end
                end
            end)
        else
            if LocalPlayer.Character then
                for _,v in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        if _G.MYLF_NC.r[v] ~= nil then
                            v.CanCollide = _G.MYLF_NC.r[v]
                        else
                            v.CanCollide = true
                        end
                    end
                end
            end

            _G.MYLF_NC.r = {}
        end
    end):setState(false, true)

end
do
    local s = sections[5]
    createLabel(s, "PLACEHOLDER")
    local p = createToggleRow(s, "TAB 5 SECTION", false, function() end)
    p:setState(false, true)
end

do
    local s = sections[6]

    createLabel(s, "CONFIG NAME")
    configNameInput = createInputBox(s, "enter config name...", "default")

    createLabel(s, "CONFIG ACTIONS")
    createActionButton(s, "NEW", function() newConfig() end)
    createActionButton(s, "SAVE", function()
        local name = configNameInput and configNameInput.Text or ""
        saveConfig(name)
    end)
    createActionButton(s, "LOAD", function()
        local selected = configDropdownApi and configDropdownApi.selectedText or "NO CONFIGS"
        loadConfig(selected)
    end)
    createActionButton(s, "DELETE", function()
        local selected = configDropdownApi and configDropdownApi.selectedText or "NO CONFIGS"
        deleteConfig(selected)
    end)

    createLabel(s, "SAVED CONFIGS")
    configDropdownApi = createDropdown(s, "CONFIG", {"NO CONFIGS"}, false, function(value)
        if value ~= "NO CONFIGS" then
            uiState.currentConfigName = sanitizeConfigName(value)
            if configNameInput then configNameInput.Text = uiState.currentConfigName end
        end
    end)

    configStatusLabel = Instance.new("TextLabel")
    configStatusLabel.Parent = s
    configStatusLabel.BackgroundTransparency = 1
    configStatusLabel.Size = UDim2.new(1, 0, 0, 18)
    configStatusLabel.Text = "CONFIG STATUS : READY"
    configStatusLabel.TextColor3 = Color3.fromRGB(180,180,180)
    configStatusLabel.TextStrokeTransparency = 1
    configStatusLabel.TextSize = 10
    configStatusLabel.Font = Enum.Font.GothamBold
    configStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    configStatusLabel.ZIndex = 12
end

Teams.ChildAdded:Connect(function(child)
    if child:IsA("Team") then task.defer(refreshTeamDropdownOptions) end
end)

Teams.ChildRemoved:Connect(function(child)
    if child:IsA("Team") then task.defer(refreshTeamDropdownOptions) end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if listeningHotkeyRef then
        local formatted = formatInputObject(input)
        if formatted then
            listeningHotkeyRef.value = formatted
            listeningHotkeyRef.listening = false
            listeningHotkeyRef.label.Text = formatted
            TweenService:Create(listeningHotkeyRef.stroke, TweenInfo.new(0.12), {Transparency = 0.18}):Play()
            if listeningHotkeyRef.onChanged then listeningHotkeyRef.onChanged(formatted) end
            listeningHotkeyRef = nil
            return
        end
    end

    local formatted = formatInputObject(input)
    if formatted then
        local boundToggle = hotkeyBindings[string.lower(formatted)]
        if boundToggle then
            boundToggle:setState(not boundToggle.state)
            return
        end
    end

    if input.KeyCode == Enum.KeyCode.K then
        menuVisible = not menuVisible
        main.Visible = menuVisible
        sidePanel.Visible = menuVisible
        topBrand.Visible = menuVisible
        sideBrand.Visible = menuVisible

        if menuVisible then
            TweenService:Create(blur, TweenInfo.new(0.18), {Size = 12}):Play()
        else
            TweenService:Create(blur, TweenInfo.new(0.18), {Size = 0}):Play()
        end
    end
end)

-- Mouse FX (tamamı aynı)
local mouseInsideMain = false
local activeTrails = {}
local maxTrails = 8
local lastMousePos = nil
local lastFxTime = 0
local fxThrottle = 0.03
local lastSparkTime = 0
local sparkThrottle = 0.06

local function createSparkBurst(x, y)
    if not menuVisible then return end
    local now = tick()
    if now - lastSparkTime < sparkThrottle then return end
    lastSparkTime = now

    for _ = 1, math.random(2, 3) do
        local spark = Instance.new("Frame")
        spark.Parent = mouseFxLayer
        spark.AnchorPoint = Vector2.new(0.5, 0.5)
        spark.Position = UDim2.new(0, x, 0, y)
        spark.Size = UDim2.new(0, 2, 0, 2)
        spark.BackgroundColor3 = currentThemeColor
        spark.BackgroundTransparency = 0.2
        spark.BorderSizePixel = 0
        spark.ZIndex = 43
        Instance.new("UICorner", spark).CornerRadius = UDim.new(1,0)

        local offsetX = math.random(-8, 8)
        local offsetY = math.random(-8, 8)

        TweenService:Create(spark, TweenInfo.new(0.18), {
            Position = UDim2.new(0, x + offsetX, 0, y + offsetY),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 1, 0, 1)
        }):Play()

        task.delay(0.2, function() if spark then spark:Destroy() end end)
    end
end

local function createMouseRipple(x, y)
    if not menuVisible then return end

    local ripple = Instance.new("Frame")
    ripple.Parent = mouseFxLayer
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.Size = UDim2.new(0, 4, 0, 4)
    ripple.BackgroundColor3 = currentThemeColor
    ripple.BackgroundTransparency = 0.55
    ripple.BorderSizePixel = 0
    ripple.ZIndex = 41
    Instance.new("UICorner", ripple).CornerRadius = UDim.new(1,0)

    local rippleStroke = Instance.new("UIStroke")
    rippleStroke.Parent = ripple
    rippleStroke.Color = currentThemeColor
    rippleStroke.Thickness = 1
    rippleStroke.Transparency = 0.35

    TweenService:Create(ripple, TweenInfo.new(0.18), {Size = UDim2.new(0, 14, 0, 14), BackgroundTransparency = 1}):Play()
    TweenService:Create(rippleStroke, TweenInfo.new(0.18), {Transparency = 1}):Play()

    task.delay(0.2, function() if ripple then ripple:Destroy() end end)
end

local function createTrail(fromPos, toPos)
    if not menuVisible then return end
    local delta = toPos - fromPos
    local dist = delta.Magnitude
    if dist < 4 then return end

    local trail = Instance.new("Frame")
    trail.Parent = mouseFxLayer
    trail.AnchorPoint = Vector2.new(0, 0.5)
    trail.Position = UDim2.new(0, fromPos.X, 0, fromPos.Y)
    trail.Size = UDim2.new(0, dist, 0, 2)
    trail.BackgroundColor3 = currentThemeColor
    trail.BackgroundTransparency = 0.4
    trail.BorderSizePixel = 0
    trail.Rotation = math.deg(math.atan2(delta.Y, delta.X))
    trail.ZIndex = 42
    Instance.new("UICorner", trail).CornerRadius = UDim.new(1,0)

    local gradTrail = Instance.new("UIGradient")
    gradTrail.Parent = trail
    gradTrail.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, currentThemeColor), ColorSequenceKeypoint.new(1, currentThemeColor)})
    gradTrail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(0.45, 0.35), NumberSequenceKeypoint.new(1, 1)})

    table.insert(activeTrails, trail)
    if #activeTrails > maxTrails then
        local oldest = table.remove(activeTrails, 1)
        if oldest then oldest:Destroy() end
    end

    TweenService:Create(trail, TweenInfo.new(0.14), {BackgroundTransparency = 1, Size = UDim2.new(0, math.max(0, dist - 8), 0, 1)}):Play()
    task.delay(0.16, function() if trail then trail:Destroy() end end)
end

main.MouseEnter:Connect(function()
    mouseInsideMain = true
    lastMousePos = nil
end)

main.MouseLeave:Connect(function()
    mouseInsideMain = false
    lastMousePos = nil
end)

UIS.InputChanged:Connect(function(input)
    if not menuVisible then return end
    if not mouseInsideMain then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

    local now = tick()
    if now - lastFxTime < fxThrottle then return end
    lastFxTime = now

    local absPos = main.AbsolutePosition
    local rel = Vector2.new(input.Position.X - absPos.X, input.Position.Y - absPos.Y)

    if rel.X < 0 or rel.Y < 0 or rel.X > main.AbsoluteSize.X or rel.Y > main.AbsoluteSize.Y then return end

    if lastMousePos then createTrail(lastMousePos, rel) end
    createMouseRipple(rel.X, rel.Y)
    createSparkBurst(rel.X, rel.Y)
    lastMousePos = rel
end)

local function applyThemeByIndex(index)
    if index < 1 then index = #themeOrder elseif index > #themeOrder then index = 1 end

    currentThemeIndex = index
    local themeName = themeOrder[currentThemeIndex]
    local t = themes[themeName]
    currentThemeColor = t.stroke

    TweenService:Create(stroke, TweenInfo.new(0.22), {Color = t.stroke}):Play()
    TweenService:Create(innerStroke, TweenInfo.new(0.22), {Color = t.inner}):Play()
    TweenService:Create(main, TweenInfo.new(0.22), {BackgroundColor3 = t.g2}):Play()
    TweenService:Create(sidePanel, TweenInfo.new(0.22), {BackgroundColor3 = t.g2}):Play()

    setSequence(grad, t)
    setSequence(sideGrad, t)
    setSequence(themeSwitchGradient, t)

    TweenService:Create(brandImage1, TweenInfo.new(0.25), {ImageColor3 = t.stroke}):Play()
    TweenService:Create(centerBrandImage, TweenInfo.new(0.25), {ImageColor3 = t.stroke}):Play()
    TweenService:Create(brandImage2, TweenInfo.new(0.25), {ImageColor3 = t.stroke}):Play()

    themeText.Text = themeName
    themeDot.BackgroundColor3 = t.stroke

    for _, obj in ipairs(themeableStrokes) do
        if obj and obj.Parent then TweenService:Create(obj, TweenInfo.new(0.22), {Color = t.stroke}):Play() end
    end

    for _, obj in ipairs(themeableFills) do
        if obj and obj.Parent and obj:IsA("Frame") then TweenService:Create(obj, TweenInfo.new(0.22), {BackgroundColor3 = t.stroke}):Play() end
    end

    for _, obj in ipairs(themeableGlows) do
        if obj and obj.Parent then TweenService:Create(obj, TweenInfo.new(0.22), {Color = t.stroke}):Play() end
    end

    TweenService:Create(sideInnerStroke, TweenInfo.new(0.22), {Color = t.inner}):Play()

    if refreshActivePreviewBindings then task.defer(refreshActivePreviewBindings) end
    refreshAllESP()
end

local function nextTheme()
    applyThemeByIndex(currentThemeIndex + 1)
end

local function prevTheme()
    applyThemeByIndex(currentThemeIndex - 1)
end

themeSwitch.MouseButton1Click:Connect(nextTheme)

themeSwitch.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        if input.Position.Z > 0 then nextTheme() elseif input.Position.Z < 0 then prevTheme() end
    end
end)

-- Animasyonlar (tamamı aynı)
task.spawn(function()
    while gui.Parent do
        if menuVisible and lines.Parent and main.Parent then
            lines.Position = UDim2.new(0,0,-1,0)
            TweenService:Create(lines, TweenInfo.new(4.8, Enum.EasingStyle.Linear), {Position = UDim2.new(0,0,0,0)}):Play()
            task.wait(4.8)
        else
            task.wait(0.25)
        end
    end
end)

task.spawn(function()
    while gui.Parent do
        if menuVisible and sideLines.Parent and sidePanel.Parent then
            sideLines.Position = UDim2.new(0,0,-1,0)
            TweenService:Create(sideLines, TweenInfo.new(4.8, Enum.EasingStyle.Linear), {Position = UDim2.new(0,0,0,0)}):Play()
            task.wait(4.8)
        else
            task.wait(0.25)
        end
    end
end)

task.spawn(function()
    while gui.Parent do
        if menuVisible and stroke.Parent then
            TweenService:Create(stroke, TweenInfo.new(1.2), {Transparency = 0.22}):Play()
            task.wait(1.2)
            TweenService:Create(stroke, TweenInfo.new(1.2), {Transparency = 0.62}):Play()
            task.wait(1.2)
        else
            task.wait(0.25)
        end
    end
end)

task.spawn(function()
    while gui.Parent do
        if menuVisible and brandImage1 and centerBrandImage and brandImage2 then
            TweenService:Create(brandImage1, TweenInfo.new(0.8), {ImageTransparency = 0.35}):Play()
            TweenService:Create(centerBrandImage, TweenInfo.new(0.8), {ImageTransparency = 0.35}):Play()
            TweenService:Create(brandImage2, TweenInfo.new(0.8), {ImageTransparency = 0.35}):Play()
            task.wait(0.8)
            TweenService:Create(brandImage1, TweenInfo.new(0.8), {ImageTransparency = 0.1}):Play()
            TweenService:Create(centerBrandImage, TweenInfo.new(0.8), {ImageTransparency = 0.1}):Play()
            TweenService:Create(brandImage2, TweenInfo.new(0.8), {ImageTransparency = 0.1}):Play()
            task.wait(0.8)
        else
            task.wait(0.3)
        end
    end
end)

task.spawn(function()
    local pulseOn = false
    while gui.Parent do
        if menuVisible then
            pulseOn = not pulseOn
            for _, obj in ipairs(pulsingObjects) do
                if obj and obj.Parent then
                    TweenService:Create(obj, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                        BackgroundTransparency = pulseOn and 0.08 or 0.24
                    }):Play()
                end
            end
            task.wait(0.6)
        else
            task.wait(0.25)
        end
    end
end)

-- Drag sistemi (tamamı aynı)
local mainDragZone = Instance.new("TextButton")
mainDragZone.Parent = main
mainDragZone.Name = "MainDragZone"
mainDragZone.Size = UDim2.new(1, -170, 0, 44)
mainDragZone.Position = UDim2.new(0, 72, 0, 8)
mainDragZone.BackgroundTransparency = 1
mainDragZone.Text = ""
mainDragZone.AutoButtonColor = false
mainDragZone.ZIndex = 30

local sideDragZone = Instance.new("TextButton")
sideDragZone.Parent = sidePanel
sideDragZone.Name = "SideDragZone"
sideDragZone.Size = UDim2.new(1, 0, 0, 40)
sideDragZone.Position = UDim2.new(0, 0, 0, 0)
sideDragZone.BackgroundTransparency = 1
sideDragZone.Text = ""
sideDragZone.AutoButtonColor = false
sideDragZone.ZIndex = 30

local dragging = false
local dragStart
local currentDragMousePos
local startPosMain
local startPosSide
local startPosBrand
local startPosSideBrand

local function startDrag(input)
    dragging = true
    dragStart = input.Position
    currentDragMousePos = input.Position
    startPosMain = main.Position
    startPosSide = sidePanel.Position
    startPosBrand = topBrand.Position
    startPosSideBrand = sideBrand.Position
end

mainDragZone.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then startDrag(input) end
end)

sideDragZone.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then startDrag(input) end
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then currentDragMousePos = input.Position end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
        dragStart = nil
        currentDragMousePos = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragStart and currentDragMousePos then
        local delta = currentDragMousePos - dragStart

        main.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
        sidePanel.Position = UDim2.new(startPosSide.X.Scale, startPosSide.X.Offset + delta.X, startPosSide.Y.Scale, startPosSide.Y.Offset + delta.Y)
        topBrand.Position = UDim2.new(startPosBrand.X.Scale, startPosBrand.X.Offset + delta.X, startPosBrand.Y.Scale, startPosBrand.Y.Offset + delta.Y)
        sideBrand.Position = UDim2.new(startPosSideBrand.X.Scale, startPosSideBrand.X.Offset + delta.X, startPosSideBrand.Y.Scale, startPosSideBrand.Y.Offset + delta.Y)
    end
end)

local function setMenuVisible(state)
    menuVisible = state
    main.Visible = state
    sidePanel.Visible = state
    topBrand.Visible = state
    sideBrand.Visible = state

    mouseInsideMain = false
    lastMousePos = nil
    dragging = false
    dragStart = nil
    currentDragMousePos = nil

    if state then
        TweenService:Create(blur, TweenInfo.new(0.18), {Size = 12}):Play()
    else
        TweenService:Create(blur, TweenInfo.new(0.18), {Size = 0}):Play()
        for i = 1, #activeTrails do
            if activeTrails[i] then activeTrails[i]:Destroy() end
        end
        table.clear(activeTrails)
    end
end


applyThemeByIndex(currentThemeIndex)
setActiveTab(1)
refreshConfigDropdown()
applyLoadedState(serializeState())



-- ================= LIVE COUNTER (SOL ÜST) =================

task.spawn(function()

    local requestFn =
        (syn and syn.request)
        or (http and http.request)
        or http_request
        or request

    local LIVE_ENDPOINT = "https://mylflive.bythekyol.workers.dev"

    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = Players.LocalPlayer

    local function getHWID()
        local ok, id = pcall(function()
            if gethwid then
                return gethwid()
            elseif syn and syn.get_hwid then
                return syn.get_hwid()
            else
                return game:GetService("RbxAnalyticsService"):GetClientId()
            end
        end)

        return ok and id or ("unknown_" .. math.random(1111,9999))
    end

    local HWID = getHWID()

    local liveHolder = Instance.new("Frame")
    liveHolder.Parent = main
    liveHolder.Name = "LiveCounter"
    liveHolder.Position = UDim2.new(0, 13, 0, 13)
    liveHolder.Size = UDim2.new(0, 118, 0, 24)
    liveHolder.BackgroundColor3 = currentThemeColor
    liveHolder.BackgroundTransparency = 0.93
    liveHolder.BorderSizePixel = 0
    liveHolder.ZIndex = 30
    Instance.new("UICorner", liveHolder).CornerRadius = UDim.new(0,8)
    addThemeFill(liveHolder)

    local liveStroke = Instance.new("UIStroke")
    liveStroke.Parent = liveHolder
    liveStroke.Color = currentThemeColor
    liveStroke.Thickness = 1
    liveStroke.Transparency = 0.18
    addThemeStroke(liveStroke)

    local pulseDot = Instance.new("Frame")
    pulseDot.Parent = liveHolder
    pulseDot.Position = UDim2.new(0, 8, 0.5, -4)
    pulseDot.Size = UDim2.new(0, 8, 0, 8)
    pulseDot.BackgroundColor3 = currentThemeColor
    pulseDot.BorderSizePixel = 0
    pulseDot.ZIndex = 31
    Instance.new("UICorner", pulseDot).CornerRadius = UDim.new(1,0)
    addThemeFill(pulseDot)

    local liveText = Instance.new("TextLabel")
    liveText.Parent = liveHolder
    liveText.BackgroundTransparency = 1
    liveText.Position = UDim2.new(0, 22, 0, 0)
    liveText.Size = UDim2.new(1, -26, 1, 0)
    liveText.Text = "LIVE : ..."
    liveText.TextColor3 = Color3.fromRGB(255,255,255)
    liveText.TextSize = 11
    liveText.Font = Enum.Font.GothamBold
    liveText.TextXAlignment = Enum.TextXAlignment.Left
    liveText.ZIndex = 31

    -- Kendini sisteme ekle
    local function sendHeartbeat()
        if not requestFn then return end

        pcall(function()
            requestFn({
                Url = LIVE_ENDPOINT .. "/heartbeat",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode({
                    hwid = HWID,
                    username = LocalPlayer and LocalPlayer.Name or "Unknown"
                })
            })
        end)
    end

    -- Sayıyı çek
    local function fetchLive()
        if not requestFn then
            liveText.Text = "LIVE : N/A"
            return
        end

        local ok, res = pcall(function()
            return requestFn({
                Url = LIVE_ENDPOINT .. "/active",
                Method = "GET",
                Headers = {
                    ["Content-Type"] = "application/json"
                }
            })
        end)

        if not ok or not res or not res.Body then
            liveText.Text = "LIVE : OFF"
            return
        end

        local success, data = pcall(function()
            return HttpService:JSONDecode(res.Body)
        end)

        if success and data and data.active then
            liveText.Text = "LIVE : " .. tostring(data.active)
        else
            liveText.Text = "LIVE : 0"
        end
    end

    -- pulse anim
    task.spawn(function()
        while liveHolder.Parent do
            TweenService:Create(pulseDot, TweenInfo.new(0.7), {
                Size = UDim2.new(0,12,0,12),
                Position = UDim2.new(0,6,0.5,-6),
                BackgroundTransparency = 0.15
            }):Play()

            task.wait(0.7)

            TweenService:Create(pulseDot, TweenInfo.new(0.7), {
                Size = UDim2.new(0,8,0,8),
                Position = UDim2.new(0,8,0.5,-4),
                BackgroundTransparency = 0
            }):Play()

            task.wait(0.7)
        end
    end)

    -- Menü açılınca hemen bağlan
    sendHeartbeat()
    fetchLive()

    -- sürekli yenile
    while liveHolder.Parent do
        sendHeartbeat()
        fetchLive()
        task.wait(5)
    end

end)
