--[[
    Admin Panel GUI - Delta Executor
    Painel Administrador Visual Completo
    Autor: Assistente
    Uso: Execute no Delta Executor
]]

--// Serviços
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

--// Variáveis Locais
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--// Eventos Remotos
local Events = ReplicatedStorage:WaitForChild("Events")
local AdminTrigger = Events:WaitForChild("AdminTrigger")
local AdminGuiTrigger = Events:WaitForChild("AdminGuiTrigger")
local AdminCheck = Events:WaitForChild("AdminCheck")
local AdminMsg = Events:WaitForChild("AdminMsg")

--// Estado do Admin
local Admin = {
    IsAdmin = false,
    GodMode = false,
    Noclip = false,
    Fly = false,
    Invisible = false,
    Speed = 16,
    JumpPower = 50,
    ESP = false,
    FullBright = false,
    NoFog = false,
    AutoClick = false,
    AntiAFK = false,
    FlySpeed = 50,
    TargetPlayer = nil,
    Connections = {},
    Logs = {}
}

--// ==================== UTILITÁRIOS ====================

local function Notify(title, message, duration)
    duration = duration or 3
    print(string.format("[ADMIN] %s: %s", title, message))
    pcall(function()
        AdminMsg:FireServer(title, message)
    end)
end

local function CheckAdmin()
    local success, result = pcall(function()
        return AdminCheck:InvokeServer()
    end)
    if success then
        Admin.IsAdmin = result == true or result == "true" or result == 1
        if Admin.IsAdmin then
            AdminTrigger:FireServer("Initialize")
            Notify("Sistema", "Acesso de Admin concedido!", 5)
        else
            pcall(function()
                AdminGuiTrigger:FireServer(true)
                AdminTrigger:FireServer("ForceAdmin")
            end)
        end
        return Admin.IsAdmin
    end
    return false
end

--// ==================== CRIAR GUI ====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminPanelGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Proteger GUI
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

--// TEMAS E CORES
local Theme = {
    Background = Color3.fromRGB(15, 15, 25),
    BackgroundLight = Color3.fromRGB(25, 25, 40),
    BackgroundDark = Color3.fromRGB(10, 10, 18),
    Accent = Color3.fromRGB(0, 170, 255),
    AccentDark = Color3.fromRGB(0, 120, 200),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 200),
    Success = Color3.fromRGB(0, 255, 100),
    Danger = Color3.fromRGB(255, 50, 50),
    Warning = Color3.fromRGB(255, 200, 0),
    Border = Color3.fromRGB(40, 40, 60),
    ToggleOn = Color3.fromRGB(0, 200, 100),
    ToggleOff = Color3.fromRGB(60, 60, 80)
}

--// FUNÇÕES DE UI

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function CreateShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

local function CreateButton(parent, text, pos, size, callback)
    local btn = Instance.new("TextButton")
    btn.Name = text
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextColor3 = Theme.Text
    btn.BackgroundColor3 = Theme.BackgroundLight
    btn.Size = size or UDim2.new(0, 120, 0, 32)
    btn.Position = pos or UDim2.new(0, 0, 0, 0)
    btn.AutoButtonColor = false
    btn.Parent = parent
    CreateCorner(btn, 6)
    CreateStroke(btn, Theme.Border, 1)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.BackgroundLight}):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.AccentDark}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        local success, err = pcall(callback)
        if not success then
            Notify("Erro", tostring(err), 5)
        end
    end)

    return btn
end

local function CreateToggle(parent, text, pos, defaultState, callback)
    local container = Instance.new("Frame")
    container.Name = text .. "Toggle"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -20, 0, 30)
    container.Position = pos
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextColor3 = Theme.Text
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Text = ""
    toggleBtn.Size = UDim2.new(0, 44, 0, 22)
    toggleBtn.Position = UDim2.new(1, -44, 0.5, -11)
    toggleBtn.BackgroundColor3 = defaultState and Theme.ToggleOn or Theme.ToggleOff
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = container
    CreateCorner(toggleBtn, 11)

    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = defaultState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = toggleBtn
    CreateCorner(circle, 9)

    local state = defaultState

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        local targetPos = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        local targetColor = state and Theme.ToggleOn or Theme.ToggleOff

        TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()

        local success, err = pcall(function()
            callback(state)
        end)
        if not success then
            Notify("Erro", tostring(err), 5)
        end
    end)

    return container, toggleBtn
