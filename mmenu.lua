--// MYLF OneFile UI Library (Legit, non-destructive) — v1.1
--// Exposes: Library, ThemeManager, SaveManager   | Global: Options
--// Works with loader: Library -> CreateWindow -> Tabs/Groupboxes/Controls

-- Services
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

-- ============== Theme ==============
local Theme = {
  Accent     = Color3.fromRGB(230, 0, 35),
  Background = Color3.fromRGB(20, 20, 24),
  Panel      = Color3.fromRGB(28, 28, 34),
  Text       = Color3.fromRGB(235, 235, 240),
  SubText    = Color3.fromRGB(170, 170, 180),
  Hover      = Color3.fromRGB(40, 40, 50),
  Stroke     = Color3.fromRGB(255, 255, 255),
}

local Presets = {
  ["Dark-Red"]   = {Accent=Color3.fromRGB(230,0,35),  Background=Color3.fromRGB(20,20,24), Panel=Color3.fromRGB(28,28,34)},
  ["Neo-Purple"] = {Accent=Color3.fromRGB(153,102,255), Background=Color3.fromRGB(14,12,22), Panel=Color3.fromRGB(26,22,45)},
  ["Midnight"]   = {Accent=Color3.fromRGB(0,180,216), Background=Color3.fromRGB(10,12,16), Panel=Color3.fromRGB(20,24,30)},
}

-- ============== utils ==============
local function new(class, parent, props)
  local o = Instance.new(class)
  if parent then o.Parent = parent end
  if props then for k,v in pairs(props) do o[k]=v end end
  return o
end
local function corner(p, r) local c=new("UICorner", p, {CornerRadius=UDim.new(0, r or 10)}); return c end
local function stroke(p, th, tr, col) local s=new("UIStroke", p, {Thickness=th or 1, Transparency=tr or 0.12, Color=col or Theme.Stroke}); return s end
local function pad(p, px) new("UIPadding", p, {PaddingTop=UDim.new(0,px),PaddingBottom=UDim.new(0,px),PaddingLeft=UDim.new(0,px),PaddingRight=UDim.new(0,px)}) end
local function vlist(p, gap) return new("UIListLayout", p, {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0, gap or 8)}) end

-- ============== signal ==============
local function Signal()
  local list = {}
  return {
    Connect = function(self, fn) table.insert(list, fn); return {Disconnect=function() for i,f in ipairs(list) do if f==fn then table.remove(list,i) break end end end} end,
    Fire = function(_, ...) for _,fn in ipairs(list) do pcall(fn, ...) end end,
  }
end

-- ============== Options registry (Linoria-like) ==============
getgenv().Options = getgenv().Options or {}
local Options = getgenv().Options
local function mkOption(flag, default)
  local o = Options[flag]
  if o then return o end
  o = {
    Value = default,
    _sig  = Signal(),
    OnChanged = function(self, cb) return self._sig:Connect(cb) end,
    SetValue  = function(self, v) self.Value=v; self._sig:Fire(v) end,
  }
  Options[flag] = o
  return o
end

-- ============== Library core ==============
local Library = {}
Library.__index = Library

local function rootParent()
  local ok,ui = pcall(function() return gethui and gethui() end)
  if ok and ui then return ui end
  return CoreGui
end

local function applyThemeToTree(gui)
  for _,x in ipairs(gui:GetDescendants()) do
    if x:IsA("TextLabel") or x:IsA("TextButton") then x.TextColor3 = Theme.Text end
  end
end

function Library:SetTheme(tbl)
  if typeof(tbl)=="table" then for k,v in pairs(tbl) do Theme[k]=v end end
  for _,sg in ipairs(rootParent():GetChildren()) do
    if sg.Name=="MYLF_ONEFILE_UI" then applyThemeToTree(sg) end
  end
end

