--[[
    Steal a Superpower - Universal Hub
    Version: 1.1.0
    Build: 2026-11-08
    Game: [⚡] Steal a Superpower! (universe 10770228857 / place 74183246285569)

    PC + Mobile. The game updates frequently and its remotes are not public,
    so this build uses runtime remote discovery plus a guided Learn Mode.
    Features that need a remote fall back to ProximityPrompt, ClickDetector,
    tool activation, or GUI clicking where possible.

    This file is the complete script. Execute it directly, or use Loader.lua
    to always pull the latest version from the repository.
]]

local SCRIPT_VERSION = "1.1.0"
local BUILD_DATE = "2026-11-08"
local unpackArgs = table.unpack or unpack
local GAME_ID = 10770228857
local PLACE_ID = 74183246285569
local REPO_RAW = "https://raw.githubusercontent.com/reizure87-create/StealASuperpower/main"
local MANIFEST_URL = REPO_RAW .. "/manifest.json"
local CODES_URL = REPO_RAW .. "/codes.json"

if not game then
    return
end

local okGameId, currentGameId = pcall(function()
    return game.GameId
end)
if not okGameId or currentGameId ~= GAME_ID then
    warn("[SAS] This script only works in [⚡] Steal a Superpower! (universe " .. tostring(GAME_ID) .. ").")
    return
end

local function getService(name)
    local ok, service = pcall(function()
        return game:GetService(name)
    end)
    if ok then
        return service
    end
    return nil
end

local Services = {
    Players = getService("Players"),
    ReplicatedStorage = getService("ReplicatedStorage"),
    Workspace = getService("Workspace") or workspace,
    RunService = getService("RunService"),
    UserInputService = getService("UserInputService"),
    TweenService = getService("TweenService"),
    Lighting = getService("Lighting"),
    HttpService = getService("HttpService"),
    GuiService = getService("GuiService"),
    TeleportService = getService("TeleportService"),
    CoreGui = getService("CoreGui"),
    CollectionService = getService("CollectionService"),
    VirtualUser = getService("VirtualUser"),
    VirtualInputManager = getService("VirtualInputManager"),
    StarterGui = getService("StarterGui"),
}

local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local Workspace = Services.Workspace
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local Lighting = Services.Lighting
local HttpService = Services.HttpService
local GuiService = Services.GuiService
local TeleportService = Services.TeleportService

if not Players then
    warn("[SAS] Players service is unavailable.")
    return
end

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    local waited = 0
    repeat
        task.wait(0.1)
        waited = waited + 1
        LocalPlayer = Players.LocalPlayer
    until LocalPlayer or waited >= 100
end
if not LocalPlayer then
    warn("[SAS] LocalPlayer did not load.")
    return
end

local function getGenv()
    local ok, env = pcall(function()
        return getgenv()
    end)
    if ok and type(env) == "table" then
        return env
    end
    return _G
end

local Genv = getGenv()

local function execFn(name)
    local direct = rawget(_G, name)
    if type(direct) == "function" then
        return direct
    end
    local fromGenv = Genv and Genv[name]
    if type(fromGenv) == "function" then
        return fromGenv
    end
    return nil
end

local function getExecutorName()
    local name = "Unknown"
    local identify = execFn("identifyexecutor")
    if identify then
        local ok, a, b = pcall(identify)
        if ok then
            name = tostring(a or b or "Unknown")
        end
    elseif execFn("getexecutorname") then
        local ok, a = pcall(execFn("getexecutorname"))
        if ok then
            name = tostring(a or "Unknown")
        end
    end
    return name
end

local ExecutorName = getExecutorName()
local function httpRequest(options)
    if type(options) ~= "table" then
        return nil
    end
    local requestFn = execFn("request") or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request)
    if requestFn then
        local ok, response = pcall(requestFn, options)
        if ok and type(response) == "table" then
            return response
        end
    end
    if (options.Method or "GET") == "GET" and options.Url then
        local ok, body = pcall(function()
            return game:HttpGet(options.Url, true)
        end)
        if ok and body then
            return { StatusCode = 200, Body = body }
        end
    end
    return nil
end

local function jsonEncode(value)
    if HttpService then
        local ok, encoded = pcall(function()
            return HttpService:JSONEncode(value)
        end)
        if ok and encoded then
            return encoded
        end
    end
    return "{}"
end

local function jsonDecode(value)
    if HttpService and type(value) == "string" and value ~= "" then
        local ok, decoded = pcall(function()
            return HttpService:JSONDecode(value)
        end)
        if ok then
            return decoded
        end
    end
    return nil
end

local FILE_DIR = "StealASuperpower"
local function ensureFolders()
    local makeFolder = execFn("makefolder")
    if makeFolder then
        pcall(makeFolder, FILE_DIR)
        pcall(makeFolder, FILE_DIR .. "/profiles")
    end
end

local function writeFile(name, contents)
    local write = execFn("writefile")
    if write and type(contents) == "string" then
        local ok = pcall(write, FILE_DIR .. "/" .. name, contents)
        return ok
    end
    return false
end

local function readFile(name)
    local read = execFn("readfile")
    if read then
        local ok, contents = pcall(read, FILE_DIR .. "/" .. name)
        if ok and type(contents) == "string" then
            return contents
        end
    end
    return nil
end

local function copyText(text)
    local setClipboard = execFn("setclipboard") or execFn("toclipboard")
    if setClipboard then
        local ok = pcall(setClipboard, text)
        if ok then
            return true
        end
    end
    return false
end

local function now()
    return os.clock()
end

local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

local function roundTo(value, step)
    if not step or step <= 0 then
        return value
    end
    return math.floor(value / step + 0.5) * step
end

local function commas(number)
    local text = tostring(math.floor(number or 0))
    local result
    repeat
        text, result = text:gsub("^(%d+)(%d%d%d)", "%1,%2")
    until result == 0
    return text
end

local function compact(number)
    number = tonumber(number)
    if not number then
        return "?"
    end
    if number >= 1000000000 then
        return string.format("%.2fB", number / 1000000000)
    elseif number >= 1000000 then
        return string.format("%.2fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fK", number / 1000)
    end
    return string.format("%d", math.floor(number))
end

local function joinNames(list, separator)
    local parts = {}
    for index = 1, #list do
        parts[index] = tostring(list[index])
    end
    return table.concat(parts, separator or ", ")
end

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local character = getCharacter()
    if not character then
        return nil
    end
    local ok, humanoid = pcall(function()
        return character:FindFirstChildOfClass("Humanoid")
    end)
    if ok then
        return humanoid
    end
    return nil
end

local function getHumanoidRootPart()
    local character = getCharacter()
    if not character then
        return nil
    end
    local ok, root = pcall(function()
        return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    end)
    if ok then
        return root
    end
    return nil
end

local function isAlive(model)
    if not model or not model.Parent then
        return false
    end
    local ok, humanoid = pcall(function()
        return model:FindFirstChildOfClass("Humanoid")
    end)
    return ok and humanoid ~= nil and humanoid.Health > 0
end

-- ---------------------------------------------------------------------------
-- Logging
-- ---------------------------------------------------------------------------

local Log = {
    entries = {},
    maxEntries = 300,
    listeners = {},
}

function Log.add(level, message)
    local line = string.format("[%s] [%s] %s", os.date("%H:%M:%S"), tostring(level):upper(), tostring(message))
    Log.entries[#Log.entries + 1] = line
    if #Log.entries > Log.maxEntries then
        table.remove(Log.entries, 1)
    end
    print("[SAS] " .. line)
    for index = 1, #Log.listeners do
        local ok = pcall(Log.listeners[index], line)
        if not ok then
            table.remove(Log.listeners, index)
        end
    end
end

function Log.info(message)
    Log.add("info", message)
end

function Log.warn(message)
    Log.add("warn", message)
end

function Log.error(message)
    Log.add("error", message)
end

function Log.tail(count)
    count = count or 40
    local first = math.max(1, #Log.entries - count + 1)
    local output = {}
    for index = first, #Log.entries do
        output[#output + 1] = Log.entries[index]
    end
    return table.concat(output, "\n")
end

-- ---------------------------------------------------------------------------
-- Settings and config
-- ---------------------------------------------------------------------------

local Settings = {
    -- UI
    uiKeybind = "RightShift",
    notifications = true,
    showToggleButton = true,
    -- Farm
    autoFarm = false,
    killAura = false,
    autoBoss = false,
    autoZone = false,
    autoMovement = true,
    targetPlayers = false,
    farmRange = 180,
    attackRange = 18,
    attackDelay = 0.35,
    tpToTargets = false,
    guiFallback = true,
    -- Packs
    autoClaimPacks = false,
    autoGrabDrops = false,
    autoOpenPacks = false,
    autoBankPacks = false,
    autoFuse = false,
    autoPlaceBest = false,
    autoEquipBest = false,
    autoPotions = false,
    packInterval = 1.0,
    -- Training / Economy
    autoTrain = false,
    trainInterval = 1.0,
    trainRange = 500,
    autoUpgrade = false,
    autoRebirth = false,
    rebirthThreshold = 100000,
    autoRewards = false,
    autoCodes = false,
    upgradeInterval = 5,
    -- ESP
    espPlayers = false,
    espBosses = false,
    espPacks = false,
    espChests = false,
    espNames = true,
    -- Misc
    antiAfk = true,
    hud = true,
    speedEnabled = false,
    walkSpeed = 24,
    jumpEnabled = false,
    jumpPower = 60,
    noclip = false,
    infiniteJump = false,
    antiVoid = false,
    fullbright = false,
    fpsCap = 0,
    webhookEnabled = false,
    webhookUrl = "",
    customCodes = "",
    -- Adapter
    autoResolve = true,
}

local SETTING_ORDER = {
    "uiKeybind", "notifications", "showToggleButton",
    "autoFarm", "killAura", "autoBoss", "autoZone", "autoMovement", "targetPlayers",
    "farmRange", "attackRange", "attackDelay", "tpToTargets", "guiFallback",
    "autoClaimPacks", "autoGrabDrops", "autoOpenPacks", "autoBankPacks", "autoFuse",
    "autoPlaceBest", "autoEquipBest", "autoPotions", "packInterval",
    "autoTrain", "trainInterval", "trainRange",
    "autoUpgrade", "autoRebirth", "rebirthThreshold", "autoRewards", "autoCodes", "upgradeInterval",
    "espPlayers", "espBosses", "espPacks", "espChests", "espNames",
    "antiAfk", "hud", "speedEnabled", "walkSpeed", "jumpEnabled", "jumpPower",
    "noclip", "infiniteJump", "antiVoid",
    "fullbright", "fpsCap", "webhookEnabled", "webhookUrl", "customCodes", "autoResolve",
}

local DEFAULT_SETTINGS = {}
for key, value in pairs(Settings) do
    DEFAULT_SETTINGS[key] = value
end

local function saveConfig()
    local data = {}
    for index = 1, #SETTING_ORDER do
        local key = SETTING_ORDER[index]
        data[key] = Settings[key]
    end
    local encoded = jsonEncode(data)
    if writeFile("config.json", encoded) then
        return true
    end
    return false
end

local function resetSettings()
    for index = 1, #SETTING_ORDER do
        local key = SETTING_ORDER[index]
        Settings[key] = DEFAULT_SETTINGS[key]
    end
    saveConfig()
    return true
end

local function loadConfig()
    local raw = readFile("config.json")
    if not raw then
        return false
    end
    local data = jsonDecode(raw)
    if type(data) ~= "table" then
        return false
    end
    for index = 1, #SETTING_ORDER do
        local key = SETTING_ORDER[index]
        local value = data[key]
        if value ~= nil and type(value) == type(Settings[key]) then
            Settings[key] = value
        end
    end
    return true
end

local function saveSetting(key)
    if Settings[key] ~= nil then
        saveConfig()
    end
end

-- ---------------------------------------------------------------------------
-- Theme
-- ---------------------------------------------------------------------------

local Theme = {
    background = Color3.fromRGB(13, 15, 24),
    panel = Color3.fromRGB(21, 24, 36),
    panelLight = Color3.fromRGB(29, 33, 48),
    panelHover = Color3.fromRGB(38, 43, 62),
    accent = Color3.fromRGB(0, 200, 255),
    accentDark = Color3.fromRGB(0, 140, 190),
    accent2 = Color3.fromRGB(164, 92, 255),
    text = Color3.fromRGB(235, 240, 255),
    muted = Color3.fromRGB(148, 158, 184),
    good = Color3.fromRGB(80, 230, 150),
    danger = Color3.fromRGB(255, 86, 108),
    warning = Color3.fromRGB(255, 190, 80),
    black = Color3.fromRGB(0, 0, 0),
    white = Color3.fromRGB(255, 255, 255),
}

local Fonts = {
    regular = Enum.Font.GothamMedium,
    bold = Enum.Font.GothamBold,
    code = Enum.Font.Code,
}

local function newInstance(className, properties)
    local instance = Instance.new(className)
    if properties then
        for key, value in pairs(properties) do
            if key ~= "Parent" then
                pcall(function()
                    instance[key] = value
                end)
            end
        end
    end
    if properties and properties.Parent then
        local okParent = pcall(function()
            instance.Parent = properties.Parent
        end)
        if not okParent then
            pcall(function()
                instance.Parent = nil
            end)
        end
    end
    return instance
end

local function corner(parent, radius)
    local uiCorner = newInstance("UICorner", { Parent = parent })
    uiCorner.CornerRadius = UDim.new(0, radius or 8)
    return uiCorner
end

local function stroke(parent, color, thickness, transparency)
    local uiStroke = newInstance("UIStroke", { Parent = parent })
    uiStroke.Color = color or Theme.panelHover
    uiStroke.Thickness = thickness or 1
    uiStroke.Transparency = transparency or 0.4
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return uiStroke
end

local function padding(parent, amount)
    local uiPadding = newInstance("UIPadding", { Parent = parent })
    uiPadding.PaddingLeft = UDim.new(0, amount or 8)
    uiPadding.PaddingRight = UDim.new(0, amount or 8)
    uiPadding.PaddingTop = UDim.new(0, amount or 6)
    uiPadding.PaddingBottom = UDim.new(0, amount or 6)
    return uiPadding
end
-- ---------------------------------------------------------------------------
-- UI library
-- ---------------------------------------------------------------------------

-- Forward declarations so tab builders can reference modules defined later.
local Adapter, Learn, Remotes, Scanner, Gui, Combat, Packs, Train, Potions, Economy, Stats, ESP, Teleport, Codes, Misc

local UI = {
    screen = nil,
    window = nil,
    header = nil,
    body = nil,
    sidebar = nil,
    tabBar = nil,
    tabBarScroll = nil,
    content = nil,
    tabs = {},
    tabOrder = {},
    tabButtons = {},
    activeTab = nil,
    toggleButton = nil,
    hud = nil,
    hudLabels = {},
    hudVisible = true,
    minimised = false,
    hidden = false,
    mobile = false,
    viewport = Vector2.new(1280, 720),
    topInset = 36,
    bottomInset = 12,
    toastFrame = nil,
    toastLabel = nil,
    toastToken = 0,
    connections = {},
    menuBackdrop = nil,
    menu = nil,
    toggleMoved = false,
    logLabel = nil,
    learnStatusLabel = nil,
    remoteStatusLabel = nil,
    diagLabels = {},
}

local function getViewport()
    local camera = Workspace and Workspace.CurrentCamera
    if camera then
        local ok, size = pcall(function()
            return camera.ViewportSize
        end)
        if ok and size then
            return size
        end
    end
    return Vector2.new(1280, 720)
end

local function computeInsets()
    local top = 36
    local bottom = 12
    if GuiService then
        local ok, rect = pcall(function()
            return GuiService.TopbarInset
        end)
        if ok and rect and rect.Max then
            top = math.max(top, rect.Max.Y)
        end
        local ok2, topLeft, bottomRight = pcall(function()
            return GuiService:GetGuiInset()
        end)
        if ok2 then
            if topLeft then
                top = math.max(top, topLeft.Y)
            end
            if bottomRight then
                bottom = math.max(bottom, bottomRight.Y)
            end
        end
    end
    return top, bottom
end

local function isMobileDevice()
    if UserInputService then
        local ok, preferred = pcall(function()
            return UserInputService.PreferredInput
        end)
        if ok and preferred then
            local text = tostring(preferred):lower()
            if text:find("touch", 1, true) then
                return true
            end
        end
        local touch = false
        local keyboard = false
        pcall(function()
            touch = UserInputService.TouchEnabled
            keyboard = UserInputService.KeyboardEnabled
        end)
        if touch and not keyboard then
            return true
        end
    end
    return UI.viewport.X < 720
end

local function connect(signal, callback)
    if not signal then
        return nil
    end
    local ok, connection = pcall(function()
        return signal:Connect(callback)
    end)
    if ok then
        UI.connections[#UI.connections + 1] = connection
        return connection
    end
    return nil
end

local function makeDraggable(frame, handle, onMoved)
    if not frame or not handle then
        return
    end
    local dragging = false
    local moved = false
    local startPosition = nil
    local startInput = nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            startInput = input.Position
            startPosition = frame.Position
        end
    end)
    connect(UserInputService and UserInputService.InputChanged, function(input)
        if not dragging then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local delta = input.Position - startInput
        if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
            moved = true
        end
        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
        if onMoved then
            onMoved(moved)
        end
    end)
    connect(UserInputService and UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if onMoved then
                onMoved(moved)
            end
        end
    end)
end

local function makeLabel(parent, text, size, color, font, alignment)
    local label = newInstance("TextLabel", {
        Parent = parent,
        BackgroundTransparency = 1,
        Size = size or UDim2.new(1, 0, 0, 20),
        Font = font or Fonts.regular,
        Text = text or "",
        TextColor3 = color or Theme.text,
        TextSize = 14,
        TextXAlignment = alignment or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    return label
end

function UI.add(tab, gui, height)
    gui.AnchorPoint = Vector2.new(0, 0)
    gui.Position = UDim2.new(0, 10, 0, tab._y)
    gui.Size = UDim2.new(1, -20, 0, height)
    gui.Parent = tab.frame
    tab._y = tab._y + height + 6
    tab.frame.CanvasSize = UDim2.new(0, 0, 0, tab._y + 10)
    return gui
end

function UI.addLabel(tab, text, height, color, font)
    local label = makeLabel(tab.frame, text, UDim2.new(1, -20, 0, height or 20), color, font)
    return UI.add(tab, label, height or 20)
end

function UI.addSection(tab, title, subtitle)
    local holder = newInstance("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, subtitle and 42 or 26),
    })
    makeLabel(holder, title, UDim2.new(1, 0, 0, 20), Theme.accent, Fonts.bold)
    if subtitle then
        local sub = makeLabel(holder, subtitle, UDim2.new(1, 0, 0, 16), Theme.muted, Fonts.regular)
        sub.Position = UDim2.new(0, 0, 0, 20)
        sub.TextSize = 12
    end
    return UI.add(tab, holder, subtitle and 42 or 26)
end

function UI.addNote(tab, text, height, color)
    local label = makeLabel(tab.frame, text, UDim2.new(1, -20, 0, height or 34), color or Theme.muted, Fonts.regular)
    label.TextWrapped = true
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.TextSize = 12
    return UI.add(tab, label, height or 34)
end

function UI.addSpacer(tab, height)
    local spacer = newInstance("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, height or 8),
    })
    return UI.add(tab, spacer, height or 8)
end

function UI.addDivider(tab)
    local line = newInstance("Frame", {
        BackgroundColor3 = Theme.panelHover,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 0, 1),
    })
    return UI.add(tab, line, 1)
end

function UI.addButton(tab, text, callback, options)
    options = options or {}
    local height = options.height or 36
    local button = newInstance("TextButton", {
        BackgroundColor3 = options.color or Theme.panelLight,
        BackgroundTransparency = options.transparency or 0.05,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Fonts.bold,
        Text = text,
        TextColor3 = options.textColor or Theme.text,
        TextSize = options.textSize or 13,
        Size = UDim2.new(1, -20, 0, height),
    })
    corner(button, 7)
    stroke(button, options.strokeColor or Theme.panelHover, 1, 0.45)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = options.hoverColor or Theme.panelHover
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = options.color or Theme.panelLight
    end)
    local lastClick = nil
    button.Activated:Connect(function()
        local time = now()
        if lastClick and time - lastClick < 0.15 then
            return
        end
        lastClick = time
        local ok, err = pcall(callback, button)
        if not ok then
            Log.error("Button '" .. tostring(text) .. "': " .. tostring(err))
            UI.notify("Action failed: " .. tostring(err), Theme.danger)
        end
    end)
    UI.add(tab, button, height)
    return button
end

function UI.addToggle(tab, text, key, callback, options)
    options = options or {}
    local row = newInstance("TextButton", {
        BackgroundColor3 = Theme.panelLight,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        Size = UDim2.new(1, -20, 0, 36),
    })
    corner(row, 7)
    stroke(row, Theme.panelHover, 1, 0.55)
    local label = makeLabel(row, text, UDim2.new(1, -70, 1, 0), Theme.text, Fonts.regular)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(1, -70, 1, 0)

    local switch = newInstance("Frame", {
        BackgroundColor3 = Theme.panelHover,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 42, 0, 22),
        Position = UDim2.new(1, -52, 0.5, -11),
    })
    corner(switch, 999)
    local knob = newInstance("Frame", {
        BackgroundColor3 = Theme.white,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 2, 0.5, -9),
    })
    corner(knob, 999)
    knob.Parent = switch

    local function refresh()
        local enabled = Settings[key] == true
        switch.BackgroundColor3 = enabled and Theme.accent or Theme.panelHover
        knob.Position = enabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        label.TextColor3 = enabled and Theme.white or Theme.text
    end

    row.Activated:Connect(function()
        Settings[key] = not Settings[key]
        refresh()
        saveSetting(key)
        if callback then
            local ok, err = pcall(callback, Settings[key])
            if not ok then
                Log.error("Toggle '" .. tostring(text) .. "': " .. tostring(err))
            end
        end
    end)
    refresh()
    UI.add(tab, row, 36)
    return refresh