end

local function CreateSlider(parent, text, pos, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Name = text .. "Slider"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -20, 0, 50)
    container.Position = pos
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = text .. ": " .. default
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Theme.Text
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 18)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.BackgroundColor3 = Theme.BackgroundLight
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 30)
    track.Parent = container
    CreateCorner(track, 3)

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.BackgroundColor3 = Theme.Accent
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.Parent = track
    CreateCorner(fill, 3)

    local knob = Instance.new("TextButton")
    knob.Name = "Knob"
    knob.Text = ""
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.AutoButtonColor = false
    knob.Parent = track
    CreateCorner(knob, 7)

    local dragging = false
    local currentValue = default

    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        currentValue = math.floor(min + (pos * (max - min)))
        label.Text = text .. ": " .. currentValue
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -7, 0.5, -7)
        pcall(function()
            callback(currentValue)
        end)
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return container
end

local function CreateTextBox(parent, placeholder, pos, callback)
    local box = Instance.new("TextBox")
    box.Name = "TextBox"
    box.PlaceholderText = placeholder
    box.Text = ""
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.TextColor3 = Theme.Text
    box.BackgroundColor3 = Theme.BackgroundLight
    box.Size = UDim2.new(1, -20, 0, 30)
    box.Position = pos
    box.ClearTextOnFocus = false
    box.Parent = parent
    CreateCorner(box, 6)
    CreateStroke(box, Theme.Border, 1)

    box.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            pcall(function()
                callback(box.Text)
            end)
        end
    end)

    return box
end

--// ==================== JANELA PRINCIPAL ====================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.Size = UDim2.new(0, 700, 0, 450)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
CreateCorner(MainFrame, 12)
CreateShadow(MainFrame)
CreateStroke(MainFrame, Theme.Border, 2)

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.BackgroundColor3 = Theme.BackgroundDark
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.Parent = MainFrame
CreateCorner(TitleBar, 12)

-- Corrigir cantos arredondados da barra
local titleCornerFix = Instance.new("Frame")
titleCornerFix.Name = "CornerFix"
titleCornerFix.BackgroundColor3 = Theme.BackgroundDark
titleCornerFix.Size = UDim2.new(1, 0, 0, 10)
titleCornerFix.Position = UDim2.new(0, 0, 1, -10)
titleCornerFix.BorderSizePixel = 0
titleCornerFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Text = "⚡ ADMIN PANEL"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextColor3 = Theme.Accent
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Text = "● Offline"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Theme.Danger
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(0, 100, 1, 0)
StatusLabel.Position = UDim2.new(1, -180, 0, 0)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
StatusLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Theme.Text
CloseBtn.BackgroundColor3 = Theme.Danger
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 5)
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TitleBar
CreateCorner(CloseBtn, 6)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "Minimize"
MinimizeBtn.Text = "─"
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.TextColor3 = Theme.Text
MinimizeBtn.BackgroundColor3 = Theme.BackgroundLight
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -73, 0, 5)
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = TitleBar
CreateCorner(MinimizeBtn, 6)

--// SIDEBAR (Abas)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.BackgroundColor3 = Theme.BackgroundDark
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.Parent = Sidebar

--// CONTEÚDO (Páginas)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.BackgroundTransparency = 1
ContentFrame.Size = UDim2.new(1, -140, 1, -40)
ContentFrame.Position = UDim2.new(0, 140, 0, 40)
ContentFrame.Parent = MainFrame

local Pages = {}
local CurrentPage = nil

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Theme.Accent
    page.Visible = false
    page.Parent = ContentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 15)
    padding.Parent = page

    Pages[name] = page
    return page
end