-- Groupbox object
local function makeGroup(parent, title)
  local gb = new("Frame", parent, {BackgroundColor3=Theme.Background, Size=UDim2.new(1,0,0,230)})
  corner(gb,10); stroke(gb,1,0.10); pad(gb,10)
  local header = new("TextLabel", gb, {BackgroundTransparency=1, Text=title, Font=Enum.Font.GothamSemibold, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=Theme.Text, Size=UDim2.new(1,0,0,20)})
  local body = new("Frame", gb, {BackgroundTransparency=1, Position=UDim2.new(0,0,0,26), Size=UDim2.new(1,0,1,-32)}); vlist(body,8)

  local API = {}

  function API:AddToggle(flag, cfg)
    cfg = cfg or {}; local text = cfg.Text or flag; local default = cfg.Default or false
    local opt = mkOption(flag, default)

    local row = new("Frame", body, {Size=UDim2.new(1,0,0,36), BackgroundColor3=Theme.Panel})
    corner(row,8); stroke(row,1,0.08); pad(row,8)
    new("TextLabel", row, {BackgroundTransparency=1,Text=text,Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Theme.Text,Size=UDim2.new(1,-64,1,0)})

    local btn = new("TextButton", row, {AutoButtonColor=false,Size=UDim2.new(0,48,0,22),Position=UDim2.new(1,-56,0.5,-11),Text="",BackgroundColor3=Color3.fromRGB(60,60,68)})
    corner(btn,11); stroke(btn,1,0.12)
    local knob = new("Frame", btn, {Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,2,0.5,-9),BackgroundColor3=Theme.Text}); corner(knob,9)

    local function redraw(v)
      if v then btn.BackgroundColor3=Theme.Accent; knob:TweenPosition(UDim2.new(1,-20,0.5,-9),"Out","Quad",.12,true)
      else btn.BackgroundColor3=Color3.fromRGB(60,60,68); knob:TweenPosition(UDim2.new(0,2,0.5,-9),"Out","Quad",.12,true) end
    end
    redraw(opt.Value)

    btn.MouseButton1Click:Connect(function() opt:SetValue(not opt.Value); redraw(opt.Value) end)

    return opt
  end

  function API:AddSlider(flag, cfg)
    cfg = cfg or {}
    local text, min, max = cfg.Text or flag, cfg.Min or 0, cfg.Max or 100
    local default, rounding = cfg.Default or min, cfg.Rounding or 0
    local opt = mkOption(flag, default)

    local row = new("Frame", body, {Size=UDim2.new(1,0,0,52), BackgroundColor3=Theme.Panel})
    corner(row,8); stroke(row,1,0.08); pad(row,10)
    local lbl = new("TextLabel", row, {BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=Theme.Text, Size=UDim2.new(1,0,0,18)})

    local bar = new("Frame", row, {Size=UDim2.new(1,-20,0,10), Position=UDim2.new(0,10,0,26), BackgroundColor3=Color3.fromRGB(60,60,68)}); corner(bar,6); stroke(bar,1,0.1)
    local fill= new("Frame", bar, {BackgroundColor3=Theme.Accent}); corner(fill,6)

    local function setText(v) lbl.Text = string.format("%s (%.2f)", text, v) end
    local function relFromVal(v) return (v-min)/math.max(1e-9,(max-min)) end
    local function setVis(v) fill.Size = UDim2.new(relFromVal(v),0,1,0); setText(v) end
    setVis(opt.Value)

    local dragging=false
    local function setFromX(x)
      local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1)
      local v = min + (max-min) * rel
      if rounding>0 then local m=10^rounding; v = math.floor(v*m+0.5)/m end
      opt:SetValue(v); setVis(v)
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromX(i.Position.X) end end)
    bar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then setFromX(i.Position.X) end end)

    return opt
  end

  function API:AddDropdown(flag, cfg)
    cfg = cfg or {}
    local text, values = cfg.Text or flag, (cfg.Values or {})
    local default = cfg.Default or values[1]
    local opt = mkOption(flag, default)

    local row = new("Frame", body, {Size=UDim2.new(1,0,0,42), BackgroundColor3=Theme.Panel})
    corner(row,8); stroke(row,1,0.08); pad(row,8)
    local btn = new("TextButton", row, {AutoButtonColor=false, Size=UDim2.new(1,0,1,0), BackgroundColor3=Theme.Background, Font=Enum.Font.Gotham, TextSize=13, TextColor3=Theme.Text})
    corner(btn,8); stroke(btn,1,0.1)
    local function redraw() btn.Text = text..": "..tostring(opt.Value or "") end
    redraw()

    btn.MouseButton1Click:Connect(function()
      if #values == 0 then return end
      local i = table.find(values, opt.Value) or 0
      i = (i % #values) + 1
      opt:SetValue(values[i]); redraw()
    end)

    return opt
  end

  function API:AddButton(text, cb)
    local b = new("TextButton", body, {AutoButtonColor=false, Size=UDim2.new(1,0,0,36), Text=text, Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Theme.Text, BackgroundColor3=Theme.Panel})
    corner(b,8); stroke(b,1,0.08)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Theme.Hover end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = Theme.Panel end)
    b.MouseButton1Click:Connect(function() if type(cb)=="function" then pcall(cb) end end)
    return b
  end

  function API:AddInput(flag, cfg)
    cfg = cfg or {}
    local text, placeholder, default = cfg.Text or flag, cfg.Placeholder or "type...", cfg.Default or ""
    local opt = mkOption(flag, default)

    local row = new("Frame", body, {Size=UDim2.new(1,0,0,36), BackgroundColor3=Theme.Panel})
    corner(row,8); stroke(row,1,0.08); pad(row,8)
    local lbl = new("TextLabel", row, {BackgroundTransparency=1,Text=text,Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Theme.Text,Size=UDim2.new(0.35,0,1,0)})

    local box = new("TextBox", row, {Text=tostring(default), PlaceholderText=placeholder, Font=Enum.Font.Gotham, TextSize=13, TextColor3=Theme.Text, BackgroundColor3=Theme.Background, Size=UDim2.new(0.62,0,1,0), Position=UDim2.new(0.36,0,0,0)})
    corner(box,8); stroke(box,1,0.08)
    box.FocusLost:Connect(function() opt:SetValue(box.Text) end)

    return opt
  end

  function API:SetSubtitle(txt) header.Text = title .. (txt and (" — "..txt) or "") end
  return API