end

function UI.addSlider(tab, text, key, minValue, maxValue, step, suffix, callback)
    local holder = newInstance("Frame", {
        BackgroundColor3 = Theme.panelLight,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 0, 50),
    })
    corner(holder, 7)
    stroke(holder, Theme.panelHover, 1, 0.55)
    local label = makeLabel(holder, text, UDim2.new(1, -80, 0, 24), Theme.text, Fonts.regular)
    label.Position = UDim2.new(0, 10, 0, 2)
    local valueLabel = makeLabel(holder, "", UDim2.new(0, 70, 0, 24), Theme.accent, Fonts.bold, Enum.TextXAlignment.Right)
    valueLabel.Position = UDim2.new(1, -80, 0, 2)
    valueLabel.Size = UDim2.new(0, 70, 0, 24)

    local track = newInstance("Frame", {
        BackgroundColor3 = Theme.panelHover,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 0, 8),
        Position = UDim2.new(0, 10, 0, 30),
    })
    corner(track, 999)
    local fill = newInstance("Frame", {
        BackgroundColor3 = Theme.accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
    })
    corner(fill, 999)
    fill.Parent = track
    local knob = newInstance("Frame", {
        BackgroundColor3 = Theme.white,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 0, 0.5, -8),
    })
    corner(knob, 999)
    knob.Parent = track

    local function setValue(value, fireCallback)
        value = clamp(roundTo(value, step), minValue, maxValue)
        Settings[key] = value
        local display = step < 1 and string.format("%.2f", value) or tostring(math.floor(value + 0.5))
        valueLabel.Text = display .. (suffix or "")
        local alpha = (value - minValue) / math.max(maxValue - minValue, 0.0001)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, -8, 0.5, -8)
        if fireCallback and callback then
            local ok, err = pcall(callback, value)
            if not ok then
                Log.error("Slider '" .. tostring(text) .. "': " .. tostring(err))
            end
        end
    end

    local dragging = false
    local function beginDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            pcall(function()
                local absolute = track.AbsolutePosition
                local width = math.max(track.AbsoluteSize.X, 1)
                local alpha = clamp((input.Position.X - absolute.X) / width, 0, 1)
                setValue(minValue + (maxValue - minValue) * alpha, true)
            end)
        end
    end

    track.InputBegan:Connect(beginDrag)
    fill.InputBegan:Connect(beginDrag)
    knob.InputBegan:Connect(beginDrag)
    connect(UserInputService and UserInputService.InputChanged, function(input)
        if not dragging then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        pcall(function()
            local absolute = track.AbsolutePosition
            local width = math.max(track.AbsoluteSize.X, 1)
            local alpha = clamp((input.Position.X - absolute.X) / width, 0, 1)
            setValue(minValue + (maxValue - minValue) * alpha, true)
        end)
    end)
    connect(UserInputService and UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                saveSetting(key)
            end
        end
    end)

    setValue(Settings[key] or minValue, false)
    UI.add(tab, holder, 50)
    return setValue
end

function UI.addTextBox(tab, text, key, placeholder, callback)
    local holder = newInstance("Frame", {
        BackgroundColor3 = Theme.panelLight,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 0, 60),
    })
    corner(holder, 7)
    stroke(holder, Theme.panelHover, 1, 0.55)
    local label = makeLabel(holder, text, UDim2.new(1, -20, 0, 20), Theme.text, Fonts.regular)
    label.Position = UDim2.new(0, 10, 0, 2)
    local box = newInstance("TextBox", {
        BackgroundColor3 = Theme.panel,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Fonts.regular,
        PlaceholderColor3 = Theme.muted,
        PlaceholderText = placeholder or "",
        Text = tostring(Settings[key] or ""),
        TextColor3 = Theme.text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -20, 0, 28),
        Position = UDim2.new(0, 10, 0, 26),
    })
    corner(box, 5)
    padding(box, 6)
    box.FocusLost:Connect(function()
        Settings[key] = box.Text
        saveSetting(key)
        if callback then
            local ok, err = pcall(callback, box.Text)
            if not ok then
                Log.error("TextBox '" .. tostring(text) .. "': " .. tostring(err))
            end
        end
    end)
    UI.add(tab, holder, 60)
    return box
end

function UI.closeMenu()
    if UI.menu then
        UI.menu:Destroy()
        UI.menu = nil
    end
    if UI.menuBackdrop then
        UI.menuBackdrop:Destroy()
        UI.menuBackdrop = nil
    end
end

function UI.openMenu(button, options, onSelect)
    UI.closeMenu()
    if not options or #options == 0 then
        UI.notify("No options available.", Theme.warning)
        return
    end
    local backdrop = newInstance("TextButton", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 90,
        Parent = UI.screen,
    })
    backdrop.Activated:Connect(function()
        UI.closeMenu()
    end)
    UI.menuBackdrop = backdrop

    local itemHeight = 32
    local menuHeight = math.min(#options * itemHeight + 10, 260)
    local position = button.AbsolutePosition
    local x = clamp(position.X, 8, math.max(UI.viewport.X - 228, 8))
    local y = clamp(position.Y + button.AbsoluteSize.Y + 4, 8, math.max(UI.viewport.Y - menuHeight - 8, 8))
    local menu = newInstance("Frame", {
        BackgroundColor3 = Theme.panel,
        BorderSizePixel = 0,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, 220, 0, menuHeight),
        ZIndex = 100,
        Parent = UI.screen,
    })
    corner(menu, 8)
    stroke(menu, Theme.accent, 1, 0.45)
    local scroll = newInstance("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, #options * itemHeight),
        ScrollBarThickness = 3,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 101,
    })
    scroll.Parent = menu
    for index = 1, #options do
        local option = options[index]
        local optionText = type(option) == "table" and (option.label or option.value) or tostring(option)
        local optionValue = type(option) == "table" and (option.value ~= nil and option.value or option.label) or option
        local optionButton = newInstance("TextButton", {
            BackgroundColor3 = Theme.panelLight,
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = Fonts.regular,
            Text = tostring(optionText),
            TextColor3 = Theme.text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, -8, 0, itemHeight - 4),
            Position = UDim2.new(0, 4, 0, (index - 1) * itemHeight + 2),
            ZIndex = 102,
        })
        corner(optionButton, 5)
        optionButton.Activated:Connect(function()
            UI.closeMenu()
            if onSelect then
                local ok, err = pcall(onSelect, optionValue)
                if not ok then
                    Log.error("Select option: " .. tostring(err))
                end
            end
        end)
        optionButton.Parent = scroll
    end
    UI.menu = menu
end

function UI.addSelect(tab, text, getOptions, onSelect, options)
    options = options or {}
    local button = newInstance("TextButton", {
        BackgroundColor3 = Theme.panelLight,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Fonts.regular,
        Text = text,
        TextColor3 = Theme.text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -20, 0, 38),
    })
    corner(button, 7)
    stroke(button, Theme.panelHover, 1, 0.55)
    padding(button, 10)
    local arrow = makeLabel(button, "▼", UDim2.new(0, 20, 1, 0), Theme.accent, Fonts.regular, Enum.TextXAlignment.Right)
    arrow.Position = UDim2.new(1, -24, 0, 0)
    arrow.Size = UDim2.new(0, 20, 1, 0)
    button.Activated:Connect(function()
        local ok, list = pcall(function()
            return getOptions and getOptions() or {}
        end)
        if not ok or type(list) ~= "table" then
            UI.notify("Unable to build the option list.", Theme.warning)
            return
        end
        UI.openMenu(button, list, onSelect)
    end)
    UI.add(tab, button, 38)
    return button
end

function UI.addKeybind(tab, text, key, callback)
    local row = newInstance("Frame", {
        BackgroundColor3 = Theme.panelLight,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 0, 38),
    })
    corner(row, 7)
    stroke(row, Theme.panelHover, 1, 0.55)
    local label = makeLabel(row, text, UDim2.new(1, -120, 1, 0), Theme.text, Fonts.regular)
    label.Position = UDim2.new(0, 10, 0, 0)
    local button = newInstance("TextButton", {
        BackgroundColor3 = Theme.panel,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Fonts.bold,
        Text = tostring(Settings[key] or "None"),
        TextColor3 = Theme.accent,
        TextSize = 12,
        Size = UDim2.new(0, 100, 0, 26),
        Position = UDim2.new(1, -110, 0.5, -13),
    })
    corner(button, 5)
    local listening = false
    local function refresh()
        button.Text = listening and "Press a key..." or tostring(Settings[key] or "None")
        button.TextColor3 = listening and Theme.warning or Theme.accent
    end
    button.Activated:Connect(function()
        listening = true
        refresh()
    end)
    connect(UserInputService and UserInputService.InputBegan, function(input, processed)
        if not listening then
            return
        end
        if input.KeyCode then
            listening = false
            if input.KeyCode ~= Enum.KeyCode.Escape then
                Settings[key] = input.KeyCode.Name
                saveSetting(key)
                if callback then
                    pcall(callback, Settings[key])
                end
            end
            refresh()
        end
    end)
    button.Parent = row
    UI.add(tab, row, 38)
    return refresh
end