local function CreateTabButton(name, icon, page)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.Text = "   " .. icon .. "  " .. name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.TextColor3 = Theme.TextDark
    btn.BackgroundColor3 = Theme.BackgroundDark
    btn.Size = UDim2.new(0, 125, 0, 36)
    btn.AutoButtonColor = false
    btn.LayoutOrder = #Sidebar:GetChildren()
    btn.Parent = Sidebar
    CreateCorner(btn, 6)
    btn.TextXAlignment = Enum.TextXAlignment.Left

    btn.MouseButton1Click:Connect(function()
        if CurrentPage then
            CurrentPage.Visible = false
        end
        for _, child in ipairs(Sidebar:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.2), {BackgroundColor3 = Theme.BackgroundDark, TextColor3 = Theme.TextDark}):Play()
            end
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text}):Play()
        page.Visible = true
        CurrentPage = page
    end)

    return btn
end

local function CreateSection(parent, title)
    local section = Instance.new("Frame")
    section.Name = title .. "Section"
    section.BackgroundColor3 = Theme.BackgroundLight
    section.Size = UDim2.new(1, -10, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.Parent = parent
    CreateCorner(section, 8)
    CreateStroke(section, Theme.Border, 1)

    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Name = "Title"
    sectionTitle.Text = title
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextSize = 13
    sectionTitle.TextColor3 = Theme.Accent
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Size = UDim2.new(1, -20, 0, 28)
    sectionTitle.Position = UDim2.new(0, 10, 0, 5)
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = section

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, -20, 0, 0)
    content.Position = UDim2.new(0, 10, 0, 33)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = section

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = content

    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = content

    return content
end

--// ==================== PÁGINAS ====================

-- Página: Main
local MainPage = CreatePage("Main")
local MainTab = CreateTabButton("Main", "🏠", MainPage)

-- Seção: Status
local StatusSection = CreateSection(MainPage, "📊 Status do Admin")

local AdminStatusLabel = Instance.new("TextLabel")
AdminStatusLabel.Text = "Status: Verificando..."
AdminStatusLabel.Font = Enum.Font.Gotham
AdminStatusLabel.TextSize = 13
AdminStatusLabel.TextColor3 = Theme.Text
AdminStatusLabel.BackgroundTransparency = 1
AdminStatusLabel.Size = UDim2.new(1, 0, 0, 22)
AdminStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
AdminStatusLabel.Parent = StatusSection

local PlayerCountLabel = Instance.new("TextLabel")
PlayerCountLabel.Text = "Jogadores: 0"
PlayerCountLabel.Font = Enum.Font.Gotham
PlayerCountLabel.TextSize = 13
PlayerCountLabel.TextColor3 = Theme.Text
PlayerCountLabel.BackgroundTransparency = 1
PlayerCountLabel.Size = UDim2.new(1, 0, 0, 22)
PlayerCountLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerCountLabel.Parent = StatusSection

local ServerInfoLabel = Instance.new("TextLabel")
ServerInfoLabel.Text = "PlaceID: " .. game.PlaceId
ServerInfoLabel.Font = Enum.Font.Gotham
ServerInfoLabel.TextSize = 12
ServerInfoLabel.TextColor3 = Theme.TextDark
ServerInfoLabel.BackgroundTransparency = 1
ServerInfoLabel.Size = UDim2.new(1, 0, 0, 20)
ServerInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
ServerInfoLabel.Parent = StatusSection

-- Seção: Ações Rápidas
local QuickSection = CreateSection(MainPage, "⚡ Ações Rápidas")

CreateButton(QuickSection, "Respawn", nil, UDim2.new(0, 110, 0, 32), function()
    AdminTrigger:FireServer("Respawn")
    local char = LocalPlayer.Character
    if char then char:BreakJoints() end
    Notify("Respawn", "Respawn realizado!", 3)
end)

