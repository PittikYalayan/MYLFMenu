--// MYLF OneFile UI Library (Linoria-Compatible) — v1.0
--// Exposes: Library, ThemeManager, SaveManager, Options (global)
--// Single-file. Works with your loader without changes.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

-- ===============================
-- Internal: Theme & Utility
-- ===============================
local Theme = {
  Accent     = Color3.fromRGB(230, 57, 70),
  Background = Color3.fromRGB(16,16,18),
  Dark       = Color3.fromRGB(24,24,28),
  Outline    = Color3.fromRGB(255,255,255),
  Text       = Color3.fromRGB(235,235,240),
  SubText    = Color3.fromRGB(170,170,180),
  Hover      = Color3.fromRGB(34,34,38),
  Shadow     = Color3.fromRGB(0,0,0),
}

local function new(inst, props)
  local o = Instance.new(inst)
  for k,v in pairs(props or {}) do o[k]=v end
  return o
end
local function corner(p, r) local c=new("UICorner",{CornerRadius=UDim.new(0, r or 8)}); c.Parent=p; return c end
local function stroke(p, t, tr, col)
  local s=new("UIStroke", {Thickness=t or 1, Transparency=tr or 0.1, Color=col or Theme.Outline, ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
  s.Parent=p; return s
end
local function pad(p, px)
  local x=new("UIPadding", {PaddingTop=UDim.new(0,px),PaddingBottom=UDim.new(0,px),PaddingLeft=UDim.new(0,px),PaddingRight=UDim.new(0,px)})
  x.Parent=p; return x
end
local function vlist(parent, gap)
  local l=new("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0, gap or 6)})
  l.Parent=parent; return l
end

-- ===============================
-- Signals (for OnChanged)
-- ===============================
local function Signal()
  local bind = {}
  function bind:Connect(fn) table.insert(self, fn); return {Disconnect=function() for i,f in ipairs(bind) do if f==fn then table.remove(bind,i) break end end end} end
  function bind:Fire(...) for _,f in ipairs(self) do pcall(f, ...) end end
  return bind
end

-- ===============================
-- Options registry (Linoria-like)
-- ===============================
getgenv().Options = getgenv().Options or {}
local Options = getgenv().Options

local function mkOption(flag, default)
  local opt = Options[flag]
  if opt then return opt end
  opt = {
    Value = default,
    _sig  = Signal(),
    OnChanged = function(self, cb) return self._sig:Connect(cb) end,
    SetValue  = function(self, v) self.Value=v; self._sig:Fire(v) end
  }
  Options[flag] = opt
  return opt
end

-- ===============================
-- Library (Window/Tab/Group/Controls)
-- ===============================
local Library = {}
Library.__index=Library

local function applyThemeTo(x)
  -- recolor a few known nodes
  if x:IsA("TextLabel") or x:IsA("TextButton") then
    x.TextColor3 = Theme.Text
  end
end

function Library:SetTheme(nameOrTbl)
  if typeof(nameOrTbl)=="table" then for k,v in pairs(nameOrTbl) do Theme[k]=v end end
  -- light recolor pass
  for _,gui in ipairs(CoreGui:GetChildren()) do
    if gui.Name=="MYLF_ONEFILE" then
      for _,inst in ipairs(gui:GetDescendants()) do pcall(applyThemeTo, inst) end
    end
  end
end

local function createRoot()
  local sg=new("ScreenGui", {
    Name="MYLF_ONEFILE", IgnoreGuiInset=true, ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Global, DisplayOrder=999999999
  })
  pcall(function() sg.Parent=CoreGui end)
  return sg
end

-- Control constructors
local Controls = {}

function Controls.Toggle(parent, flag, cfg)
  cfg=cfg or {}; local text=cfg.Text or flag; local default=cfg.Default or false
  local opt = mkOption(flag, default)

  local row=new("Frame",{Parent=parent, Size=UDim2.new(1,0,0,36), BackgroundColor3=Theme.Dark}); corner(row,8); stroke(row,1,0.08); pad(row,8)
  local lbl=new("TextLabel",{Parent=row, BackgroundTransparency=1, Text=text, Font=Enum.Font.Gotham, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Size=UDim2.new(1,-64,1,0), TextColor3=Theme.Text})

  local btn=new("TextButton",{Parent=row, AutoButtonColor=false, Size=UDim2.new(0,48,0,22), Position=UDim2.new(1,-56,0.5,-11), Text="", BackgroundColor3=Color3.fromRGB(60,60,68)}); corner(btn,11); stroke(btn,1,0.12)
  local knob=new("Frame",{Parent=btn, Size=UDim2.new(0,18,0,18), Position=UDim2.new(0,2,0.5,-9), BackgroundColor3=Theme.Text}); corner(knob,9)

  local function redraw(v)
    if v then
      btn.BackgroundColor3 = Theme.Accent
      knob:TweenPosition(UDim2.new(1,-20,0.5,-9), "Out","Quad", .12, true)
    else
      btn.BackgroundColor3 = Color3.fromRGB(60,60,68)
      knob:TweenPosition(UDim2.new(0,2,0.5,-9), "Out","Quad", .12, true)
    end
  end
  redraw(opt.Value)

  btn.MouseButton1Click:Connect(function()
    opt:SetValue(not opt.Value)
    redraw(opt.Value)
  end)

  return opt
end

function Controls.Slider(parent, flag, cfg)
  cfg=cfg or {}; local text=cfg.Text or flag; local min, max = cfg.Min or 0, cfg.Max or 100
  local default=cfg.Default or min; local rounding=cfg.Rounding or 0
  local opt=mkOption(flag, default)

  local row=new("Frame",{Parent=parent, Size=UDim2.new(1,0,0,52), BackgroundColor3=Theme.Dark}); corner(row,8); stroke(row,1,0.08); pad(row,10)
  local lbl=new("TextLabel",{Parent=row, BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Size=UDim2.new(1,0,0,18), TextColor3=Theme.Text})
  local bar=new("Frame",{Parent=row, Size=UDim2.new(1,-20,0,10), Position=UDim2.new(0,10,0,26), BackgroundColor3=Color3.fromRGB(60,60,68)}); corner(bar,6); stroke(bar,1,0.1)
  local fill=new("Frame",{Parent=bar, BackgroundColor3=Theme.Accent}); corner(fill,6)

  local function setText(v) lbl.Text = string.format("%s (%.2f)", text, v) end
  local function relFromVal(v) return (v-min)/math.max(1e-9,(max-min)) end
  local function setVis(v) fill.Size = UDim2.new(relFromVal(v),0,1,0); setText(v) end

  setVis(opt.Value)

  local dragging=false
  local function setFromX(x)
    local rel=math.clamp((x - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1)
    local v = min + (max-min)*rel
    if rounding>0 then local m=10^rounding; v=math.floor(v*m+0.5)/m end
    opt:SetValue(v); setVis(v)
  end
  bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromX(i.Position.X) end end)
  bar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
  UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then setFromX(i.Position.X) end end)

  return opt
end

function Controls.Button(parent, text, cb)
  local b=new("TextButton",{Parent=parent, AutoButtonColor=false, Size=UDim2.new(1,0,0,36), Text=text, Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Theme.Text, BackgroundColor3=Theme.Dark})
  corner(b,8); stroke(b,1,0.08)
  b.MouseEnter:Connect(function() b.BackgroundColor3=Theme.Hover end)
  b.MouseLeave:Connect(function() b.BackgroundColor3=Theme.Dark end)
  b.MouseButton1Click:Connect(function() if type(cb)=="function" then pcall(cb) end end)
  return b
end

function Controls.Dropdown(parent, flag, cfg)
  cfg=cfg or {}; local text=cfg.Text or flag; local values=cfg.Values or {}; local default=cfg.Default or values[1]
  local opt=mkOption(flag, default)

  local row=new("Frame",{Parent=parent, Size=UDim2.new(1,0,0,42), BackgroundColor3=Theme.Dark}); corner(row,8); stroke(row,1,0.08); pad(row,8)
  local btn=new("TextButton",{Parent=row, AutoButtonColor=false, Size=UDim2.new(1,0,1,0), Text=text..": "..tostring(opt.Value), Font=Enum.Font.Gotham, TextSize=13, TextColor3=Theme.Text, BackgroundColor3=Theme.Background})
  corner(btn,8); stroke(btn,1,0.1)

  btn.MouseButton1Click:Connect(function()
    local idx = table.find(values, opt.Value) or 0
    idx = (idx % #values) + 1
    opt:SetValue(values[idx])
    btn.Text = text..": "..tostring(opt.Value)
  end)

  return opt
end

-- GroupBox object
local function makeGroup(parent, title)
  local gb=new("Frame",{Parent=parent, Size=UDim2.new(1,0,0,220), BackgroundColor3=Theme.Background})
  corner(gb,10); stroke(gb,1,0.12); pad(gb,10)

  local header=new("TextLabel",{Parent=gb, BackgroundTransparency=1, Text=title, Font=Enum.Font.GothamSemibold, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=Theme.Text, Size=UDim2.new(1,0,0,20)})
  local body=new("Frame",{Parent=gb, BackgroundTransparency=1, Position=UDim2.new(0,0,0,26), Size=UDim2.new(1,0,1,-32)})
  vlist(body,8)

  local API = {}
  function API:AddToggle(flag,cfg) return Controls.Toggle(body,flag,cfg) end
  function API:AddSlider(flag,cfg) return Controls.Slider(body,flag,cfg) end
  function API:AddDropdown(flag,cfg) return Controls.Dropdown(body,flag,cfg) end
  function API:AddButton(text,cb) return Controls.Button(body,text,cb) end
  function API:SetSubtitle(txt) header.Text = title .. (txt and (" — "..txt) or "") end
  return API
end

-- Tab object
local function makeTab(pages, name)
  local btn=new("TextButton",{Parent=pages._tabs, Size=UDim2.new(0,120,1,0), BackgroundColor3=Theme.Dark, AutoButtonColor=false, Text=name, Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Theme.Text})
  corner(btn,10); stroke(btn,1,0.12)
  btn.MouseEnter:Connect(function() btn.BackgroundColor3=Theme.Hover end)
  btn.MouseLeave:Connect(function() btn.BackgroundColor3=Theme.Dark end)

  local page=new("Frame",{Parent=pages._pages, Size=UDim2.new(1,0,1,0), BackgroundColor3=Theme.Dark, Visible=false})
  corner(page,10); stroke(page,1,0.08); pad(page,10)

  local columns=new("Frame",{Parent=page, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)})
  local grid=new("UIGridLayout", columns)
  grid.CellPadding=UDim2.new(0,10,0,10); grid.CellSize=UDim2.new(0.5,-8,0,220)

  local API={}
  function API:AddLeftGroupbox(title) return makeGroup(columns, title) end
  function API:AddRightGroupbox(title) return makeGroup(columns, title) end

  btn.MouseButton1Click:Connect(function()
    for _,p in ipairs(pages._pages:GetChildren()) do if p:IsA("Frame") then p.Visible=false end end
    page.Visible=true
  end)

  if #pages._pages:GetChildren()==1 then page.Visible=true end
  return API
end

-- Window (CreateWindow)
function Library:CreateWindow(opts)
  opts = opts or {}
  pcall(function() StarterGui:SetCore("TopbarEnabled", true) end)

  local sg=createRoot()

  -- Window
  local Win=new("Frame",{Parent=sg, Size=UDim2.new(0,820,0,520), Position=UDim2.new(opts.Center and 0.5 or 0.12, (opts.Center and -410 or 0), opts.Center and 0.5 or 0.18, (opts.Center and -260 or 0)), BackgroundColor3=Theme.Dark})
  corner(Win,12); stroke(Win,1,0.14); pad(Win,8)

  local titleBar=new("Frame",{Parent=Win, Size=UDim2.new(1,-16,0,48), Position=UDim2.new(0,8,0,8), BackgroundColor3=Theme.Background})
  corner(titleBar,10); stroke(titleBar,1,0.18); pad(titleBar,10)
  local title=new("TextLabel",{Parent=titleBar, BackgroundTransparency=1, Text=opts.Title or "⚡ MYLF | Hub ⚡", Font=Enum.Font.GothamSemibold, TextSize=17, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=Theme.Text, Size=UDim2.new(1,-160,1,-10), Position=UDim2.new(0,10,0,5)})

  -- drag (header only)
  do
    local dragging, start, startPos=false
    titleBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; start=i.Position; startPos=Win.Position end end)
    titleBar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-start; Win.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)
  end

  local TabsBar=new("Frame",{Parent=Win, BackgroundTransparency=1, Size=UDim2.new(1,-16,0,44), Position=UDim2.new(0,8,0,64)})
  local tl=new("UIListLayout", TabsBar); tl.FillDirection=Enum.FillDirection.Horizontal; tl.Padding=UDim.new(0,8)

  local Pages=new("Frame",{Parent=Win, BackgroundTransparency=1, Size=UDim2.new(1,-16,1,-120), Position=UDim2.new(0,8,0,112)})

  -- HUD (capsule)
  local HUDsg=new("ScreenGui",{Name="MYLF_HUD", IgnoreGuiInset=true, ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Global, DisplayOrder=999999999})
  HUDsg.Parent = CoreGui
  local hud=new("Frame",{Parent=HUDsg, Size=UDim2.new(0,420,0,42), Position=UDim2.new(0.6,0,0.08,0), BackgroundColor3=Theme.Dark}); corner(hud,14); stroke(hud,1,0.16); pad(hud,8)
  local hudText=new("TextLabel",{Parent=hud, BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=Theme.Text, Size=UDim2.new(1,-16,1,-16), Position=UDim2.new(0,10,0,6), Text="FPS: -- | Ping: -- (--%CV) | CPU: -- ms | GPU: -- ms"})
  local underline=new("Frame",{Parent=hud, AnchorPoint=Vector2.new(0.5,1), Position=UDim2.new(0.5,0,1,-3), Size=UDim2.new(1,-18,0,3), BackgroundColor3=Color3.new(1,1,1)})
  corner(underline,3)
  local grad=new("UIGradient",{Parent=underline, Color=ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0.00,1,1)),
    ColorSequenceKeypoint.new(0.20, Color3.fromHSV(0.20,1,1)),
    ColorSequenceKeypoint.new(0.40, Color3.fromHSV(0.40,1,1)),
    ColorSequenceKeypoint.new(0.60, Color3.fromHSV(0.60,1,1)),
    ColorSequenceKeypoint.new(0.80, Color3.fromHSV(0.80,1,1)),
    ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1.00,1,1)),
  }})

  -- HUD drag
  do
    local dragging, start, startPos=false
    hud.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; start=i.Position; startPos=hud.Position end end)
    hud.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-start; hud.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)
  end

  -- HUD updater
  do
    local acc, frames, samples, maxS = 0,0,{},50
    local function push(ms) samples[#samples+1]=ms; if #samples>maxS then table.remove(samples,1) end end
    local function meanCV(t) if #t==0 then return 0,0 end local s=0 for _,v in ipairs(t) do s+=v end local m=s/#t local v=0 for _,v2 in ipairs(t) do v+=(v2-m)*(v2-m) end v=v/#t local sd=math.sqrt(v) local cv=(m~=0) and (sd/m*100) or 0 return m,cv end
    RunService.RenderStepped:Connect(function(dt)
      grad.Rotation=(grad.Rotation+80*dt)%360
      acc+=dt; frames+=1
      if acc>=0.1 then
        local fps=math.max(1, math.floor(frames/acc+0.5))
        local framems=(acc/frames)*1000
        frames,acc=0,0
        local ping=0; pcall(function() local item=Stats.Network.ServerStatsItem["Data Ping"]; if item then local v=item:GetValue(); if typeof(v)=="number" then ping=v end end end)
        push(ping); local mp,cv=meanCV(samples)
        hudText.Text=string.format("FPS: %d | Ping: %.1f (%.0f%%CV) | CPU: %.1f ms | GPU: %.1f ms", fps, mp, cv, framems, framems)
    end end)
  end

  -- Pages bundle
  local PagesBundle = { _tabs=TabsBar, _pages=Pages }

  local API = {}
  function API:AddTab(name) return makeTab(PagesBundle, name) end
  function API:Show() Win.Visible=true end
  function API:Hide() Win.Visible=false end
  function API:Toggle() Win.Visible = not Win.Visible end

  -- AutoShow (default true)
  if opts.AutoShow==false then Win.Visible=false else Win.Visible=true end

  -- Return window api
  -- (small helper for ThemeManager)
  API.___root = {Win=Win, TabsBar=TabsBar, Pages=Pages, HUDFrame=hud, HUDText=hudText}
  return API
end

-- ===============================
-- ThemeManager (minimal but working)
-- ===============================
local ThemeManager = {}
ThemeManager.__index=ThemeManager
ThemeManager._folder = "MYLFHub"

function ThemeManager:SetLibrary(lib) self._lib=lib end
function ThemeManager:SetFolder(path) self._folder=path or self._folder end

-- live-updating theme table via metatable
local themeProxyMT={}
function themeProxyMT.__newindex(t,k,v) rawset(Theme,k,v); if ThemeManager._lib and ThemeManager._lib.SetTheme then ThemeManager._lib:SetTheme(Theme) end end
function ThemeManager:CurrentTheme()
  local proxy=setmetatable({}, themeProxyMT)
  for k,v in pairs(Theme) do proxy[k]=v end -- triggers apply but ok
  return proxy
end

function ThemeManager:ApplyToTab(tab)
  -- optional: add a tiny theme dropdown on given tab
  local gb = tab:AddLeftGroupbox("Theme")
  gb:AddDropdown("mylf_theme", {Text="Preset", Values={"Dark-Red","Neo-Purple","Midnight"}, Default="Dark-Red"})
    :OnChanged(function(v)
      if v=="Dark-Red" then
        Theme.Accent=Color3.fromRGB(230,57,70); Theme.Background=Color3.fromRGB(16,16,18); Theme.Outline=Color3.fromRGB(255,255,255)
      elseif v=="Neo-Purple" then
        Theme.Accent=Color3.fromRGB(153,102,255); Theme.Background=Color3.fromRGB(14,12,22)
      else
        Theme.Accent=Color3.fromRGB(0,180,216); Theme.Background=Color3.fromRGB(10,12,16)
      end
      if self._lib and self._lib.SetTheme then self._lib:SetTheme(Theme) end
    end)
end

-- ===============================
-- SaveManager (minimal, RAM-based)
-- ===============================
local SaveManager = {}
SaveManager.__index=SaveManager
SaveManager._folder = "MYLFHub/saves"
SaveManager._ignore = {}
SaveManager._lib = nil
SaveManager._db = {} -- RAM only

function SaveManager:SetLibrary(lib) self._lib=lib end
function SaveManager:SetFolder(path) self._folder=path or self._folder end
function SaveManager:IgnoreThemeSettings() self._ignore.theme=true end
function SaveManager:SetIgnoreIndexes(t) self._ignore.indexes=t or {} end

local function snapshot()
  local out={}
  for k,opt in pairs(Options) do
    if not SaveManager._ignore.indexes or not SaveManager._ignore.indexes[k] then
      out[k]=opt.Value
    end
  end
  return out
end
local function restore(snap)
  if type(snap)=="table" then
    for k,v in pairs(snap) do
      if Options[k] then Options[k]:SetValue(v) end
    end
  end
end

function SaveManager:BuildConfigSection(tab)
  local gb = tab:AddRightGroupbox("Config")
  local nameOpt = gb:AddInput("cfg_name", {Text="Config Name", Default="default", Placeholder="type..."})
  gb:AddButton("Save Config", function()
    local nm = Options.cfg_name and Options.cfg_name.Value or "default"
    self._db[nm]=snapshot()
  end)
  gb:AddButton("Load Config", function()
    local nm = Options.cfg_name and Options.cfg_name.Value or "default"
    restore(self._db[nm])
  end)
end

-- ===============================
-- Expose globals
-- ===============================
return (function()
  -- expose three values like Linoria loader expects:
  return Library, ThemeManager, SaveManager
end)()