function UI.createTab(name)
    local tab = {
        name = name,
        _y = 8,
    }
    local frame = newInstance("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        Parent = UI.content,
    })
    tab.frame = frame

    local pcButton = newInstance("TextButton", {
        BackgroundColor3 = Theme.panel,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Fonts.regular,
        Text = name,
        TextColor3 = Theme.muted,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -12, 0, 32),
        Position = UDim2.new(0, 6, 0, 8 + (#UI.tabOrder) * 36),
        Parent = UI.sidebar,
    })
    corner(pcButton, 6)
    padding(pcButton, 8)
    tab.pcButton = pcButton

    local mobileButton = newInstance("TextButton", {
        BackgroundColor3 = Theme.panel,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Fonts.regular,
        Text = name,
        TextColor3 = Theme.muted,
        TextSize = 12,
        Size = UDim2.new(0, 82, 0, 28),
        Position = UDim2.new(0, 4 + (#UI.tabOrder) * 86, 0, 4),
        Parent = UI.tabBarScroll,
    })
    corner(mobileButton, 5)
    tab.mobileButton = mobileButton

    local function select()
        UI.selectTab(name)
    end
    pcButton.Activated:Connect(select)
    mobileButton.Activated:Connect(select)

    UI.tabs[name] = tab
    UI.tabOrder[#UI.tabOrder + 1] = name
    if UI.tabBarScroll then
        UI.tabBarScroll.CanvasSize = UDim2.new(0, 4 + (#UI.tabOrder + 1) * 86, 0, 0)
    end
    UI.tabButtons[name] = { pc = pcButton, mobile = mobileButton }
    if not UI.activeTab then
        UI.selectTab(name)
    end
    return tab
end

function UI.selectTab(name)
    UI.activeTab = name
    for tabName, tab in pairs(UI.tabs) do
        local active = tabName == name
        tab.frame.Visible = active
        local buttons = UI.tabButtons[tabName]
        if buttons then
            if buttons.pc then
                buttons.pc.BackgroundColor3 = active and Theme.accentDark or Theme.panel
                buttons.pc.TextColor3 = active and Theme.white or Theme.muted
            end
            if buttons.mobile then
                buttons.mobile.BackgroundColor3 = active and Theme.accentDark or Theme.panel
                buttons.mobile.TextColor3 = active and Theme.white or Theme.muted
            end
        end
    end
end

function UI.getTab(name)
    return UI.tabs[name] or UI.createTab(name)
end

function UI.notify(message, color)
    if not Settings.notifications or not UI.screen then
        Log.info(message)
        return
    end
    if not UI.toastFrame then
        local frame = newInstance("Frame", {
            BackgroundColor3 = Theme.panel,
            BackgroundTransparency = 0.08,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 360, 0, 40),
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 60),
            ZIndex = 200,
            Parent = UI.screen,
        })
        corner(frame, 8)
        stroke(frame, Theme.accent, 1, 0.4)
        local label = makeLabel(frame, "", UDim2.new(1, -20, 1, 0), Theme.text, Fonts.regular)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Size = UDim2.new(1, -20, 1, 0)
        label.TextWrapped = true
        label.TextSize = 13
        label.ZIndex = 201
        UI.toastFrame = frame
        UI.toastLabel = label
    end
    UI.toastToken = UI.toastToken + 1
    local token = UI.toastToken
    UI.toastLabel.Text = tostring(message)
    UI.toastLabel.TextColor3 = color or Theme.text
    UI.toastFrame.Visible = true
    task.delay(3.2, function()
        if token == UI.toastToken and UI.toastFrame and UI.toastFrame.Parent then
            pcall(function()
                UI.toastFrame.Visible = false
            end)
        end
    end)
end

local function notify(message, color)
    UI.notify(message, color)
end

function UI.toggleWindow()
    if not UI.window then
        return
    end
    if UI.hidden then
        UI.hidden = false
        UI.window.Visible = true
        if UI.toggleButton then
            UI.toggleButton.Visible = false
        end
    else
        UI.hidden = true
        UI.window.Visible = false
        if UI.toggleButton and (Settings.showToggleButton or UI.mobile) then
            UI.toggleButton.Visible = true
        end
    end
end

function UI.showWindow()
    UI.hidden = false
    if UI.window then
        UI.window.Visible = true
    end
    if UI.toggleButton then
        UI.toggleButton.Visible = false
    end
end

function UI.hideWindow()
    UI.hidden = true
    if UI.window then
        UI.window.Visible = false
    end
    if UI.toggleButton and (Settings.showToggleButton or UI.mobile) then
        UI.toggleButton.Visible = true
    end
end

function UI.applyLayout()
    UI.viewport = getViewport()
    UI.mobile = isMobileDevice()
    UI.topInset, UI.bottomInset = computeInsets()

    if UI.window then
        if UI.minimised then
            UI.window.Size = UDim2.new(0, UI.viewport.X - 24, 0, 44)
            UI.window.Position = UDim2.new(0.5, 0, 0, UI.topInset + 8)
            UI.window.AnchorPoint = Vector2.new(0.5, 0)
            if UI.body then
                UI.body.Visible = false
            end
        else
            if UI.body then
                UI.body.Visible = true
            end
            if UI.mobile then
                local width = clamp(UI.viewport.X - 20, 300, 560)
                local height = clamp(UI.viewport.Y * 0.72, 360, 640)
                UI.window.Size = UDim2.new(0, width, 0, height)
                UI.window.Position = UDim2.new(0.5, 0, 1, -UI.bottomInset - 8)
                UI.window.AnchorPoint = Vector2.new(0.5, 1)
            else
                local width = clamp(UI.viewport.X * 0.44, 600, 780)
                local height = clamp(UI.viewport.Y * 0.72, 440, 660)
                UI.window.Size = UDim2.new(0, width, 0, height)
                UI.window.Position = UDim2.new(0.5, 0, 0.5, 0)
                UI.window.AnchorPoint = Vector2.new(0.5, 0.5)
            end
        end
    end

    if UI.sidebar then
        UI.sidebar.Visible = not UI.mobile
    end
    if UI.tabBar then
        UI.tabBar.Visible = UI.mobile
    end
    if UI.content then
        if UI.mobile then
            UI.content.Position = UDim2.new(0, 0, 0, 36)
            UI.content.Size = UDim2.new(1, 0, 1, -36)
        else
            UI.content.Position = UDim2.new(0, 152, 0, 0)
            UI.content.Size = UDim2.new(1, -152, 1, 0)
        end
    end

    if UI.toggleButton and not UI.toggleMoved then
        UI.toggleButton.Position = UDim2.new(1, -70, 1, -UI.bottomInset - 70)
    end
    if UI.hud then
        UI.hud.Position = UDim2.new(0, 12, 0, UI.topInset + 8)
    end
    if UI.toastFrame then
        UI.toastFrame.Position = UDim2.new(0.5, 0, 0, UI.topInset + 8)
        UI.toastFrame.Size = UDim2.new(0, math.min(UI.viewport.X - 30, 380), 0, 40)
    end
    if UI.menu then
        UI.closeMenu()
    end
end

function UI.buildHUD()
    if UI.hud then
        return
    end
    local hud = newInstance("Frame", {
        BackgroundColor3 = Theme.panel,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 196, 0, 88),
        Position = UDim2.new(0, 12, 0, 60),
        ZIndex = 50,
        Parent = UI.screen,
    })
    corner(hud, 8)
    stroke(hud, Theme.accent, 1, 0.55)
    local title = makeLabel(hud, "SAS HUD", UDim2.new(1, -16, 0, 20), Theme.accent, Fonts.bold)
    title.Position = UDim2.new(0, 10, 0, 2)
    title.Size = UDim2.new(1, -16, 0, 20)
    title.TextSize = 11
    local function entry(index, key, labelText)
        local label = makeLabel(hud, labelText .. ": ?", UDim2.new(1, -16, 0, 16), Theme.text, Fonts.code)
        label.Position = UDim2.new(0, 10, 0, 22 + (index - 1) * 16)
        label.Size = UDim2.new(1, -16, 0, 16)
        label.TextSize = 11
        UI.hudLabels[key] = label
    end
    entry(1, "cash", "Cash")
    entry(2, "power", "Power")
    entry(3, "rebirth", "Rebirth")
    entry(4, "remotes", "Remotes")
    UI.hud = hud
end

function UI.updateHUD(data)
    if not UI.hud then
        return
    end
    UI.hud.Visible = Settings.hud
    if data then
        if UI.hudLabels.cash then
            UI.hudLabels.cash.Text = "Cash: " .. (data.cash and compact(data.cash) or "?")
        end
        if UI.hudLabels.power then
            UI.hudLabels.power.Text = "Power: " .. (data.power and compact(data.power) or "?")
        end
        if UI.hudLabels.rebirth then
            UI.hudLabels.rebirth.Text = "Rebirth: " .. (data.rebirth and compact(data.rebirth) or "?")
        end
        if UI.hudLabels.remotes then
            local text = "Remotes: " .. tostring(data.remotes or 0)
            if data.fps then
                text = text .. " • " .. tostring(data.fps) .. " FPS"
            end
            UI.hudLabels.remotes.Text = text
        end
    end
end

function UI.buildToggleButton()
    local button = newInstance("TextButton", {
        BackgroundColor3 = Theme.accentDark,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Fonts.bold,
        Text = "SAS",
        TextColor3 = Theme.white,
        TextSize = 13,
        Size = UDim2.new(0, 54, 0, 54),
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(1, -70, 1, -80),
        Visible = false,
        ZIndex = 150,
        Parent = UI.screen,
    })
    corner(button, 999)
    stroke(button, Theme.accent, 1, 0.2)
    local moved = false
    local function onMoved(state)
        if state then
            moved = true
            UI.toggleMoved = true
        end
    end
    makeDraggable(button, button, onMoved)
    button.Activated:Connect(function()
        if moved then
            moved = false
            return
        end
        UI.showWindow()
    end)
    UI.toggleButton = button
end

function UI.buildShell()
    UI.viewport = getViewport()
    UI.mobile = isMobileDevice()
    UI.topInset, UI.bottomInset = computeInsets()

    local playerGui = nil
    pcall(function()
        playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end)
    if not playerGui then
        pcall(function()
            playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
        end)
    end

    local parent = nil
    local getHiddenGui = execFn("gethui")
    if getHiddenGui then
        local ok, hidden = pcall(getHiddenGui)
        if ok and hidden then
            parent = hidden
        end
    end
    if not parent then
        parent = Services.CoreGui
    end
    if not parent then
        parent = playerGui
    end

    if parent then
        local existing = nil
        pcall(function()
            existing = parent:FindFirstChild("SAS_Hub")
        end)
        if existing then
            pcall(function()
                existing:Destroy()
            end)
        end
    end

    local screen = newInstance("ScreenGui", {
        Name = "SAS_Hub",
        ResetOnSpawn = false,
        DisplayOrder = 999999,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = parent,
    })
    pcall(function()
        screen.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
    end)
    pcall(function()
        screen.ClipToDeviceSafeArea = true
    end)
    if not screen.Parent and playerGui then
        pcall(function()
            screen.Parent = playerGui
        end)
    end
    if not screen.Parent then
        Log.warn("No writable GUI parent found; the menu may not be visible.")
    end
    UI.screen = screen

    local window = newInstance("Frame", {
        Name = "Window",
        BackgroundColor3 = Theme.background,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 680, 0, 500),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
        Parent = screen,
    })
    corner(window, 12)
    stroke(window, Theme.accent, 1, 0.55)
    UI.window = window

    local header = newInstance("Frame", {
        Name = "Header",
        BackgroundColor3 = Theme.panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 44),
        Parent = window,
    })
    UI.header = header
    local headerAccent = newInstance("Frame", {
        BackgroundColor3 = Theme.accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 0, 22),
        Position = UDim2.new(0, 12, 0.5, -11),
        Parent = header,
    })
    corner(headerAccent, 2)
    local title = makeLabel(header, "STEAL A SUPERPOWER", UDim2.new(1, -180, 0, 20), Theme.white, Fonts.bold)
    title.Position = UDim2.new(0, 24, 0, 3)
    title.Size = UDim2.new(1, -180, 0, 20)
    title.TextSize = 14
    local subtitle = makeLabel(header, "Universal • v" .. SCRIPT_VERSION .. " • " .. ExecutorName, UDim2.new(1, -180, 0, 14), Theme.muted, Fonts.regular)
    subtitle.Position = UDim2.new(0, 24, 0, 23)
    subtitle.Size = UDim2.new(1, -180, 0, 14)
    subtitle.TextSize = 10

    local minimize = newInstance("TextButton", {
        BackgroundColor3 = Theme.panelLight,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Fonts.bold,
        Text = "—",
        TextColor3 = Theme.text,
        TextSize = 14,
        Size = UDim2.new(0, 28, 0, 24),
        Position = UDim2.new(1, -70, 0.5, -12),
        Parent = header,
    })
    corner(minimize, 5)
    local close = newInstance("TextButton", {
        BackgroundColor3 = Theme.panelLight,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Fonts.bold,
        Text = "×",
        TextColor3 = Theme.danger,
        TextSize = 16,
        Size = UDim2.new(0, 28, 0, 24),
        Position = UDim2.new(1, -36, 0.5, -12),
        Parent = header,
    })
    corner(close, 5)
    close.Activated:Connect(function()
        UI.hideWindow()
        notify("Window hidden. Use the SAS button or " .. tostring(Settings.uiKeybind) .. " to reopen.", Theme.muted)
    end)
    minimize.Activated:Connect(function()
        UI.minimised = not UI.minimised
        UI.applyLayout()
    end)
    makeDraggable(window, header)

    local body = newInstance("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        Parent = window,
    })
    UI.body = body

    local sidebar = newInstance("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Theme.panel,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 152, 1, 0),
        Parent = body,
    })
    UI.sidebar = sidebar

    local tabBar = newInstance("Frame", {
        Name = "TabBar",
        BackgroundColor3 = Theme.panel,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        Visible = false,
        Parent = body,
    })
    UI.tabBar = tabBar
    local tabBarScroll = newInstance("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = tabBar,
    })
    UI.tabBarScroll = tabBarScroll

    local content = newInstance("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -152, 1, 0),
        Position = UDim2.new(0, 152, 0, 0),
        Parent = body,
    })
    UI.content = content

    connect(UserInputService and UserInputService.InputBegan, function(input, processed)
        if processed then
            return
        end
        if not input.KeyCode then
            return
        end
        if input.KeyCode.Name ~= tostring(Settings.uiKeybind) then
            return
        end
        local focused = nil
        pcall(function()
            focused = UserInputService:GetFocusedTextBox()
        end)
        if focused then
            return
        end
        UI.toggleWindow()
    end)

    local function watchCamera()
        local camera = Workspace and Workspace.CurrentCamera
        if not camera or camera == UI.watchedCamera then
            return
        end
        UI.watchedCamera = camera
        connect(camera:GetPropertyChangedSignal("ViewportSize"), function()
            UI.applyLayout()
        end)
    end
    watchCamera()
    connect(Workspace and Workspace:GetPropertyChangedSignal("CurrentCamera"), function()
        watchCamera()
        UI.applyLayout()
    end)

    Log.info("UI shell created for " .. (UI.mobile and "mobile" or "PC") .. " (" .. tostring(math.floor(UI.viewport.X)) .. "x" .. tostring(math.floor(UI.viewport.Y)) .. ").")
end

function UI.build()
    UI.buildShell()
    if UI.buildTabs then
        UI.buildTabs()
    end
    UI.buildToggleButton()
    UI.buildHUD()
    UI.applyLayout()
    UI.showWindow()
    UI.updateHUD({ remotes = 0 })
end
-- ---------------------------------------------------------------------------
-- Remote discovery
-- ---------------------------------------------------------------------------

Remotes = {
    list = {},
    byPath = {},
    lastScan = 0,
    scanning = false,
    connections = {},
}

local ACTION_KEYWORDS = {
    attack = { "attack", "hit", "damage", "punch", "combat", "strike", "slash", "swing", "ability", "skill", "use" },
    openPack = { "open", "unbox", "pull", "pack", "crate", "spin" },
    claimPack = { "claim", "collect", "grab", "pickup", "pick", "pack", "drop" },
    bankPack = { "bank", "deposit", "store", "pack" },
    placeCard = { "place", "holder", "card", "slot", "deploy" },
    fuse = { "fuse", "merge", "combine", "craft" },
    rebirth = { "rebirth", "prestige", "reincarnate", "reset" },
    upgrade = { "upgrade", "buy", "purchase", "level", "enhance" },
    equipAura = { "aura", "equip", "skin" },
    equipTrail = { "trail", "equip" },
    reward = { "reward", "daily", "offline", "index", "free", "claim" },
    code = { "code", "redeem", "promo", "gift" },
}

local function isRemoteObject(object)
    local ok, result = pcall(function()
        return object:IsA("RemoteEvent")
            or object:IsA("UnreliableRemoteEvent")
            or object:IsA("RemoteFunction")
    end)
    return ok and result == true
end

