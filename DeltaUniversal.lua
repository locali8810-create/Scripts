-- ============================================
-- DELTA UNIVERSAL - ALL FUNCTIONS
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- ============================================
-- GUI SETUP
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaUniversal"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DELTA UNIVERSAL"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 2)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(0, 120, 1, -35)
TabFrame.Position = UDim2.new(0, 0, 0, 35)
TabFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 0)
TabCorner.Parent = TabFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -120, 1, -35)
ContentFrame.Position = UDim2.new(0, 120, 0, 35)
ContentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 0)
ContentCorner.Parent = ContentFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.Parent = ContentFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================

local NotifFrame = Instance.new("Frame")
NotifFrame.Size = UDim2.new(0, 280, 0, 0)
NotifFrame.Position = UDim2.new(1, -290, 0, 10)
NotifFrame.BackgroundTransparency = 1
NotifFrame.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Parent = NotifFrame

function Notify(text, duration)
    duration = duration or 3
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 50)
    notif.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    notif.BorderSizePixel = 0
    notif.BackgroundTransparency = 1
    notif.Parent = NotifFrame

    local nc = Instance.new("UICorner")
    nc.CornerRadius = UDim.new(0, 6)
    nc.Parent = notif

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    bar.BorderSizePixel = 0
    bar.Parent = notif

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = bar

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = notif

    TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()

    task.delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        notif:Destroy()
    end)
end

-- ============================================
-- TOGGLE BUTTON CREATOR
-- ============================================

local Toggles = {}

function CreateToggle(name, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Parent = ScrollingFrame

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 6)
    fc.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 28)
    btn.Position = UDim2.new(1, -70, 0.5, -14)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = frame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 14)
    bc.Parent = btn

    local enabled = false

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            btn.Text = "ON"
            Toggles[name] = true
        else
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.Text = "OFF"
            Toggles[name] = false
        end
        callback(enabled)
    end)

    return frame
end

-- ============================================
-- SLIDER CREATOR
-- ============================================

function CreateSlider(name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 65)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Parent = ScrollingFrame

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 6)
    fc.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 0, 25)
    lbl.Position = UDim2.new(0, 15, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.3, 0, 0, 25)
    valLbl.Position = UDim2.new(0.6, 0, 0, 5)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 14
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -30, 0, 6)
    track.Position = UDim2.new(0, 15, 0, 40)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    track.BorderSizePixel = 0
    track.Parent = frame

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 3)
    tc.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fc2 = Instance.new("UICorner")
    fc2.CornerRadius = UDim.new(0, 3)
    fc2.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -7, 0.5, -7)
        valLbl.Text = tostring(value)
        callback(value)
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            update(input)
            dragging = true
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ============================================
-- BUTTON CREATOR
-- ============================================

function CreateButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = ScrollingFrame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    btn.MouseButton1Click:Connect(function()
        callback()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    end)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    end)

    return btn
end

-- ============================================
-- TAB SYSTEM
-- ============================================

local Tabs = {}
local CurrentTab = nil

