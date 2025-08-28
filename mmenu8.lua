--// MYLF Ultra UI Library - Single File
--// Usage:
--//   local Library = loadstring(game:HttpGet("YOUR_URL/MYLF_UltraLib.lua"))()
--//   -- or local Library = (function() <paste this file> end)()
--//   local win = Library:CreateWindow({ Title = "⚡ MYLF | Ultra", Keybind = Enum.KeyCode.RightShift })

local Library = {}
Library.__index = Library

--== Services ==--
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local Stats              = game:GetService("Stats")
local CoreGui            = game:GetService("CoreGui")
local StarterGui         = game:GetService("StarterGui")

local LP = Players.LocalPlayer

--== Defaults ==--
local HUD_INTERVAL = 0.1 -- 100ms
local HUGE_ORDER   = 999999999 -- büyük DisplayOrder
local FONT_TITLE   = Enum.Font.GothamSemibold
local FONT_TEXT    = Enum.Font.Gotham

--== Theme Engine ==--
local Themes = {
  ["Dark-Red"] = {
    Bg       = Color3.fromRGB(16,16,18),
    Panel    = Color3.fromRGB(24,24,28),
    Accent   = Color3.fromRGB(230,57,70),
    Text     = Color3.fromRGB(235,235,240),
    SubText  = Color3.fromRGB(170,170,180),
    Hover    = Color3.fromRGB(34,34,38),
    Stroke   = Color3.fromRGB(255,255,255),
    Shadow   = Color3.fromRGB(0,0,0),
  },
  ["Neo-Purple"] = {
    Bg       = Color3.fromRGB(14,12,22),
    Panel    = Color3.fromRGB(26,22,45),
    Accent   = Color3.fromRGB(153,102,255),
    Text     = Color3.fromRGB(240,240,248),
    SubText  = Color3.fromRGB(180,175,200),
    Hover    = Color3.fromRGB(40,35,62),
    Stroke   = Color3.fromRGB(255,255,255),
    Shadow   = Color3.fromRGB(0,0,0),
  },
  ["Midnight"] = {
    Bg       = Color3.fromRGB(10,12,16),
    Panel    = Color3.fromRGB(20,24,30),
    Accent   = Color3.fromRGB(0,180,216),
    Text     = Color3.fromRGB(230,235,240),
    SubText  = Color3.fromRGB(165,175,185),
    Hover    = Color3.fromRGB(28,32,40),
    Stroke   = Color3.fromRGB(255,255,255),
    Shadow   = Color3.fromRGB(0,0,0),
  },
}
local CurrentTheme = Themes["Dark-Red"]

--== Helpers ==--
local function corner(inst, r)
  local c = Instance.new("UICorner")
  c.CornerRadius = UDim.new(0, r or 8)
  c.Parent = inst
  return c
end

local function stroke(inst, t, tr)
  local s = Instance.new("UIStroke")
  s.Thickness = t or 1
  s.Transparency = tr or 0.1
  s.Color = CurrentTheme.Stroke
  s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  s.Parent = inst
  return s
end

local function padding(inst, px)
  local p = Instance.new("UIPadding")
  p.PaddingTop = UDim.new(0, px)
  p.PaddingBottom = UDim.new(0, px)
  p.PaddingLeft = UDim.new(0, px)
  p.PaddingRight = UDim.new(0, px)
  p.Parent = inst
  return p
end

local function vlist(parent, pad)
  local lay = Instance.new("UIListLayout")
  lay.SortOrder = Enum.SortOrder.LayoutOrder
  lay.Padding = UDim.new(0, pad or 6)
  lay.Parent = parent
  return lay
end

--== Base ScreenGui ==--
local function createRoot()
  local gui = Instance.new("ScreenGui")
  gui.Name = "MYLF_UltraLib"
  gui.IgnoreGuiInset = true
  gui.ResetOnSpawn = false
  gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
  gui.DisplayOrder = HUGE_ORDER
  pcall(function() gui.Parent = CoreGui end)
  return gui
end