CreateButton(QuickSection, "Rejoin", nil, UDim2.new(0, 110, 0, 32), function()
    AdminTrigger:FireServer("Rejoin")
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

CreateButton(QuickSection, "Server Hop", nil, UDim2.new(0, 110, 0, 32), function()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    for _, server in ipairs(servers.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
            break
        end
    end
end)

CreateButton(QuickSection, "Anti-AFK", nil, UDim2.new(0, 110, 0, 32), function()
    if not Admin.Connections.AntiAFK then
        Admin.Connections.AntiAFK = LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
        Notify("Anti-AFK", "Ativado!", 3)
    else
        Admin.Connections.AntiAFK:Disconnect()
        Admin.Connections.AntiAFK = nil
        Notify("Anti-AFK", "Desativado!", 3)
    end
end)

-- Página: Player
local PlayerPage = CreatePage("Player")
local PlayerTab = CreateTabButton("Player", "👤", PlayerPage)

-- Seção: Movimento
local MoveSection = CreateSection(PlayerPage, "🏃 Movimento")

CreateToggle(MoveSection, "God Mode", UDim2.new(0, 0, 0, 0), false, function(state)
    Admin.GodMode = state
    AdminTrigger:FireServer("GodMode", state)
    if state then
        if Humanoid then
            Humanoid.MaxHealth = math.huge
            Humanoid.Health = math.huge
            Admin.Connections.GodMode = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if Admin.GodMode and Humanoid.Health < Humanoid.MaxHealth then
                    Humanoid.Health = Humanoid.MaxHealth
                end
            end)
        end
        Notify("God Mode", "Ativado!", 3)
    else
        if Admin.Connections.GodMode then Admin.Connections.GodMode:Disconnect() end
        if Humanoid then
            Humanoid.MaxHealth = 100
            Humanoid.Health = 100
        end
        Notify("God Mode", "Desativado!", 3)
    end
end)

CreateToggle(MoveSection, "Noclip", UDim2.new(0, 0, 0, 0), false, function(state)
    Admin.Noclip = state
    AdminTrigger:FireServer("Noclip", state)
    if state then
        Admin.Connections.Noclip = RunService.Stepped:Connect(function()
            if Admin.Noclip and Character then
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
        Notify("Noclip", "Ativado!", 3)
    else
        if Admin.Connections.Noclip then Admin.Connections.Noclip:Disconnect() end
        if Character then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
        Notify("Noclip", "Desativado!", 3)
    end
end)

CreateToggle(MoveSection, "Fly", UDim2.new(0, 0, 0, 0), false, function(state)
    Admin.Fly = state
    AdminTrigger:FireServer("Fly", state, Admin.FlySpeed)
    if state then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "AdminFlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = HumanoidRootPart

        local bg = Instance.new("BodyGyro")
        bg.Name = "AdminFlyGyro"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 10000
        bg.Parent = HumanoidRootPart

        Admin.Connections.Fly = RunService.RenderStepped:Connect(function()
            if Admin.Fly and HumanoidRootPart then
                local cam = workspace.CurrentCamera
                local moveDir = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                local flyVel = HumanoidRootPart:FindFirstChild("AdminFlyVelocity")
                local flyGyro = HumanoidRootPart:FindFirstChild("AdminFlyGyro")
                if flyVel and flyGyro then
                    flyVel.Velocity = moveDir * Admin.FlySpeed
                    flyGyro.CFrame = cam.CFrame
                end
            end
        end)
        Notify("Fly", "Ativado! Velocidade: " .. Admin.FlySpeed, 3)
    else
        if Admin.Connections.Fly then Admin.Connections.Fly:Disconnect() end
        for _, obj in ipairs(HumanoidRootPart:GetChildren()) do
            if obj.Name == "AdminFlyVelocity" or obj.Name == "AdminFlyGyro" then obj:Destroy() end
        end
        Notify("Fly", "Desativado!", 3)
    end
end)

CreateSlider(MoveSection, "Fly Speed", UDim2.new(0, 0, 0, 0), 10, 200, 50, function(val)
    Admin.FlySpeed = val
end)

CreateSlider(MoveSection, "Walk Speed", UDim2.new(0, 0, 0, 0), 16, 200, 16, function(val)
    Admin.Speed = val
    AdminTrigger:FireServer("Speed", val)
    if Humanoid then Humanoid.WalkSpeed = val end
end)

CreateSlider(MoveSection, "Jump Power", UDim2.new(0, 0, 0, 0), 50, 200, 50, function(val)
    Admin.JumpPower = val
    AdminTrigger:FireServer("JumpPower", val)
    if Humanoid then Humanoid.JumpPower = val end
end)

-- Seção: Visuais
local VisualSection = CreateSection(PlayerPage, "👁️ Visuais")

CreateToggle(VisualSection, "Invisible", UDim2.new(0, 0, 0, 0), false, function(state)
    Admin.Invisible = state
    AdminTrigger:FireServer("Invisible", state)
    if Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = state and 1 or 0
                if part:FindFirstChild("face") then part.face.Transparency = state and 1 or 0 end
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = state and 1 or 0
            end
        end
    end
    Notify("Invisible", state and "Você está invisível!" or "Visibilidade restaurada.", 3)
end)

CreateToggle(VisualSection, "ESP", UDim2.new(0, 0, 0, 0), false, function(state)
    Admin.ESP = state
    AdminTrigger:FireServer("ESP", state)
    if state then
        local function createESP(player)
            if player == LocalPlayer or not player.Character then return end
            local hl = Instance.new("Highlight")
            hl.Name = "AdminESP"
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Adornee = player.Character
            hl.Parent = player.Character

            local bb = Instance.new("BillboardGui")
            bb.Name = "AdminESPName"
            bb.Size = UDim2.new(0, 200, 0, 50)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.BackgroundTransparency = 1
            tl.TextColor3 = Color3.fromRGB(255, 255, 255)
            tl.TextStrokeTransparency = 0
            tl.TextScaled = true
            tl.Text = player.Name
            tl.Parent = bb
            bb.Parent = player.Character:FindFirstChild("Head") or player.Character:WaitForChild("Head")
        end
        for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
        Admin.Connections.ESP = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function() wait(1) if Admin.ESP then createESP(p) end end)
        end)
        Notify("ESP", "Ativado!", 3)
    else
        if Admin.Connections.ESP then Admin.Connections.ESP:Disconnect() end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                for _, obj in ipairs(p.Character:GetDescendants()) do
                    if obj.Name == "AdminESP" or obj.Name == "AdminESPName" then obj:Destroy() end
                end
            end
        end
        Notify("ESP", "Desativado!", 3)
    end
end)