end

-- Tab object
local function makeTab(bundle, name)
  local btn = new("TextButton", bundle._tabs, {AutoButtonColor=false, Size=UDim2.new(0,130,1,0), Text=name, Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Theme.Text, BackgroundColor3=Theme.Panel})
  corner(btn,10); stroke(btn,1,0.12)
  btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Theme.Hover end)
  btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Theme.Panel end)

  local page = new("Frame", bundle._pages, {Size=UDim2.new(1,0,1,0), BackgroundColor3=Theme.Panel, Visible=false})
  corner(page,10); stroke(page,1,0.08); pad(page,10)
  local columns = new("Frame", page, {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)})
  local grid = new("UIGridLayout", columns, {CellPadding=UDim2.new(0,10,0,10), CellSize=UDim2.new(0.5,-8,0,230), SortOrder=Enum.SortOrder.LayoutOrder})

  local API = {}
  function API:AddLeftGroupbox(title)  return makeGroup(columns, title) end
  function API:AddRightGroupbox(title) return makeGroup(columns, title) end

  btn.MouseButton1Click:Connect(function()
    for _,p in ipairs(bundle._pages:GetChildren()) do if p:IsA("Frame") then p.Visible=false end end
    page.Visible = true
  end)
  if #bundle._pages:GetChildren()==1 then page.Visible=true end

  return API
end

