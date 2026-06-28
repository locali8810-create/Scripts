-- TurtleSpy V6.0.0 - Major Overhaul Update
-- Credits: Intrer#0421 (Original), Turtle-Brand Community
-- Changelog V6: Modern UI, Universal Executor Support, Advanced Features, Bug Fixes

-- ═══════════════════════════════════════════════════════════
-- SECTION 1: UNIVERSAL EXECUTOR COMPATIBILITY & ENV SETUP
-- ═══════════════════════════════════════════════════════════

local getgenv = getgenv or function() return _G end
local setclipboard = setclipboard or function() end
local getcallingscript = getcallingscript or function() return nil end
local decompile = decompile or function() return "-- Decompilation not supported on this executor" end
local getnamecallmethod = getnamecallmethod or get_namecall_method or function() return "" end
local get_thread_context = get_thread_context or syn and syn.get_thread_identity or function() return 2 end
local set_thread_context = set_thread_context or syn and syn.set_thread_identity or function() end
local checkcaller = checkcaller or function() return false end
local hookmetamethod = hookmetamethod or function() return function() end end
local hookfunction = hookfunction or function() return function() end end
local isfile = isfile or function(f) 
    local s, e = pcall(function() return readfile(f) end)
    return s and e ~= nil
end
local writefile = writefile or function() end
local readfile = readfile or function() return "" end
local syn = syn or {}
syn.protect_gui = syn.protect_gui or function() end

-- Executor detection
local executorName = "Unknown"
if syn and syn.request then executorName = "Synapse X" 
elseif PROTOSMASHER_LOADED then executorName = "ProtoSmasher"
elseif KRNL_LOADED then executorName = "KRNL"
elseif is_sirhurt_closure then executorName = "SirHurt"
elseif pebc_execute then executorName = "Panda"
elseif getexecutorname then executorName = getexecutorname()
elseif identifyexecutor then executorName = identifyexecutor()
end

-- ═══════════════════════════════════════════════════════════
-- SECTION 2: SETTINGS & CONFIGURATION SYSTEM
-- ═══════════════════════════════════════════════════════════

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")

local client = Players.LocalPlayer
local mouse = client:GetMouse()

-- Default settings with new V6 features
local defaultSettings = {
    ["Keybind"] = "P",
    ["Theme"] = "Dark",
    ["AutoScroll"] = true,
    ["MaxLogs"] = 500,
    ["ShowReturnValues"] = true,
    ["AutoFireDelay"] = 0.1,
    ["EnableSound"] = false,
    ["CompactMode"] = false,
    ["ShowTimestamps"] = true,
    ["FavoriteColor"] = "Yellow",
    ["BlockColor"] = "Red",
    ["IgnoreColor"] = "Gray",
    ["LogFormat"] = "default", -- default, detailed, minimal
}

-- Theme presets
local themes = {
    ["Dark"] = {
        HeaderColor = Color3.fromRGB(30, 30, 35),
        HeaderShadingColor = Color3.fromRGB(25, 25, 30),
        HeaderTextColor = Color3.fromRGB(220, 220, 230),
        MainBackgroundColor = Color3.fromRGB(35, 35, 42),
        InfoScrollingFrameBgColor = Color3.fromRGB(35, 35, 42),
        ScrollBarImageColor = Color3.fromRGB(80, 80, 90),
        BorderColor = Color3.fromRGB(60, 60, 70),
        ButtonBackground = Color3.fromRGB(45, 45, 55),
        ButtonText = Color3.fromRGB(220, 221, 225),
        CodeBackground = Color3.fromRGB(28, 28, 35),
        CodeText = Color3.fromRGB(220, 221, 225),
        CreditsColor = Color3.fromRGB(120, 120, 130),
        AccentColor = Color3.fromRGB(0, 168, 255),
    },
    ["Light"] = {
        HeaderColor = Color3.fromRGB(240, 240, 245),
        HeaderShadingColor = Color3.fromRGB(230, 230, 235),
        HeaderTextColor = Color3.fromRGB(50, 50, 60),
        MainBackgroundColor = Color3.fromRGB(250, 250, 255),
        InfoScrollingFrameBgColor = Color3.fromRGB(250, 250, 255),
        ScrollBarImageColor = Color3.fromRGB(180, 180, 190),
        BorderColor = Color3.fromRGB(200, 200, 210),
        ButtonBackground = Color3.fromRGB(240, 240, 245),
        ButtonText = Color3.fromRGB(50, 50, 60),
        CodeBackground = Color3.fromRGB(245, 245, 250),
        CodeText = Color3.fromRGB(50, 50, 60),
        CreditsColor = Color3.fromRGB(150, 150, 160),
        AccentColor = Color3.fromRGB(0, 140, 220),
    },
    ["Midnight"] = {
        HeaderColor = Color3.fromRGB(15, 15, 25),
        HeaderShadingColor = Color3.fromRGB(10, 10, 20),
        HeaderTextColor = Color3.fromRGB(180, 180, 200),
        MainBackgroundColor = Color3.fromRGB(20, 20, 30),
        InfoScrollingFrameBgColor = Color3.fromRGB(20, 20, 30),
        ScrollBarImageColor = Color3.fromRGB(60, 60, 80),
        BorderColor = Color3.fromRGB(40, 40, 55),
        ButtonBackground = Color3.fromRGB(30, 30, 45),
        ButtonText = Color3.fromRGB(200, 200, 220),
        CodeBackground = Color3.fromRGB(15, 15, 25),
        CodeText = Color3.fromRGB(200, 200, 220),
        CreditsColor = Color3.fromRGB(100, 100, 120),
        AccentColor = Color3.fromRGB(138, 43, 226),
    },
    ["Ocean"] = {
        HeaderColor = Color3.fromRGB(0, 100, 150),
        HeaderShadingColor = Color3.fromRGB(0, 80, 120),
        HeaderTextColor = Color3.fromRGB(220, 240, 255),
        MainBackgroundColor = Color3.fromRGB(0, 40, 60),
        InfoScrollingFrameBgColor = Color3.fromRGB(0, 40, 60),
        ScrollBarImageColor = Color3.fromRGB(0, 120, 180),
        BorderColor = Color3.fromRGB(0, 80, 120),
        ButtonBackground = Color3.fromRGB(0, 60, 90),
        ButtonText = Color3.fromRGB(220, 240, 255),
        CodeBackground = Color3.fromRGB(0, 30, 45),
        CodeText = Color3.fromRGB(220, 240, 255),
        CreditsColor = Color3.fromRGB(100, 150, 180),
        AccentColor = Color3.fromRGB(0, 200, 255),
    },
    ["Cyberpunk"] = {
        HeaderColor = Color3.fromRGB(20, 0, 40),
        HeaderShadingColor = Color3.fromRGB(15, 0, 30),
        HeaderTextColor = Color3.fromRGB(0, 255, 200),
        MainBackgroundColor = Color3.fromRGB(10, 0, 20),
        InfoScrollingFrameBgColor = Color3.fromRGB(10, 0, 20),
        ScrollBarImageColor = Color3.fromRGB(255, 0, 200),
        BorderColor = Color3.fromRGB(50, 0, 80),
        ButtonBackground = Color3.fromRGB(30, 0, 50),
        ButtonText = Color3.fromRGB(0, 255, 200),
        CodeBackground = Color3.fromRGB(15, 0, 25),
        CodeText = Color3.fromRGB(0, 255, 200),
        CreditsColor = Color3.fromRGB(150, 0, 200),
        AccentColor = Color3.fromRGB(255, 0, 200),
    }
}

-- Load or create settings
local settingsFile = "TurtleSpySettings_V6.json"
local settings = {}

if not isfile(settingsFile) then
    settings = defaultSettings
    writefile(settingsFile, HttpService:JSONEncode(settings))