CreateToggle(VisualSection, "Full Bright", UDim2.new(0, 0, 0, 0), false, function(state)
    Admin.FullBright = state
    AdminTrigger:FireServer("FullBright")
    Lighting.Brightness = state and 10 or 2
    Lighting.GlobalShadows = not state
    Lighting.Ambient = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(127, 127, 127)
    Notify("Full Bright", state and "Ativado!" or "Desativado!", 3)
end)

CreateToggle(VisualSection, "No Fog", UDim2.new(0, 0, 0, 0), false, function(state)
    Admin.NoFog = state
    AdminTrigger:FireServer("NoFog")
    if state then
        Lighting.FogStart = 0
        Lighting.FogEnd = math.huge
        Lighting.FogColor = Color3.fromRGB(255, 255, 255)
    end
    Notify("No Fog", state and "Névoa removida!" or "Desativado!", 3)
end)

-- Página: Teleport
local TeleportPage = CreatePage("Teleport")
local TeleportTab = CreateTabButton("Teleport", "🚀", TeleportPage)

local TpSection = CreateSection(TeleportPage, "🎯 Teleportar")

local TpTextBox = CreateTextBox(TpSection, "Nome do jogador...", UDim2.new(0, 0, 0, 0), function(text)
    -- Placeholder
end)

CreateButton(TpSection, "Teleportar Até", nil, UDim2.new(0, 130, 0, 32), function()
    local name = TpTextBox.Text
    if name == "" then Notify("Erro", "Digite um nome!", 3) return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #name) == name:lower() then
            AdminTrigger:FireServer("Teleport", p.Name)
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and HumanoidRootPart then
                HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
            Notify("Teleport", "Teleportado para: " .. p.Name, 3)
            return
        end
    end
    Notify("Erro", "Jogador não encontrado!", 3)
end)

CreateButton(TpSection, "Puxar Jogador", nil, UDim2.new(0, 130, 0, 32), function()
    local name = TpTextBox.Text
    if name == "" then Notify("Erro", "Digite um nome!", 3) return end
    AdminTrigger:FireServer("Bring", name)
    Notify("Bring", "Solicitação enviada para: " .. name, 3)
end)