-- CreateWindow
function Library:CreateWindow(opts)
  opts = opts or {}
  pcall(function() StarterGui:SetCore("TopbarEnabled", true) end)

  local parent = rootParent()
  local sg = new("ScreenGui", parent, {Name="MYLF_ONEFILE_UI", IgnoreGuiInset=true, ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Global, DisplayOrder=999999999})

  local Win = new("Frame", sg, {Size=UDim2.new(0,820,0,520), Position=UDim2.new(opts.Center and 0.5 or 0.12, (opts.Center and -410 or 0), opts.Center and 0.5 or 0.18, (opts.Center and -260 or 0)), BackgroundColor3=Theme.Panel, Active=true})
  corner(Win,12); stroke(Win,1,0.14); pad(Win,8)

  local TitleBar = new("Frame", Win, {Size=UDim2.new(1,-16,0,48), Position=UDim2.new(0,8,0,8), BackgroundColor3=Theme.Background})
  corner(TitleBar,10); stroke(TitleBar,1,0.18); pad(TitleBar,10)
  local Title = new("TextLabel", TitleBar, {BackgroundTransparency=1, Text=opts.Title or "⚡ MYLF | Hub ⚡", Font=Enum.Font.GothamSemibold, TextSize=17, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=Theme.Text, Size=UDim2.new(1,-160,1,-10), Position=UDim2.new(0,10,0,5)})

  -- drag (title-only)
  do
    local dragging, start, startPos = false
    TitleBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; start=i.Position; startPos=Win.Position end end)
    TitleBar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-start; Win.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)
  end

  local TabsBar = new("Frame", Win, {BackgroundTransparency=1, Size=UDim2.new(1,-16,0,44), Position=UDim2.new(0,8,0,64)})
  local tl = new("UIListLayout", TabsBar, {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8)})

  local Pages = new("Frame", Win, {BackgroundTransparency=1, Size=UDim2.new(1,-16,1,-120), Position=UDim2.new(0,8,0,112)})

  local bundle = { _tabs=TabsBar, _pages=Pages }
  local API = {}
  function API:AddTab(name) return makeTab(bundle, name) end
  function API:Show() Win.Visible = true end
  function API:Hide() Win.Visible = false end
  function API:Toggle() Win.Visible = not Win.Visible end

  -- AutoShow
  if opts.AutoShow == false then Win.Visible=false else Win.Visible=true end

  -- Toggle keybind (Linoria-like)
  Library.ToggleKeybind = Library.ToggleKeybind or Enum.KeyCode.LeftControl
  UIS.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == (Library.ToggleKeybind or Enum.KeyCode.LeftControl) then
      API:Toggle()
    end
  end)

  -- Expose for theming
  API.___root = {Win=Win, TitleBar=TitleBar, Title=Title, TabsBar=TabsBar, Pages=Pages}
  return API
end

-- ============== ThemeManager (minimal) ==============
local ThemeManager = {}
ThemeManager.__index = ThemeManager
ThemeManager._folder = "MYLFHub"

function ThemeManager:SetLibrary(lib) self._lib = lib end
function ThemeManager:SetFolder(path) self._folder = path or self._folder end
local proxyMt = {
  __newindex = function(_,k,v) Theme[k]=v; if Library.SetTheme then Library:SetTheme(Theme) end end,
  __index = function(_,k) return Theme[k] end
}
function ThemeManager:CurrentTheme() return setmetatable({}, proxyMt) end
function ThemeManager:ApplyToTab(tab)
  local g = tab:AddLeftGroupbox("Theme")
  g:AddDropdown("mylf_theme", {Text="Preset", Values={"Dark-Red","Neo-Purple","Midnight"}, Default="Dark-Red"})
    :OnChanged(function(sel) local p=Presets[sel]; if p then Library:SetTheme(p) end end)
end

-- ============== SaveManager (RAM only) ==============
local SaveManager = {}
SaveManager.__index = SaveManager
SaveManager._folder = "MYLFHub/saves"
SaveManager._ignore = {}
SaveManager._db = {}

function SaveManager:SetLibrary(lib) self._lib=lib end
function SaveManager:SetFolder(path) self._folder = path or self._folder end
function SaveManager:IgnoreThemeSettings() self._ignore.theme = true end
function SaveManager:SetIgnoreIndexes(t) self._ignore.indexes = t or {} end

local function snapshot()
  local snap = {}
  for k,opt in pairs(Options) do
    if not SaveManager._ignore.indexes or not SaveManager._ignore.indexes[k] then
      snap[k] = opt.Value
    end
  end
  return snap
end
local function restore(snap)
  if type(snap) ~= "table" then return end
  for k,v in pairs(snap) do
    if Options[k] then Options[k]:SetValue(v) end
  end
end

function SaveManager:BuildConfigSection(tab)
  local g = tab:AddRightGroupbox("Config")
  g:AddInput("cfg_name", {Text="Config Name", Default="default", Placeholder="type..."})
  g:AddButton("Save Config", function()
    local nm = (Options.cfg_name and Options.cfg_name.Value) or "default"
    self._db[nm] = snapshot()
  end)
  g:AddButton("Load Config", function()
    local nm = (Options.cfg_name and Options.cfg_name.Value) or "default"
    restore(self._db[nm])
  end)
end

-- ============== return ==============
return (function() return Library, ThemeManager, SaveManager end)()