else
    local success, loadedSettings = pcall(function()
        return HttpService:JSONDecode(readfile(settingsFile))
    end)
    if success and loadedSettings then
        settings = loadedSettings
        -- Merge with defaults for new V6 settings
        for k, v in pairs(defaultSettings) do
            if settings[k] == nil then
                settings[k] = v
            end
        end
    else
        settings = defaultSettings
        writefile(settingsFile, HttpService:JSONEncode(settings))
    end
end

-- Save settings function
local function saveSettings()
    pcall(function()
        writefile(settingsFile, HttpService:JSONEncode(settings))
    end)
end

-- Get current theme
local currentTheme = themes[settings["Theme"]] or themes["Dark"]

-- ═══════════════════════════════════════════════════════════
-- SECTION 3: UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════

function isSynapse()
    return syn and syn.request and true or false
end

function Parent(GUI)
    if syn and syn.protect_gui then
        syn.protect_gui(GUI)
        GUI.Parent = CoreGui
    elseif PROTOSMASHER_LOADED and get_hidden_gui then
        GUI.Parent = get_hidden_gui()
    else
        GUI.Parent = CoreGui
    end
end

local function toUnicode(string)
    local codepoints = "utf8.char("
    for _i, v in utf8.codes(string) do
        codepoints = codepoints .. v .. ', '
    end
    return codepoints:sub(1, -3) .. ')'
end