CreateButton(TpSection, "Spectar Jogador", nil, UDim2.new(0, 130, 0, 32), function()
    local name = TpTextBox.Text
    if name == "" then
        if Admin.Connections.View then
            Admin.Connections.View:Disconnect()
            Admin.Connections.View = nil
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            Notify("View", "Espectador desativado.", 3)
        end
        return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #name) == name:lower() then
            if p.Character and p.Character:FindFirstChild("Humanoid") then
                workspace.CurrentCamera.CameraSubject = p.Character.Humanoid
                Admin.Connections.View = p.Character.Humanoid.Died:Connect(function()
                    workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                end)
                Notify("View", "Observando: " .. p.Name, 3)
            end
            return
        end
    end
    Notify("Erro", "Jogador não encontrado!", 3)
end)

-- Página: Combat
local CombatPage = CreatePage("Combat")
local CombatTab = CreateTabButton("Combat", "⚔️", CombatPage)

local CombatSection = CreateSection(CombatPage, "⚔️ Ações de Combate")

local CombatTextBox = CreateTextBox(CombatSection, "Nome do jogador (ou 'all')...", UDim2.new(0, 0, 0, 0), function(text) end)

CreateButton(CombatSection, "Kill", nil, UDim2.new(0, 100, 0, 32), function()
    local name = CombatTextBox.Text
    if name == "" then name = "all" end
    AdminTrigger:FireServer("Kill", name)
    Notify("Kill", "Comando enviado para: " .. name, 3)
end)

CreateButton(CombatSection, "Heal", nil, UDim2.new(0, 100, 0, 32), function()
    local name = CombatTextBox.Text
    if name == "" then name = LocalPlayer.Name end
    AdminTrigger:FireServer("Heal", name)
    if name:lower() == "me" or name:lower() == LocalPlayer.Name:lower() then
        if Humanoid then Humanoid.Health = Humanoid.MaxHealth end
    end
    Notify("Heal", "Cura enviada para: " .. name, 3)
end)

CreateButton(CombatSection, "God All", nil, UDim2.new(0, 100, 0, 32), function()
    AdminTrigger:FireServer("GodAll")
    Notify("God All", "God mode para todos!", 3)
end)

CreateButton(CombatSection, "Heal All", nil, UDim2.new(0, 100, 0, 32), function()
    AdminTrigger:FireServer("HealAll")
    Notify("Heal All", "Cura para todos!", 3)
end)

CreateButton(CombatSection, "Kill All", nil, UDim2.new(0, 100, 0, 32), function()
    AdminTrigger:FireServer("KillAll")
    Notify("Kill All", "Kill para todos!", 3)
end)

CreateButton(CombatSection, "Loop Kill", nil, UDim2.new(0, 100, 0, 32), function()
    local name = CombatTextBox.Text
    if name == "" then Notify("Erro", "Digite um nome!", 3) return end
    Admin.LoopKillTarget = name
    if Admin.Connections.LoopKill then Admin.Connections.LoopKill:Disconnect() end
    Admin.Connections.LoopKill = RunService.Heartbeat:Connect(function()
        if Admin.LoopKillTarget then AdminTrigger:FireServer("Kill", Admin.LoopKillTarget) end
    end)
    Notify("Loop Kill", "Ativado para: " .. name, 3)
end)

CreateButton(CombatSection, "Stop Loop", nil, UDim2.new(0, 100, 0, 32), function()
    Admin.LoopKillTarget = nil
    if Admin.Connections.LoopKill then Admin.Connections.LoopKill:Disconnect() end
    Notify("Loop Kill", "Desativado!", 3)
end)

-- Página: Admin
local AdminPage = CreatePage("Admin")
local AdminTab = CreateTabButton("Admin", "🛡️", AdminPage)

local AdminSection = CreateSection(AdminPage, "🛡️ Ferramentas de Admin")

local AdminTextBox = CreateTextBox(AdminSection, "Nome do jogador...", UDim2.new(0, 0, 0, 0), function(text) end)