--== Window / Tabs / Page system ==--
function Library:CreateWindow(opts)
  opts = opts or {}
  local TitleText = opts.Title or "⚡ MYLF | Ultra"
  local ToggleKey = opts.Keybind or Enum.KeyCode.RightShift

  local gui = createRoot()

  -- Main window
  local Window = Instance.new("Frame", gui)
  Window.Name = "Window"
  Window.Size = UDim2.new(0, 820, 0, 520)
  Window.Position = UDim2.new(0.12, 0, 0.18, 0)
  Window.BackgroundColor3 = CurrentTheme.Panel
  corner(Window, 12); stroke(Window, 1, 0.14); padding(Window, 8)

  -- Soft shadow
  local Shadow = Instance.new("ImageLabel", Window)
  Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
  Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
  Shadow.Size = UDim2.new(1, 48, 1, 48)
  Shadow.BackgroundTransparency = 1
  Shadow.Image = "rbxassetid://5028857084"
  Shadow.ImageTransparency = 0.55
  Shadow.ImageColor3 = CurrentTheme.Shadow
  Shadow.ZIndex = 0

  -- TitleBar (drag only here)
  local TitleBar = Instance.new("Frame", Window)
  TitleBar.Name = "TitleBar"
  TitleBar.Size = UDim2.new(1, -16, 0, 48)
  TitleBar.Position = UDim2.new(0, 8, 0, 8)
  TitleBar.BackgroundColor3 = CurrentTheme.Bg
  corner(TitleBar, 10); stroke(TitleBar, 1, 0.18); padding(TitleBar, 10)

  local Title = Instance.new("TextLabel", TitleBar)
  Title.BackgroundTransparency = 1
  Title.Text = TitleText
  Title.Font = FONT_TITLE
  Title.TextSize = 17
  Title.TextColor3 = CurrentTheme.Text
  Title.TextXAlignment = Enum.TextXAlignment.Left
  Title.Size = UDim2.new(1, -160, 1, -10)
  Title.Position = UDim2.new(0, 10, 0, 5)

  -- Drag logic
  do
    local dragging, dragStart, startPos = false, nil, nil
    TitleBar.InputBegan:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging, dragStart, startPos = true, input.Position, Window.Position
      end
    end)
    TitleBar.InputEnded:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
      if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
      end
    end)
  end

  -- Tabs bar
  local Tabs = Instance.new("Frame", Window)
  Tabs.Name = "Tabs"
  Tabs.BackgroundTransparency = 1
  Tabs.Size = UDim2.new(1, -16, 0, 44)
  Tabs.Position = UDim2.new(0, 8, 0, 64)
  local tabsLayout = Instance.new("UIListLayout", Tabs)
  tabsLayout.FillDirection = Enum.FillDirection.Horizontal
  tabsLayout.Padding = UDim.new(0, 8)
  tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder

  -- Pages container
  local Pages = Instance.new("Frame", Window)
  Pages.Name = "Pages"
  Pages.BackgroundTransparency = 1
  Pages.Size = UDim2.new(1, -16, 1, -120)
  Pages.Position = UDim2.new(0, 8, 0, 112)

  -- Watermark / HUD capsule (draggable)
  local HUD = Instance.new("Frame", gui)
  HUD.Name = "HUD"
  HUD.Size = UDim2.new(0, 380, 0, 44)
  HUD.Position = UDim2.new(0.66, 0, 0.08, 0)
  HUD.BackgroundColor3 = CurrentTheme.Panel
  corner(HUD, 14); stroke(HUD, 1, 0.16); padding(HUD, 8)

  local HUDText = Instance.new("TextLabel", HUD)
  HUDText.BackgroundTransparency = 1
  HUDText.Font = FONT_TEXT
  HUDText.TextSize = 13
  HUDText.TextColor3 = CurrentTheme.Text
  HUDText.TextXAlignment = Enum.TextXAlignment.Left
  HUDText.Size = UDim2.new(1, 0, 1, -12)
  HUDText.Position = UDim2.new(0, 10, 0, 2)
  HUDText.Text = "FPS: -- | Ping: -- | CPU: -- ms | GPU: -- ms"

  local Under = Instance.new("Frame", HUD)
  Under.AnchorPoint = Vector2.new(0.5, 1)
  Under.Position = UDim2.new(0.5, 0, 1, -2)
  Under.Size = UDim2.new(1, -18, 0, 4)
  Under.BackgroundColor3 = Color3.fromRGB(255,255,255)
  corner(Under, 4)
  local grad = Instance.new("UIGradient", Under)
  grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0.00,1,1)),
    ColorSequenceKeypoint.new(0.20, Color3.fromHSV(0.20,1,1)),
    ColorSequenceKeypoint.new(0.40, Color3.fromHSV(0.40,1,1)),
    ColorSequenceKeypoint.new(0.60, Color3.fromHSV(0.60,1,1)),
    ColorSequenceKeypoint.new(0.80, Color3.fromHSV(0.80,1,1)),
    ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1.00,1,1)),
  }

  -- HUD drag
  do
    local dragging, dragStart, startPos = false, nil, nil
    HUD.InputBegan:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging, dragStart, startPos = true, input.Position, HUD.Position
      end
    end)
    HUD.InputEnded:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
      if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        HUD.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
      end
    end)
  end

  -- HUD updater (FPS/Ping/CPU/GPU)
  do
    local acc, frames = 0, 0
    local pingSamples = {}
    local maxSamples = 50
    local function addPingSample(ms)
      pingSamples[#pingSamples+1] = ms
      if #pingSamples > maxSamples then
        table.remove(pingSamples, 1)
      end
    end
    local function statMeanCV(t)
      if #t == 0 then return 0, 0 end
      local s = 0
      for _,v in ipairs(t) do s += v end
      local mean = s / #t
      local var = 0
      for _,v in ipairs(t) do var += (v-mean)*(v-mean) end
      var = var / #t
      local sd = math.sqrt(var)
      local cv = (mean ~= 0) and (sd/mean*100) or 0
      return mean, cv
    end

    RunService.RenderStepped:Connect(function(dt)
      -- animate rainbow
      grad.Rotation = (grad.Rotation + 80*dt) % 360

      acc += dt; frames += 1
      if acc >= HUD_INTERVAL then
        local fps = math.max(1, math.floor(frames / acc + 0.5))
        local framems = (acc / frames) * 1000
        frames, acc = 0, 0

        -- Ping (Stats-based, safe)
        local pingMs = nil
        pcall(function()
          local net = Stats and Stats.Network
          local item = net and net.ServerStatsItem and net.ServerStatsItem["Data Ping"]
          if item then
            local v = item:GetValue()
            if typeof(v) == "number" then pingMs = v end
          end
        end)
        pingMs = pingMs or 0
        addPingSample(pingMs)
        local meanPing, cvPing = statMeanCV(pingSamples)

        -- CPU/GPU proxies (Roblox gerçek CPU/GPU yüzdesi vermez)
        local cpuMs = framems
        local gpuMs = framems

        HUDText.Text = string.format("FPS: %d | Ping: %.1f (%.0f%%CV) | CPU: %.1f ms | GPU: %.1f ms",
          fps, meanPing, cvPing, cpuMs, gpuMs)
      end
    end)
  end

  -- Tabs API
  local WindowApi = {}
  WindowApi.__index = WindowApi

  function WindowApi:AddTab(name)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = Tabs
    btn.Text = name
    btn.AutoButtonColor = false
    btn.Size = UDim2.new(0, 120, 1, 0)
    btn.BackgroundColor3 = CurrentTheme.Panel
    btn.TextColor3 = CurrentTheme.Text
    btn.Font = FONT_TITLE
    btn.TextSize = 14
    corner(btn, 10); stroke(btn, 1, 0.12)

    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = CurrentTheme.Hover end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = CurrentTheme.Panel end)

    local page = Instance.new("Frame", Pages)
    page.Name = name .. "_Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = false
    page.BackgroundColor3 = CurrentTheme.Panel
    corner(page, 10); stroke(page, 1, 0.08); padding(page, 10)

    -- content grid (2 sütun)
    local content = Instance.new("Frame", page)
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, 0, 1, 0)
    local grid = Instance.new("UIGridLayout", content)
    grid.CellPadding = UDim2.new(0, 10, 0, 10)
    grid.CellSize = UDim2.new(0.5, -8, 0, 220)
    grid.SortOrder = Enum.SortOrder.LayoutOrder

    btn.MouseButton1Click:Connect(function()
      for _, p in ipairs(Pages:GetChildren()) do
        if p:IsA("Frame") then p.Visible = false end
      end
      page.Visible = true
    end)

    local TabApi = {}
    TabApi.__index = TabApi

    function TabApi:AddGroupbox(title)
      local gb = Instance.new("Frame", content)
      gb.BackgroundColor3 = CurrentTheme.Bg
      corner(gb, 10); stroke(gb, 1, 0.12); padding(gb, 10)

      local header = Instance.new("TextLabel", gb)
      header.BackgroundTransparency = 1
      header.Text = title
      header.Font = FONT_TITLE
      header.TextSize = 14
      header.TextColor3 = CurrentTheme.Text
      header.TextXAlignment = Enum.TextXAlignment.Left
      header.Size = UDim2.new(1, 0, 0, 20)

      local body = Instance.new("Frame", gb)
      body.BackgroundTransparency = 1
      body.Position = UDim2.new(0, 0, 0, 26)
      body.Size = UDim2.new(1, 0, 1, -32)
      vlist(body, 8)

      local GroupApi = {}
      GroupApi.__index = GroupApi

      function GroupApi:AddToggle(id, cfg)
        cfg = cfg or {}
        local text, default, callback = cfg.Text or id, cfg.Default or false, cfg.Callback
        local row = Instance.new("Frame", body)
        row.Size = UDim2.new(1, 0, 0, 36)
        row.BackgroundColor3 = CurrentTheme.Panel
        corner(row, 8); stroke(row, 1, 0.08); padding(row, 8)

        local lbl = Instance.new("TextLabel", row)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = FONT_TEXT
        lbl.TextSize = 13
        lbl.TextColor3 = CurrentTheme.Text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size = UDim2.new(1, -64, 1, 0)

        local btn = Instance.new("TextButton", row)
        btn.AutoButtonColor = false
        btn.Size = UDim2.new(0, 48, 0, 22)
        btn.Position = UDim2.new(1, -56, 0.5, -11)
        btn.Text = ""
        btn.BackgroundColor3 = Color3.fromRGB(60,60,68)
        corner(btn, 11); stroke(btn, 1, 0.12)

        local knob = Instance.new("Frame", btn)
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = UDim2.new(0, 2, 0.5, -9)
        knob.BackgroundColor3 = CurrentTheme.Text
        corner(knob, 9)

        local state = default and true or false
        local function redraw()
          if state then
            btn.BackgroundColor3 = CurrentTheme.Accent
            knob:TweenPosition(UDim2.new(1, -20, 0.5, -9), "Out", "Quad", 0.12, true)
          else
            btn.BackgroundColor3 = Color3.fromRGB(60,60,68)
            knob:TweenPosition(UDim2.new(0, 2, 0.5, -9), "Out", "Quad", 0.12, true)
          end
        end
        redraw()

        btn.MouseButton1Click:Connect(function()
          state = not state
          redraw()
          if callback then
            local ok, err = pcall(callback, state)
            if not ok then warn("Toggle("..id..") cb:", err) end
          end
        end)

        return {
          Set = function(v) state=v; redraw() end,
          Get = function() return state end,
        }
      end

      function GroupApi:AddSlider(id, cfg)
        cfg = cfg or {}
        local text = cfg.Text or id
        local min, max = cfg.Min or 0, cfg.Max or 100
        local default = cfg.Default or min
        local rounding = cfg.Rounding or 0
        local callback = cfg.Callback

        local row = Instance.new("Frame", body)
        row.Size = UDim2.new(1, 0, 0, 52)
        row.BackgroundColor3 = CurrentTheme.Panel
        corner(row, 8); stroke(row, 1, 0.08); padding(row, 10)

        local lbl = Instance.new("TextLabel", row)
        lbl.BackgroundTransparency = 1
        lbl.Text = string.format("%s (%.2f)", text, default)
        lbl.Font = FONT_TEXT
        lbl.TextSize = 13
        lbl.TextColor3 = CurrentTheme.Text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size = UDim2.new(1, 0, 0, 18)

        local bar = Instance.new("Frame", row)
        bar.Size = UDim2.new(1, -20, 0, 10)
        bar.Position = UDim2.new(0, 10, 0, 26)
        bar.BackgroundColor3 = Color3.fromRGB(60,60,68)
        corner(bar, 6); stroke(bar, 1, 0.1)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = CurrentTheme.Accent
        corner(fill, 6)

        local dragging = false
        local value = default

        local function setFromX(x)
          local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1)
          value = min + (max - min) * rel
          if rounding and rounding > 0 then
            local m = 10 ^ rounding
            value = math.floor(value * m + 0.5) / m
          end
          fill.Size = UDim2.new(rel, 0, 1, 0)
          lbl.Text = string.format("%s (%.2f)", text, value)
          if callback then
            local ok, err = pcall(callback, value)
            if not ok then warn("Slider("..id..") cb:", err) end
          end
        end

        bar.InputBegan:Connect(function(input)
          if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setFromX(input.Position.X)
          end
        end)
        bar.InputEnded:Connect(function(input)
          if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
          if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromX(input.Position.X)
          end
        end)

        return {
          Set = function(v)
            v = math.clamp(v, min, max)
            value = v
            local rel = (v - min) / (max - min)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            lbl.Text = string.format("%s (%.2f)", text, value)
          end,
          Get = function() return value end,
        }
      end

      function GroupApi:AddInput(id, cfg)
        cfg = cfg or {}
        local text = cfg.Text or id
        local default = cfg.Default or ""
        local placeholder = cfg.Placeholder or ""
        local callback = cfg.Callback

        local row = Instance.new("Frame", body)
        row.Size = UDim2.new(1, 0, 0, 42)
        row.BackgroundColor3 = CurrentTheme.Panel
        corner(row, 8); stroke(row, 1, 0.08); padding(row, 8)

        local box = Instance.new("TextBox", row)
        box.Size = UDim2.new(1, -10, 1, -0)
        box.Text = default
        box.PlaceholderText = placeholder ~= "" and placeholder or text
        box.Font = FONT_TEXT
        box.TextSize = 13
        box.TextColor3 = CurrentTheme.Text
        box.BackgroundColor3 = CurrentTheme.Bg
        corner(box, 8); stroke(box, 1, 0.1)

        box.FocusLost:Connect(function()
          if callback then
            local ok, err = pcall(callback, box.Text)
            if not ok then warn("Input("..id..") cb:", err) end
          end
        end)

        return box
      end

      function GroupApi:AddDropdown(id, cfg)
        cfg = cfg or {}
        local text = cfg.Text or id
        local values = cfg.Values or {}
        local default = cfg.Default
        local callback = cfg.Callback

        local row = Instance.new("Frame", body)
        row.Size = UDim2.new(1, 0, 0, 42)
        row.BackgroundColor3 = CurrentTheme.Panel
        corner(row, 8); stroke(row, 1, 0.08); padding(row, 8)

        local btn = Instance.new("TextButton", row)
        btn.AutoButtonColor = false
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.Text = default and (text..": "..tostring(default)) or (text.." ▼")
        btn.Font = FONT_TEXT; btn.TextSize = 13; btn.TextColor3 = CurrentTheme.Text
        btn.BackgroundColor3 = CurrentTheme.Bg
        corner(btn, 8); stroke(btn, 1, 0.1)

        local current = default

        btn.MouseButton1Click:Connect(function()
          local idx = table.find(values, current) or 0
          idx = idx + 1
          if idx > #values then idx = 1 end
          current = values[idx]
          btn.Text = text..": "..tostring(current)
          if callback then
            local ok, err = pcall(callback, current)
            if not ok then warn("Dropdown("..id..") cb:", err) end
          end
        end)

        return {
          Set = function(v) current = v; btn.Text = text..": "..tostring(current) end,
          Get = function() return current end,
        }
      end

      function GroupApi:AddButton(text, callback)
        local b = Instance.new("TextButton", body)
        b.AutoButtonColor = false
        b.Size = UDim2.new(1, 0, 0, 36)
        b.Text = text
        b.Font = FONT_TITLE
        b.TextSize = 14
        b.TextColor3 = CurrentTheme.Text
        b.BackgroundColor3 = CurrentTheme.Panel
        corner(b, 8); stroke(b, 1, 0.08)

        b.MouseEnter:Connect(function() b.BackgroundColor3 = CurrentTheme.Hover end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = CurrentTheme.Panel end)
        b.MouseButton1Click:Connect(function()
          if callback then
            local ok, err = pcall(callback)
            if not ok then warn("Button('"..text.."') cb:", err) end
          end
        end)
        return b
      end

      return setmetatable({}, {
        __index = GroupApi
      })
    end

    -- auto-select first tab
    if #Pages:GetChildren() == 1 then page.Visible = true end

    return setmetatable({}, { __index = TabApi })
  end

  -- Visibility keybind
  local visible = true
  local function setVisible(v)
    visible = v
    Window.Visible = v
  end
  setVisible(true)

  UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == ToggleKey then
      setVisible(not visible)
    end
  end)

  -- Public API
  local api = {}
  function api:SetTheme(nameOrTable)
    if typeof(nameOrTable) == "string" and Themes[nameOrTable] then
      CurrentTheme = Themes[nameOrTable]
    elseif typeof(nameOrTable) == "table" then
      CurrentTheme = nameOrTable
    end
    -- quick recolor
    Window.BackgroundColor3 = CurrentTheme.Panel
    TitleBar.BackgroundColor3 = CurrentTheme.Bg
    Title.TextColor3 = CurrentTheme.Text
    HUD.BackgroundColor3 = CurrentTheme.Panel
    HUDText.TextColor3 = CurrentTheme.Text
  end

  function api:GetHUD() return HUD, HUDText end
  function api:SetKeybind(keycode) ToggleKey = keycode end
  function api:AddTab(name) return self:AddTab(name) end -- syntactic sugar
  setmetatable(api, { __index = WindowApi })

  -- Try to stay on top of ESC
  pcall(function() StarterGui:SetCore("TopbarEnabled", true) end)

  return api
end

return setmetatable({}, Library)