local function GetFullPathOfAnInstance(instance)
    if not instance then return "nil" end
    local name = instance.Name
    local head = (#name > 0 and '.' .. name) or "['']"

    if not instance.Parent and instance ~= game then
        return head .. " --[[ PARENTED TO NIL OR DESTROYED ]]"
    end

    if instance == game then
        return "game"
    elseif instance == workspace then
        return "workspace"
    else
        local _success, result = pcall(game.GetService, game, instance.ClassName)
        if result then
            head = ':GetService("' .. instance.ClassName .. '")'
        elseif instance == client then
            head = '.LocalPlayer'
        else
            local nonAlphaNum = name:gsub('[%w_]', '')
            local noPunct = nonAlphaNum:gsub('[%s%p]', '')
            if tonumber(name:sub(1, 1)) or (#nonAlphaNum ~= 0 and #noPunct == 0) then
                head = '["' .. name:gsub('"', '\"'):gsub('\', '\\') .. '"'
            elseif #nonAlphaNum ~= 0 and #noPunct > 0 then
                head = '[' .. toUnicode(name) .. ']'
            end
        end
    end
    return GetFullPathOfAnInstance(instance.Parent) .. head
end

local function len(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

local function formatTimestamp()
    if not settings["ShowTimestamps"] then return "" end
    local time = os.date("%H:%M:%S")
    return "[" .. time .. "] "
end

-- ═══════════════════════════════════════════════════════════
-- SECTION 4: TABLE TO STRING CONVERTER (IMPROVED)
-- ═══════════════════════════════════════════════════════════

local function convertTableToString(args, depth)
    depth = depth or 0
    local indent = string.rep("    ", depth)
    local string = ""
    local index = 1
    local totalLen = len(args)

    for i, v in pairs(args) do
        if type(i) == "string" then
            string = string .. indent .. '["' .. tostring(i) .. '"] = '
        elseif type(i) == "number" then
            string = string .. indent
        elseif type(i) == "userdata" and typeof(i) ~= "Instance" then
            string = string .. indent .. "[" .. typeof(i) .. ".new(" .. tostring(i) .. ")] = "
        elseif type(i) == "userdata" then
            string = string .. indent .. "[" .. GetFullPathOfAnInstance(i) .. "] = "
        end

        if v == nil then
            string = string .. "nil"
        elseif typeof(v) == "Instance" then
            string = string .. GetFullPathOfAnInstance(v)
        elseif type(v) == "number" then
            string = string .. tostring(v)
        elseif type(v) == "function" then
            string = string .. "function() --[[ Function ]] end"
        elseif type(v) == "userdata" then
            local vType = typeof(v)
            if vType == "Vector3" then
                string = string .. "Vector3.new(" .. tostring(v) .. ")"
            elseif vType == "Vector2" then
                string = string .. "Vector2.new(" .. tostring(v) .. ")"
            elseif vType == "CFrame" then
                string = string .. "CFrame.new(" .. tostring(v) .. ")"
            elseif vType == "Color3" then
                string = string .. "Color3.fromRGB(" .. math.floor(v.R * 255) .. ", " .. math.floor(v.G * 255) .. ", " .. math.floor(v.B * 255) .. ")"
            elseif vType == "UDim2" then
                string = string .. "UDim2.new(" .. tostring(v) .. ")"
            elseif vType == "UDim" then
                string = string .. "UDim.new(" .. tostring(v) .. ")"
            elseif vType == "Ray" then
                string = string .. "Ray.new(" .. tostring(v.Origin) .. ", " .. tostring(v.Direction) .. ")"
            elseif vType == "BrickColor" then
                string = string .. "BrickColor.new("" .. tostring(v) .. "")"
            elseif vType == "NumberRange" then
                string = string .. "NumberRange.new(" .. tostring(v) .. ")"
            elseif vType == "NumberSequence" then
                string = string .. "NumberSequence.new(" .. tostring(v) .. ")"
            elseif vType == "ColorSequence" then
                string = string .. "ColorSequence.new(" .. tostring(v) .. ")"
            else
                string = string .. vType .. ".new(" .. tostring(v) .. ")"
            end
        elseif type(v) == "string" then
            string = string .. [["]] .. v:gsub("\", "\\"):gsub('"', '\"'):gsub("
", "\n") .. [["]]
        elseif type(v) == "table" then
            string = string .. "{
"
            string = string .. convertTableToString(v, depth + 1)
            string = string .. indent .. "}"
        elseif type(v) == 'boolean' then
            string = string .. (v and 'true' or 'false')
        elseif type(v) == "thread" then
            string = string .. "coroutine.create(function() end)"
        end

        if totalLen > 1 and index < totalLen then
            string = string .. ",
"
        else
            string = string .. "
"
        end
        index = index + 1
    end
    return string
end

-- ═══════════════════════════════════════════════════════════
-- SECTION 5: GUI CREATION (MODERNIZED V6 UI)
-- ═══════════════════════════════════════════════════════════

-- Delete previous instances
for _, gui in pairs(CoreGui:GetChildren()) do
    if gui.Name == "TurtleSpyGUI" or gui.Name == "TurtleSpyGUI_V6" then
        gui:Destroy()
    end
end

-- Important tables
local remotes = {}
local remoteArgs = {}
local remoteButtons = {}
local remoteScripts = {}
local remoteTimestamps = {}
local remoteFavCount = {}
local IgnoreList = {}
local BlockList = {}
local FavoriteList = {}
local connections = {}
local unstacked = {}
local browsedRemotes = {}
local browsedConnections = {}

-- GUI Instances
local TurtleSpyGUI = Instance.new("ScreenGui")
TurtleSpyGUI.Name = "TurtleSpyGUI_V6"
TurtleSpyGUI.ResetOnSpawn = false
Parent(TurtleSpyGUI)

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "mainFrame"
mainFrame.Parent = TurtleSpyGUI
mainFrame.BackgroundColor3 = currentTheme.MainBackgroundColor
mainFrame.BorderColor3 = currentTheme.BorderColor
mainFrame.Position = UDim2.new(0.1, 0, 0.24, 0)
mainFrame.Size = UDim2.new(0, 220, 0, 35)
mainFrame.ZIndex = 8
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = mainFrame
Header.BackgroundColor3 = currentTheme.HeaderColor
Header.BorderColor3 = currentTheme.HeaderColor
Header.Size = UDim2.new(0, 220, 0, 28)
Header.ZIndex = 9

local HeaderShading = Instance.new("Frame")
HeaderShading.Name = "HeaderShading"
HeaderShading.Parent = Header
HeaderShading.BackgroundColor3 = currentTheme.HeaderShadingColor
HeaderShading.BorderColor3 = currentTheme.HeaderShadingColor
HeaderShading.Position = UDim2.new(0, 0, 0.3, 0)
HeaderShading.Size = UDim2.new(0, 220, 0, 28)
HeaderShading.ZIndex = 8

local HeaderTextLabel = Instance.new("TextLabel")
HeaderTextLabel.Name = "HeaderTextLabel"
HeaderTextLabel.Parent = HeaderShading
HeaderTextLabel.BackgroundTransparency = 1
HeaderTextLabel.Position = UDim2.new(0, 30, 0, 0)
HeaderTextLabel.Size = UDim2.new(0, 160, 0, 28)
HeaderTextLabel.ZIndex = 10
HeaderTextLabel.Font = Enum.Font.SourceSansBold
HeaderTextLabel.Text = "TurtleSpy V6"
HeaderTextLabel.TextColor3 = currentTheme.HeaderTextColor
HeaderTextLabel.TextSize = 16

-- Version label
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name = "VersionLabel"
VersionLabel.Parent = HeaderShading
VersionLabel.BackgroundTransparency = 1
VersionLabel.Position = UDim2.new(0, 30, 0, 14)
VersionLabel.Size = UDim2.new(0, 160, 0, 12)
VersionLabel.ZIndex = 10
VersionLabel.Font = Enum.Font.SourceSans
VersionLabel.Text = "Executor: " .. executorName
VersionLabel.TextColor3 = currentTheme.CreditsColor
VersionLabel.TextSize = 10

-- Icon
local IconImage = Instance.new("ImageLabel")
IconImage.Parent = Header
IconImage.BackgroundTransparency = 1
IconImage.Position = UDim2.new(0, 6, 0, 5)
IconImage.Size = UDim2.new(0, 18, 0, 18)
IconImage.ZIndex = 10
IconImage.Image = "rbxassetid://169476802"
IconImage.ImageColor3 = currentTheme.AccentColor

-- ═══════════════════════════════════════════════════════════
-- SECTION 6: SEARCH BAR (NEW V6 FEATURE)
-- ═══════════════════════════════════════════════════════════

local SearchFrame = Instance.new("Frame")
SearchFrame.Name = "SearchFrame"
SearchFrame.Parent = mainFrame
SearchFrame.BackgroundColor3 = currentTheme.ButtonBackground
SearchFrame.BorderColor3 = currentTheme.BorderColor
SearchFrame.Position = UDim2.new(0, 5, 0, 32)
SearchFrame.Size = UDim2.new(0, 210, 0, 24)
SearchFrame.ZIndex = 9
SearchFrame.Visible = false

local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Parent = SearchFrame
SearchBox.BackgroundTransparency = 1
SearchBox.Position = UDim2.new(0, 5, 0, 0)
SearchBox.Size = UDim2.new(0, 200, 0, 24)
SearchBox.ZIndex = 10
SearchBox.Font = Enum.Font.SourceSans
SearchBox.PlaceholderText = "Search remotes..."
SearchBox.Text = ""
SearchBox.TextColor3 = currentTheme.ButtonText
SearchBox.PlaceholderColor3 = currentTheme.CreditsColor
SearchBox.TextSize = 14
SearchBox.ClearTextOnFocus = false

-- ═══════════════════════════════════════════════════════════
-- SECTION 7: REMOTE SCROLL FRAME (IMPROVED)
-- ═══════════════════════════════════════════════════════════

local RemoteScrollFrame = Instance.new("ScrollingFrame")
RemoteScrollFrame.Name = "RemoteScrollFrame"
RemoteScrollFrame.Parent = mainFrame
RemoteScrollFrame.Active = true
RemoteScrollFrame.BackgroundColor3 = currentTheme.MainBackgroundColor
RemoteScrollFrame.BorderColor3 = currentTheme.MainBackgroundColor
RemoteScrollFrame.Position = UDim2.new(0, 0, 0, 58)
RemoteScrollFrame.Size = UDim2.new(0, 220, 0, 280)
RemoteScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 280)
RemoteScrollFrame.ScrollBarThickness = 6
RemoteScrollFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
RemoteScrollFrame.ScrollBarImageColor3 = currentTheme.ScrollBarImageColor
RemoteScrollFrame.Visible = false

-- Template Remote Button
local RemoteButton = Instance.new("TextButton")
RemoteButton.Name = "RemoteButton"
RemoteButton.Parent = RemoteScrollFrame
RemoteButton.BackgroundColor3 = currentTheme.ButtonBackground
RemoteButton.BorderColor3 = currentTheme.BorderColor
RemoteButton.Position = UDim2.new(0, 5, 0, 5)
RemoteButton.Size = UDim2.new(0, 210, 0, 26)
RemoteButton.ZIndex = 10
RemoteButton.Font = Enum.Font.SourceSans
RemoteButton.Text = ""
RemoteButton.TextSize = 16
RemoteButton.TextXAlignment = Enum.TextXAlignment.Left
RemoteButton.Visible = false

local Number = Instance.new("TextLabel")
Number.Name = "Number"
Number.Parent = RemoteButton
Number.BackgroundTransparency = 1
Number.Position = UDim2.new(0, 5, 0, 0)
Number.Size = UDim2.new(0, 30, 0, 26)
Number.ZIndex = 11
Number.Font = Enum.Font.SourceSansBold
Number.Text = "1"
Number.TextColor3 = currentTheme.AccentColor
Number.TextSize = 14
Number.TextXAlignment = Enum.TextXAlignment.Left

local RemoteName = Instance.new("TextLabel")
RemoteName.Name = "RemoteName"
RemoteName.Parent = RemoteButton
RemoteName.BackgroundTransparency = 1
RemoteName.Position = UDim2.new(0, 35, 0, 0)
RemoteName.Size = UDim2.new(0, 140, 0, 26)
RemoteName.ZIndex = 11
RemoteName.Font = Enum.Font.SourceSans
RemoteName.Text = "RemoteEvent"
RemoteName.TextColor3 = currentTheme.ButtonText
RemoteName.TextSize = 14
RemoteName.TextXAlignment = Enum.TextXAlignment.Left
RemoteName.TextTruncate = Enum.TextTruncate.AtEnd

local RemoteIcon = Instance.new("ImageLabel")
RemoteIcon.Name = "RemoteIcon"
RemoteIcon.Parent = RemoteButton
RemoteIcon.BackgroundTransparency = 1
RemoteIcon.Position = UDim2.new(0, 185, 0, 1)
RemoteIcon.Size = UDim2.new(0, 22, 0, 22)
RemoteIcon.ZIndex = 11
RemoteIcon.Image = "http://www.roblox.com/asset/?id=413369506"

local FavoriteStar = Instance.new("TextLabel")
FavoriteStar.Name = "FavoriteStar"
FavoriteStar.Parent = RemoteButton
FavoriteStar.BackgroundTransparency = 1
FavoriteStar.Position = UDim2.new(0, 170, 0, 0)
FavoriteStar.Size = UDim2.new(0, 14, 0, 26)
FavoriteStar.ZIndex = 11
FavoriteStar.Font = Enum.Font.SourceSans
FavoriteStar.Text = "★"
FavoriteStar.TextColor3 = Color3.fromRGB(255, 215, 0)
FavoriteStar.TextSize = 14
FavoriteStar.Visible = false

-- ═══════════════════════════════════════════════════════════
-- SECTION 8: INFO FRAME (EXPANDED)
-- ═══════════════════════════════════════════════════════════

local InfoFrame = Instance.new("Frame")
InfoFrame.Name = "InfoFrame"
InfoFrame.Parent = mainFrame
InfoFrame.BackgroundColor3 = currentTheme.MainBackgroundColor
InfoFrame.BorderColor3 = currentTheme.MainBackgroundColor
InfoFrame.Position = UDim2.new(1, 0, 0, 0)
InfoFrame.Size = UDim2.new(0, 380, 0, 340)
InfoFrame.Visible = false
InfoFrame.ZIndex = 6

local InfoFrameHeader = Instance.new("Frame")
InfoFrameHeader.Name = "InfoFrameHeader"
InfoFrameHeader.Parent = InfoFrame
InfoFrameHeader.BackgroundColor3 = currentTheme.HeaderColor
InfoFrameHeader.BorderColor3 = currentTheme.HeaderColor
InfoFrameHeader.Size = UDim2.new(0, 380, 0, 28)
InfoFrameHeader.ZIndex = 14

local InfoTitleShading = Instance.new("Frame")
InfoTitleShading.Name = "InfoTitleShading"
InfoTitleShading.Parent = InfoFrame
InfoTitleShading.BackgroundColor3 = currentTheme.HeaderShadingColor
InfoTitleShading.BorderColor3 = currentTheme.HeaderShadingColor
InfoTitleShading.Position = UDim2.new(0, 0, 0, 0)
InfoTitleShading.Size = UDim2.new(0, 380, 0, 32)
InfoTitleShading.ZIndex = 13

local InfoHeaderText = Instance.new("TextLabel")
InfoHeaderText.Name = "InfoHeaderText"
InfoHeaderText.Parent = InfoFrame
InfoHeaderText.BackgroundTransparency = 1
InfoHeaderText.Position = UDim2.new(0, 10, 0, 0)
InfoHeaderText.Size = UDim2.new(0, 340, 0, 32)
InfoHeaderText.ZIndex = 18
InfoHeaderText.Font = Enum.Font.SourceSansBold
InfoHeaderText.Text = "Info: RemoteFunction"
InfoHeaderText.TextColor3 = currentTheme.HeaderTextColor
InfoHeaderText.TextSize = 16

-- Code Frame with Syntax Highlighting support
local CodeFrame = Instance.new("ScrollingFrame")
CodeFrame.Name = "CodeFrame"
CodeFrame.Parent = InfoFrame
CodeFrame.Active = true
CodeFrame.BackgroundColor3 = currentTheme.CodeBackground
CodeFrame.BorderColor3 = currentTheme.BorderColor
CodeFrame.Position = UDim2.new(0, 10, 0, 38)
CodeFrame.Size = UDim2.new(0, 360, 0, 70)
CodeFrame.ZIndex = 16
CodeFrame.CanvasSize = UDim2.new(0, 700, 2, 0)
CodeFrame.ScrollBarThickness = 6
CodeFrame.ScrollingDirection = Enum.ScrollingDirection.XY
CodeFrame.ScrollBarImageColor3 = currentTheme.ScrollBarImageColor

local CodeComment = Instance.new("TextLabel")
CodeComment.Name = "CodeComment"
CodeComment.Parent = CodeFrame
CodeComment.BackgroundTransparency = 1
CodeComment.Position = UDim2.new(0, 5, 0, 2)
CodeComment.Size = UDim2.new(0, 1000, 0, 18)
CodeComment.ZIndex = 18
CodeComment.Font = Enum.Font.SourceSansItalic
CodeComment.Text = "-- Script generated by TurtleSpy V6"
CodeComment.TextColor3 = currentTheme.CreditsColor
CodeComment.TextSize = 12
CodeComment.TextXAlignment = Enum.TextXAlignment.Left

local Code = Instance.new("TextLabel")
Code.Name = "Code"
Code.Parent = CodeFrame
Code.BackgroundTransparency = 1
Code.Position = UDim2.new(0, 5, 0, 20)
Code.Size = UDim2.new(0, 10000, 0, 25)
Code.ZIndex = 18
Code.Font = Enum.Font.Code
Code.Text = "Thanks for using TurtleSpy V6!"
Code.TextColor3 = currentTheme.CodeText
Code.TextSize = 13
Code.TextWrapped = true
Code.TextXAlignment = Enum.TextXAlignment.Left

-- Timestamp label
local TimestampLabel = Instance.new("TextLabel")
TimestampLabel.Name = "TimestampLabel"
TimestampLabel.Parent = InfoFrame
TimestampLabel.BackgroundTransparency = 1
TimestampLabel.Position = UDim2.new(0, 10, 0, 110)
TimestampLabel.Size = UDim2.new(0, 360, 0, 16)
TimestampLabel.ZIndex = 16
TimestampLabel.Font = Enum.Font.SourceSans
TimestampLabel.Text = "Last fired: Never"
TimestampLabel.TextColor3 = currentTheme.CreditsColor
TimestampLabel.TextSize = 12
TimestampLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Info Buttons Scroll
local InfoButtonsScroll = Instance.new("ScrollingFrame")
InfoButtonsScroll.Name = "InfoButtonsScroll"
InfoButtonsScroll.Parent = InfoFrame
InfoButtonsScroll.Active = true
InfoButtonsScroll.BackgroundColor3 = currentTheme.MainBackgroundColor
InfoButtonsScroll.BorderColor3 = currentTheme.MainBackgroundColor
InfoButtonsScroll.Position = UDim2.new(0, 10, 0, 130)
InfoButtonsScroll.Size = UDim2.new(0, 360, 0, 200)
InfoButtonsScroll.ZIndex = 11
InfoButtonsScroll.CanvasSize = UDim2.new(0, 0, 1.5, 0)
InfoButtonsScroll.ScrollBarThickness = 6
InfoButtonsScroll.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
InfoButtonsScroll.ScrollBarImageColor3 = currentTheme.ScrollBarImageColor

-- Button creation helper
local function createInfoButton(name, text, yPos)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = InfoButtonsScroll
    btn.BackgroundColor3 = currentTheme.ButtonBackground
    btn.BorderColor3 = currentTheme.BorderColor
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.Size = UDim2.new(0, 350, 0, 26)
    btn.ZIndex = 15
    btn.Font = Enum.Font.SourceSans
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(250, 251, 255)
    btn.TextSize = 14
    btn.AutoButtonColor = true
    return btn
end

local CopyCode = createInfoButton("CopyCode", "📋 Copy code", 5)
local RunCode = createInfoButton("RunCode", "▶ Execute", 36)
local CopyScriptPath = createInfoButton("CopyScriptPath", "📁 Copy script path", 67)
local CopyDecompiled = createInfoButton("CopyDecompiled", "🔍 Copy decompiled script", 98)
local FavoriteRemote = createInfoButton("FavoriteRemote", "⭐ Add to favorites", 129)
local DoNotStack = createInfoButton("DoNotStack", "🔄 Unstack remote (new args)", 160)
local IgnoreRemote = createInfoButton("IgnoreRemote", "🚫 Ignore remote", 191)
local BlockRemote = createInfoButton("BlockRemote", "🛑 Block remote from firing", 222)
local WhileLoop = createInfoButton("WhileLoop", "🔁 Generate while loop script", 253)
local AutoFire = createInfoButton("AutoFire", "🔥 Auto-fire remote", 284)
local Clear = createInfoButton("Clear", "🗑 Clear all logs", 315)
local CopyReturn = createInfoButton("CopyReturn", "📤 Execute & copy return", 346)
local ExportLogs = createInfoButton("ExportLogs", "💾 Export logs to file", 377)
local ThemeToggle = createInfoButton("ThemeToggle", "🎨 Toggle theme", 408)

-- ═══════════════════════════════════════════════════════════
-- SECTION 9: REMOTE BROWSER (ENHANCED)
-- ═══════════════════════════════════════════════════════════

local BrowserHeader = Instance.new("Frame")
BrowserHeader.Name = "BrowserHeader"
BrowserHeader.Parent = TurtleSpyGUI
BrowserHeader.BackgroundColor3 = currentTheme.HeaderShadingColor
BrowserHeader.BorderColor3 = currentTheme.HeaderShadingColor
BrowserHeader.Position = UDim2.new(0.5, 0, 0.3, 0)
BrowserHeader.Size = UDim2.new(0, 220, 0, 30)
BrowserHeader.ZIndex = 20
BrowserHeader.Active = true
BrowserHeader.Draggable = true
BrowserHeader.Visible = false

local BrowserHeaderFrame = Instance.new("Frame")
BrowserHeaderFrame.Name = "BrowserHeaderFrame"
BrowserHeaderFrame.Parent = BrowserHeader
BrowserHeaderFrame.BackgroundColor3 = currentTheme.HeaderColor
BrowserHeaderFrame.BorderColor3 = currentTheme.HeaderColor
BrowserHeaderFrame.Size = UDim2.new(0, 220, 0, 26)
BrowserHeaderFrame.ZIndex = 21

local BrowserHeaderText = Instance.new("TextLabel")
BrowserHeaderText.Name = "BrowserHeaderText"
BrowserHeaderText.Parent = BrowserHeaderFrame
BrowserHeaderText.BackgroundTransparency = 1
BrowserHeaderText.Size = UDim2.new(0, 200, 0, 26)
BrowserHeaderText.ZIndex = 22
BrowserHeaderText.Font = Enum.Font.SourceSansBold
BrowserHeaderText.Text = "🔍 Remote Browser"
BrowserHeaderText.TextColor3 = currentTheme.HeaderTextColor
BrowserHeaderText.TextSize = 15

local CloseBrowser = Instance.new("TextButton")
CloseBrowser.Name = "CloseBrowser"
CloseBrowser.Parent = BrowserHeaderFrame
CloseBrowser.BackgroundColor3 = currentTheme.HeaderColor
CloseBrowser.BorderColor3 = currentTheme.HeaderColor
CloseBrowser.Position = UDim2.new(0, 195, 0, 2)
CloseBrowser.Size = UDim2.new(0, 22, 0, 22)
CloseBrowser.ZIndex = 38
CloseBrowser.Font = Enum.Font.SourceSansLight
CloseBrowser.Text = "✕"
CloseBrowser.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBrowser.TextSize = 16

local BrowserSearch = Instance.new("TextBox")
BrowserSearch.Name = "BrowserSearch"
BrowserSearch.Parent = BrowserHeaderFrame
BrowserSearch.BackgroundColor3 = currentTheme.ButtonBackground
BrowserSearch.BorderColor3 = currentTheme.BorderColor
BrowserSearch.Position = UDim2.new(0, 5, 0, 30)
BrowserSearch.Size = UDim2.new(0, 210, 0, 22)
BrowserSearch.ZIndex = 22
BrowserSearch.Font = Enum.Font.SourceSans
BrowserSearch.PlaceholderText = "Filter remotes..."
BrowserSearch.Text = ""
BrowserSearch.TextColor3 = currentTheme.ButtonText
BrowserSearch.PlaceholderColor3 = currentTheme.CreditsColor
BrowserSearch.TextSize = 13

local RemoteBrowserFrame = Instance.new("ScrollingFrame")
RemoteBrowserFrame.Name = "RemoteBrowserFrame"
RemoteBrowserFrame.Parent = BrowserHeader
RemoteBrowserFrame.Active = true
RemoteBrowserFrame.BackgroundColor3 = currentTheme.MainBackgroundColor
RemoteBrowserFrame.BorderColor3 = currentTheme.MainBackgroundColor
RemoteBrowserFrame.Position = UDim2.new(0, 0, 0, 58)
RemoteBrowserFrame.Size = UDim2.new(0, 220, 0, 260)
RemoteBrowserFrame.ZIndex = 19
RemoteBrowserFrame.CanvasSize = UDim2.new(0, 0, 0, 260)
RemoteBrowserFrame.ScrollBarThickness = 6
RemoteBrowserFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
RemoteBrowserFrame.ScrollBarImageColor3 = currentTheme.ScrollBarImageColor

-- ═══════════════════════════════════════════════════════════
-- SECTION 10: CONTROL BUTTONS
-- ═══════════════════════════════════════════════════════════

local OpenInfoFrame = Instance.new("TextButton")
OpenInfoFrame.Name = "OpenInfoFrame"
OpenInfoFrame.Parent = mainFrame
OpenInfoFrame.BackgroundColor3 = currentTheme.HeaderColor
OpenInfoFrame.BorderColor3 = currentTheme.HeaderColor
OpenInfoFrame.Position = UDim2.new(0, 195, 0, 3)
OpenInfoFrame.Size = UDim2.new(0, 22, 0, 22)
OpenInfoFrame.ZIndex = 18
OpenInfoFrame.Font = Enum.Font.SourceSansBold
OpenInfoFrame.Text = "▶"
OpenInfoFrame.TextColor3 = currentTheme.AccentColor
OpenInfoFrame.TextSize = 14

local Minimize = Instance.new("TextButton")
Minimize.Name = "Minimize"
Minimize.Parent = mainFrame
Minimize.BackgroundColor3 = currentTheme.HeaderColor
Minimize.BorderColor3 = currentTheme.HeaderColor
Minimize.Position = UDim2.new(0, 172, 0, 3)
Minimize.Size = UDim2.new(0, 22, 0, 22)
Minimize.ZIndex = 18
Minimize.Font = Enum.Font.SourceSansBold
Minimize.Text = "─"
Minimize.TextColor3 = currentTheme.HeaderTextColor
Minimize.TextSize = 14

local BrowserToggle = Instance.new("TextButton")
BrowserToggle.Name = "BrowserToggle"
BrowserToggle.Parent = mainFrame
BrowserToggle.BackgroundColor3 = currentTheme.HeaderColor
BrowserToggle.BorderColor3 = currentTheme.HeaderColor
BrowserToggle.Position = UDim2.new(0, 149, 0, 3)
BrowserToggle.Size = UDim2.new(0, 22, 0, 22)
BrowserToggle.ZIndex = 18
BrowserToggle.Font = Enum.Font.SourceSans
BrowserToggle.Text = "🔍"
BrowserToggle.TextSize = 12

-- ═══════════════════════════════════════════════════════════
-- SECTION 11: CORE LOGIC & FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local buttonOffset = -25
local scrollSizeOffset = 280
local InfoFrameOpen = false
local lookingAt
local lookingAtArgs
local lookingAtButton
local decompiling = false
local autoFiring = false
local autoFireConnection

local functionImage = "http://www.roblox.com/asset/?id=413369623"
local eventImage = "http://www.roblox.com/asset/?id=413369506"

-- Button effect
local function ButtonEffect(textlabel, text)
    text = text or "✓ Copied!"
    local orgText = textlabel.Text
    local orgColor = textlabel.TextColor3
    textlabel.Text = text
    textlabel.TextColor3 = Color3.fromRGB(76, 209, 55)
    wait(0.8)
    textlabel.Text = orgText
    textlabel.TextColor3 = orgColor
end

-- Find remote function (improved)
local function FindRemote(remote, args)
    local currentId = get_thread_context()
    set_thread_context(7)
    local i
    if table.find(unstacked, remote) then
        for b, v in pairs(remotes) do
            if v == remote then
                for i2, v2 in pairs(remoteArgs) do
                    if table.unpack(remoteArgs[b]) == table.unpack(args) then
                        i = b
                    end
                end
            end
        end
    else
        i = table.find(remotes, remote)
    end
    set_thread_context(currentId)
    return i
end

-- ═══════════════════════════════════════════════════════════
-- SECTION 12: BUTTON FUNCTIONALITY
-- ═══════════════════════════════════════════════════════════

CopyCode.MouseButton1Click:Connect(function()
    if not lookingAt then return end
    setclipboard(CodeComment.Text .. "

" .. Code.Text)
    ButtonEffect(CopyCode)
end)

RunCode.MouseButton1Click:Connect(function()
    if not lookingAt then return end
    local success, err = pcall(function()
        if typeof(lookingAt) == "Instance" and lookingAt:IsA("RemoteFunction") then
            lookingAt:InvokeServer(unpack(lookingAtArgs))
        elseif typeof(lookingAt) == "Instance" and lookingAt:IsA("RemoteEvent") then
            lookingAt:FireServer(unpack(lookingAtArgs))
        end
    end)
    if not success then
        RunCode.Text = "❌ Error: " .. tostring(err):sub(1, 30)
        RunCode.TextColor3 = Color3.fromRGB(255, 80, 80)
        wait(2)
        RunCode.Text = "▶ Execute"
        RunCode.TextColor3 = Color3.fromRGB(250, 251, 255)
    else
        ButtonEffect(RunCode, "✓ Executed!")
    end
end)

CopyScriptPath.MouseButton1Click:Connect(function()
    local remote = FindRemote(lookingAt, lookingAtArgs)
    if remote and lookingAt then
        setclipboard(GetFullPathOfAnInstance(remoteScripts[remote]))
        ButtonEffect(CopyScriptPath)
    end
end)

CopyDecompiled.MouseButton1Click:Connect(function()
    local remote = FindRemote(lookingAt, lookingAtArgs)
    if not decompile then
        CopyDecompiled.Text = "❌ Decompilation not supported!"
        CopyDecompiled.TextColor3 = Color3.fromRGB(255, 80, 80)
        wait(2)
        CopyDecompiled.Text = "🔍 Copy decompiled script"
        CopyDecompiled.TextColor3 = Color3.fromRGB(250, 251, 255)
        return
    end
    if not decompiling and remote and lookingAt then
        decompiling = true
        spawn(function()
            local dots = 0
            while decompiling do
                dots = (dots + 1) % 4
                CopyDecompiled.Text = "🔍 Decompiling" .. string.rep(".", dots)
                wait(0.5)
            end
        end)
        local success, result = pcall(function()
            return decompile(remoteScripts[remote])
        end)
        decompiling = false
        if success then
            setclipboard(result)
            CopyDecompiled.Text = "✓ Copied decompilation!"
            CopyDecompiled.TextColor3 = Color3.fromRGB(76, 209, 55)
        else
            CopyDecompiled.Text = "❌ Decompilation error!"
            CopyDecompiled.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
        wait(2)
        CopyDecompiled.Text = "🔍 Copy decompiled script"
        CopyDecompiled.TextColor3 = Color3.fromRGB(250, 251, 255)
    end
end)

FavoriteRemote.MouseButton1Click:Connect(function()
    if not lookingAt then return end
    local favIndex = table.find(FavoriteList, lookingAt)
    if favIndex then
        table.remove(FavoriteList, favIndex)
        FavoriteRemote.Text = "⭐ Add to favorites"
        FavoriteRemote.TextColor3 = Color3.fromRGB(250, 251, 255)
    else
        table.insert(FavoriteList, lookingAt)
        FavoriteRemote.Text = "💛 Remove from favorites"
        FavoriteRemote.TextColor3 = Color3.fromRGB(255, 215, 0)
    end
    -- Update visual indicator on button
    local remote = table.find(remotes, lookingAt)
    if remote and remoteButtons[remote] then
        local btn = remoteButtons[remote].Parent
        if btn and btn:FindFirstChild("FavoriteStar") then
            btn.FavoriteStar.Visible = not favIndex
        end
    end
end)

BlockRemote.MouseButton1Click:Connect(function()
    local bRemote = table.find(BlockList, lookingAt)
    if lookingAt and not bRemote then
        table.insert(BlockList, lookingAt)
        BlockRemote.Text = "✅ Unblock remote"
        BlockRemote.TextColor3 = Color3.fromRGB(251, 197, 49)
        local remote = table.find(remotes, lookingAt)
        if remote and remoteButtons[remote] then
            remoteButtons[remote].Parent.RemoteName.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    elseif lookingAt and bRemote then
        table.remove(BlockList, bRemote)
        BlockRemote.Text = "🛑 Block remote from firing"
        BlockRemote.TextColor3 = Color3.fromRGB(250, 251, 255)
        local remote = table.find(remotes, lookingAt)
        if remote and remoteButtons[remote] then
            remoteButtons[remote].Parent.RemoteName.TextColor3 = Color3.fromRGB(245, 246, 250)
        end
    end
end)

IgnoreRemote.MouseButton1Click:Connect(function()
    local iRemote = table.find(IgnoreList, lookingAt)
    if lookingAt and not iRemote then
        table.insert(IgnoreList, lookingAt)
        IgnoreRemote.Text = "👁 Stop ignoring remote"
        IgnoreRemote.TextColor3 = Color3.fromRGB(127, 143, 166)
        local remote = table.find(remotes, lookingAt)
        if remote and remoteButtons[remote] then
            remoteButtons[remote].Parent.RemoteName.TextColor3 = Color3.fromRGB(127, 143, 166)
        end
    elseif lookingAt and iRemote then
        table.remove(IgnoreList, iRemote)
        IgnoreRemote.Text = "🚫 Ignore remote"
        IgnoreRemote.TextColor3 = Color3.fromRGB(250, 251, 255)
        local remote = table.find(remotes, lookingAt)
        if remote and remoteButtons[remote] then
            remoteButtons[remote].Parent.RemoteName.TextColor3 = Color3.fromRGB(245, 246, 250)
        end
    end
end)

WhileLoop.MouseButton1Click:Connect(function()
    if not lookingAt then return end
    setclipboard("while wait() do
    " .. Code.Text .. "
end")
    ButtonEffect(WhileLoop)
end)

-- NEW V6: Auto-fire feature
AutoFire.MouseButton1Click:Connect(function()
    if not lookingAt then return end
    if autoFiring then
        autoFiring = false
        if autoFireConnection then
            autoFireConnection:Disconnect()
            autoFireConnection = nil
        end
        AutoFire.Text = "🔥 Auto-fire remote"
        AutoFire.TextColor3 = Color3.fromRGB(250, 251, 255)
    else
        autoFiring = true
        AutoFire.Text = "🔥 Stop auto-fire"
        AutoFire.TextColor3 = Color3.fromRGB(255, 80, 80)
        autoFireConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not autoFiring or not lookingAt then return end
            pcall(function()
                if lookingAt:IsA("RemoteFunction") then
                    lookingAt:InvokeServer(unpack(lookingAtArgs))
                elseif lookingAt:IsA("RemoteEvent") then
                    lookingAt:FireServer(unpack(lookingAtArgs))
                end
            end)
            wait(settings["AutoFireDelay"] or 0.1)
        end)
    end
end)

Clear.MouseButton1Click:Connect(function()
    for i, v in pairs(RemoteScrollFrame:GetChildren()) do
        if i > 1 and v:IsA("TextButton") then
            v:Destroy()
        end
    end
    for i, v in pairs(connections) do
        pcall(function() v:Disconnect() end)
    end
    buttonOffset = -25
    scrollSizeOffset = 280
    remotes = {}
    remoteArgs = {}
    remoteButtons = {}
    remoteScripts = {}
    remoteTimestamps = {}
    remoteFavCount = {}
    IgnoreList = {}
    BlockList = {}
    FavoriteList = {}
    unstacked = {}
    connections = {}
    RemoteScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 280)
    ButtonEffect(Clear, "✓ Cleared!")
end)

CopyReturn.MouseButton1Click:Connect(function()
    local remote = FindRemote(lookingAt, lookingAtArgs)
    if lookingAt and remote then
        if typeof(lookingAt) == "Instance" and lookingAt:IsA("RemoteFunction") then
            local success, result = pcall(function()
                return remotes[remote]:InvokeServer(unpack(remoteArgs[remote]))
            end)
            if success then
                setclipboard(convertTableToString(table.pack(result)))
                ButtonEffect(CopyReturn, "✓ Return copied!")
            else
                ButtonEffect(CopyReturn, "❌ Error!")
            end
        end
    end
end)

-- NEW V6: Export logs
ExportLogs.MouseButton1Click:Connect(function()
    local exportText = "-- TurtleSpy V6 Log Export
-- Date: " .. os.date("%Y-%m-%d %H:%M:%S") .. "

"
    for i, remote in pairs(remotes) do
        local fireFunc = remote:IsA("RemoteEvent") and ":FireServer" or ":InvokeServer"
        exportText = exportText .. "-- Remote: " .. remote.Name .. "
"
        exportText = exportText .. GetFullPathOfAnInstance(remote) .. fireFunc .. "(" .. convertTableToString(remoteArgs[i]) .. ")

"
    end
    local exportFile = "TurtleSpy_Logs_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
    pcall(function()
        writefile(exportFile, exportText)
    end)
    setclipboard(exportText)
    ButtonEffect(ExportLogs, "✓ Exported & copied!")
end)

-- NEW V6: Theme toggle
local themeNames = {"Dark", "Light", "Midnight", "Ocean", "Cyberpunk"}
local currentThemeIndex = 1
for i, name in ipairs(themeNames) do
    if name == settings["Theme"] then
        currentThemeIndex = i
        break
    end
end

ThemeToggle.MouseButton1Click:Connect(function()
    currentThemeIndex = (currentThemeIndex % #themeNames) + 1
    local newThemeName = themeNames[currentThemeIndex]
    settings["Theme"] = newThemeName
    saveSettings()
    ThemeToggle.Text = "🎨 Theme: " .. newThemeName .. " (restart to apply)"
    ButtonEffect(ThemeToggle, "✓ Theme saved!")
end)

DoNotStack.MouseButton1Click:Connect(function()
    if lookingAt then
        local isUnstacked = table.find(unstacked, lookingAt)
        if isUnstacked then
            table.remove(unstacked, isUnstacked)
            DoNotStack.Text = "🔄 Unstack remote (new args)"
            DoNotStack.TextColor3 = Color3.fromRGB(245, 246, 250)
        else
            table.insert(unstacked, lookingAt)
            DoNotStack.Text = "🔄 Stack remote"
            DoNotStack.TextColor3 = Color3.fromRGB(251, 197, 49)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- SECTION 13: WINDOW CONTROLS
-- ═══════════════════════════════════════════════════════════

CloseBrowser.MouseButton1Click:Connect(function()
    BrowserHeader.Visible = false
end)

BrowserToggle.MouseButton1Click:Connect(function()
    BrowserHeader.Visible = not BrowserHeader.Visible
    if BrowserHeader.Visible then
        -- Clear previous
        for _, conn in pairs(browsedConnections) do
            pcall(function() conn:Disconnect() end)
        end
        for _, child in pairs(RemoteBrowserFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        browsedConnections = {}
        browsedRemotes = {}
        local browsedButtonOffset = 5
        local browserCanvasSize = 260

        local filter = BrowserSearch.Text:lower()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                if filter == "" or v.Name:lower():find(filter) then
                    local bButton = RemoteButton:Clone()
                    bButton.Parent = RemoteBrowserFrame
                    bButton.Visible = true
                    bButton.Position = UDim2.new(0, 5, 0, browsedButtonOffset)
                    local fireFunction = v:IsA("RemoteEvent") and ":FireServer()" or ":InvokeServer()"
                    bButton.RemoteName.Text = v.Name
                    bButton.RemoteIcon.Image = v:IsA("RemoteEvent") and eventImage or functionImage
                    bButton.Number.Text = "🔍"
                    bButton.Number.TextColor3 = currentTheme.AccentColor

                    local connection = bButton.MouseButton1Click:Connect(function()
                        setclipboard(GetFullPathOfAnInstance(v) .. fireFunction)
                        bButton.RemoteName.Text = "✓ " .. v.Name
                        wait(1)
                        bButton.RemoteName.Text = v.Name
                    end)
                    table.insert(browsedConnections, connection)
                    browsedButtonOffset = browsedButtonOffset + 32

                    if #browsedConnections > 8 then
                        browserCanvasSize = browserCanvasSize + 32
                        RemoteBrowserFrame.CanvasSize = UDim2.new(0, 0, 0, browserCanvasSize)
                    end
                end
            end
        end
    end
end)

OpenInfoFrame.MouseButton1Click:Connect(function()
    if not InfoFrame.Visible then
        mainFrame.Size = UDim2.new(0, 600, 0, 35)
        OpenInfoFrame.Text = "◀"
    elseif RemoteScrollFrame.Visible then
        mainFrame.Size = UDim2.new(0, 220, 0, 35)
        OpenInfoFrame.Text = "▶"
    end
    InfoFrame.Visible = not InfoFrame.Visible
    InfoFrameOpen = not InfoFrameOpen
end)

Minimize.MouseButton1Click:Connect(function()
    if RemoteScrollFrame.Visible then
        mainFrame.Size = UDim2.new(0, 220, 0, 35)
        OpenInfoFrame.Text = "▶"
        InfoFrame.Visible = false
        SearchFrame.Visible = false
    else
        if InfoFrameOpen then
            mainFrame.Size = UDim2.new(0, 600, 0, 35)
            OpenInfoFrame.Text = "◀"
            InfoFrame.Visible = true
        else
            mainFrame.Size = UDim2.new(0, 220, 0, 35)
            OpenInfoFrame.Text = "▶"
            InfoFrame.Visible = false
        end
    end
    RemoteScrollFrame.Visible = not RemoteScrollFrame.Visible
    SearchFrame.Visible = RemoteScrollFrame.Visible
end)

-- ═══════════════════════════════════════════════════════════
-- SECTION 14: SEARCH FUNCTIONALITY (NEW V6)
-- ═══════════════════════════════════════════════════════════

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchBox.Text:lower()
    for _, child in pairs(RemoteScrollFrame:GetChildren()) do
        if child:IsA("TextButton") and child.Name ~= "RemoteButton" then
            if query == "" then
                child.Visible = true
            else
                local rName = child:FindFirstChild("RemoteName")
                if rName then
                    child.Visible = rName.Text:lower():find(query) ~= nil
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- SECTION 15: KEYBIND & MAIN LOOP
-- ═══════════════════════════════════════════════════════════

mouse.KeyDown:Connect(function(key)
    if key:lower() == settings["Keybind"]:lower() then
        TurtleSpyGUI.Enabled = not TurtleSpyGUI.Enabled
    end
end)

-- ═══════════════════════════════════════════════════════════
-- SECTION 16: ADD TO LIST (CORE FUNCTION - IMPROVED)
-- ═══════════════════════════════════════════════════════════

function addToList(event, remote, ...)
    local currentId = get_thread_context()
    set_thread_context(7)
    if not remote then 
        set_thread_context(currentId)
        return 
    end

    local name = remote.Name
    local args = {...}
    local i = FindRemote(remote, args)

    if not i then
        -- Check max logs limit
        if #remotes >= (settings["MaxLogs"] or 500) then
            table.remove(remotes, 1)
            table.remove(remoteArgs, 1)
            table.remove(remoteButtons, 1)
            table.remove(remoteScripts, 1)
            table.remove(remoteTimestamps, 1)
            table.remove(remoteFavCount, 1)
            -- Rebuild UI
            for _, child in pairs(RemoteScrollFrame:GetChildren()) do
                if child:IsA("TextButton") and child.Name ~= "RemoteButton" then
                    child:Destroy()
                end
            end
            buttonOffset = -25
            for idx, r in pairs(remotes) do
                -- Recreate buttons (simplified for V6)
            end
        end

        table.insert(remotes, remote)
        local rButton = RemoteButton:Clone()
        remoteButtons[#remotes] = rButton.Number
        remoteArgs[#remotes] = args
        remoteScripts[#remotes] = (isSynapse() and getcallingscript() or nil)
        remoteTimestamps[#remotes] = os.time()
        remoteFavCount[#remotes] = 0

        rButton.Parent = RemoteScrollFrame
        rButton.Visible = true
        rButton.Number.Text = "1"

        -- Check if favorite
        if table.find(FavoriteList, remote) then
            rButton.FavoriteStar.Visible = true
        end

        if name then
            rButton.RemoteName.Text = name
        end
        if not event then
            rButton.RemoteIcon.Image = functionImage
        end

        buttonOffset = buttonOffset + 32
        rButton.Position = UDim2.new(0, 5, 0, buttonOffset)

        if #remotes > 8 then
            scrollSizeOffset = scrollSizeOffset + 32
            RemoteScrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollSizeOffset)
        end

        -- Auto-scroll to bottom
        if settings["AutoScroll"] then
            RemoteScrollFrame.CanvasPosition = Vector2.new(0, RemoteScrollFrame.CanvasSize.Y.Offset)
        end
    else
        remoteButtons[i].Text = tostring(tonumber(remoteButtons[i].Text) + 1)
        remoteFavCount[i] = (remoteFavCount[i] or 0) + 1
        remoteArgs[i] = args
        remoteTimestamps[i] = os.time()

        if lookingAt and lookingAt == remote and lookingAtButton == remoteButtons[i] and InfoFrame.Visible then
            local fireFunction = remote:IsA("RemoteEvent") and ":FireServer(" or ":InvokeServer("
            Code.Text = GetFullPathOfAnInstance(remote) .. fireFunction .. convertTableToString(remoteArgs[i]) .. ")"
            local textsize = TextService:GetTextSize(Code.Text, Code.TextSize, Code.Font, Vector2.new(math.huge, math.huge))
            CodeFrame.CanvasSize = UDim2.new(0, textsize.X + 20, 2, 0)
            TimestampLabel.Text = "Last fired: " .. os.date("%H:%M:%S", remoteTimestamps[i])
        end
    end
    set_thread_context(currentId)
end

-- ═══════════════════════════════════════════════════════════
-- SECTION 17: REMOTE DETECTION HOOKS (ENHANCED)
-- ═══════════════════════════════════════════════════════════

local OldEvent
OldEvent = hookfunction(Instance.new("RemoteEvent").FireServer, function(Self, ...)
    if not checkcaller() and table.find(BlockList, Self) then
        return
    elseif table.find(IgnoreList, Self) then
        return OldEvent(Self, ...)
    end
    addToList(true, Self, ...)
    return OldEvent(Self, ...)
end)

local OldFunction
OldFunction = hookfunction(Instance.new("RemoteFunction").InvokeServer, function(Self, ...)
    if not checkcaller() and table.find(BlockList, Self) then
        return
    elseif table.find(IgnoreList, Self) then
        return OldFunction(Self, ...)
    end
    addToList(false, Self, ...)
    return OldFunction(Self, ...)
end)

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(...)
    local args = {...}
    local Self = args[1]
    local method = getnamecallmethod()

    if method == "FireServer" and typeof(Self) == "Instance" and Self:IsA("RemoteEvent") then
        if not checkcaller() and table.find(BlockList, Self) then
            return
        elseif table.find(IgnoreList, Self) then
            return OldNamecall(...)
        end
        addToList(true, ...)
    elseif method == "InvokeServer" and typeof(Self) == "Instance" and Self:IsA("RemoteFunction") then
        if not checkcaller() and table.find(BlockList, Self) then
            return
        elseif table.find(IgnoreList, Self) then
            return OldNamecall(...)
        end
        addToList(false, ...)
    end
    return OldNamecall(...)
end)

-- ═══════════════════════════════════════════════════════════
-- SECTION 18: REMOTE BUTTON CLICK HANDLER
-- ═══════════════════════════════════════════════════════════

RemoteScrollFrame.ChildAdded:Connect(function(child)
    if not child:IsA("TextButton") or child.Name == "RemoteButton" then return end

    local remote = remotes[#remotes]
    local args = remoteArgs[#remotes]
    local event = remote:IsA("RemoteEvent")
    local fireFunction = event and ":FireServer(" or ":InvokeServer("

    local connection = child.MouseButton1Click:Connect(function()
        InfoHeaderText.Text = "Info: " .. remote.Name
        if event then
            InfoButtonsScroll.CanvasSize = UDim2.new(0, 0, 1.3, 0)
            CopyReturn.Visible = false
        else
            InfoButtonsScroll.CanvasSize = UDim2.new(0, 0, 1.6, 0)
            CopyReturn.Visible = true
        end

        mainFrame.Size = UDim2.new(0, 600, 0, 35)
        OpenInfoFrame.Text = "◀"
        InfoFrame.Visible = true
        Code.Text = GetFullPathOfAnInstance(remote) .. fireFunction .. convertTableToString(args) .. ")"

        local textsize = TextService:GetTextSize(Code.Text, Code.TextSize, Code.Font, Vector2.new(math.huge, math.huge))
        CodeFrame.CanvasSize = UDim2.new(0, textsize.X + 20, 2, 0)

        lookingAt = remote
        lookingAtArgs = args
        lookingAtButton = child.Number

        -- Update timestamp display
        local idx = table.find(remotes, remote)
        if idx and remoteTimestamps[idx] then
            TimestampLabel.Text = "Last fired: " .. os.date("%H:%M:%S", remoteTimestamps[idx])
        end

        -- Update button states
        local blocked = table.find(BlockList, remote)
        BlockRemote.Text = blocked and "✅ Unblock remote" or "🛑 Block remote from firing"
        BlockRemote.TextColor3 = blocked and Color3.fromRGB(251, 197, 49) or Color3.fromRGB(250, 251, 255)

        local iRemote = table.find(IgnoreList, remote)
        IgnoreRemote.Text = iRemote and "👁 Stop ignoring remote" or "🚫 Ignore remote"
        IgnoreRemote.TextColor3 = iRemote and Color3.fromRGB(127, 143, 166) or Color3.fromRGB(250, 251, 255)

        local fav = table.find(FavoriteList, remote)
        FavoriteRemote.Text = fav and "💛 Remove from favorites" or "⭐ Add to favorites"
        FavoriteRemote.TextColor3 = fav and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(250, 251, 255)

        local unstack = table.find(unstacked, remote)
        DoNotStack.Text = unstack and "🔄 Stack remote" or "🔄 Unstack remote (new args)"
        DoNotStack.TextColor3 = unstack and Color3.fromRGB(251, 197, 49) or Color3.fromRGB(245, 246, 250)

        InfoFrameOpen = true
    end)
    table.insert(connections, connection)
end)

-- ═══════════════════════════════════════════════════════════
-- SECTION 19: INITIALIZATION & WELCOME
-- ═══════════════════════════════════════════════════════════

-- Show initial UI
RemoteScrollFrame.Visible = true
SearchFrame.Visible = true
mainFrame.Size = UDim2.new(0, 220, 0, 340)

-- Welcome notification
spawn(function()
    wait(1)
    local welcome = Instance.new("TextLabel")
    welcome.Parent = TurtleSpyGUI
    welcome.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    welcome.BackgroundTransparency = 0.3
    welcome.BorderSizePixel = 0
    welcome.Position = UDim2.new(0.5, -150, 0, 50)
    welcome.Size = UDim2.new(0, 300, 0, 40)
    welcome.ZIndex = 100
    welcome.Font = Enum.Font.SourceSansBold
    welcome.Text = "🐢 TurtleSpy V6 Loaded! Press '" .. settings["Keybind"] .. "' to toggle"
    welcome.TextColor3 = Color3.fromRGB(0, 255, 150)
    welcome.TextSize = 16
    welcome.TextStrokeTransparency = 0.8

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = welcome

    wait(4)
    for i = 1, 20 do
        welcome.BackgroundTransparency = 0.3 + (i * 0.035)
        welcome.TextTransparency = i * 0.05
        wait(0.05)
    end
    welcome:Destroy()
end)

print("🐢 TurtleSpy V6 loaded successfully!")
print("Executor: " .. executorName)
print("Theme: " .. settings["Theme"])
print("Keybind: " .. settings["Keybind"])