function Remotes.add(object)
    if not object then
        return
    end
    local className = nil
    pcall(function()
        className = object.ClassName
    end)
    if className ~= "RemoteEvent" and className ~= "UnreliableRemoteEvent" and className ~= "RemoteFunction" then
        return
    end
    local ok, path = pcall(function()
        return object:GetFullName()
    end)
    if not ok or not path or Remotes.byPath[path] then
        return
    end
    if not isRemoteObject(object) then
        return
    end
    local kind = "event"
    pcall(function()
        if object:IsA("RemoteFunction") then
            kind = "function"
        end
    end)
    local lower = (tostring(object.Name) .. " " .. tostring(path)):lower()
    local score = 0
    local keywords = {
        "remote", "event", "pack", "open", "claim", "reward", "upgrade", "rebirth",
        "aura", "trail", "boss", "zone", "attack", "damage", "code", "fuse", "equip",
    }
    for index = 1, #keywords do
        if lower:find(keywords[index], 1, true) then
            score = score + 1
        end
    end
    local record = {
        object = object,
        path = path,
        name = tostring(object.Name),
        kind = kind,
        lower = lower,
        score = score,
    }
    Remotes.byPath[path] = record
    Remotes.list[#Remotes.list + 1] = record
    if UI.remoteStatusLabel then
        UI.remoteStatusLabel.Text = "Discovered remotes: " .. tostring(#Remotes.list)
    end
    if UI.diagLabels.remotes then
        UI.diagLabels.remotes.Text = "Remotes discovered: " .. tostring(#Remotes.list)
    end
end

function Remotes.scan(root)
    if not root then
        return
    end
    local ok, descendants = pcall(function()
        return root:GetDescendants()
    end)
    if not ok or not descendants then
        return
    end
    for index = 1, #descendants do
        Remotes.add(descendants[index])
    end
end

function Remotes.scanAll()
    if Remotes.scanning then
        return
    end
    Remotes.scanning = true
    local ok, err = pcall(function()
        Remotes.scan(ReplicatedStorage)
        Remotes.scan(Workspace)
        Remotes.scan(LocalPlayer)
        Remotes.lastScan = now()
        Log.info("Remote scan complete: " .. tostring(#Remotes.list) .. " discovered.")
    end)
    Remotes.scanning = false
    if not ok then
        Log.warn("Remote scan failed: " .. tostring(err))
    end
end

function Remotes.installWatchers()
    local function watch(container)
        if not container then
            return
        end
        local ok, connection = pcall(function()
            return container.DescendantAdded:Connect(function(object)
                Remotes.add(object)
            end)
        end)
        if ok then
            Remotes.connections[#Remotes.connections + 1] = connection
        end
    end
    watch(ReplicatedStorage)
    watch(Workspace)
end

function Remotes.resolve(path)
    if not path then
        return nil
    end
    local record = Remotes.byPath[path]
    if record and record.object and record.object.Parent then
        return record.object
    end
    local current = game
    local pathText = tostring(path):gsub("^game%.", "")
    for part in string.gmatch(pathText, "[^%.]+") do
        local nextObject = nil
        local ok = pcall(function()
            nextObject = current:FindFirstChild(part)
        end)
        if not ok or not nextObject then
            local okRecursive, recursive = pcall(function()
                return game:FindFirstChild(part, true)
            end)
            if okRecursive then
                nextObject = recursive
            end
        end
        if not nextObject then
            return nil
        end
        current = nextObject
    end
    return current
end

function Remotes.findByAction(action)
    local keywords = ACTION_KEYWORDS[action]
    if not keywords then
        return nil
    end
    local best = nil
    local bestScore = 0
    for index = 1, #Remotes.list do
        local record = Remotes.list[index]
        local score = 0
        for keywordIndex = 1, #keywords do
            if record.lower:find(keywords[keywordIndex], 1, true) then
                score = score + 1
            end
        end
        if score > bestScore then
            bestScore = score
            best = record
        end
    end
    if best and bestScore >= 1 then
        return best, bestScore
    end
    return nil, 0
end

function Remotes.sorted()
    local copy = {}
    for index = 1, #Remotes.list do
        copy[index] = Remotes.list[index]
    end
    table.sort(copy, function(a, b)
        if a.score == b.score then
            return a.path < b.path
        end
        return a.score > b.score
    end)
    return copy
end

-- ---------------------------------------------------------------------------
-- Learn Mode / adapter
-- ---------------------------------------------------------------------------

Learn = {
    capturing = false,
    entries = {},
    maxEntries = 400,
    stepIndex = 1,
    stepStart = 1,
    suppress = false,
    hookInstalled = false,
    oldNamecall = nil,
    steps = {
        { label = "Attack a target", action = "attack" },
        { label = "Open a pack", action = "openPack" },
        { label = "Claim or grab a pack", action = "claimPack" },
        { label = "Bank a pack", action = "bankPack" },
        { label = "Place a card on a holder", action = "placeCard" },
        { label = "Fuse cards", action = "fuse" },
        { label = "Rebirth", action = "rebirth" },
        { label = "Buy an upgrade", action = "upgrade" },
        { label = "Equip an aura", action = "equipAura" },
        { label = "Equip a trail", action = "equipTrail" },
        { label = "Claim a reward", action = "reward" },
        { label = "Redeem a code", action = "code" },
    },
}

local TypeOf = typeof or type

local function serializeArg(value, depth, seen)
    depth = depth or 1
    seen = seen or {}
    local valueType = TypeOf(value)
    if valueType == "Instance" then
        local okPath, path = pcall(function()
            return value:GetFullName()
        end)
        return {
            t = "instance",
            class = tostring(value.ClassName or "Instance"),
            path = okPath and path or nil,
            name = tostring(value.Name or ""),
        }
    elseif valueType == "EnumItem" then
        return { t = "enum", v = tostring(value) }
    elseif valueType == "string" then
        if value == LocalPlayer.Name then
            return { t = "player", v = "LocalPlayer" }
        end
        return { t = "string", v = value }
    elseif valueType == "number" or valueType == "boolean" then
        return { t = valueType, v = value }
    elseif value == nil then
        return { t = "nil" }
    elseif valueType == "table" then
        if depth > 4 then
            return { t = "table", v = "<depth>" }
        end
        if seen[value] then
            return { t = "table", v = "<cycle>" }
        end
        seen[value] = true
        local items = {}
        local count = 0
        for key, item in pairs(value) do
            if count >= 100 then
                break
            end
            if type(key) == "number" or type(key) == "string" then
                items[#items + 1] = {
                    k = key,
                    v = serializeArg(item, depth + 1, seen),
                }
                count = count + 1
            end
        end
        seen[value] = nil
        return { t = "table", v = items }
    end
    return { t = "other", v = tostring(value) }
end

function Learn.updateStatus()
    if UI.learnStatusLabel then
        local step = Learn.steps[Learn.stepIndex]
        UI.learnStatusLabel.Text = string.format(
            "%s • %d captured • %d actions known",
            Learn.capturing and "CAPTURING" or "Idle",
            #Learn.entries,
            Adapter and Adapter.count and Adapter.count() or 0
        )
        if step then
            UI.learnStatusLabel.Text = UI.learnStatusLabel.Text .. " • Step: " .. step.label
        end
    end
    if UI.diagLabels.learn then
        UI.diagLabels.learn.Text = "Learn: " .. (Learn.capturing and "on" or "off") .. " / " .. tostring(#Learn.entries) .. " calls"
    end
end

function Learn.record(remote, method, args)
    if Learn.suppress or not Learn.capturing then
        return
    end
    if method ~= "FireServer" and method ~= "InvokeServer" then
        return
    end
    Learn.suppress = true
    local ok, err = pcall(function()
        local okPath, path = pcall(function()
            return remote:GetFullName()
        end)
        if not okPath or not path then
            return
        end
        local serialized = {}
        for index = 1, #args do
            serialized[index] = serializeArg(args[index], 1, {})
        end
        local step = Learn.steps[Learn.stepIndex]
        Learn.entries[#Learn.entries + 1] = {
            remote = path,
            method = method,
            args = serialized,
            step = step and step.action or "general",
            stepLabel = step and step.label or "General",
            time = os.time(),
        }
        if #Learn.entries > Learn.maxEntries then
            table.remove(Learn.entries, 1)
            if Learn.stepStart > 1 then
                Learn.stepStart = Learn.stepStart - 1
            end
        end
        Learn.updateStatus()
    end)
    Learn.suppress = false
    if not ok then
        Log.warn("Learn capture failed: " .. tostring(err))
    end
end

function Learn.installHook()
    if Learn.hookInstalled then
        return true
    end
    local hookMetamethod = execFn("hookmetamethod")
    local getNamecallMethod = execFn("getnamecallmethod")
    if hookMetamethod and getNamecallMethod then
        local oldNamecall = nil
        local ok = pcall(function()
            oldNamecall = hookMetamethod(game, "__namecall", function(self, ...)
                local method = getNamecallMethod()
                if method == "FireServer" or method == "InvokeServer" then
                    if not Learn.suppress then
                        local args = { ... }
                        pcall(Learn.record, self, method, args)
                    end
                end
                return oldNamecall(self, ...)
            end)
        end)
        if ok and oldNamecall then
            Learn.oldNamecall = oldNamecall
            Learn.hookInstalled = true
            Log.info("Namecall hook installed (Learn Mode ready).")
            return true
        end
    end

    local getRawMetatable = execFn("getrawmetatable") or rawget(_G, "getrawmetatable")
    local setReadonly = execFn("setreadonly") or rawget(_G, "setreadonly")
    if getRawMetatable and setReadonly and getNamecallMethod then
        local ok = pcall(function()
            local metatable = getRawMetatable(game)
            if not metatable or not rawget(metatable, "__namecall") then
                return
            end
            local oldNamecall = rawget(metatable, "__namecall")
            setReadonly(metatable, false)
            metatable.__namecall = function(self, ...)
                local method = getNamecallMethod()
                if method == "FireServer" or method == "InvokeServer" then
                    if not Learn.suppress then
                        local args = { ... }
                        pcall(Learn.record, self, method, args)
                    end
                end
                return oldNamecall(self, ...)
            end
            setReadonly(metatable, true)
            Learn.oldNamecall = oldNamecall
            Learn.hookInstalled = true
        end)
        if ok and Learn.hookInstalled then
            Log.info("Namecall hook installed through raw metatable.")
            return true
        end
    end

    Log.warn("Learn Mode cannot install a namecall hook with this executor. Manual profiles still work.")
    return false
end

function Learn.start()
    if not Learn.installHook() then
        notify("This executor blocks hooks. Learn Mode is unavailable.", Theme.warning)
        return
    end
    Learn.capturing = true
    Learn.stepStart = #Learn.entries + 1
    Learn.updateStatus()
    notify("Learn Mode started. Perform the selected action once.", Theme.good)
end

function Learn.stop()
    Learn.capturing = false
    Learn.updateStatus()
    notify("Learn Mode stopped. " .. tostring(#Learn.entries) .. " calls captured.", Theme.muted)
end

function Learn.clear()
    Learn.entries = {}
    Learn.stepStart = 1
    Learn.updateStatus()
    notify("Capture log cleared.", Theme.muted)
end

function Learn.nextStep()
    Learn.stepIndex = Learn.stepIndex + 1
    if Learn.stepIndex > #Learn.steps then
        Learn.stepIndex = 1
    end
    Learn.stepStart = #Learn.entries + 1
    Learn.updateStatus()
    notify("Learn step: " .. Learn.steps[Learn.stepIndex].label, Theme.accent)
end

function Learn.currentStep()
    return Learn.steps[Learn.stepIndex]
end

function Learn.saveCurrentStep()
    local step = Learn.currentStep()
    if not step then
        return
    end
    local chosen = nil
    for index = #Learn.entries, math.max(1, Learn.stepStart), -1 do
        local entry = Learn.entries[index]
        if entry.step == step.action then
            chosen = entry
            break
        end
    end
    if not chosen then
        for index = #Learn.entries, 1, -1 do
            if Learn.entries[index].step == step.action then
                chosen = Learn.entries[index]
                break
            end
        end
    end
    if not chosen then
        notify("No " .. step.label .. " call captured yet. Start capture and do it once.", Theme.warning)
        return
    end
    Adapter.profile.actions[step.action] = {
        remote = chosen.remote,
        method = chosen.method,
        args = chosen.args,
        source = "learned",
        savedAt = os.time(),
        step = step.label,
    }
    local _, saved = Learn.saveProfile()
    Learn.updateStatus()
    if saved then
        notify("Mapped " .. step.action .. " -> " .. chosen.remote, Theme.good)
    else
        notify("Mapped " .. step.action .. " for this session. Executor file writing is unavailable, so the profile will not persist.", Theme.warning)
    end
    Log.info("Learned " .. step.action .. " = " .. chosen.remote .. " (" .. chosen.method .. ").")
end

function Learn.saveProfile()
    local placeVersion = 0
    pcall(function()
        placeVersion = game.PlaceVersion or 0
    end)
    Adapter.profile.gameId = GAME_ID
    Adapter.profile.placeVersion = placeVersion
    Adapter.profile.updated = os.time()
    local encoded = jsonEncode(Adapter.profile)
    local savedVersion = writeFile("profiles/" .. tostring(placeVersion) .. ".json", encoded)
    local savedGeneric = writeFile("profile.json", encoded)
    return encoded, (savedVersion or savedGeneric)
end

function Learn.loadProfile()
    local placeVersion = 0
    pcall(function()
        placeVersion = game.PlaceVersion or 0
    end)
    local raw = readFile("profiles/" .. tostring(placeVersion) .. ".json") or readFile("profile.json")
    if not raw then
        Learn.updateStatus()
        return false
    end
    local data = jsonDecode(raw)
    if type(data) ~= "table" or type(data.actions) ~= "table" then
        Learn.updateStatus()
        return false
    end
    Adapter.profile = data
    if type(Adapter.profile.actions) ~= "table" then
        Adapter.profile.actions = {}
    end
    if tonumber(Adapter.profile.placeVersion or -1) ~= placeVersion then
        Log.warn("Loaded profile was saved for PlaceVersion " .. tostring(Adapter.profile.placeVersion) .. " (current " .. tostring(placeVersion) .. "). Re-check mappings if actions fail.")
    end
    Log.info("Loaded learned profile with " .. tostring(Adapter.count()) .. " action(s).")
    Learn.updateStatus()
    return true
end

function Learn.export()
    local encoded = Learn.saveProfile()
    if copyText(encoded) then
        notify("Profile JSON copied to clipboard.", Theme.good)
    else
        notify("Clipboard unavailable. Profile saved to executor files.", Theme.warning)
    end
    return encoded
end

-- ---------------------------------------------------------------------------
-- Adapter
-- ---------------------------------------------------------------------------

Adapter = {
    profile = { actions = {}, gameId = GAME_ID },
    logged = {},
}

function Adapter.count()
    local count = 0
    for _ in pairs(Adapter.profile.actions or {}) do
        count = count + 1
    end
    return count
end

function Adapter.get(action)
    local learned = Adapter.profile.actions and Adapter.profile.actions[action]
    if learned and learned.remote then
        return learned
    end
    if Settings.autoResolve then
        local record, score = Remotes.findByAction(action)
        if record and score >= 2 then
            if not Adapter.logged[action] then
                Adapter.logged[action] = true
                Log.info("Auto-resolved " .. action .. " -> " .. record.path)
            end
            return {
                remote = record.path,
                method = record.kind == "function" and "InvokeServer" or "FireServer",
                args = {},
                source = "auto",
                score = score,
            }
        end
    end
    return nil
end

function Adapter.compileArg(arg, context)
    if type(arg) ~= "table" then
        return nil
    end
    if arg.t == "instance" then
        local pathText = tostring(arg.path or "")
        if context then
            if arg.class == "Player" and context.targetPlayer then
                return context.targetPlayer
            end
            if arg.class == "Humanoid" and context.humanoid then
                return context.humanoid
            end
            if pathText:find("%.Humanoid$") and context.humanoid then
                return context.humanoid
            end
            if arg.class == "BasePart" then
                if context.targetPart then
                    return context.targetPart
                end
                if context.targetModel then
                    return context.targetModel
                end
            end
            if (arg.class == "Model" or arg.class == "Instance") and context.targetModel then
                return context.targetModel
            end
        end
        return Remotes.resolve(arg.path)
    elseif arg.t == "player" then
        if arg.v == "LocalPlayer" then
            return LocalPlayer
        end
        local named = nil
        if type(arg.v) == "string" and Players then
            pcall(function()
                named = Players:FindFirstChild(arg.v)
            end)
        end
        if named then
            return named
        end
        if context and context.targetPlayer then
            return context.targetPlayer
        end
        return LocalPlayer
    elseif arg.t == "string" or arg.t == "number" or arg.t == "boolean" then
        return arg.v
    elseif arg.t == "nil" then
        return nil
    elseif arg.t == "enum" then
        return nil
    elseif arg.t == "table" then
        if type(arg.v) ~= "table" then
            return {}
        end
        local result = {}
        for index = 1, #arg.v do
            local item = arg.v[index]
            if type(item) == "table" and item.k ~= nil then
                result[item.k] = Adapter.compileArg(item.v, context)
            end
        end
        return result
    end
    return nil
end

function Adapter.fire(action, context)
    local mapping = Adapter.get(action)
    if not mapping then
        return false, "unmapped"
    end
    local remote = Remotes.resolve(mapping.remote)
    if not remote then
        if not Adapter.logged["missing:" .. action] then
            Adapter.logged["missing:" .. action] = true
            Log.warn("Remote for " .. action .. " not found: " .. tostring(mapping.remote))
        end
        return false, "missing"
    end
    local argCount = #(mapping.args or {})
    local args = {}
    for index = 1, argCount do
        args[index] = Adapter.compileArg(mapping.args[index], context)
    end
    Learn.suppress = true
    local ok, err = pcall(function()
        if mapping.method == "InvokeServer" or (mapping.method == nil and remote:IsA("RemoteFunction")) then
            remote:InvokeServer(unpackArgs(args, 1, argCount))
        else
            remote:FireServer(unpackArgs(args, 1, argCount))
        end
    end)
    Learn.suppress = false
    if not ok then
        Log.warn("Remote action " .. action .. " failed: " .. tostring(err))
        return false, "error"
    end
    if mapping.source ~= "learned" and not Adapter.logged["auto-used:" .. action] then
        Adapter.logged["auto-used:" .. action] = true
        Log.info("Using auto-resolved remote for " .. action .. ".")
    end
    return true, mapping.source or "learned"
end

-- ---------------------------------------------------------------------------
-- World scanner
-- ---------------------------------------------------------------------------

Scanner = {
    enemies = {},
    bosses = {},
    packs = {},
    portals = {},
    benches = {},
    lastRefresh = -math.huge,
    interval = 2.5,
}

local EXCLUDED_ENEMY_NAMES = {
    "holder", "stand", "display", "shop", "portal", "zone", "gate", "door",
    "spawn", "base", "sign", "board", "npc", "vendor", "kiosk",
    "bench", "weight", "dumbbell", "treadmill", "training", "workout",
}

local PACK_KEYWORDS = { "pack", "crate", "chest", "drop", "loot", "present", "potion", "orb" }
local PORTAL_KEYWORDS = { "zone", "portal", "gate", "door", "next", "unlock" }
local BENCH_KEYWORDS = { "bench", "weight", "dumbbell", "treadmill", "workout" }

local function nameMatches(name, keywords)
    local lower = tostring(name):lower()
    for index = 1, #keywords do
        if lower:find(keywords[index], 1, true) then
            return true
        end
    end
    return false
end

local function excludedEnemyName(name)
    local lower = tostring(name):lower()
    for index = 1, #EXCLUDED_ENEMY_NAMES do
        if lower:find(EXCLUDED_ENEMY_NAMES[index], 1, true) then
            return true
        end
    end
    return false
end

local function getModelRoot(model)
    local root = nil
    pcall(function()
        root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
    end)
    if root then
        return root
    end
    pcall(function()
        root = model:FindFirstChildWhichIsA("BasePart")
    end)
    return root
end

local function visualKey(part)
    if not part then
        return nil
    end
    local position = nil
    pcall(function()
        position = part.Position
    end)
    if not position then
        return nil
    end
    return string.format("%d:%d:%d", math.floor(position.X / 4), math.floor(position.Y / 4), math.floor(position.Z / 4))
end

local function addUnique(list, seen, key, entry)
    if not key or seen[key] then
        return
    end
    seen[key] = true
    list[#list + 1] = entry
end

local function refreshScanner()
    local newEnemies = {}
    local newBosses = {}
    local newPacks = {}
    local newPortals = {}
    local newBenches = {}
    local seenPacks = {}
    local seenPortals = {}
    local seenBenches = {}
    local character = LocalPlayer.Character

    local ok, descendants = pcall(function()
        return Workspace:GetDescendants()
    end)
    if not ok or not descendants then
        return
    end

    for index = 1, #descendants do
        local object = descendants[index]
        local isModel = false
        local isPart = false
        pcall(function()
            isModel = object:IsA("Model")
            isPart = object:IsA("BasePart")
        end)

        if isModel then
            local humanoid = nil
            pcall(function()
                humanoid = object:FindFirstChildOfClass("Humanoid")
            end)
            if humanoid and object ~= character and humanoid.Health > 0 then
                local player = nil
                pcall(function()
                    player = Players:GetPlayerFromCharacter(object)
                end)
                local allowed = true
                if player and not Settings.targetPlayers then
                    allowed = false
                end
                if allowed and not excludedEnemyName(object.Name) then
                    local root = getModelRoot(object)
                    if root then
                        local isBoss = nameMatches(object.Name, { "boss", "dominus", "titan", "king", "queen", "lord" })
                        if not isBoss then
                            pcall(function()
                                isBoss = object:GetAttribute("Boss") == true
                                    or object:GetAttribute("IsBoss") == true
                                    or humanoid.MaxHealth >= 5000
                            end)
                        end
                        local entry = {
                            model = object,
                            humanoid = humanoid,
                            root = root,
                            name = tostring(object.Name),
                            isBoss = isBoss,
                            player = player,
                        }
                        newEnemies[#newEnemies + 1] = entry
                        if isBoss then
                            newBosses[#newBosses + 1] = entry
                        end
                    end
                end
            end
        end

        if isModel or isPart then
            local lowerName = tostring(object.Name):lower()
            if nameMatches(lowerName, PACK_KEYWORDS) then
                local root = object
                if isModel then
                    root = getModelRoot(object)
                end
                if root then
                    addUnique(newPacks, seenPacks, visualKey(root) or tostring(object), {
                        model = object,
                        root = root,
                        name = tostring(object.Name),
                    })
                end
            end
            if nameMatches(lowerName, PORTAL_KEYWORDS) then
                local hasPrompt = false
                pcall(function()
                    hasPrompt = object:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil
                        or object:FindFirstChildWhichIsA("ClickDetector", true) ~= nil
                end)
                if hasPrompt then
                    local root = object
                    if isModel then
                        root = getModelRoot(object) or object
                    end
                    local key = visualKey(root) or tostring(object)
                    addUnique(newPortals, seenPortals, key, {
                        model = object,
                        root = root,
                        name = tostring(object.Name),
                    })
                end
            end
            if nameMatches(lowerName, BENCH_KEYWORDS) then
                local hasPrompt = false
                pcall(function()
                    hasPrompt = object:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil
                        or object:FindFirstChildWhichIsA("ClickDetector", true) ~= nil
                end)
                if hasPrompt or lowerName:find("bench", 1, true) then
                    local root = object
                    if isModel then
                        root = getModelRoot(object) or object
                    end
                    local key = visualKey(root) or tostring(object)
                    addUnique(newBenches, seenBenches, key, {
                        model = object,
                        root = root,
                        name = tostring(object.Name),
                    })
                end
            end
        end
    end

    Scanner.enemies = newEnemies
    Scanner.bosses = newBosses
    Scanner.packs = newPacks
    Scanner.portals = newPortals
    Scanner.benches = newBenches
    Scanner.lastRefresh = now()
end

function Scanner.ensure(force)
    if force or now() - Scanner.lastRefresh >= Scanner.interval then
        local ok, err = pcall(refreshScanner)
        if not ok then
            Log.warn("Scanner refresh failed: " .. tostring(err))
        end
    end
end

function Scanner.distance(entry)
    local root = getHumanoidRootPart()
    if not root or not entry or not entry.root then
        return math.huge
    end
    local ok, distance = pcall(function()
        return (root.Position - entry.root.Position).Magnitude
    end)
    if ok then
        return distance
    end
    return math.huge
end

function Scanner.nearestEnemy(maxDistance, bossesOnly)
    local best = nil
    local bestDistance = maxDistance or math.huge
    local list = bossesOnly and Scanner.bosses or Scanner.enemies
    for index = 1, #list do
        local entry = list[index]
        if entry.model.Parent and entry.humanoid.Health > 0 then
            local distance = Scanner.distance(entry)
            if distance < bestDistance then
                bestDistance = distance
                best = entry
            end
        end
    end
    return best, bestDistance
end

function Scanner.nearestPack(maxDistance)
    local best = nil
    local bestDistance = maxDistance or math.huge
    local rootPart = getHumanoidRootPart()
    if not rootPart then
        return nil, math.huge
    end
    for index = 1, #Scanner.packs do
        local entry = Scanner.packs[index]
        if entry.root and entry.root.Parent then
            local ok, distance = pcall(function()
                return (rootPart.Position - entry.root.Position).Magnitude
            end)
            if ok and distance < bestDistance then
                bestDistance = distance
                best = entry
            end
        end
    end
    return best, bestDistance
end

function Scanner.nearestBench(maxDistance)
    local best = nil
    local bestDistance = maxDistance or math.huge
    local rootPart = getHumanoidRootPart()
    if not rootPart then
        return nil, math.huge
    end
    for index = 1, #Scanner.benches do
        local entry = Scanner.benches[index]
        if entry.root and entry.root.Parent then
            local ok, distance = pcall(function()
                return (rootPart.Position - entry.root.Position).Magnitude
            end)
            if ok and distance < bestDistance then
                bestDistance = distance
                best = entry
            end
        end
    end
    return best, bestDistance
end

function Scanner.nearestPortal(maxDistance)
    local best = nil
    local bestDistance = maxDistance or math.huge
    local rootPart = getHumanoidRootPart()
    if not rootPart then
        return nil, math.huge
    end
    for index = 1, #Scanner.portals do
        local entry = Scanner.portals[index]
        local root = entry.root
        local position = nil
        if root and root.Parent then
            if root:IsA("BasePart") then
                position = root.Position
            elseif root.PrimaryPart then
                position = root.PrimaryPart.Position
            end
        end
        if position then
            local distance = (rootPart.Position - position).Magnitude
            if distance < bestDistance then
                bestDistance = distance
                best = entry
            end
        end
    end
    return best, bestDistance
end

-- ---------------------------------------------------------------------------
-- ProximityPrompt / ClickDetector / GUI clicking
-- ---------------------------------------------------------------------------

local function triggerPrompt(prompt)
    if not prompt or not prompt.Parent then
        return false
    end
    local firePrompt = execFn("fireproximityprompt")
    if firePrompt then
        local ok = pcall(firePrompt, prompt)
        if ok then
            return true
        end
    end
    local ok = pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance or 10, 100)
        prompt:InputHoldBegin()
        task.wait(0.05)
        prompt:InputHoldEnd()
    end)
    return ok
end

local function triggerClickDetector(detector)
    if not detector or not detector.Parent then
        return false
    end
    local fireClick = execFn("fireclickdetector")
    if fireClick then
        local ok = pcall(fireClick, detector)
        if ok then
            return true
        end
    end
    return false
end

local function triggerObject(object)
    if not object then
        return false
    end
    local prompt = nil
    local detector = nil
    pcall(function()
        prompt = object:FindFirstChildWhichIsA("ProximityPrompt", true)
        detector = object:FindFirstChildWhichIsA("ClickDetector", true)
    end)
    if prompt and triggerPrompt(prompt) then
        return true
    end
    if detector and triggerClickDetector(detector) then
        return true
    end
    return false
end

local function clickAt(x, y)
    local virtualInput = Services.VirtualInputManager
    if not virtualInput then
        local ok, service = pcall(function()
            return game:GetService("VirtualInputManager")
        end)
        if ok then
            virtualInput = service
        end
    end
    if virtualInput then
        local ok = pcall(function()
            virtualInput:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(0.03)
            virtualInput:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end)
        if ok then
            return true
        end
    end

    local virtualUser = Services.VirtualUser
    if virtualUser then
        local ok = pcall(function()
            virtualUser:Button1Down(Vector2.new(x, y))
            task.wait(0.03)
            virtualUser:Button1Up(Vector2.new(x, y))
        end)
        if ok then
            return true
        end
    end

    local moveMouse = execFn("mousemoveabs")
    local clickMouse = execFn("mouse1click")
    if moveMouse then
        pcall(moveMouse, x, y)
    end
    if clickMouse then
        local ok = pcall(clickMouse)
        if ok then
            return true
        end
    end
    return false
end

Gui = {
    buttons = {},
    textBoxes = {},
    lastRefresh = -math.huge,
    interval = 1.0,
    lastClick = {},
}

local function ownedByUs(object)
    local current = object
    for _ = 1, 14 do
        if not current then
            return false
        end
        if current.Name == "SAS_Hub" or current.Name == "SAS_HUD" then
            return true
        end
        current = current.Parent
    end
    return false
end

local function isVisibleChain(object)
    local current = object
    for _ = 1, 20 do
        if not current then
            return true
        end
        local visible = true
        local parent = nil
        pcall(function()
            visible = current.Visible
            parent = current.Parent
        end)
        if visible == false then
            return false
        end
        if not parent then
            return true
        end
        current = parent
    end
    return true
end

function Gui.refresh(force)
    if not force and now() - Gui.lastRefresh < Gui.interval then
        return
    end
    Gui.lastRefresh = now()
    local playerGui = nil
    pcall(function()
        playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    end)
    if not playerGui then
        return
    end
    local ok, descendants = pcall(function()
        return playerGui:GetDescendants()
    end)
    if not ok or not descendants then
        return
    end
    local buttons = {}
    local textBoxes = {}
    for index = 1, #descendants do
        local object = descendants[index]
        local isButton = false
        local isTextBox = false
        pcall(function()
            isButton = object:IsA("GuiButton")
            isTextBox = object:IsA("TextBox")
        end)
        if (isButton or isTextBox) and not ownedByUs(object) then
            local size = nil
            pcall(function()
                size = object.AbsoluteSize
            end)
            if isVisibleChain(object) and size and (size.X > 4 or size.Y > 4) then
                local text = ""
                if isButton then
                    pcall(function()
                        text = tostring(object.Text or "")
                    end)
                    if text == "" then
                        text = tostring(object.Name or "")
                    end
                    buttons[#buttons + 1] = {
                        button = object,
                        text = text,
                        key = (tostring(object.Name) .. " " .. text):lower(),
                    }
                else
                    local placeholder = ""
                    pcall(function()
                        text = tostring(object.Text or "")
                        placeholder = tostring(object.PlaceholderText or "")
                    end)
                    textBoxes[#textBoxes + 1] = {
                        box = object,
                        text = text,
                        key = (tostring(object.Name) .. " " .. text .. " " .. placeholder):lower(),
                    }
                end
            end
        end
    end
    Gui.buttons = buttons
    Gui.textBoxes = textBoxes
end

local function matchesKeywords(key, keywords, excludes)
    if not keywords or #keywords == 0 then
        return false
    end
    local matched = false
    for index = 1, #keywords do
        if key:find(keywords[index], 1, true) then
            matched = true
            break
        end
    end
    if not matched then
        return false
    end
    if excludes then
        for index = 1, #excludes do
            if key:find(excludes[index], 1, true) then
                return false
            end
        end
    end
    return true
end

function Gui.findButtons(keywords, excludes)
    Gui.refresh()
    local found = {}
    for index = 1, #Gui.buttons do
        local entry = Gui.buttons[index]
        if matchesKeywords(entry.key, keywords, excludes) then
            found[#found + 1] = entry
        end
    end
    return found
end

function Gui.click(keywords, excludes, options)
    options = options or {}
    local found = Gui.findButtons(keywords, excludes)
    if #found == 0 then
        return false, nil
    end
    for index = 1, #found do
        local entry = found[index]
        local key = entry.button
        local last = Gui.lastClick[key]
        if not last or now() - last >= (options.cooldown or 0.6) then
            local ok = Gui.clickButton(key)
            if ok then
                Gui.lastClick[key] = now()
                if options.log then
                    Log.info("GUI click: " .. entry.text)
                end
                return true, entry.text
            end
        end
    end
    return false, nil
end

function Gui.clickButton(button)
    if not button or not button.Parent then
        return false
    end
    local position = nil
    local size = nil
    pcall(function()
        position = button.AbsolutePosition
        size = button.AbsoluteSize
    end)
    if not isVisibleChain(button) or not position or not size then
        return false
    end
    if size.X <= 1 or size.Y <= 1 then
        return false
    end
    local viewport = UI.viewport or Vector2.new(1280, 720)
    if position.X + size.X < 0 or position.Y + size.Y < 0
        or position.X > viewport.X or position.Y > viewport.Y then
        return false
    end
    return clickAt(position.X + size.X / 2, position.Y + size.Y / 2)
end

function Gui.findTextBox(keywords)
    Gui.refresh()
    for index = 1, #Gui.textBoxes do
        local entry = Gui.textBoxes[index]
        if matchesKeywords(entry.key, keywords, nil) then
            return entry.box, entry
        end
    end
    return nil
end

function Gui.enterText(box, text, buttonKeywords)
    if not box then
        return false
    end
    pcall(function()
        box:CaptureFocus()
    end)
    local ok = pcall(function()
        box.Text = text
    end)
    if not ok then
        return false
    end
    task.wait(0.05)
    pcall(function()
        box:ReleaseFocus()
    end)
    task.wait(0.05)
    if buttonKeywords then
        return Gui.click(buttonKeywords, nil, { cooldown = 0.4 })
    end
    return true
end

function Gui.copyRemoteList()
    local lines = {}
    local sorted = Remotes.sorted()
    for index = 1, #sorted do
        lines[#lines + 1] = sorted[index].path
    end
    local text = table.concat(lines, "\n")
    if copyText(text) then
        notify("Copied " .. tostring(#sorted) .. " remote path(s).", Theme.good)
    else
        notify("Clipboard unavailable.", Theme.warning)
    end
    return text
end
-- ---------------------------------------------------------------------------
-- Potions
-- ---------------------------------------------------------------------------

Potions = {
    lastAttempt = {},
    lastSuccess = {},
}

function Potions.use(kind, force)
    kind = string.lower(tostring(kind or ""))
    if kind == "" then
        return false
    end
    if not force and not Settings.autoPotions then
        return false
    end
    local attempted = Potions.lastAttempt[kind]
    if not force and attempted and now() - attempted < 8 then
        return false
    end
    local succeeded = Potions.lastSuccess[kind]
    if not force and succeeded and now() - succeeded < 240 then
        return false
    end
    Potions.lastAttempt[kind] = now()

    local excludes = {
        "buy", "purchase", "shop", "robux", "gamepass", "price", "sell",
        "upgrade", "rebirth", "trade", "settings",
    }
    local clicked = Gui.click({ kind .. " potion" }, excludes, { cooldown = 0.6 })
    if not clicked then
        clicked = Gui.click({ kind }, excludes, { cooldown = 0.6 })
    end
    if not clicked then
        return false
    end
    task.wait(0.05)
    local used = Gui.click(
        { "use", "drink", "consume", "activate", "apply" },
        { "buy", "purchase", "shop", "robux", "gamepass", "sell", "upgrade" },
        { cooldown = 0.4, log = true }
    )
    if used then
        Potions.lastSuccess[kind] = now()
        Log.info("Used a " .. kind .. " potion.")
        return true
    end
    return false
end

-- ---------------------------------------------------------------------------
-- Combat
-- ---------------------------------------------------------------------------

Combat = {
    lastAttack = -math.huge,
    lastMove = -math.huge,
    lastTeleport = -math.huge,
    lastGuiAbility = -math.huge,
}

function Combat.getTool()
    local character = LocalPlayer.Character
    if not character then
        return nil
    end
    local tool = nil
    pcall(function()
        tool = character:FindFirstChildOfClass("Tool")
    end)
    return tool
end

function Combat.equipTool()
    local humanoid = getHumanoid()
    if not humanoid then
        return nil
    end
    local current = Combat.getTool()
    if current then
        return current
    end
    local backpack = nil
    pcall(function()
        backpack = LocalPlayer:FindFirstChild("Backpack")
    end)
    if not backpack then
        return nil
    end
    local best = nil
    pcall(function()
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                best = item
                break
            end
        end
    end)
    if best then
        pcall(function()
            humanoid:EquipTool(best)
        end)
    end
    return best
end

function Combat.attack(target)
    if not target or not target.model or not target.model.Parent then
        return false
    end
    if target.humanoid and target.humanoid.Health <= 0 then
        return false
    end
    if Combat.lastAttack and now() - Combat.lastAttack < Settings.attackDelay then
        return false
    end
    Combat.lastAttack = now()

    local context = {
        targetModel = target.model,
        targetPlayer = target.player,
        targetPart = target.root,
        humanoid = target.humanoid,
    }
    local fired, source = Adapter.fire("attack", context)
    if fired and source == "learned" then
        return true
    end

    local tool = Combat.equipTool()
    if tool then
        pcall(function()
            tool:Activate()
        end)
    end

    if Settings.guiFallback and (not Combat.lastGuiAbility or now() - Combat.lastGuiAbility > math.max(Settings.attackDelay, 0.25)) then
        Combat.lastGuiAbility = now()
        Gui.click(
            { "attack", "punch", "strike", "slash", "blast", "ability", "skill", "swing", "m1", "special" },
            { "upgrade", "buy", "shop", "purchase", "gamepass", "robux", "rebirth", "settings" },
            { cooldown = 0.3 }
        )
    end
    return fired or tool ~= nil
end

function Combat.moveToward(target)
    if not target or not target.root then
        return
    end
    local humanoid = getHumanoid()
    local root = getHumanoidRootPart()
    if not humanoid or not root then
        return
    end
    local distance = (root.Position - target.root.Position).Magnitude
    if distance <= Settings.attackRange then
        return
    end
    if Settings.tpToTargets and distance > 25 and (not Combat.lastTeleport or now() - Combat.lastTeleport > 1.5) then
        Combat.lastTeleport = now()
        local destination = target.root.Position - Vector3.new(0, 0, 6)
        pcall(function()
            root.CFrame = CFrame.new(destination + Vector3.new(0, 5, 0))
        end)
        return
    end
    if Settings.autoMovement and (not Combat.lastMove or now() - Combat.lastMove > 0.5) then
        Combat.lastMove = now()
        pcall(function()
            humanoid:MoveTo(target.root.Position)
        end)
    end
end

function Combat.getTargets(maxDistance, bossesOnly)
    local targets = {}
    local list = bossesOnly and Scanner.bosses or Scanner.enemies
    for index = 1, #list do
        local entry = list[index]
        if entry.model.Parent and entry.humanoid.Health > 0 then
            local distance = Scanner.distance(entry)
            if distance <= (maxDistance or math.huge) then
                targets[#targets + 1] = { entry = entry, distance = distance }
            end
        end
    end
    table.sort(targets, function(a, b)
        return a.distance < b.distance
    end)
    return targets
end

function Combat.update()
    Scanner.ensure()

    if Settings.killAura then
        local targets = Combat.getTargets(Settings.attackRange, false)
        for index = 1, math.min(#targets, 6) do
            Combat.attack(targets[index].entry)
        end
    end

    if Settings.autoFarm or Settings.autoBoss then
        local target = Scanner.nearestEnemy(Settings.farmRange, Settings.autoBoss and not Settings.autoFarm)
        if target then
            if Settings.autoPotions and target.isBoss and Settings.autoBoss then
                Potions.use("power")
            end
            Combat.moveToward(target)
            local distance = Scanner.distance(target)
            if distance <= Settings.attackRange then
                Combat.attack(target)
            end
        end
    end

    if Settings.autoZone and not Settings.autoFarm and not Settings.killAura and not Settings.autoBoss then
        local portal, distance = Scanner.nearestPortal(200)
        if portal then
            if distance <= 20 then
                triggerObject(portal.root)
            else
                local root = getHumanoidRootPart()
                local position = nil
                if portal.root:IsA("BasePart") then
                    position = portal.root.Position
                elseif portal.root.PrimaryPart then
                    position = portal.root.PrimaryPart.Position
                end
                if position and root and Settings.autoMovement then
                    local humanoid = getHumanoid()
                    if humanoid then
                        pcall(function()
                            humanoid:MoveTo(position)
                        end)
                    end
                end
            end
        end
    end
end

-- ---------------------------------------------------------------------------
-- Packs
-- ---------------------------------------------------------------------------

Packs = {
    timers = {},
}

local function ready(key, interval)
    local last = Packs.timers[key]
    if not last or now() - last >= interval then
        Packs.timers[key] = now()
        return true
    end
    return false
end

function Packs.moveToObject(entry)
    if not entry or not entry.root then
        return
    end
    local root = getHumanoidRootPart()
    local humanoid = getHumanoid()
    if not root or not humanoid then
        return
    end
    local ok, distance = pcall(function()
        return (root.Position - entry.root.Position).Magnitude
    end)
    if not ok then
        return
    end
    if distance <= 18 then
        triggerObject(entry.root)
        return
    end
    if Settings.tpToTargets and distance > 30 and now() - Combat.lastTeleport > 1.5 then
        Combat.lastTeleport = now()
        pcall(function()
            root.CFrame = CFrame.new(entry.root.Position + Vector3.new(0, 5, 0))
        end)
        return
    end
    if Settings.autoMovement then
        pcall(function()
            humanoid:MoveTo(entry.root.Position)
        end)
    end
end

function Packs.update()
    if not (Settings.autoClaimPacks or Settings.autoGrabDrops or Settings.autoOpenPacks
        or Settings.autoBankPacks or Settings.autoFuse or Settings.autoPlaceBest
        or Settings.autoEquipBest) then
        return
    end

    Scanner.ensure()

    if Settings.autoClaimPacks or Settings.autoGrabDrops then
        if ready("claim", 0.5) then
            local pack = Scanner.nearestPack(400)
            if pack then
                Packs.moveToObject(pack)
            else
                Gui.click(
                    { "claim pack", "collect pack", "grab pack", "pickup pack" },
                    { "reward", "daily", "code", "gamepass", "robux", "upgrade" },
                    { cooldown = 1.0 }
                )
            end
        end
    end

    if Settings.autoOpenPacks and ready("open", Settings.packInterval) then
        if Settings.autoPotions then
            Potions.use("luck")
        end
        local fired = false
        if Adapter.profile.actions.openPack then
            fired = Adapter.fire("openPack")
        end
        if not fired then
            Gui.click(
                { "open pack", "open", "unbox", "pull" },
                { "settings", "gamepass", "robux", "shop", "upgrade", "rebirth", "trade", "inventory" },
                { cooldown = 0.8 }
            )
        end
    end

    if Settings.autoBankPacks and ready("bank", 1.0) then
        local fired = false
        if Adapter.profile.actions.bankPack then
            fired = Adapter.fire("bankPack")
        end
        if not fired then
            Gui.click({ "bank", "deposit" }, { "withdraw", "gamepass", "robux" }, { cooldown = 1.0 })
        end
    end

    if Settings.autoFuse and ready("fuse", 1.2) then
        local fired = false
        if Adapter.profile.actions.fuse then
            fired = Adapter.fire("fuse")
        end
        if not fired then
            Gui.click({ "fuse", "merge" }, { "gamepass", "robux", "shop" }, { cooldown = 1.2 })
        end
    end

    if Settings.autoPlaceBest and ready("place", 1.5) then
        local fired = false
        if Adapter.profile.actions.placeCard then
            fired = Adapter.fire("placeCard")
        end
        if not fired then
            local clicked = Gui.click({ "place best", "auto place" }, { "gamepass", "robux", "shop", "upgrade", "sell" }, { cooldown = 1.5 })
            if not clicked then
                Gui.click({ "place", "deploy" }, { "gamepass", "robux", "shop", "upgrade", "sell" }, { cooldown = 1.5 })
            end
        end
    end

    if Settings.autoEquipBest and ready("equip", 1.5) then
        if Adapter.profile.actions.equipAura then
            Adapter.fire("equipAura")
        end
        if Adapter.profile.actions.equipTrail then
            Adapter.fire("equipTrail")
        end
        local clicked = Gui.click({ "equip best" }, { "gamepass", "robux", "shop" }, { cooldown = 1.2 })
        if not clicked then
            clicked = Gui.click({ "best aura", "best trail" }, { "gamepass", "robux", "shop" }, { cooldown = 1.2 })
        end
        if not clicked then
            Gui.click({ "equip" }, { "gamepass", "robux", "shop" }, { cooldown = 1.2 })
        end
    end
end

-- ---------------------------------------------------------------------------
-- Bench training
-- ---------------------------------------------------------------------------

Train = {
    lastRun = -math.huge,
}

function Train.update()
    if not Settings.autoTrain then
        return
    end
    if Train.lastRun and now() - Train.lastRun < Settings.trainInterval then
        return
    end
    Train.lastRun = now()
    Scanner.ensure()

    local bench, distance = Scanner.nearestBench(Settings.trainRange)
    if bench then
        if distance <= 20 then
            triggerObject(bench.root)
        else
            Packs.moveToObject(bench)
        end
    end

    Gui.click(
        { "train power", "train", "lift", "workout", "bench" },
        { "buy", "purchase", "shop", "robux", "gamepass", "upgrade", "rebirth", "sell" },
        { cooldown = 0.9 }
    )
end

-- ---------------------------------------------------------------------------
-- Stats
-- ---------------------------------------------------------------------------

Stats = {
    cash = nil,
    power = nil,
    rebirth = nil,
    lastRefresh = -math.huge,
    lastFpsTime = 0,
    frames = 0,
    fps = 0,
    warned = false,
}

local function extractNumber(text)
    if not text then
        return nil
    end
    local cleaned = tostring(text):gsub(",", "")
    local number, suffix = cleaned:match("([%d]+%.?[%d]*)%s*([KkMmBb]?)")
    if not number then
        return nil
    end
    local value = tonumber(number)
    if not value then
        return nil
    end
    suffix = string.lower(suffix or "")
    if suffix == "k" then
        value = value * 1000
    elseif suffix == "m" then
        value = value * 1000000
    elseif suffix == "b" then
        value = value * 1000000000
    end
    return value
end

local SHOP_WORDS = {
    "price", "cost", "shop", "gamepass", "robux", "purchase",
    "buy", "sell", "upgrade price", "trade",
}

local function looksLikeShop(name, text)
    local merged = string.lower(tostring(name or "") .. " " .. tostring(text or ""))
    for index = 1, #SHOP_WORDS do
        if merged:find(SHOP_WORDS[index], 1, true) then
            return true
        end
    end
    return false
end

local function readStatContainer(container, data)
    if not container then
        return
    end
    local children = nil
    pcall(function()
        children = container:GetChildren()
    end)
    if children then
        for index = 1, #children do
            local child = children[index]
            local value = nil
            pcall(function()
                if child:IsA("IntValue") or child:IsA("NumberValue") or child:IsA("StringValue") then
                    value = tonumber(child.Value)
                end
            end)
            if value ~= nil then
                local lower = string.lower(tostring(child.Name))
                if lower:find("cash", 1, true) or lower:find("money", 1, true) then
                    data.cash = data.cash or value
                elseif lower:find("power", 1, true) then
                    data.power = data.power or value
                elseif lower:find("rebirth", 1, true) then
                    data.rebirth = data.rebirth or value
                end
            end
        end
    end
    local attributeNames = { "Cash", "Money", "Power", "Rebirth" }
    for index = 1, #attributeNames do
        local name = attributeNames[index]
        local value = nil
        pcall(function()
            value = tonumber(container:GetAttribute(name))
        end)
        if value ~= nil then
            if name == "Cash" or name == "Money" then
                data.cash = data.cash or value
            elseif name == "Power" then
                data.power = data.power or value
            else
                data.rebirth = data.rebirth or value
            end
        end
    end
end

function Stats.refresh()
    if now() - Stats.lastRefresh < 1.0 then
        return
    end
    Stats.lastRefresh = now()

    local data = {}
    local leaderstats = nil
    pcall(function()
        leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    end)
    readStatContainer(leaderstats, data)
    readStatContainer(LocalPlayer, data)
    readStatContainer(LocalPlayer.Character, data)

    local playerGui = nil
    pcall(function()
        playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end)
    if playerGui and (not data.cash or not data.power or not data.rebirth) then
        local ok, descendants = pcall(function()
            return playerGui:GetDescendants()
        end)
        if ok and descendants then
            local priorities = {
                cash = data.cash and 99 or 0,
                power = data.power and 99 or 0,
                rebirth = data.rebirth and 99 or 0,
            }
            for index = 1, #descendants do
                local object = descendants[index]
                local isLabel = false
                pcall(function()
                    isLabel = object:IsA("TextLabel")
                end)
                if isLabel and isVisibleChain(object) and not ownedByUs(object) then
                    local text = ""
                    local objectName = ""
                    pcall(function()
                        text = tostring(object.Text or "")
                        objectName = tostring(object.Name or "")
                    end)
                    if text ~= "" and not looksLikeShop(objectName, text) then
                        local lowerText = string.lower(text)
                        local lowerName = string.lower(objectName)
                        local function consider(kind, priority)
                            if data[kind] ~= nil and priorities[kind] >= priority then
                                return
                            end
                            local value = extractNumber(text)
                            if value ~= nil and (data[kind] == nil or priorities[kind] <= priority) then
                                data[kind] = value
                                priorities[kind] = priority
                            end
                        end
                        if lowerName:find("cash", 1, true) or lowerName:find("money", 1, true) then
                            consider("cash", 3)
                        elseif lowerText:find("cash", 1, true) or lowerText:find("money", 1, true) or text:find("%$") then
                            consider("cash", (text:find("%$") and 1) or 2)
                        end
                        if lowerName:find("power", 1, true) then
                            consider("power", 3)
                        elseif lowerText:find("power", 1, true) then
                            consider("power", 2)
                        end
                        if lowerName:find("rebirth", 1, true) then
                            consider("rebirth", 3)
                        elseif lowerText:find("rebirth", 1, true) then
                            consider("rebirth", 2)
                        end
                    end
                end
            end
        end
    end

    if data.cash ~= nil then
        Stats.cash = data.cash
    end
    if data.power ~= nil then
        Stats.power = data.power
    end
    if data.rebirth ~= nil then
        Stats.rebirth = data.rebirth
    end
end

function Stats.updateHud()
    UI.updateHUD({
        cash = Stats.cash,
        power = Stats.power,
        rebirth = Stats.rebirth,
        remotes = #Remotes.list,
        fps = Stats.fps,
    })
end

-- ---------------------------------------------------------------------------
-- Codes
-- ---------------------------------------------------------------------------

Codes = {
    list = {
        "10KCCU", "50KLIKES", "30KLIKES", "SOZFORUPDATES",
        "20KLIKES", "10KLIKES", "1KCCU", "POTIONS", "DISCORD",
    },
    tried = {},
    lastRun = -math.huge,
    warned = false,
    fetched = false,
}

function Codes.add(list)
    if type(list) ~= "table" then
        return
    end
    for index = 1, #list do
        local code = tostring(list[index])
        if code ~= "" then
            local exists = false
            for existingIndex = 1, #Codes.list do
                if string.lower(Codes.list[existingIndex]) == string.lower(code) then
                    exists = true
                    break
                end
            end
            if not exists then
                Codes.list[#Codes.list + 1] = code
            end
        end
    end
end

function Codes.fetch()
    if Codes.fetched then
        return
    end
    Codes.fetched = true
    task.spawn(function()
        local response = httpRequest({
            Url = CODES_URL .. "?t=" .. tostring(os.time()),
            Method = "GET",
        })
        if response and response.Body then
            local data = jsonDecode(response.Body)
            if type(data) == "table" then
                if type(data.codes) == "table" then
                    Codes.add(data.codes)
                elseif #data > 0 then
                    Codes.add(data)
                end
                Log.info("Loaded code list from repository (" .. tostring(#Codes.list) .. " codes).")
            end
        end
    end)
end

function Codes.customList()
    local result = {}
    local custom = tostring(Settings.customCodes or "")
    for code in string.gmatch(custom, "[^,%s]+") do
        if code ~= "" then
            result[#result + 1] = code
        end
    end
    return result
end

function Codes.nextCode()
    local all = {}
    for index = 1, #Codes.list do
        all[#all + 1] = Codes.list[index]
    end
    local custom = Codes.customList()
    for index = 1, #custom do
        all[#all + 1] = custom[index]
    end
    for index = 1, #all do
        if not Codes.tried[all[index]] then
            return all[index]
        end
    end
    return nil
end

function Codes.update()
    if not Settings.autoCodes then
        return
    end
    if Codes.lastRun and now() - Codes.lastRun < 2.5 then
        return
    end
    Codes.lastRun = now()
    local code = Codes.nextCode()
    if not code then
        return
    end
    local box = Gui.findTextBox({ "code", "promo", "redeem" })
    if not box then
        if not Codes.warned then
            Codes.warned = true
            Log.warn("Auto Codes: no code TextBox found. Open the codes menu once.")
        end
        return
    end
    Gui.enterText(box, code, { "redeem", "claim", "submit", "enter", "use", "apply" })
    Codes.tried[code] = true
    notify("Tried code: " .. code, Theme.accent)
    Log.info("Redeemed code attempt: " .. code)
end

-- ---------------------------------------------------------------------------
-- Economy
-- ---------------------------------------------------------------------------

Economy = {
    timers = {},
}

local function economyReady(key, interval)
    local last = Economy.timers[key]
    if not last or now() - last >= interval then
        Economy.timers[key] = now()
        return true
    end
    return false
end

function Economy.triggerRebirth()
    if Adapter.profile.actions.rebirth then
        local fired = Adapter.fire("rebirth")
        if fired then
            return true
        end
    end
    return Gui.click({ "rebirth", "prestige" }, { "gamepass", "robux", "shop" }, { cooldown = 2.0 })
end

function Economy.update()
    if Settings.autoUpgrade and economyReady("upgrade", Settings.upgradeInterval) then
        local fired = false
        if Adapter.profile.actions.upgrade then
            fired = Adapter.fire("upgrade")
        end
        if not fired then
            Gui.click(
                { "upgrade", "buy" },
                { "gamepass", "robux", "rebirth", "code", "sell", "trade" },
                { cooldown = 0.8 }
            )
        end
    end

    if Settings.autoRewards and economyReady("reward", 3.0) then
        local fired = false
        if Adapter.profile.actions.reward then
            fired = Adapter.fire("reward")
        end
        if not fired then
            Gui.click(
                { "daily", "offline", "index", "free", "reward", "claim" },
                { "pack", "code", "purchase", "gamepass", "robux", "rebirth" },
                { cooldown = 1.0 }
            )
        end
    end

    if Settings.autoRebirth and economyReady("rebirth", 5.0) then
        if Stats.power and Stats.power >= Settings.rebirthThreshold then
            if Economy.triggerRebirth() then
                notify("Rebirth triggered at " .. compact(Stats.power) .. " Power.", Theme.good)
            end
        elseif not Stats.power and not Stats.warned then
            Stats.warned = true
            Log.warn("Auto Rebirth is waiting for a visible Power value. Open the main game HUD.")
        end
    end

    Codes.update()
end

-- ---------------------------------------------------------------------------
-- ESP
-- ---------------------------------------------------------------------------

ESP = {
    objects = {},
}

local function makeBillboard(model, labelText)
    local adornee = model
    pcall(function()
        if model:IsA("Model") then
            adornee = model:FindFirstChild("Head")
                or model.PrimaryPart
                or model:FindFirstChildWhichIsA("BasePart")
                or model
        end
    end)
    local billboard = newInstance("BillboardGui", {
        Name = "SAS_ESPLabel",
        Adornee = adornee,
        AlwaysOnTop = true,
        Size = UDim2.new(0, 150, 0, 24),
        StudsOffset = Vector3.new(0, 3, 0),
        Parent = model,
    })
    local label = newInstance("TextLabel", {
        BackgroundTransparency = 1,
        Font = Fonts.bold,
        Size = UDim2.new(1, 0, 1, 0),
        Text = labelText or "",
        TextColor3 = Theme.white,
        TextSize = 12,
        TextStrokeTransparency = 0.4,
        TextStrokeColor3 = Theme.black,
    })
    label.Parent = billboard
    return billboard
end

function ESP.add(model, color, labelText)
    if not model or not model.Parent then
        return
    end
    local existing = ESP.objects[model]
    if existing then
        if existing.highlight then
            existing.highlight.FillColor = color
            existing.highlight.OutlineColor = color
        end
        if existing.billboard then
            local textLabel = nil
            pcall(function()
                textLabel = existing.billboard:FindFirstChildOfClass("TextLabel")
            end)
            if textLabel then
                textLabel.Text = labelText or ""
            end
        end
        if existing.billboard and not Settings.espNames then
            existing.billboard:Destroy()
            existing.billboard = nil
        elseif not existing.billboard and Settings.espNames then
            existing.billboard = makeBillboard(model, labelText)
        end
        return
    end
    local highlight = newInstance("Highlight", {
        Name = "SAS_ESP",
        FillColor = color,
        OutlineColor = color,
        FillTransparency = 0.58,
        OutlineTransparency = 0.1,
        Parent = model,
    })
    pcall(function()
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end)
    local billboard = nil
    if Settings.espNames then
        billboard = makeBillboard(model, labelText)
    end
    ESP.objects[model] = {
        highlight = highlight,
        billboard = billboard,
    }
end

function ESP.remove(model)
    local data = ESP.objects[model]
    if not data then
        return
    end
    if data.highlight then
        data.highlight:Destroy()
    end
    if data.billboard then
        data.billboard:Destroy()
    end
    ESP.objects[model] = nil
end

function ESP.update()
    if not (Settings.espPlayers or Settings.espBosses or Settings.espPacks or Settings.espChests) then
        if next(ESP.objects) then
            ESP.cleanup()
        end
        return
    end
    Scanner.ensure()
    local desired = {}

    if Settings.espPlayers then
        local players = Players:GetPlayers()
        for index = 1, #players do
            local player = players[index]
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local humanoid = nil
                pcall(function()
                    humanoid = character:FindFirstChildOfClass("Humanoid")
                end)
                if humanoid and humanoid.Health > 0 then
                    desired[character] = {
                        color = Theme.accent2,
                        label = player.Name .. " [" .. tostring(math.floor(humanoid.Health)) .. "]",
                    }
                end
            end
        end
    end

    if Settings.espBosses then
        for index = 1, #Scanner.bosses do
            local entry = Scanner.bosses[index]
            desired[entry.model] = {
                color = Theme.danger,
                label = "BOSS • " .. entry.name,
            }
        end
    end

    if Settings.espPacks then
        for index = 1, #Scanner.packs do
            local entry = Scanner.packs[index]
            desired[entry.model] = {
                color = Theme.good,
                label = "PACK • " .. entry.name,
            }
        end
    end

    if Settings.espChests then
        for index = 1, #Scanner.packs do
            local entry = Scanner.packs[index]
            local lower = string.lower(entry.name)
            if lower:find("chest", 1, true) or lower:find("loot", 1, true) then
                desired[entry.model] = {
                    color = Theme.warning,
                    label = "CHEST • " .. entry.name,
                }
            end
        end
    end

    for model, data in pairs(desired) do
        ESP.add(model, data.color, data.label)
    end

    local current = {}
    for model in pairs(ESP.objects) do
        current[#current + 1] = model
    end
    for index = 1, #current do
        local model = current[index]
        if not desired[model] or not model.Parent then
            ESP.remove(model)
        end
    end
end

function ESP.cleanup()
    local models = {}
    for model in pairs(ESP.objects) do
        models[#models + 1] = model
    end
    for index = 1, #models do
        ESP.remove(models[index])
    end
    ESP.objects = {}
end

-- ---------------------------------------------------------------------------
-- Teleport
-- ---------------------------------------------------------------------------

Teleport = {
    points = {},
    lastRefresh = -math.huge,
}

local function positionOf(object)
    if not object then
        return nil
    end
    local isPart = false
    pcall(function()
        isPart = object:IsA("BasePart")
    end)
    if isPart then
        return object.Position
    end
    local position = nil
    pcall(function()
        if object.PrimaryPart then
            position = object.PrimaryPart.Position
        else
            local part = object:FindFirstChildWhichIsA("BasePart")
            if part then
                position = part.Position
            end
        end
    end)
    return position
end

function Teleport.refresh(force)
    if not force and Teleport.lastRefresh ~= 0 and now() - Teleport.lastRefresh < 5 then
        return
    end
    Teleport.lastRefresh = now()
    local points = {}
    local seen = {}
    local ok, descendants = pcall(function()
        return Workspace:GetDescendants()
    end)
    if not ok or not descendants then
        return
    end
    for index = 1, #descendants do
        local object = descendants[index]
        local isPart = false
        local isModel = false
        pcall(function()
            isPart = object:IsA("BasePart")
            isModel = object:IsA("Model")
        end)
        if isPart or isModel then
            local lower = string.lower(tostring(object.Name))
            local isPoint = lower:find("zone", 1, true)
                or lower:find("portal", 1, true)
                or lower:find("area", 1, true)
                or lower:find("boss", 1, true)
                or lower:find("spawn", 1, true)
                or lower:find("base", 1, true)
                or lower:find("bench", 1, true)
                or lower:find("holder", 1, true)
            if isPoint then
                local position = positionOf(object)
                if position then
                    local key = string.format("%d:%d:%d", math.floor(position.X / 8), math.floor(position.Y / 8), math.floor(position.Z / 8))
                    if not seen[key] then
                        seen[key] = true
                        points[#points + 1] = {
                            name = tostring(object.Name),
                            position = position,
                        }
                    end
                end
            end
        end
    end
    table.sort(points, function(a, b)
        return a.name < b.name
    end)
    if #points > 100 then
        local trimmed = {}
        for index = 1, 100 do
            trimmed[index] = points[index]
        end
        points = trimmed
    end
    Teleport.points = points
    if UI.diagLabels.teleports then
        UI.diagLabels.teleports.Text = "Teleport points: " .. tostring(#points)
    end
end

function Teleport.toPosition(position)
    if not position then
        return false
    end
    local root = getHumanoidRootPart()
    if not root then
        return false
    end
    local ok = pcall(function()
        root.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
    end)
    return ok
end

function Teleport.toSpawn()
    local spawn = nil
    pcall(function()
        spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    end)
    if spawn then
        return Teleport.toPosition(spawn.Position)
    end
    for index = 1, #Teleport.points do
        if string.lower(Teleport.points[index].name):find("spawn", 1, true) then
            return Teleport.toPosition(Teleport.points[index].position)
        end
    end
    notify("No spawn point found.", Theme.warning)
    return false
end

function Teleport.toBase()
    for index = 1, #Teleport.points do
        if string.lower(Teleport.points[index].name):find("base", 1, true) then
            return Teleport.toPosition(Teleport.points[index].position)
        end
    end
    notify("No base point found.", Theme.warning)
    return false
end

function Teleport.toBoss()
    Scanner.ensure(true)
    local boss = Scanner.nearestEnemy(2000, true)
    if boss then
        return Teleport.toPosition(boss.root.Position)
    end
    notify("No boss found.", Theme.warning)
    return false
end

function Teleport.toNextZone()
    Teleport.refresh()
    for index = 1, #Teleport.points do
        local lower = string.lower(Teleport.points[index].name)
        if lower:find("zone", 1, true) or lower:find("portal", 1, true) then
            return Teleport.toPosition(Teleport.points[index].position)
        end
    end
    notify("No zone or portal found.", Theme.warning)
    return false
end

function Teleport.toBench()
    Teleport.refresh()
    for index = 1, #Teleport.points do
        if string.lower(Teleport.points[index].name):find("bench", 1, true) then
            return Teleport.toPosition(Teleport.points[index].position)
        end
    end
    notify("No bench found. Use the teleport list or move closer.", Theme.warning)
    return false
end

function Teleport.toHolders()
    Teleport.refresh()
    for index = 1, #Teleport.points do
        if string.lower(Teleport.points[index].name):find("holder", 1, true) then
            return Teleport.toPosition(Teleport.points[index].position)
        end
    end
    notify("No holder found.", Theme.warning)
    return false
end

function Teleport.options()
    Teleport.refresh()
    local options = {}
    for index = 1, #Teleport.points do
        local point = Teleport.points[index]
        options[#options + 1] = {
            label = string.format("%s (%.0f, %.0f)", point.name, point.position.X, point.position.Z),
            value = point,
        }
    end
    return options
end

-- ---------------------------------------------------------------------------
-- Misc: anti-AFK, fullbright, speed, webhook, server hop
-- ---------------------------------------------------------------------------

Misc = {
    lightingBackup = nil,
    lastHop = -math.huge,
    webhookWarned = false,
    originalWalkSpeed = nil,
    originalJumpPower = nil,
    originalHumanoid = nil,
    appliedSpeed = false,
    appliedJump = false,
    noclipParts = {},
    noclipCharacter = nil,
    lastSafePosition = nil,
    lastVoidTeleport = -math.huge,
    fpsApplied = false,
}

function Misc.setFullbright(enabled)
    if not Lighting then
        return
    end
    if enabled then
        if not Misc.lightingBackup then
            Misc.lightingBackup = {
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                GlobalShadows = Lighting.GlobalShadows,
                FogEnd = Lighting.FogEnd,
            }
        end
        pcall(function()
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
        end)
    elseif Misc.lightingBackup then
        pcall(function()
            Lighting.Ambient = Misc.lightingBackup.Ambient
            Lighting.OutdoorAmbient = Misc.lightingBackup.OutdoorAmbient
            Lighting.Brightness = Misc.lightingBackup.Brightness
            Lighting.ClockTime = Misc.lightingBackup.ClockTime
            Lighting.GlobalShadows = Misc.lightingBackup.GlobalShadows
            Lighting.FogEnd = Misc.lightingBackup.FogEnd
        end)
        Misc.lightingBackup = nil
    end
end

function Misc.setNoclip(enabled)
    local character = getCharacter()
    if enabled then
        if not character then
            return
        end
        if Misc.noclipCharacter ~= character then
            Misc.noclipParts = {}
            Misc.noclipCharacter = character
        end
        pcall(function()
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if Misc.noclipParts[part] == nil then
                        Misc.noclipParts[part] = part.CanCollide
                    end
                    part.CanCollide = false
                end
            end
        end)
    else
        for part, original in pairs(Misc.noclipParts) do
            pcall(function()
                if part.Parent then
                    part.CanCollide = original
                end
            end)
        end
        Misc.noclipParts = {}
        Misc.noclipCharacter = nil
    end
end

function Misc.applyMovement()
    local humanoid = getHumanoid()
    if humanoid then
        if Misc.originalHumanoid ~= humanoid then
            Misc.originalHumanoid = humanoid
            Misc.originalWalkSpeed = humanoid.WalkSpeed
            Misc.originalJumpPower = humanoid.JumpPower
            Misc.appliedSpeed = false
            Misc.appliedJump = false
        end
        pcall(function()
            if Settings.speedEnabled then
                if humanoid.WalkSpeed ~= Settings.walkSpeed then
                    humanoid.WalkSpeed = Settings.walkSpeed
                end
                Misc.appliedSpeed = true
            elseif Misc.appliedSpeed then
                if Misc.originalWalkSpeed then
                    humanoid.WalkSpeed = Misc.originalWalkSpeed
                end
                Misc.appliedSpeed = false
            end
            if Settings.jumpEnabled then
                humanoid.UseJumpPower = true
                if humanoid.JumpPower ~= Settings.jumpPower then
                    humanoid.JumpPower = Settings.jumpPower
                end
                Misc.appliedJump = true
            elseif Misc.appliedJump then
                if Misc.originalJumpPower then
                    humanoid.JumpPower = Misc.originalJumpPower
                end
                Misc.appliedJump = false
            end
        end)
    end

    if Settings.noclip then
        Misc.setNoclip(true)
    elseif next(Misc.noclipParts) then
        Misc.setNoclip(false)
    end

    if Settings.antiVoid then
        local root = getHumanoidRootPart()
        if root then
            local ok, position = pcall(function()
                return root.Position
            end)
            if ok and position then
                if position.Y > 5 then
                    Misc.lastSafePosition = position
                elseif position.Y < -75 and now() - Misc.lastVoidTeleport > 3 then
                    Misc.lastVoidTeleport = now()
                    local target = Misc.lastSafePosition or Vector3.new(0, 12, 0)
                    pcall(function()
                        root.CFrame = CFrame.new(target + Vector3.new(0, 8, 0))
                    end)
                    Log.info("Anti-Void returned the character to a safe position.")
                end
            end
        end
    end
end

function Misc.installMovementHelpers()
    connect(UserInputService and UserInputService.JumpRequest, function()
        if not Settings.infiniteJump then
            return
        end
        local humanoid = getHumanoid()
        if humanoid then
            pcall(function()
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end
    end)
end

function Misc.applyFpsCap()
    local setFps = execFn("setfpscap")
    if not setFps then
        return
    end
    if Settings.fpsCap and Settings.fpsCap > 0 then
        pcall(setFps, Settings.fpsCap)
        Misc.fpsApplied = true
    elseif Misc.fpsApplied then
        pcall(setFps, 9999)
        Misc.fpsApplied = false
    end
end

function Misc.installAntiAfk()
    connect(LocalPlayer.Idled, function()
        if not Settings.antiAfk then
            return
        end
        local virtualUser = Services.VirtualUser
        if virtualUser then
            pcall(function()
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end
        Log.info("Anti-AFK triggered.")
    end)
end

function Misc.sendWebhook(message)
    if not Settings.webhookEnabled or Settings.webhookUrl == "" then
        return false
    end
    local body = jsonEncode({
        username = "Steal a Superpower Hub",
        content = tostring(message),
    })
    local response = httpRequest({
        Url = Settings.webhookUrl,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = body,
    })
    return response ~= nil
end

function Misc.testWebhook()
    if Settings.webhookUrl == "" then
        notify("Enter a webhook URL first.", Theme.warning)
        return
    end
    if Misc.sendWebhook("Webhook test from Steal a Superpower Hub v" .. SCRIPT_VERSION) then
        notify("Webhook sent.", Theme.good)
    else
        notify("Webhook failed. Check the URL and executor HTTP access.", Theme.danger)
    end
end

function Misc.hop()
    if Misc.lastHop and now() - Misc.lastHop < 10 then
        return
    end
    Misc.lastHop = now()
    local placeId = PLACE_ID
    pcall(function()
        placeId = game.PlaceId or PLACE_ID
    end)
    local url = "https://games.roblox.com/v1/games/" .. tostring(placeId) .. "/servers/Public?sortOrder=Asc&limit=100"
    local response = httpRequest({ Url = url, Method = "GET" })
    if not response or not response.Body then
        notify("Server list request failed.", Theme.danger)
        return
    end
    local data = jsonDecode(response.Body)
    if type(data) ~= "table" or type(data.data) ~= "table" then
        notify("Server list response was invalid.", Theme.danger)
        return
    end
    local target = nil
    for index = 1, #data.data do
        local server = data.data[index]
        if server.id and server.playing and server.maxPlayers and server.playing < server.maxPlayers - 1 then
            target = server
            break
        end
    end
    if not target then
        notify("No low-population server found.", Theme.warning)
        return
    end
    local teleportService = TeleportService
    if not teleportService then
        notify("TeleportService unavailable.", Theme.danger)
        return
    end
    local ok = pcall(function()
        teleportService:TeleportToPlaceInstance(placeId, target.id, LocalPlayer)
    end)
    if ok then
        notify("Hopping to " .. tostring(target.playing) .. "/" .. tostring(target.maxPlayers) .. " server.", Theme.good)
    else
        notify("Server hop failed.", Theme.danger)
    end
end

function Misc.rejoin()
    local placeId = PLACE_ID
    local jobId = nil
    pcall(function()
        placeId = game.PlaceId or PLACE_ID
        jobId = game.JobId
    end)
    if not TeleportService then
        notify("TeleportService unavailable.", Theme.danger)
        return false
    end
    local ok = false
    pcall(function()
        if jobId and jobId ~= "" then
            TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
        else
            TeleportService:Teleport(placeId, LocalPlayer)
        end
        ok = true
    end)
    if ok then
        notify("Rejoining the current server.", Theme.good)
    else
        notify("Rejoin failed.", Theme.danger)
    end
    return ok
end

function Misc.cleanupMovement()
    Misc.setNoclip(false)
    local humanoid = getHumanoid()
    if humanoid then
        pcall(function()
            if Misc.originalWalkSpeed then
                humanoid.WalkSpeed = Misc.originalWalkSpeed
            end
            if Misc.originalJumpPower then
                humanoid.JumpPower = Misc.originalJumpPower
            end
        end)
    end
end
-- ---------------------------------------------------------------------------
-- Tabs
-- ---------------------------------------------------------------------------

function UI.buildTabs()
    -- Farm ------------------------------------------------------------------
    local farm = UI.getTab("Farm")
    UI.addSection(farm, "COMBAT", "Runtime adapter with tool and GUI fallbacks")
    UI.addToggle(farm, "Auto Farm (nearest enemy)", "autoFarm")
    UI.addToggle(farm, "Kill Aura", "killAura")
    UI.addToggle(farm, "Auto Boss (prioritize bosses)", "autoBoss")
    UI.addToggle(farm, "Auto Unlock / Enter Zones", "autoZone")
    UI.addToggle(farm, "Auto Movement", "autoMovement")
    UI.addToggle(farm, "Teleport to targets (risky)", "tpToTargets")
    UI.addToggle(farm, "Target other players", "targetPlayers")
    UI.addToggle(farm, "Use GUI ability buttons", "guiFallback")
    UI.addSlider(farm, "Farm range", "farmRange", 20, 1000, 10, " studs")
    UI.addSlider(farm, "Attack range", "attackRange", 5, 100, 1, " studs")
    UI.addSlider(farm, "Attack delay", "attackDelay", 0.1, 2, 0.05, "s")
    UI.diagLabels.farm = UI.addLabel(farm, "Scanner: waiting...", 18, Theme.muted)
    UI.addButton(farm, "Equip best tool", function()
        local tool = Combat.equipTool()
        if tool then
            notify("Equipped: " .. tostring(tool.Name), Theme.good)
        else
            notify("No tool found in Backpack.", Theme.warning)
        end
    end)
    UI.addButton(farm, "Attack nearest target", function()
        Scanner.ensure(true)
        local target, distance = Scanner.nearestEnemy(Settings.farmRange, false)
        if target then
            Combat.attack(target)
            notify("Attacking " .. target.name .. " (" .. string.format("%.0f", distance) .. " studs).", Theme.good)
        else
            notify("No target in range.", Theme.warning)
        end
    end)
    UI.addNote(farm, "Kill Aura and Auto Farm use a learned attack remote first. If none is mapped, they activate your equipped tool and click ability buttons. The game is server-authoritative, so not every action is guaranteed.", 62)

    UI.addSection(farm, "POWER TRAINING", "Bench training feeds Power, and Rebirth spends Power")
    UI.addToggle(farm, "Auto Train on Bench", "autoTrain")
    UI.addSlider(farm, "Train action interval", "trainInterval", 0.2, 5, 0.1, "s")
    UI.addSlider(farm, "Bench search range", "trainRange", 50, 3000, 25, " studs")
    UI.diagLabels.bench = UI.addLabel(farm, "Benches: 0 • nearest: ?", 18, Theme.muted)
    UI.addButton(farm, "Train at nearest bench now", function()
        Scanner.ensure(true)
        local bench, distance = Scanner.nearestBench(Settings.trainRange)
        if bench then
            if distance <= 20 then
                triggerObject(bench.root)
            else
                Packs.moveToObject(bench)
            end
            notify(string.format("Training at %s (%.0f studs).", bench.name, distance), Theme.good)
        else
            notify("No bench found in range. Walk to the training area or raise the search range.", Theme.warning)
        end
    end)
    UI.addButton(farm, "Diagnose bench scan", function()
        Scanner.ensure(true)
        local bench, distance = Scanner.nearestBench(Settings.trainRange)
        local message
        if bench then
            message = string.format("Found %d bench object(s). Nearest: %s at %.0f studs.", #Scanner.benches, bench.name, distance)
        else
            message = string.format("Found %d bench object(s), none within %d studs. Trigger names may not contain 'bench'.", #Scanner.benches, Settings.trainRange)
        end
        notify(message, bench and Theme.good or Theme.warning)
        Log.info(message)
    end)
    UI.addNote(farm, "The scanner looks for models and parts named bench, weight, dumbbell, treadmill or workout with a ProximityPrompt or ClickDetector. It also clicks visible Train buttons as a fallback. If nothing is found, stand in the training area and press Diagnose.", 62)

    -- Packs -----------------------------------------------------------------
    local packs = UI.getTab("Packs")
    UI.addSection(packs, "PACKS", "Claim, open, bank, fuse and place")
    UI.addToggle(packs, "Auto Claim Packs", "autoClaimPacks")
    UI.addToggle(packs, "Auto Grab Dropped Packs", "autoGrabDrops")
    UI.addToggle(packs, "Auto Open Packs", "autoOpenPacks")
    UI.addToggle(packs, "Auto Bank Packs", "autoBankPacks")
    UI.addToggle(packs, "Auto Fuse Cards", "autoFuse")
    UI.addToggle(packs, "Auto Place Best Cards", "autoPlaceBest")
    UI.addToggle(packs, "Auto Equip Best Aura / Trail", "autoEquipBest")
    UI.addToggle(packs, "Auto Use Luck / Power Potions", "autoPotions")
    UI.addSlider(packs, "Pack action interval", "packInterval", 0.2, 5, 0.1, "s")
    UI.diagLabels.packs = UI.addLabel(packs, "Packs found: 0", 18, Theme.muted)
    UI.addButton(packs, "Claim nearest pack", function()
        Scanner.ensure(true)
        local pack = Scanner.nearestPack(500)
        if pack then
            Packs.moveToObject(pack)
            notify("Moving to " .. pack.name, Theme.good)
        else
            notify("No pack found.", Theme.warning)
        end
    end)
    UI.addButton(packs, "Open pack now", function()
        if Adapter.profile.actions.openPack then
            Adapter.fire("openPack")
        end
        local clicked, text = Gui.click({ "open pack", "open", "unbox", "pull" }, { "settings", "shop", "robux", "upgrade", "rebirth" })
        if clicked then
            notify("Clicked: " .. tostring(text), Theme.good)
        else
            notify("No open button found. Use Learn Mode to map the open remote.", Theme.warning)
        end
    end)
    UI.addButton(packs, "Use Luck potion now", function()
        local used = Potions.use("luck", true)
        notify(used and "Luck potion used." or "No Luck potion button found. Open the potions menu first.", used and Theme.good or Theme.warning)
    end)
    UI.addButton(packs, "Use Power potion now", function()
        local used = Potions.use("power", true)
        notify(used and "Power potion used." or "No Power potion button found. Open the potions menu first.", used and Theme.good or Theme.warning)
    end)
    UI.addButton(packs, "Bank / deposit now", function()
        if Adapter.profile.actions.bankPack then
            Adapter.fire("bankPack")
        end
        local clicked = Gui.click({ "bank", "deposit" }, { "withdraw" })
        notify(clicked and "Bank button clicked." or "No bank button found.", clicked and Theme.good or Theme.warning)
    end)
    UI.addButton(packs, "Fuse cards now", function()
        if Adapter.profile.actions.fuse then
            Adapter.fire("fuse")
        end
        local clicked = Gui.click({ "fuse", "merge" }, nil)
        notify(clicked and "Fuse button clicked." or "No fuse button found.", clicked and Theme.good or Theme.warning)
    end)
    UI.addNote(packs, "Pack names and GUI labels change with updates. The scanner matches pack/crate/chest/drop names; Learn Mode maps the exact server calls when a feature stops working. Auto Potions uses Luck before opening packs and Power before boss fights.", 60)

    -- Economy ---------------------------------------------------------------
    local economy = UI.getTab("Economy")
    UI.addSection(economy, "PROGRESSION", "Upgrades, rebirth, rewards and codes")
    UI.addToggle(economy, "Auto Upgrade", "autoUpgrade")
    UI.addToggle(economy, "Auto Rebirth", "autoRebirth")
    UI.addToggle(economy, "Auto Claim Rewards", "autoRewards")
    UI.addToggle(economy, "Auto Codes", "autoCodes")
    UI.addSlider(economy, "Rebirth Power threshold", "rebirthThreshold", 10000, 100000000, 10000)
    UI.addSlider(economy, "Upgrade interval", "upgradeInterval", 1, 30, 1, "s")
    UI.addTextBox(economy, "Custom codes (comma separated)", "customCodes", "CODE1, CODE2")
    UI.diagLabels.economy = UI.addLabel(economy, "Cash: ? • Power: ? • Rebirth: ?", 18, Theme.muted)
    UI.addButton(economy, "Trigger rebirth now", function()
        if Economy.triggerRebirth() then
            notify("Rebirth action sent.", Theme.good)
        else
            notify("No rebirth button or remote found.", Theme.warning)
        end
    end)
    UI.addButton(economy, "Try next code now", function()
        local code = Codes.nextCode()
        if not code then
            notify("All known codes have been tried this session.", Theme.muted)
            return
        end
        local box = Gui.findTextBox({ "code", "promo", "redeem" })
        if not box then
            notify("Open the codes menu first.", Theme.warning)
            return
        end
        Gui.enterText(box, code, { "redeem", "claim", "submit", "enter", "use", "apply" })
        Codes.tried[code] = true
        notify("Tried code: " .. code, Theme.accent)
    end)
    UI.addButton(economy, "Reset tried codes", function()
        Codes.tried = {}
        notify("Code attempt history cleared.", Theme.muted)
    end)
    UI.addSection(economy, "GAME MENUS", "Open the game's own panels with their buttons")
    local menuShortcuts = {
        { "Open Codes menu", { "codes", "code", "promo" }, { "discord", "settings", "robux", "gamepass" } },
        { "Open Cards / Index", { "cards", "index", "collection", "inventory" }, { "settings", "robux", "gamepass" } },
        { "Open Upgrades / Shop", { "upgrades", "upgrade", "shop" }, { "rebirth", "codes", "settings" } },
        { "Open Auras / Trails", { "auras", "aura", "trails", "trail" }, { "settings", "robux", "gamepass", "rebirth" } },
        { "Open Rebirth menu", { "rebirth", "prestige" }, { "gamepass", "robux", "shop", "settings" } },
    }
    for index = 1, #menuShortcuts do
        local entry = menuShortcuts[index]
        UI.addButton(economy, entry[1], function()
            local clicked, text = Gui.click(entry[2], entry[3], { cooldown = 1.0 })
            notify(clicked and ("Opened: " .. tostring(text)) or "Button not found. Open the menu manually once.", clicked and Theme.good or Theme.warning)
        end)
    end
    UI.addSection(economy, "MAINTENANCE", "Reset or repair this configuration")
    UI.addButton(economy, "Reset all settings to defaults", function()
        resetSettings()
        notify("Settings reset and saved. Reload the script to apply everything.", Theme.accent)
    end)
    UI.addNote(economy, "Known codes are loaded from the repository and merged with your custom list. Codes expire; update codes.json in the repository or edit the custom list.", 46)

    -- Teleport --------------------------------------------------------------
    local teleport = UI.getTab("Teleport")
    UI.addSection(teleport, "TELEPORT", "Direct CFrame movement")
    UI.addButton(teleport, "Go to Spawn", function()
        Teleport.toSpawn()
    end)
    UI.addButton(teleport, "Go to Base", function()
        Teleport.toBase()
    end)
    UI.addButton(teleport, "Go to Training Bench", function()
        Teleport.toBench()
    end)
    UI.addButton(teleport, "Go to Card Holders", function()
        Teleport.toHolders()
    end)
    UI.addButton(teleport, "Go to Nearest Boss", function()
        Teleport.toBoss()
    end)
    UI.addButton(teleport, "Go to Next Zone / Portal", function()
        Teleport.toNextZone()
    end)
    local pointButton
    pointButton = UI.addSelect(teleport, "Teleport to a scanned point", function()
        return Teleport.options()
    end, function(point)
        if type(point) == "table" and point.position then
            Teleport.toPosition(point.position)
            pointButton.Text = "Teleport to: " .. tostring(point.name)
            notify("Teleported to " .. tostring(point.name), Theme.good)
        end
    end)
    UI.addButton(teleport, "Refresh teleport points", function()
        Teleport.refresh(true)
        notify("Found " .. tostring(#Teleport.points) .. " teleport points.", Theme.good)
    end)
    UI.diagLabels.teleports = UI.addLabel(teleport, "Teleport points: 0", 18, Theme.muted)
    UI.addNote(teleport, "Teleports set HumanoidRootPart.CFrame. Some servers detect or block large movement. Use this sparingly on an alt account.", 46)

    -- ESP -------------------------------------------------------------------
    local esp = UI.getTab("ESP")
    UI.addSection(esp, "ESP", "Highlights and name tags")
    UI.addToggle(esp, "Player ESP", "espPlayers")
    UI.addToggle(esp, "Boss ESP", "espBosses")
    UI.addToggle(esp, "Pack ESP", "espPacks")
    UI.addToggle(esp, "Chest / Loot ESP", "espChests")
    UI.addToggle(esp, "Show name tags", "espNames", function()
        ESP.update()
    end)
    UI.addButton(esp, "Clear all ESP", function()
        ESP.cleanup()
        notify("ESP cleared.", Theme.muted)
    end)
    UI.addNote(esp, "ESP uses Roblox Highlight and BillboardGui instances. Name tags are client-side only and may be hidden by the game's own UI.", 42)

    -- Misc ------------------------------------------------------------------
    local misc = UI.getTab("Misc")
    UI.addSection(misc, "QUALITY OF LIFE", "Client-side helpers")
    UI.addToggle(misc, "Anti-AFK", "antiAfk")
    UI.addToggle(misc, "Stats HUD", "hud", function()
        if UI.hud then
            UI.hud.Visible = Settings.hud
        end
    end)
    UI.addToggle(misc, "Show floating SAS button", "showToggleButton", function(enabled)
        if UI.toggleButton and UI.hidden then
            UI.toggleButton.Visible = enabled
        end
    end)
    UI.addToggle(misc, "Speed modifier", "speedEnabled", function()
        Misc.applyMovement()
    end)
    UI.addSlider(misc, "Walk speed", "walkSpeed", 16, 150, 1, "", function()
        Misc.applyMovement()
    end)
    UI.addToggle(misc, "Jump modifier", "jumpEnabled", function()
        Misc.applyMovement()
    end)
    UI.addSlider(misc, "Jump power", "jumpPower", 50, 250, 5, "", function()
        Misc.applyMovement()
    end)
    UI.addToggle(misc, "Noclip", "noclip", function(enabled)
        Misc.setNoclip(enabled)
    end)
    UI.addToggle(misc, "Infinite Jump", "infiniteJump")
    UI.addToggle(misc, "Anti-Void", "antiVoid")
    UI.addToggle(misc, "Fullbright", "fullbright", function(enabled)
        Misc.setFullbright(enabled)
    end)
    UI.addSlider(misc, "FPS cap (0 = off)", "fpsCap", 0, 240, 5, "", function()
        Misc.applyFpsCap()
    end)
    UI.addKeybind(misc, "Menu keybind", "uiKeybind")
    UI.addSection(misc, "WEBHOOK")
    UI.addToggle(misc, "Enable webhook", "webhookEnabled")
    UI.addTextBox(misc, "Discord webhook URL", "webhookUrl", "https://discord.com/api/webhooks/...")
    UI.addButton(misc, "Send test webhook", function()
        Misc.testWebhook()
    end)
    UI.addSection(misc, "SERVER")
    UI.addButton(misc, "Server hop (low population)", function()
        Misc.hop()
    end)
    UI.addButton(misc, "Rejoin this server", function()
        Misc.rejoin()
    end)
    UI.addButton(misc, "Unload script and clean up", function()
        if UI.unload then
            UI.unload()
        end
    end, { color = Theme.danger, hoverColor = Color3.fromRGB(180, 45, 65), textColor = Theme.white })
    UI.diagLabels.fps = UI.addLabel(misc, "FPS: ? • Executor: " .. ExecutorName, 18, Theme.muted)
    UI.addNote(misc, "Speed, jump, noclip and fullbright are client-side and may be reset by the game or blocked by server checks. Infinite Jump fires on the jump input event. Anti-Void watches your Y position and returns you to the last safe spot. Server hop uses the public Roblox server list.", 62)

    -- Learn -----------------------------------------------------------------
    local learn = UI.getTab("Learn")
    UI.addSection(learn, "LEARN MODE", "Map the current game remotes in one pass")
    UI.addNote(learn, "1. Click Start Capture. 2. Select a step. 3. Do that action once in-game. 4. Click Save Current Step. Repeat for each action. The profile is saved per PlaceVersion so it can survive small updates. Never run Learn Mode while another hub is injecting the same remote hooks.", 90)
    UI.learnStatusLabel = UI.addLabel(learn, "Idle • 0 captured", 20, Theme.accent)
    local stepButton
    stepButton = UI.addSelect(learn, "Learn step", function()
        local options = {}
        for index = 1, #Learn.steps do
            options[index] = { label = Learn.steps[index].label, value = index }
        end
        return options
    end, function(index)
        Learn.stepIndex = index
        Learn.stepStart = #Learn.entries + 1
        stepButton.Text = "Learn step: " .. Learn.steps[index].label
        Learn.updateStatus()
        notify("Learn step: " .. Learn.steps[index].label, Theme.accent)
    end)
    UI.addButton(learn, "Start capture", function()
        Learn.start()
    end, { color = Theme.accentDark, textColor = Theme.white })
    UI.addButton(learn, "Stop capture", function()
        Learn.stop()
    end)
    UI.addButton(learn, "Save current step", function()
        Learn.saveCurrentStep()
    end, { color = Theme.accentDark, textColor = Theme.white })
    UI.addButton(learn, "Next step", function()
        Learn.nextStep()
    end)
    UI.addButton(learn, "Clear capture log", function()
        Learn.clear()
    end)
    UI.addButton(learn, "Export / copy profile JSON", function()
        Learn.export()
    end)
    UI.addButton(learn, "Rescan remotes", function()
        Remotes.scanAll()
        notify("Scanning remotes...", Theme.accent)
    end)
    UI.addButton(learn, "Copy discovered remote paths", function()
        Gui.copyRemoteList()
    end)
    UI.remoteStatusLabel = UI.addLabel(learn, "Discovered remotes: 0", 18, Theme.muted)
    UI.addSection(learn, "DIAGNOSTICS")
    local function diagnostic(label, key, value)
        local text = UI.addLabel(learn, label .. ": " .. tostring(value), 17, Theme.muted)
        UI.diagLabels[key] = text
        return text
    end
    diagnostic("Executor", "executor", ExecutorName)
    diagnostic("Device", "device", (UI.mobile and "Mobile" or "PC") .. " / " .. (UserInputService and tostring(UserInputService.PreferredInput) or "?"))
    diagnostic("Game ID", "gameid", GAME_ID)
    diagnostic("Place ID", "placeid", PLACE_ID)
    diagnostic("PlaceVersion", "placeversion", "loading")
    diagnostic("Remotes discovered", "remotes", #Remotes.list)
    diagnostic("Profile actions", "profile", Adapter.count())
    diagnostic("Learn", "learn", "off")
    UI.addNote(learn, "If an executor cannot install a namecall hook, Learn Mode cannot capture calls. In that case, copy the remote list and map actions manually by editing the profile JSON.", 42)

    -- Log -------------------------------------------------------------------
    local logTab = UI.getTab("Log")
    UI.addSection(logTab, "LOG", "Last 60 events")
    local logLabel = newInstance("TextLabel", {
        BackgroundColor3 = Theme.panel,
        BorderSizePixel = 0,
        Font = Fonts.code,
        Text = Log.tail(60),
        TextColor3 = Theme.text,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Size = UDim2.new(1, -20, 0, 360),
    })
    padding(logLabel, 8)
    UI.add(logTab, logLabel, 360)
    UI.logLabel = logLabel
    Log.listeners[#Log.listeners + 1] = function()
        if UI.logLabel and UI.logLabel.Parent then
            UI.logLabel.Text = Log.tail(60)
        end
    end
    UI.addButton(logTab, "Copy log", function()
        if copyText(Log.tail(200)) then
            notify("Log copied.", Theme.good)
        else
            notify("Clipboard unavailable.", Theme.warning)
        end
    end)
    UI.addButton(logTab, "Clear log", function()
        Log.entries = {}
        if UI.logLabel then
            UI.logLabel.Text = ""
        end
    end)

    -- About -----------------------------------------------------------------
    local about = UI.getTab("About")
    UI.addSection(about, "STEAL A SUPERPOWER", "Universal Hub v" .. SCRIPT_VERSION)
    UI.addNote(about, "Build " .. BUILD_DATE .. "\nGame: [⚡] Steal a Superpower! (universe 10770228857)\nCompatibility: PC + Mobile\nUI: responsive safe-area layout, touch + mouse input\nAdapter: runtime remote discovery + guided Learn Mode", 96)
    UI.addNote(about, "Features: Auto Farm, Kill Aura, Auto Boss, Auto Zones, Auto Claim/Grab/Open/Bank Packs, Auto Fuse, Auto Place, Auto Equip, Auto Potions, Auto Train on Bench, Auto Upgrade, Power-based Auto Rebirth, Auto Rewards, Auto Codes, menu shortcuts, teleports to Bench/Holders/Boss/Zone, ESP, Anti-AFK, HUD, webhook, server hop, rejoin, speed/jump, noclip, infinite jump, anti-void, fullbright.", 108)
    UI.addButton(about, "Copy Loader.lua URL", function()
        local url = REPO_RAW .. "/Loader.lua"
        if copyText(url) then
            notify("Loader URL copied: " .. url, Theme.good)
        else
            notify("Clipboard unavailable.", Theme.warning)
        end
    end, { color = Theme.accentDark, textColor = Theme.white })
    UI.addNote(about, "Disclaimer: this is a third-party automation tool. It violates the game's intended rules and can get an account banned. Test on an alt. The script is server-authoritative-safe: it does not promise impossible effects. No key system, no data collection. The Discord webhook is optional and only sends what you enable.", 108)
    UI.addNote(about, "Repository: github.com/reizure87-create/StealASuperpower", 24, Theme.accent)

    Learn.updateStatus()
end

-- ---------------------------------------------------------------------------
-- Manifest / version notices
-- ---------------------------------------------------------------------------

local Manifest = {
    fetched = false,
}

function Manifest.fetch()
    if Manifest.fetched then
        return
    end
    Manifest.fetched = true
    task.spawn(function()
        local response = httpRequest({
            Url = MANIFEST_URL .. "?t=" .. tostring(os.time()),
            Method = "GET",
        })
        if not response or not response.Body then
            Log.info("Manifest unavailable; running local build.")
            return
        end
        local data = jsonDecode(response.Body)
        if type(data) ~= "table" then
            return
        end
        if type(data.codes) == "table" then
            Codes.add(data.codes)
        end
        if data.version and tostring(data.version) ~= SCRIPT_VERSION then
            notify("Update available: v" .. tostring(data.version) .. " (running v" .. SCRIPT_VERSION .. ").", Theme.warning)
            Log.warn("New version available: " .. tostring(data.version))
        end
        if data.message then
            Log.info("Repository: " .. tostring(data.message))
        end
        if data.gameUpdated then
            Log.info("Game version reference: " .. tostring(data.gameUpdated))
        end
    end)
end

-- ---------------------------------------------------------------------------
-- Main loop
-- ---------------------------------------------------------------------------

local Running = true

local function updateDiagnostics()
    if UI.diagLabels.farm then
        UI.diagLabels.farm.Text = string.format(
            "Scanner: %d enemies • %d bosses • %d packs",
            #Scanner.enemies,
            #Scanner.bosses,
            #Scanner.packs
        )
    end
    if UI.diagLabels.packs then
        UI.diagLabels.packs.Text = "Packs found: " .. tostring(#Scanner.packs)
    end
    if UI.diagLabels.economy then
        UI.diagLabels.economy.Text = string.format(
            "Cash: %s • Power: %s • Rebirth: %s",
            Stats.cash and compact(Stats.cash) or "?",
            Stats.power and compact(Stats.power) or "?",
            Stats.rebirth and compact(Stats.rebirth) or "?"
        )
    end
    if UI.diagLabels.bench then
        Scanner.ensure()
        local bench, distance = Scanner.nearestBench(Settings.trainRange)
        UI.diagLabels.bench.Text = string.format(
            "Benches: %d • nearest: %s",
            #Scanner.benches,
            bench and string.format("%s (%.0f)", bench.name, distance) or "none"
        )
    end
    if UI.diagLabels.teleports then
        UI.diagLabels.teleports.Text = "Teleport points: " .. tostring(#Teleport.points)
    end
    if UI.diagLabels.fps then
        UI.diagLabels.fps.Text = "FPS: " .. tostring(Stats.fps) .. " • Executor: " .. ExecutorName
    end
    if UI.diagLabels.profile then
        UI.diagLabels.profile.Text = "Profile actions: " .. tostring(Adapter.count())
    end
    if UI.diagLabels.placeversion then
        local placeVersion = 0
        pcall(function()
            placeVersion = game.PlaceVersion or 0
        end)
        UI.diagLabels.placeversion.Text = "PlaceVersion: " .. tostring(placeVersion)
    end
    if UI.diagLabels.device then
        UI.diagLabels.device.Text = "Device: " .. (UI.mobile and "Mobile" or "PC")
            .. " / " .. (UserInputService and tostring(UserInputService.PreferredInput) or "?")
    end
    Stats.updateHud()
end

local function mainLoop()
    local lastHud = 0
    while Running do
        task.wait(0.2)
        local ok, err = pcall(function()
            if Settings.autoFarm or Settings.killAura or Settings.autoBoss or Settings.autoZone then
                Combat.update()
            end
            Packs.update()
            Train.update()
            Economy.update()
            ESP.update()
            Stats.refresh()
            Misc.applyMovement()
            if now() - lastHud > 0.45 then
                lastHud = now()
                updateDiagnostics()
            end
        end)
        if not ok then
            Log.error("Main loop: " .. tostring(err))
        end
    end
end

-- ---------------------------------------------------------------------------
-- Unload
-- ---------------------------------------------------------------------------

local API_TOKEN = {}

function UI.unload()
    Running = false
    ESP.cleanup()
    Misc.cleanupMovement()
    Misc.setFullbright(false)
    for index = 1, #UI.connections do
        local connection = UI.connections[index]
        pcall(function()
            connection:Disconnect()
        end)
    end
    UI.connections = {}
    for index = 1, #Remotes.connections do
        local connection = Remotes.connections[index]
        pcall(function()
            connection:Disconnect()
        end)
    end
    Remotes.connections = {}
    local restoreFunction = execFn("restorefunction")
    if Learn.hookInstalled and Learn.oldNamecall then
        if restoreFunction then
            pcall(restoreFunction, Learn.oldNamecall)
        else
            local hookMetamethod = execFn("hookmetamethod")
            if hookMetamethod then
                pcall(hookMetamethod, game, "__namecall", Learn.oldNamecall)
            end
        end
    end
    local setFps = execFn("setfpscap")
    if setFps then
        pcall(setFps, 9999)
    end
    if UI.screen then
        UI.screen:Destroy()
    end
    if Genv and Genv.SAS_Hub and Genv.SAS_Hub._token == API_TOKEN then
        Genv.SAS_Hub = nil
    end
    print("[SAS] Unloaded. Connections closed and GUI destroyed.")
end

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------

local function start()
    local previous = Genv and Genv.SAS_Hub
    if type(previous) == "table" and type(previous.unload) == "function" then
        pcall(previous.unload)
        task.wait(0.1)
    end

    ensureFolders()
    loadConfig()
    Learn.loadProfile()
    UI.build()
    Misc.installAntiAfk()
    Misc.installMovementHelpers()
    Misc.setFullbright(Settings.fullbright)
    Misc.applyFpsCap()
    Misc.applyMovement()
    Remotes.installWatchers()
    task.spawn(Remotes.scanAll)
    task.spawn(Manifest.fetch)
    Codes.fetch()

    connect(RunService and RunService.RenderStepped, function()
        Stats.frames = Stats.frames + 1
        local time = now()
        if time - Stats.lastFpsTime >= 1 then
            Stats.fps = Stats.frames
            Stats.frames = 0
            Stats.lastFpsTime = time
        end
    end)

    task.spawn(mainLoop)

    Log.info("Loaded v" .. SCRIPT_VERSION .. " (" .. BUILD_DATE .. ") on " .. ExecutorName .. ".")
    notify("Steal a Superpower Hub loaded. Use Learn Mode if a feature stops after an update.", Theme.good)
    if Settings.webhookEnabled and Settings.webhookUrl ~= "" then
        task.spawn(function()
            Misc.sendWebhook("Hub loaded on " .. ExecutorName .. " (v" .. SCRIPT_VERSION .. ").")
        end)
    end
    Stats.updateHud()
    Learn.updateStatus()

    if Genv then
        Genv.SAS_Hub = {
            _token = API_TOKEN,
            version = SCRIPT_VERSION,
            buildDate = BUILD_DATE,
            ui = UI,
            gui = Gui,
            settings = Settings,
            stats = Stats,
            scanner = Scanner,
            remotes = Remotes,
            learn = Learn,
            adapter = Adapter,
            combat = Combat,
            packs = Packs,
            train = Train,
            potions = Potions,
            economy = Economy,
            teleport = Teleport,
            esp = ESP,
            misc = Misc,
            codes = Codes,
            notify = notify,
            saveConfig = saveConfig,
            resetSettings = resetSettings,
            unload = function()
                UI.unload()
            end,
        }
        Log.info("Debug API available at getgenv().SAS_Hub")
    end
end

local startOk, startError = pcall(start)
if not startOk then
    warn("[SAS] Startup failed: " .. tostring(startError))
    if UI and UI.screen then
        pcall(function()
            UI.screen:Destroy()
        end)
    end
end