function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, 5 + (#Tabs * 40))
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = TabFrame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Visible = false
    content.Parent = ContentFrame

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = content

    table.insert(Tabs, {Button = btn, Content = content, Name = name})

    btn.MouseButton1Click:Connect(function()
        for _, tab in ipairs(Tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end
        content.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        CurrentTab = content
    end)

    if #Tabs == 1 then
        content.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        CurrentTab = content
    end

    return content
end

-- ============================================
-- ============================================
-- ALL FUNCTIONS IMPLEMENTATION
-- ============================================
-- ============================================

-- ============================================
-- NOCLIP / WALLHACK
-- ============================================

local NoclipConnection = nil
local NoclipEnabled = false

function EnableNoclip()
    if NoclipConnection then return end
    NoclipEnabled = true
    NoclipConnection = RunService.Stepped:Connect(function()
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    Notify("Noclip Ativado", 2)
end

function DisableNoclip()
    NoclipEnabled = false
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    Notify("Noclip Desativado", 2)
end

-- ============================================
-- FLY
-- ============================================

local FlyEnabled = false
local FlyConnection = nil
local FlyBodyGyro = nil
local FlyBodyVelocity = nil

function EnableFly()
    if FlyEnabled then return end
    FlyEnabled = true

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.CFrame = hrp.CFrame
    FlyBodyGyro.Parent = hrp

    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyVelocity.Parent = hrp

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not FlyEnabled then return end
        if not LocalPlayer.Character then return end
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local camCF = Camera.CFrame
        local moveDir = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * FlySpeed * 50
        end

        FlyBodyVelocity.Velocity = moveDir
        FlyBodyGyro.CFrame = camCF
    end)

    Notify("Fly Ativado (WASD + Space/Shift)", 3)
end

function DisableFly()
    FlyEnabled = false
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    if FlyBodyGyro then
        FlyBodyGyro:Destroy()
        FlyBodyGyro = nil
    end
    if FlyBodyVelocity then
        FlyBodyVelocity:Destroy()
        FlyBodyVelocity = nil
    end
    Notify("Fly Desativado", 2)
end

-- ============================================
-- SPEED & JUMP
-- ============================================

function SetSpeed(value)
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
end

function SetJumpPower(value)
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = value
        end
    end
end

-- ============================================
-- ESP / WALLHACK
-- ============================================

local ESPEnabled = false
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP"
ESPFolder.Parent = ScreenGui

function CreateESP(player)
    if player == LocalPlayer then return end

    local function onCharacterAdded(char)
        if not ESPEnabled then return end

        local head = char:WaitForChild("Head", 5)
        if not head then return end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = player.Name .. "_ESP"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = head
        billboard.Parent = ESPFolder

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, 0, 0.5, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = player.Name
        nameLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 14
        nameLbl.Parent = billboard

        local distLbl = Instance.new("TextLabel")
        distLbl.Size = UDim2.new(1, 0, 0.5, 0)
        distLbl.Position = UDim2.new(0, 0, 0.5, 0)
        distLbl.BackgroundTransparency = 1
        distLbl.Text = "0 studs"
        distLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        distLbl.Font = Enum.Font.Gotham
        distLbl.TextSize = 12
        distLbl.Parent = billboard

        local box = Instance.new("BoxHandleAdornment")
        box.Name = player.Name .. "_Box"
        box.Size = Vector3.new(4, 6, 2)
        box.Color3 = Color3.fromRGB(255, 50, 50)
        box.Transparency = 0.7
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Adornee = char:WaitForChild("HumanoidRootPart", 5) or head
        box.Parent = ESPFolder

        local function update()
            while ESPEnabled and billboard and billboard.Parent do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                    distLbl.Text = math.floor(dist) .. " studs"
                end
                task.wait(0.1)
            end
        end

        task.spawn(update)
    end

    if player.Character then
        onCharacterAdded(player.Character)
    end

    player.CharacterAdded:Connect(onCharacterAdded)
end

function EnableESP()
    ESPEnabled = true
    for _, player in ipairs(Players:GetPlayers()) do
        CreateESP(player)
    end
    Players.PlayerAdded:Connect(CreateESP)
    Notify("ESP Ativado", 2)
end

function DisableESP()
    ESPEnabled = false
    ESPFolder:ClearAllChildren()
    Notify("ESP Desativado", 2)
end

-- ============================================
-- FULL BRIGHT
-- ============================================

local FullBrightEnabled = false
local FullBrightConnection = nil
local OriginalBrightness = Lighting.Brightness
local OriginalClockTime = Lighting.ClockTime
local OriginalFogEnd = Lighting.FogEnd
local OriginalGlobalShadows = Lighting.GlobalShadows

function EnableFullBright()
    FullBrightEnabled = true
    FullBrightConnection = RunService.RenderStepped:Connect(function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    end)
    Notify("Full Bright Ativado", 2)
end

function DisableFullBright()
    FullBrightEnabled = false
    if FullBrightConnection then
        FullBrightConnection:Disconnect()
        FullBrightConnection = nil
    end
    Lighting.Brightness = OriginalBrightness
    Lighting.ClockTime = OriginalClockTime
    Lighting.FogEnd = OriginalFogEnd
    Lighting.GlobalShadows = OriginalGlobalShadows
    Notify("Full Bright Desativado", 2)
end

-- ============================================
-- ANTI-AFK
-- ============================================

local AntiAFKEnabled = false
local AntiAFKConnection = nil

function EnableAntiAFK()
    AntiAFKEnabled = true
    AntiAFKConnection = LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
    Notify("Anti-AFK Ativado", 2)
end

function DisableAntiAFK()
    AntiAFKEnabled = false
    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end
    Notify("Anti-AFK Desativado", 2)
end

-- ============================================
-- INFINITE JUMP
-- ============================================

local InfiniteJumpEnabled = false
local InfiniteJumpConnection = nil

function EnableInfiniteJump()
    InfiniteJumpEnabled = true
    InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    Notify("Infinite Jump Ativado", 2)
end

function DisableInfiniteJump()
    InfiniteJumpEnabled = false
    if InfiniteJumpConnection then
        InfiniteJumpConnection:Disconnect()
        InfiniteJumpConnection = nil
    end
    Notify("Infinite Jump Desativado", 2)
end

-- ============================================
-- AUTO CLICK
-- ============================================

local AutoClickEnabled = false
local AutoClickConnection = nil

function EnableAutoClick()
    AutoClickEnabled = true
    AutoClickConnection = RunService.RenderStepped:Connect(function()
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            VirtualUser:Button1Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(0.01)
            VirtualUser:Button1Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end
    end)
    Notify("Auto Click Ativado", 2)
end

function DisableAutoClick()
    AutoClickEnabled = false
    if AutoClickConnection then
        AutoClickConnection:Disconnect()
        AutoClickConnection = nil
    end
    Notify("Auto Click Desativado", 2)
end

-- ============================================
-- TELEPORT TO MOUSE
-- ============================================

function TeleportToMouse()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local pos = Mouse.Hit.Position + Vector3.new(0, 3, 0)
        hrp.CFrame = CFrame.new(pos)
        Notify("Teleportado!", 2)
    end
end

-- ============================================
-- TELEPORT TO PLAYER
-- ============================================

function TeleportToPlayer(playerName)
    local target = Players:FindFirstChild(playerName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            Notify("Teleportado para " .. playerName, 2)
        end
    else
        Notify("Jogador nao encontrado", 2)
    end
end

-- ============================================
-- GOD MODE (SEMI)
-- ============================================

local GodModeEnabled = false
local GodModeConnection = nil

function EnableGodMode()
    GodModeEnabled = true
    GodModeConnection = RunService.RenderStepped:Connect(function()
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
            end
        end
    end)
    Notify("God Mode Ativado", 2)
end

function DisableGodMode()
    GodModeEnabled = false
    if GodModeConnection then
        GodModeConnection:Disconnect()
        GodModeConnection = nil
    end
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.MaxHealth = 100
            humanoid.Health = 100
        end
    end
    Notify("God Mode Desativado", 2)
end

-- ============================================
-- WATER WALK
-- ============================================

local WaterWalkEnabled = false
local WaterWalkConnection = nil

function EnableWaterWalk()
    WaterWalkEnabled = true
    WaterWalkConnection = RunService.RenderStepped:Connect(function()
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            end
        end
    end)
    Notify("Water Walk Ativado", 2)
end

function DisableWaterWalk()
    WaterWalkEnabled = false
    if WaterWalkConnection then
        WaterWalkConnection:Disconnect()
        WaterWalkConnection = nil
    end
    Notify("Water Walk Desativado", 2)
end

-- ============================================
-- BUNNY HOP
-- ============================================

local BunnyHopEnabled = false
local BunnyHopConnection = nil

function EnableBunnyHop()
    BunnyHopEnabled = true
    BunnyHopConnection = RunService.RenderStepped:Connect(function()
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    Notify("Bunny Hop Ativado", 2)
end

function DisableBunnyHop()
    BunnyHopEnabled = false
    if BunnyHopConnection then
        BunnyHopConnection:Disconnect()
        BunnyHopConnection = nil
    end
    Notify("Bunny Hop Desativado", 2)
end

-- ============================================
-- SPIN BOT
-- ============================================

local SpinBotEnabled = false
local SpinBotConnection = nil

function EnableSpinBot()
    SpinBotEnabled = true
    SpinBotConnection = RunService.RenderStepped:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(20), 0)
        end
    end)
    Notify("Spin Bot Ativado", 2)
end

function DisableSpinBot()
    SpinBotEnabled = false
    if SpinBotConnection then
        SpinBotConnection:Disconnect()
        SpinBotConnection = nil
    end
    Notify("Spin Bot Desativado", 2)
end

-- ============================================
-- AIMBOT (BASIC)
-- ============================================

local AimbotEnabled = false
local AimbotConnection = nil
local AimbotFOV = 200

function GetClosestPlayer()
    local closest = nil
    local closestDist = AimbotFOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = head
                end
            end
        end
    end

    return closest
end

function EnableAimbot()
    AimbotEnabled = true
    Notify("Aimbot Ativado (Segure o botao direito)", 3)
end

function DisableAimbot()
    AimbotEnabled = false
    Notify("Aimbot Desativado", 2)
end

UserInputService.InputBegan:Connect(function(input)
    if AimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotConnection = RunService.RenderStepped:Connect(function()
            local target = GetClosestPlayer()
            if target then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            end
        end)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and AimbotConnection then
        AimbotConnection:Disconnect()
        AimbotConnection = nil
    end
end)

-- ============================================
-- SUPER PUNCH
-- ============================================

local SuperPunchEnabled = false

function EnableSuperPunch()
    SuperPunchEnabled = true
    Notify("Super Punch Ativado", 2)
end

function DisableSuperPunch()
    SuperPunchEnabled = false
    Notify("Super Punch Desativado", 2)
end

-- ============================================
-- GRAVITY CONTROL
-- ============================================

local OriginalGravity = Workspace.Gravity

function SetGravity(value)
    Workspace.Gravity = value
end

function ResetGravity()
    Workspace.Gravity = OriginalGravity
end

-- ============================================
-- FOV CHANGER
-- ============================================

local OriginalFOV = Camera.FieldOfView

function SetFOV(value)
    Camera.FieldOfView = value
end

function ResetFOV()
    Camera.FieldOfView = OriginalFOV
end

-- ============================================
-- X-RAY
-- ============================================

local XRayEnabled = false

function EnableXRay()
    XRayEnabled = true
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Parent:FindFirstChild("Humanoid") then
            if part.Transparency < 0.5 then
                part.Transparency = 0.5
            end
        end
    end
    Notify("X-Ray Ativado", 2)
end

function DisableXRay()
    XRayEnabled = false
    Notify("X-Ray Desativado (Recarregue o mapa para resetar)", 3)
end

-- ============================================
-- FREE CAM
-- ============================================

local FreeCamEnabled = false
local FreeCamConnection = nil
local FreeCamCF = nil

function EnableFreeCam()
    FreeCamEnabled = true
    FreeCamCF = Camera.CFrame
    local speed = 1

    FreeCamConnection = RunService.RenderStepped:Connect(function()
        if not FreeCamEnabled then return end

        local moveDir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + FreeCamCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - FreeCamCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - FreeCamCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + FreeCamCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end

        if moveDir.Magnitude > 0 then
            FreeCamCF = FreeCamCF + moveDir.Unit * speed
        end

        Camera.CFrame = FreeCamCF
    end)

    Notify("Free Cam Ativado (WASD + Q/E)", 3)
end

function DisableFreeCam()
    FreeCamEnabled = false
    if FreeCamConnection then
        FreeCamConnection:Disconnect()
        FreeCamConnection = nil
    end
    Notify("Free Cam Desativado", 2)
end

-- ============================================
-- INSTANT INTERACT
-- ============================================

local InstantInteractEnabled = false

function EnableInstantInteract()
    InstantInteractEnabled = true
    Notify("Instant Interact Ativado", 2)
end

function DisableInstantInteract()
    InstantInteractEnabled = false
    Notify("Instant Interact Desativado", 2)
end

-- ============================================
-- NO FALL DAMAGE
-- ============================================

local NoFallDamageEnabled = false
local NoFallDamageConnection = nil

function EnableNoFallDamage()
    NoFallDamageEnabled = true
    NoFallDamageConnection = RunService.RenderStepped:Connect(function()
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.StateChanged:Connect(function(old, new)
                    if new == Enum.HumanoidStateType.Freefall then
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end)
            end
        end
    end)
    Notify("No Fall Damage Ativado", 2)
end

function DisableNoFallDamage()
    NoFallDamageEnabled = false
    if NoFallDamageConnection then
        NoFallDamageConnection:Disconnect()
        NoFallDamageConnection = nil
    end
    Notify("No Fall Damage Desativado", 2)
end

-- ============================================
-- REJOIN SERVER
-- ============================================

function RejoinServer()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

-- ============================================
-- SERVER HOP
-- ============================================

function ServerHop()
    local servers = {}
    local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    local data = HttpService:JSONDecode(req)

    for _, server in ipairs(data.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            table.insert(servers, server.id)
        end
    end

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
    else
        Notify("Nenhum servidor disponivel", 2)
    end
end

-- ============================================
-- KILL AURA
-- ============================================

local KillAuraEnabled = false
local KillAuraConnection = nil
local KillAuraRange = 20

function EnableKillAura()
    KillAuraEnabled = true
    KillAuraConnection = RunService.RenderStepped:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= KillAuraRange then
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid.Health = 0
                        end
                    end
                end
            end
        end
    end)
    Notify("Kill Aura Ativado", 2)
end

function DisableKillAura()
    KillAuraEnabled = false
    if KillAuraConnection then
        KillAuraConnection:Disconnect()
        KillAuraConnection = nil
    end
    Notify("Kill Aura Desativado", 2)
end

-- ============================================
-- CLICK TELEPORT
-- ============================================

local ClickTPEnabled = false

function EnableClickTP()
    ClickTPEnabled = true
    Notify("Click TP Ativado (Ctrl + Click)", 3)
end

function DisableClickTP()
    ClickTPEnabled = false
    Notify("Click TP Desativado", 2)
end

Mouse.Button1Down:Connect(function()
    if ClickTPEnabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        TeleportToMouse()
    end
end)

-- ============================================
-- SPEED HACK (ALTERNATIVE)
-- ============================================

local SpeedHackEnabled = false
local SpeedHackConnection = nil

function EnableSpeedHack()
    SpeedHackEnabled = true
    SpeedHackConnection = RunService.RenderStepped:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + humanoid.MoveDirection * 2
            end
        end
    end)
    Notify("Speed Hack Ativado", 2)
end

function DisableSpeedHack()
    SpeedHackEnabled = false
    if SpeedHackConnection then
        SpeedHackConnection:Disconnect()
        SpeedHackConnection = nil
    end
    Notify("Speed Hack Desativado", 2)
end

-- ============================================
-- INVISIBILITY
-- ============================================

local InvisibilityEnabled = false

function EnableInvisibility()
    InvisibilityEnabled = true
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = 1
            end
        end
    end
    Notify("Invisibilidade Ativada", 2)
end

function DisableInvisibility()
    InvisibilityEnabled = false
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = 0
            end
        end
    end
    Notify("Invisibilidade Desativada", 2)
end

-- ============================================
-- HEADLESS
-- ============================================

local HeadlessEnabled = false

function EnableHeadless()
    HeadlessEnabled = true
    if LocalPlayer.Character then
        local head = LocalPlayer.Character:FindFirstChild("Head")
        if head then
            head.Transparency = 1
            for _, face in ipairs(head:GetDescendants()) do
                if face:IsA("Decal") or face:IsA("Texture") then
                    face.Transparency = 1
                end
            end
        end
    end
    Notify("Headless Ativado", 2)
end

function DisableHeadless()
    HeadlessEnabled = false
    if LocalPlayer.Character then
        local head = LocalPlayer.Character:FindFirstChild("Head")
        if head then
            head.Transparency = 0
            for _, face in ipairs(head:GetDescendants()) do
                if face:IsA("Decal") or face:IsA("Texture") then
                    face.Transparency = 0
                end
            end
        end
    end
    Notify("Headless Desativado", 2)
end

-- ============================================
-- PLATFORM STAND
-- ============================================

local PlatformStandEnabled = false

function EnablePlatformStand()
    PlatformStandEnabled = true
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end
    end
    Notify("Platform Stand Ativado", 2)
end

function DisablePlatformStand()
    PlatformStandEnabled = false
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
    Notify("Platform Stand Desativado", 2)
end

-- ============================================
-- SIT
-- ============================================

function Sit()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Sit = true
        end
    end
end

-- ============================================
-- RESET CHARACTER
-- ============================================

function ResetCharacter()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
end

-- ============================================
-- BRING ALL PLAYERS
-- ============================================

function BringAllPlayers()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
            end
        end
        Notify("Todos os jogadores trazidos", 2)
    end
end

-- ============================================
-- FLING PLAYER
-- ============================================

function FlingPlayer(playerName)
    local target = Players:FindFirstChild(playerName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(math.random(-5000, 5000), math.random(-5000, 5000), math.random(-5000, 5000))
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Parent = target.Character.HumanoidRootPart

        task.wait(0.5)
        bodyVelocity:Destroy()
        Notify(playerName .. " flingado!", 2)
    else
        Notify("Jogador nao encontrado", 2)
    end
end

-- ============================================
-- LOOP FLING
-- ============================================

local LoopFlingEnabled = false
local LoopFlingConnection = nil
local LoopFlingTarget = nil

function EnableLoopFling(playerName)
    LoopFlingTarget = Players:FindFirstChild(playerName)
    if not LoopFlingTarget then
        Notify("Jogador nao encontrado", 2)
        return
    end

    LoopFlingEnabled = true
    LoopFlingConnection = RunService.RenderStepped:Connect(function()
        if LoopFlingTarget and LoopFlingTarget.Character and LoopFlingTarget.Character:FindFirstChild("HumanoidRootPart") then
            LoopFlingTarget.Character.HumanoidRootPart.Velocity = Vector3.new(math.random(-5000, 5000), math.random(-5000, 5000), math.random(-5000, 5000))
        end
    end)
    Notify("Loop Fling Ativado em " .. playerName, 2)
end

function DisableLoopFling()
    LoopFlingEnabled = false
    if LoopFlingConnection then
        LoopFlingConnection:Disconnect()
        LoopFlingConnection = nil
    end
    LoopFlingTarget = nil
    Notify("Loop Fling Desativado", 2)
end

-- ============================================
-- VIEW PLAYER
-- ============================================

local ViewingPlayer = nil
local ViewConnection = nil

function ViewPlayer(playerName)
    local target = Players:FindFirstChild(playerName)
    if target and target.Character then
        ViewingPlayer = target
        ViewConnection = RunService.RenderStepped:Connect(function()
            if ViewingPlayer and ViewingPlayer.Character and ViewingPlayer.Character:FindFirstChild("HumanoidRootPart") then
                Camera.CameraSubject = ViewingPlayer.Character:FindFirstChildOfClass("Humanoid") or ViewingPlayer.Character.HumanoidRootPart
            end
        end)
        Notify("Vendo " .. playerName, 2)
    else
        Notify("Jogador nao encontrado", 2)
    end
end

function UnviewPlayer()
    if ViewConnection then
        ViewConnection:Disconnect()
        ViewConnection = nil
    end
    ViewingPlayer = nil
    if LocalPlayer.Character then
        Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid") or LocalPlayer.Character
    end
    Notify("View Desativado", 2)
end

-- ============================================
-- TOOL GRABBER
-- ============================================

function GrabTools()
    for _, tool in ipairs(Workspace:GetDescendants()) do
        if tool:IsA("Tool") then
            tool:Clone().Parent = LocalPlayer.Backpack
        end
    end
    Notify("Todas as ferramentas pegas", 2)
end

-- ============================================
-- PATHFINDING WALK
-- ============================================

function WalkTo(position)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        humanoid:MoveTo(position)
    end
end

-- ============================================
-- ANCHOR SELF
-- ============================================

local AnchoredEnabled = false

function EnableAnchor()
    AnchoredEnabled = true
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.Anchored = true
    end
    Notify("Anchor Ativado", 2)
end

function DisableAnchor()
    AnchoredEnabled = false
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.Anchored = false
    end
    Notify("Anchor Desativado", 2)
end

-- ============================================
-- RESPAWN AT SAME POSITION
-- ============================================

local RespawnPos = nil

function SaveRespawnPos()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        RespawnPos = LocalPlayer.Character.HumanoidRootPart.CFrame
        Notify("Posicao salva", 2)
    end
end

function RespawnAtPos()
    if RespawnPos then
        LocalPlayer.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                hrp.CFrame = RespawnPos
            end
        end)
        ResetCharacter()
    else
        Notify("Nenhuma posicao salva", 2)
    end
end

-- ============================================
-- CHAT SPAM
-- ============================================

local ChatSpamEnabled = false
local ChatSpamConnection = nil
local ChatSpamText = "Delta Universal OP"

function EnableChatSpam(text)
    ChatSpamText = text or ChatSpamText
    ChatSpamEnabled = true
    ChatSpamConnection = task.spawn(function()
        while ChatSpamEnabled do
            game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(ChatSpamText, "All")
            task.wait(1.5)
        end
    end)
    Notify("Chat Spam Ativado", 2)
end

function DisableChatSpam()
    ChatSpamEnabled = false
    Notify("Chat Spam Desativado", 2)
end

-- ============================================
-- AUTO FARM (GENERIC)
-- ============================================

local AutoFarmEnabled = false
local AutoFarmConnection = nil

function EnableAutoFarm()
    AutoFarmEnabled = true
    AutoFarmConnection = task.spawn(function()
        while AutoFarmEnabled do
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():match("coin") or obj.Name:lower():match("cash") or obj.Name:lower():match("money") or obj.Name:lower():match("drop") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame
                        task.wait(0.1)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
    Notify("Auto Farm Generico Ativado", 2)
end

function DisableAutoFarm()
    AutoFarmEnabled = false
    Notify("Auto Farm Desativado", 2)
end

-- ============================================
-- BUILD GUI TABS
-- ============================================

-- PLAYER TAB
local PlayerTab = CreateTab("Player")

CreateSlider("WalkSpeed", 16, 500, 16, SetSpeed)
CreateSlider("JumpPower", 50, 500, 50, SetJumpPower)
CreateSlider("Gravity", 0, 196, 196, SetGravity)
CreateSlider("FOV", 30, 120, 70, SetFOV)

CreateToggle("Noclip", function(enabled)
    if enabled then EnableNoclip() else DisableNoclip() end
end)

CreateToggle("Fly", function(enabled)
    if enabled then EnableFly() else DisableFly() end
end)

CreateToggle("Infinite Jump", function(enabled)
    if enabled then EnableInfiniteJump() else DisableInfiniteJump() end
end)

CreateToggle("Bunny Hop", function(enabled)
    if enabled then EnableBunnyHop() else DisableBunnyHop() end
end)

CreateToggle("Water Walk", function(enabled)
    if enabled then EnableWaterWalk() else DisableWaterWalk() end
end)

CreateToggle("No Fall Damage", function(enabled)
    if enabled then EnableNoFallDamage() else DisableNoFallDamage() end
end)

CreateToggle("God Mode", function(enabled)
    if enabled then EnableGodMode() else DisableGodMode() end
end)

CreateToggle("Invisibility", function(enabled)
    if enabled then EnableInvisibility() else DisableInvisibility() end
end)

CreateToggle("Headless", function(enabled)
    if enabled then EnableHeadless() else DisableHeadless() end
end)

CreateToggle("Platform Stand", function(enabled)
    if enabled then EnablePlatformStand() else DisablePlatformStand() end
end)

CreateToggle("Spin Bot", function(enabled)
    if enabled then EnableSpinBot() else DisableSpinBot() end
end)

CreateToggle("Speed Hack", function(enabled)
    if enabled then EnableSpeedHack() else DisableSpeedHack() end
end)

CreateButton("Sit", Sit)
CreateButton("Reset Character", ResetCharacter)
CreateButton("Save Respawn Pos", SaveRespawnPos)
CreateButton("Respawn At Saved Pos", RespawnAtPos)

-- VISUAL TAB
local VisualTab = CreateTab("Visual")

CreateToggle("ESP", function(enabled)
    if enabled then EnableESP() else DisableESP() end
end)

CreateToggle("Full Bright", function(enabled)
    if enabled then EnableFullBright() else DisableFullBright() end
end)

CreateToggle("X-Ray", function(enabled)
    if enabled then EnableXRay() else DisableXRay() end
end)

CreateToggle("Free Cam", function(enabled)
    if enabled then EnableFreeCam() else DisableFreeCam() end
end)

-- COMBAT TAB
local CombatTab = CreateTab("Combat")

CreateToggle("Aimbot", function(enabled)
    if enabled then EnableAimbot() else DisableAimbot() end
end)

CreateToggle("Kill Aura", function(enabled)
    if enabled then EnableKillAura() else DisableKillAura() end
end)

CreateToggle("Auto Click", function(enabled)
    if enabled then EnableAutoClick() else DisableAutoClick() end
end)

CreateToggle("Super Punch", function(enabled)
    if enabled then EnableSuperPunch() else DisableSuperPunch() end
end)

CreateButton("Bring All Players", BringAllPlayers)
CreateButton("Grab All Tools", GrabTools)

-- TELEPORT TAB
local TPTab = CreateTab("Teleport")

CreateToggle("Click TP (Ctrl+Click)", function(enabled)
    if enabled then EnableClickTP() else DisableClickTP() end
end)

CreateButton("TP To Mouse", TeleportToMouse)

-- UTILITY TAB
local UtilityTab = CreateTab("Utility")

CreateToggle("Anti-AFK", function(enabled)
    if enabled then EnableAntiAFK() else DisableAntiAFK() end
end)

CreateToggle("Chat Spam", function(enabled)
    if enabled then EnableChatSpam() else DisableChatSpam() end
end)

CreateToggle("Auto Farm", function(enabled)
    if enabled then EnableAutoFarm() else DisableAutoFarm() end
end)

CreateButton("Rejoin Server", RejoinServer)
CreateButton("Server Hop", ServerHop)

-- ============================================
-- CLOSE/MINIMIZE
-- ============================================

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local Minimized = false
MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    ContentFrame.Visible = not Minimized
    TabFrame.Visible = not Minimized
    MainFrame.Size = Minimized and UDim2.new(0, 500, 0, 35) or UDim2.new(0, 500, 0, 400)
end)

-- ============================================
-- KEYBIND TOGGLE GUI (INSERT)
-- ============================================

local GuiVisible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        GuiVisible = not GuiVisible
        MainFrame.Visible = GuiVisible
    end
end)

-- ============================================
-- INIT
-- ============================================

Notify("Delta Universal Carregado! Pressione INSERT para esconder", 5)