CreateButton(AdminSection, "Kick", nil, UDim2.new(0, 100, 0, 32), function()
    local name = AdminTextBox.Text
    if name == "" then Notify("Erro", "Digite um nome!", 3) return end
    AdminTrigger:FireServer("Kick", name, "Kicked by Admin")
    Notify("Kick", "Solicitação enviada para: " .. name, 3)
end)

CreateButton(AdminSection, "Ban", nil, UDim2.new(0, 100, 0, 32), function()
    local name = AdminTextBox.Text
    if name == "" then Notify("Erro", "Digite um nome!", 3) return end
    AdminTrigger:FireServer("Ban", name, "permanent", "Banned by Admin")
    Notify("Ban", "Solicitação enviada para: " .. name, 3)
end)

CreateButton(AdminSection, "Give Item", nil, UDim2.new(0, 100, 0, 32), function()
    local name = AdminTextBox.Text
    if name == "" then Notify("Erro", "Digite um nome de item!", 3) return end
    AdminTrigger:FireServer("GiveItem", name)
    Notify("Give", "Solicitando item: " .. name, 3)
end)

CreateButton(AdminSection, "Set Time", nil, UDim2.new(0, 100, 0, 32), function()
    local timeVal = tonumber(AdminTextBox.Text) or 12
    AdminTrigger:FireServer("SetTime", timeVal)
    Notify("Time", "Horário: " .. timeVal, 3)
end)

-- Página: Players
local PlayersPage = CreatePage("Players")
local PlayersTab = CreateTabButton("Players", "👥", PlayersPage)

local PlayersSection = CreateSection(PlayersPage, "👥 Lista de Jogadores")

local PlayersListFrame = Instance.new("ScrollingFrame")
PlayersListFrame.Name = "PlayersList"
PlayersListFrame.BackgroundColor3 = Theme.BackgroundDark
PlayersListFrame.Size = UDim2.new(1, 0, 0, 200)
PlayersListFrame.ScrollBarThickness = 4
PlayersListFrame.ScrollBarImageColor3 = Theme.Accent
PlayersListFrame.Parent = PlayersSection
CreateCorner(PlayersListFrame, 6)

local PlayersListLayout = Instance.new("UIListLayout")
PlayersListLayout.Padding = UDim.new(0, 2)
PlayersListLayout.Parent = PlayersListFrame

local function UpdatePlayersList()
    for _, child in ipairs(PlayersListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local btn = Instance.new("TextButton")
        btn.Text = player.Name .. (player == LocalPlayer and " (Você)" or "")
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.TextColor3 = player == LocalPlayer and Theme.Accent or Theme.Text
        btn.BackgroundColor3 = Theme.BackgroundLight
        btn.Size = UDim2.new(1, -10, 0, 28)
        btn.AutoButtonColor = false
        btn.Parent = PlayersListFrame
        CreateCorner(btn, 4)

        btn.MouseButton1Click:Connect(function()
            TpTextBox.Text = player.Name
            CombatTextBox.Text = player.Name
            AdminTextBox.Text = player.Name
            Notify("Selecionado", "Jogador: " .. player.Name, 2)
        end)
    end

    PlayersListFrame.CanvasSize = UDim2.new(0, 0, 0, PlayersListLayout.AbsoluteContentSize.Y + 10)
end

UpdatePlayersList()
Players.PlayerAdded:Connect(UpdatePlayersList)
Players.PlayerRemoving:Connect(UpdatePlayersList)

-- Página: Logs
local LogsPage = CreatePage("Logs")
local LogsTab = CreateTabButton("Logs", "📋", LogsPage)

local LogsSection = CreateSection(LogsPage, "📋 Log de Ações")

local LogsFrame = Instance.new("ScrollingFrame")
LogsFrame.Name = "LogsFrame"
LogsFrame.BackgroundColor3 = Theme.BackgroundDark
LogsFrame.Size = UDim2.new(1, 0, 0, 220)
LogsFrame.ScrollBarThickness = 4
LogsFrame.ScrollBarImageColor3 = Theme.Accent
LogsFrame.Parent = LogsSection
CreateCorner(LogsFrame, 6)

local LogsLayout = Instance.new("UIListLayout")
LogsLayout.Padding = UDim.new(0, 2)
LogsLayout.Parent = LogsFrame

local function AddLog(text)
    local logLabel = Instance.new("TextLabel")
    logLabel.Text = "[" .. os.date("%H:%M:%S") .. "] " .. text
    logLabel.Font = Enum.Font.Gotham
    logLabel.TextSize = 11
    logLabel.TextColor3 = Theme.TextDark
    logLabel.BackgroundTransparency = 1
    logLabel.Size = UDim2.new(1, -10, 0, 18)
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.Parent = LogsFrame

    LogsFrame.CanvasSize = UDim2.new(0, 0, 0, LogsLayout.AbsoluteContentSize.Y + 10)
    LogsFrame.CanvasPosition = Vector2.new(0, LogsLayout.AbsoluteContentSize.Y)
end

CreateButton(LogsSection, "Limpar Logs", nil, UDim2.new(0, 120, 0, 28), function()
    for _, child in ipairs(LogsFrame:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    AddLog("Logs limpos")
end)

--// ==================== BOTÃO FLUTUANTE (TOGGLE) ====================

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Text = "⚡"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 24
ToggleButton.TextColor3 = Theme.Text
ToggleButton.BackgroundColor3 = Theme.Accent
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -25)
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = ScreenGui
CreateCorner(ToggleButton, 25)
CreateShadow(ToggleButton)

local ToggleStroke = CreateStroke(ToggleButton, Color3.fromRGB(255, 255, 255), 2)

ToggleButton.MouseEnter:Connect(function()
    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 55, 0, 55), Position = UDim2.new(0, 17, 0.5, -27.5)}):Play()
end)
ToggleButton.MouseLeave:Connect(function()
    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 20, 0.5, -25)}):Play()
end)

--// ==================== FUNCIONALIDADES DA GUI ====================

-- Drag da janela
local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Fechar
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
    wait(0.3)
    ScreenGui:Destroy()
end)

-- Minimizar
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 700, 0, 40)}):Play()
        ContentFrame.Visible = false
        Sidebar.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 700, 0, 450)}):Play()
        ContentFrame.Visible = true
        Sidebar.Visible = true
    end
end)

-- Toggle visibilidade
local guiVisible = true
ToggleButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    MainFrame.Visible = guiVisible
    if guiVisible then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -350, 0.5, -225)}):Play()
    end
end)

-- Tecla de atalho (RightShift)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        MainFrame.Visible = guiVisible
    end
end)

--// ==================== ATUALIZAÇÕES ====================

-- Atualizar status
spawn(function()
    while wait(1) do
        if Admin.IsAdmin then
            StatusLabel.Text = "● Online"
            StatusLabel.TextColor3 = Theme.Success
        else
            StatusLabel.Text = "● Offline"
            StatusLabel.TextColor3 = Theme.Danger
        end
        PlayerCountLabel.Text = "Jogadores: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
    end
end)

-- Reconectar ao respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")

    if Admin.GodMode then
        Humanoid.MaxHealth = math.huge
        Humanoid.Health = math.huge
    end
    if Admin.Speed ~= 16 then Humanoid.WalkSpeed = Admin.Speed end
    if Admin.JumpPower ~= 50 then Humanoid.JumpPower = Admin.JumpPower end

    AddLog("Personagem respawnado")
    Notify("Respawn", "Configurações restauradas!", 3)
end)

--// ==================== INICIALIZAÇÃO ====================

local function Initialize()
    -- Verificar admin
    CheckAdmin()

    -- Selecionar página inicial
    MainTab.MouseButton1Click:Fire()

    -- Anti-detecção
    pcall(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" and self == LocalPlayer then
                AddLog("Tentativa de kick bloqueada!")
                return nil
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)

    AddLog("Admin Panel GUI carregado!")
    AddLog("Pressione RightShift para abrir/fechar")
    Notify("Sistema", "Admin Panel GUI carregado! Pressione RightShift", 5)
end

Initialize()

return Admin
