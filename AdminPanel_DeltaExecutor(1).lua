--[[
    Admin Panel Script - Delta Executor
    Não-visual / Command-based
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
    Aimbot = false,
    AutoClick = false,
    Commands = {},
    Logs = {},
    Target = nil,
    Connections = {}
}

--// Notificação
local function Notify(title, message, duration)
    duration = duration or 3
    print(string.format("[ADMIN] %s: %s", title, message))

    -- Tentar notificação do jogo via Remote
    pcall(function()
        AdminMsg:FireServer(title, message)
    end)
end

--// Verificar Status de Admin
local function CheckAdmin()
    local success, result = pcall(function()
        return AdminCheck:InvokeServer()
    end)

    if success then
        Admin.IsAdmin = result == true or result == "true" or result == 1
        if Admin.IsAdmin then
            Notify("Sistema", "Acesso de Admin concedido!", 5)
            AdminTrigger:FireServer("Initialize")
        else
            Notify("Sistema", "Acesso negado. Tentando bypass...", 3)
            -- Tentar ativar via trigger alternativo
            pcall(function()
                AdminGuiTrigger:FireServer(true)
                AdminTrigger:FireServer("ForceAdmin")
            end)
        end
        return Admin.IsAdmin
    else
        Notify("Erro", "Falha ao verificar admin: " .. tostring(result), 5)
        return false
    end
end

--// Sistema de Comandos
function Admin.AddCommand(name, aliases, description, callback)
    Admin.Commands[name:lower()] = {
        Aliases = aliases or {},
        Description = description or "Sem descrição",
        Execute = callback
    }

    for _, alias in ipairs(aliases) do
        Admin.Commands[alias:lower()] = Admin.Commands[name:lower()]
    end
end

--// Processador de Comandos
function Admin.ExecuteCommand(input)
    if not input or input == "" then return end

    local args = {}
    for arg in input:gmatch("%S+") do
        table.insert(args, arg)
    end

    local cmdName = table.remove(args, 1):lower()
    local command = Admin.Commands[cmdName]

    if command then
        local success, err = pcall(function()
            command.Execute(args)
        end)

        if not success then
            Notify("Erro", "Falha no comando: " .. tostring(err), 5)
        end

        table.insert(Admin.Logs, {
            Time = os.time(),
            Command = cmdName,
            Args = args,
            Success = success
        })
    else
        Notify("Comando", "Comando '" .. cmdName .. "' não encontrado. Use .help", 3)
    end
end

--// ==================== COMANDOS ====================

-- God Mode
Admin.AddCommand("god", {"gmode", "invencible"}, "Ativa/desativa god mode", function(args)
    Admin.GodMode = not Admin.GodMode

    if Admin.GodMode then
        -- Tentar via servidor
        AdminTrigger:FireServer("GodMode", true)

        -- Backup local
        if Humanoid then
            Humanoid.MaxHealth = math.huge
            Humanoid.Health = math.huge

            Admin.Connections.GodMode = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if Admin.GodMode and Humanoid.Health < Humanoid.MaxHealth then
                    Humanoid.Health = Humanoid.MaxHealth
                end
            end)
        end

        Notify("God Mode", "Ativado! Você é invencível.", 3)
    else
        AdminTrigger:FireServer("GodMode", false)
        if Admin.Connections.GodMode then
            Admin.Connections.GodMode:Disconnect()
        end
        if Humanoid then
            Humanoid.MaxHealth = 100
            Humanoid.Health = 100
        end
        Notify("God Mode", "Desativado.", 3)
    end
end)

-- Noclip
Admin.AddCommand("noclip", {"nc", "wallhack"}, "Ativa/desativa noclip", function(args)
    Admin.Noclip = not Admin.Noclip

    if Admin.Noclip then
        AdminTrigger:FireServer("Noclip", true)

        if not Admin.Connections.Noclip then
            Admin.Connections.Noclip = RunService.Stepped:Connect(function()
                if Admin.Noclip and Character then
                    for _, part in ipairs(Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end

        Notify("Noclip", "Ativado! Atravesse paredes.", 3)
    else
        AdminTrigger:FireServer("Noclip", false)
        if Admin.Connections.Noclip then
            Admin.Connections.Noclip:Disconnect()
            Admin.Connections.Noclip = nil
        end
        if Character then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        Notify("Noclip", "Desativado.", 3)
    end
end)

-- Fly
Admin.AddCommand("fly", {"voo", "voar"}, "Ativa/desativa voo", function(args)
    Admin.Fly = not Admin.Fly
    local speed = tonumber(args[1]) or 50

    if Admin.Fly then
        AdminTrigger:FireServer("Fly", true, speed)

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Name = "AdminFlyVelocity"
        bodyVelocity.Parent = HumanoidRootPart

        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 10000
        bodyGyro.Name = "AdminFlyGyro"
        bodyGyro.Parent = HumanoidRootPart

        Admin.Connections.Fly = RunService.RenderStepped:Connect(function()
            if Admin.Fly and HumanoidRootPart then
                local cam = workspace.CurrentCamera
                local moveDir = Vector3.new(0, 0, 0)

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDir = moveDir + cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDir = moveDir - cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDir = moveDir - cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDir = moveDir + cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDir = moveDir + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDir = moveDir - Vector3.new(0, 1, 0)
                end

                local flyVelocity = HumanoidRootPart:FindFirstChild("AdminFlyVelocity")
                local flyGyro = HumanoidRootPart:FindFirstChild("AdminFlyGyro")

                if flyVelocity and flyGyro then
                    flyVelocity.Velocity = moveDir * speed
                    flyGyro.CFrame = cam.CFrame
                end
            end
        end)

        Notify("Fly", "Ativado! Velocidade: " .. speed .. " | WASD para mover, Space/Shift para subir/descer", 5)
    else
        AdminTrigger:FireServer("Fly", false)
        if Admin.Connections.Fly then
            Admin.Connections.Fly:Disconnect()
        end
        for _, obj in ipairs(HumanoidRootPart:GetChildren()) do
            if obj.Name == "AdminFlyVelocity" or obj.Name == "AdminFlyGyro" then
                obj:Destroy()
            end
        end
        Notify("Fly", "Desativado.", 3)
    end
end)

-- Speed
Admin.AddCommand("speed", {"ws", "walkspeed", "velocidade"}, "Altera velocidade de caminhada", function(args)
    local newSpeed = tonumber(args[1]) or 50
    Admin.Speed = newSpeed

    AdminTrigger:FireServer("Speed", newSpeed)

    if Humanoid then
        Humanoid.WalkSpeed = newSpeed
    end

    Notify("Speed", "Velocidade alterada para: " .. newSpeed, 3)
end)

-- Jump Power
Admin.AddCommand("jump", {"jp", "jumppower", "pulo"}, "Altera poder do pulo", function(args)
    local newJump = tonumber(args[1]) or 100
    Admin.JumpPower = newJump

    AdminTrigger:FireServer("JumpPower", newJump)

    if Humanoid then
        Humanoid.JumpPower = newJump
    end

    Notify("Jump", "Poder do pulo alterado para: " .. newJump, 3)
end)

-- Teleport to Player
Admin.AddCommand("tp", {"goto", "teleport"}, "Teleporta até um jogador", function(args)
    local targetName = args[1]
    if not targetName then
        Notify("Erro", "Use: .tp [nome do jogador]", 3)
        return
    end

    local target = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():sub(1, #targetName) == targetName:lower() then
            target = player
            break
        end
    end

    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        AdminTrigger:FireServer("Teleport", target.Name)

        if HumanoidRootPart then
            HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        end

        Notify("Teleport", "Teleportado para: " .. target.Name, 3)
    else
        Notify("Erro", "Jogador não encontrado.", 3)
    end
end)

-- Bring Player
Admin.AddCommand("bring", {"pull", "puxar"}, "Puxa um jogador até você", function(args)
    local targetName = args[1]
    if not targetName then
        Notify("Erro", "Use: .bring [nome do jogador]", 3)
        return
    end

    AdminTrigger:FireServer("Bring", targetName)
    Notify("Bring", "Solicitação enviada para: " .. targetName, 3)
end)

-- Kill Player
Admin.AddCommand("kill", {"die", "matar"}, "Mata um jogador", function(args)
    local targetName = args[1] or "all"

    AdminTrigger:FireServer("Kill", targetName)
    Notify("Kill", "Comando enviado para: " .. targetName, 3)
end)

-- Heal Player
Admin.AddCommand("heal", {"curar", " vida"}, "Cura um jogador", function(args)
    local targetName = args[1] or LocalPlayer.Name

    AdminTrigger:FireServer("Heal", targetName)

    if targetName:lower() == "me" or targetName:lower() == LocalPlayer.Name:lower() then
        if Humanoid then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end

    Notify("Heal", "Cura enviada para: " .. targetName, 3)
end)

-- Invisible
Admin.AddCommand("invisible", {"invis", "hidden"}, "Torna você invisível", function(args)
    Admin.Invisible = not Admin.Invisible

    AdminTrigger:FireServer("Invisible", Admin.Invisible)

    if Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = Admin.Invisible and 1 or 0
                if part:FindFirstChild("face") then
                    part.face.Transparency = Admin.Invisible and 1 or 0
                end
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = Admin.Invisible and 1 or 0
            end
        end
    end

    Notify("Invisible", Admin.Invisible and "Você está invisível!" or "Visibilidade restaurada.", 3)
end)

-- ESP
Admin.AddCommand("esp", {"wallhack", "chams"}, "Ativa/desativa ESP nos jogadores", function(args)
    Admin.ESP = not Admin.ESP

    AdminTrigger:FireServer("ESP", Admin.ESP)

    if Admin.ESP then
        local function createESP(player)
            if player == LocalPlayer then return end
            if not player.Character then return end

            local highlight = Instance.new("Highlight")
            highlight.Name = "AdminESP"
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Adornee = player.Character
            highlight.Parent = player.Character

            local billboard = Instance.new("BillboardGui")
            billboard.Name = "AdminESPName"
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true

            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.TextStrokeTransparency = 0
            textLabel.TextScaled = true
            textLabel.Text = player.Name .. " | HP: " .. (player.Character:FindFirstChild("Humanoid") and math.floor(player.Character.Humanoid.Health) or "?")
            textLabel.Parent = billboard

            billboard.Parent = player.Character.Head
        end

        for _, player in ipairs(Players:GetPlayers()) do
            createESP(player)
        end

        Admin.Connections.ESP = Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                wait(1)
                if Admin.ESP then
                    createESP(player)
                end
            end)
        end)

        Notify("ESP", "Ativado! Jogadores destacados.", 3)
    else
        if Admin.Connections.ESP then
            Admin.Connections.ESP:Disconnect()
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                for _, obj in ipairs(player.Character:GetDescendants()) do
                    if obj.Name == "AdminESP" or obj.Name == "AdminESPName" then
                        obj:Destroy()
                    end
                end
            end
        end

        Notify("ESP", "Desativado.", 3)
    end
end)

-- Respawn
Admin.AddCommand("respawn", {"reset", "re"}, "Dá respawn no seu personagem", function(args)
    AdminTrigger:FireServer("Respawn")

    local char = LocalPlayer.Character
    if char then
        char:BreakJoints()
    end

    Notify("Respawn", "Respawn solicitado.", 3)
end)

-- Rejoin
Admin.AddCommand("rejoin", {"rj", "serverhop"}, "Reentra no servidor", function(args)
    AdminTrigger:FireServer("Rejoin")

    local placeId = game.PlaceId
    local jobId = game.JobId

    if args[1] == "small" then
        -- Server hop para servidor menor
        local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in ipairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= jobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                break
            end
        end
    else
        game:GetService("TeleportService"):Teleport(placeId, LocalPlayer)
    end

    Notify("Rejoin", "Reentrando no servidor...", 3)
end)

-- Server Info
Admin.AddCommand("serverinfo", {"si", "info"}, "Mostra informações do servidor", function(args)
    local players = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers

    AdminTrigger:FireServer("ServerInfo")

    Notify("Server Info", string.format("Jogadores: %d/%d | PlaceID: %d | JobID: %s", players, maxPlayers, game.PlaceId, game.JobId:sub(1, 8) .. "..."), 5)
end)

-- Player List
Admin.AddCommand("players", {"plrs", "list"}, "Lista todos os jogadores", function(args)
    local playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(playerList, player.Name)
    end

    Notify("Players", table.concat(playerList, ", "), 5)
end)

-- Kick Player (se suportado pelo servidor)
Admin.AddCommand("kick", {"boot", "expulsar"}, "Expulsa um jogador", function(args)
    local targetName = args[1]
    local reason = args[2] or "Kicked by Admin"

    if not targetName then
        Notify("Erro", "Use: .kick [nome] [motivo]", 3)
        return
    end

    AdminTrigger:FireServer("Kick", targetName, reason)
    Notify("Kick", "Solicitação de kick enviada para: " .. targetName, 3)
end)

-- Ban Player (se suportado pelo servidor)
Admin.AddCommand("ban", {"banir"}, "Bane um jogador", function(args)
    local targetName = args[1]
    local duration = args[2] or "permanent"
    local reason = args[3] or "Banned by Admin"

    if not targetName then
        Notify("Erro", "Use: .ban [nome] [duração] [motivo]", 3)
        return
    end

    AdminTrigger:FireServer("Ban", targetName, duration, reason)
    Notify("Ban", "Solicitação de ban enviada para: " .. targetName, 3)
end)

-- Give Tools/Items
Admin.AddCommand("give", {"tool", "item"}, "Dá um item (se suportado)", function(args)
    local itemName = args[1]
    if not itemName then
        Notify("Erro", "Use: .give [nome do item]", 3)
        return
    end

    AdminTrigger:FireServer("GiveItem", itemName)
    Notify("Give", "Solicitando item: " .. itemName, 3)
end)

-- Set Time (se suportado pelo jogo)
Admin.AddCommand("time", {"hora", "daynight"}, "Altera o horário do jogo", function(args)
    local timeValue = tonumber(args[1]) or 12

    AdminTrigger:FireServer("SetTime", timeValue)

    if workspace:FindFirstChild("ClockTime") then
        workspace.ClockTime.Value = timeValue
    end

    Notify("Time", "Horário alterado para: " .. timeValue, 3)
end)

-- God All (dar god para todos)
Admin.AddCommand("godall", {"godmodeall"}, "Ativa god mode para todos", function(args)
    AdminTrigger:FireServer("GodAll")
    Notify("God All", "God mode ativado para todos os jogadores.", 3)
end)

-- Heal All
Admin.AddCommand("healall", {"curartodos"}, "Cura todos os jogadores", function(args)
    AdminTrigger:FireServer("HealAll")
    Notify("Heal All", "Cura enviada para todos os jogadores.", 3)
end)

-- Kill All
Admin.AddCommand("killall", {"matartodos", "dieall"}, "Mata todos os jogadores", function(args)
    AdminTrigger:FireServer("KillAll")
    Notify("Kill All", "Comando enviado para todos os jogadores.", 3)
end)

-- Loop Kill
Admin.AddCommand("loopkill", {"lk", "loopk"}, "Mata um jogador repetidamente", function(args)
    local targetName = args[1]
    if not targetName then
        Notify("Erro", "Use: .loopkill [nome] | .unloopkill para parar", 3)
        return
    end

    Admin.LoopKillTarget = targetName
    Admin.Connections.LoopKill = RunService.Heartbeat:Connect(function()
        if Admin.LoopKillTarget then
            AdminTrigger:FireServer("Kill", Admin.LoopKillTarget)
        end
    end)

    Notify("Loop Kill", "Loop kill ativado para: " .. targetName, 3)
end)

-- Unloop Kill
Admin.AddCommand("unloopkill", {"unlk"}, "Para o loop kill", function(args)
    Admin.LoopKillTarget = nil
    if Admin.Connections.LoopKill then
        Admin.Connections.LoopKill:Disconnect()
        Admin.Connections.LoopKill = nil
    end
    Notify("Loop Kill", "Loop kill desativado.", 3)
end)

-- View Player
Admin.AddCommand("view", {"spectate", "watch"}, "Observa um jogador", function(args)
    local targetName = args[1]
    if not targetName then
        if Admin.Connections.View then
            Admin.Connections.View:Disconnect()
            Admin.Connections.View = nil
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            Notify("View", "Modo espectador desativado.", 3)
        end
        return
    end

    local target = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():sub(1, #targetName) == targetName:lower() then
            target = player
            break
        end
    end

    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = target.Character.Humanoid

        Admin.Connections.View = target.Character.Humanoid.Died:Connect(function()
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            Notify("View", "Alvo morreu. Espectador desativado.", 3)
        end)

        Notify("View", "Observando: " .. target.Name, 3)
    else
        Notify("Erro", "Jogador não encontrado.", 3)
    end
end)

-- Auto Click
Admin.AddCommand("autoclick", {"ac", "click"}, "Ativa/desativa auto click", function(args)
    Admin.AutoClick = not Admin.AutoClick
    local clickInterval = tonumber(args[1]) or 0.1

    if Admin.AutoClick then
        Admin.Connections.AutoClick = RunService.Heartbeat:Connect(function()
            if Admin.AutoClick then
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):ClickButton1(Vector2.new(0, 0))
            end
        end)
        Notify("Auto Click", "Ativado! Intervalo: " .. clickInterval .. "s", 3)
    else
        if Admin.Connections.AutoClick then
            Admin.Connections.AutoClick:Disconnect()
            Admin.Connections.AutoClick = nil
        end
        Notify("Auto Click", "Desativado.", 3)
    end
end)

-- Full Bright
Admin.AddCommand("fullbright", {"fb", "bright"}, "Remove escuridão", function(args)
    AdminTrigger:FireServer("FullBright")

    game:GetService("Lighting").Brightness = 10
    game:GetService("Lighting").GlobalShadows = false
    game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)

    Notify("Full Bright", "Escuridão removida!", 3)
end)

-- No Fog
Admin.AddCommand("nofog", {"fog"}, "Remove a névoa", function(args)
    AdminTrigger:FireServer("NoFog")

    game:GetService("Lighting").FogStart = 0
    game:GetService("Lighting").FogEnd = math.huge
    game:GetService("Lighting").FogColor = Color3.fromRGB(255, 255, 255)

    Notify("No Fog", "Névoa removida!", 3)
end)

-- Anti AFK
Admin.AddCommand("antiafk", {"afk"}, "Previne kick por AFK", function(args)
    if not Admin.Connections.AntiAFK then
        Admin.Connections.AntiAFK = LocalPlayer.Idled:Connect(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new(0, 0))
        end)
        Notify("Anti AFK", "Ativado! Você não será kickado por inatividade.", 3)
    else
        Admin.Connections.AntiAFK:Disconnect()
        Admin.Connections.AntiAFK = nil
        Notify("Anti AFK", "Desativado.", 3)
    end
end)

-- Commands List
Admin.AddCommand("help", {"cmds", "commands", "comandos"}, "Mostra todos os comandos", function(args)
    local cmdList = {}
    local added = {}

    for name, data in pairs(Admin.Commands) do
        if not added[data.Description] then
            added[data.Description] = true
            local aliases = ""
            if #data.Aliases > 0 then
                aliases = " (" .. table.concat(data.Aliases, ", ") .. ")"
            end
            table.insert(cmdList, "." .. name .. aliases .. " - " .. data.Description)
        end
    end

    table.sort(cmdList)

    print("========== ADMIN COMMANDS ==========")
    for _, cmd in ipairs(cmdList) do
        print(cmd)
    end
    print("====================================")

    Notify("Help", "Lista de comandos impressa no console. Pressione F9 para ver.", 5)
end)

-- Clear Console
Admin.AddCommand("clear", {"cls"}, "Limpa o console", function(args)
    -- Não há método direto, mas podemos imprimir linhas em branco
    for i = 1, 50 do
        print("")
    end
    Notify("Clear", "Console limpo.", 2)
end)

-- Status
Admin.AddCommand("status", {"stats", "info"}, "Mostra status atual", function(args)
    local status = string.format(
        "Admin: %s | God: %s | Noclip: %s | Fly: %s | Invisible: %s | ESP: %s | Speed: %d",
        tostring(Admin.IsAdmin),
        tostring(Admin.GodMode),
        tostring(Admin.Noclip),
        tostring(Admin.Fly),
        tostring(Admin.Invisible),
        tostring(Admin.ESP),
        Admin.Speed
    )
    Notify("Status", status, 5)
end)

--// ==================== INTERFACE DE CHAT ====================

-- Conectar ao chat para comandos
local function onChatted(message)
    if message:sub(1, 1) == "." then
        local command = message:sub(2)
        Admin.ExecuteCommand(command)
    end
end

LocalPlayer.Chatted:Connect(onChatted)

--// ==================== TECLAS DE ATALHO ====================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- F3 - Status rápido
    if input.KeyCode == Enum.KeyCode.F3 then
        Admin.ExecuteCommand("status")
    end

    -- F4 - God Mode toggle
    if input.KeyCode == Enum.KeyCode.F4 then
        Admin.ExecuteCommand("god")
    end

    -- F5 - Noclip toggle
    if input.KeyCode == Enum.KeyCode.F5 then
        Admin.ExecuteCommand("noclip")
    end

    -- F6 - Fly toggle
    if input.KeyCode == Enum.KeyCode.F6 then
        Admin.ExecuteCommand("fly")
    end

    -- F7 - ESP toggle
    if input.KeyCode == Enum.KeyCode.F7 then
        Admin.ExecuteCommand("esp")
    end

    -- F8 - Invisible toggle
    if input.KeyCode == Enum.KeyCode.F8 then
        Admin.ExecuteCommand("invisible")
    end
end)

--// ==================== INICIALIZAÇÃO ====================

-- Verificar admin ao iniciar
local function Initialize()
    print("========================================")
    print("     ADMIN PANEL - DELTA EXECUTOR")
    print("     Não-visual / Command-based")
    print("========================================")
    print("Comandos iniciam com '.' (ponto)")
    print("Use .help para ver todos os comandos")
    print("Atalhos: F3-Status | F4-God | F5-Noclip | F6-Fly | F7-ESP | F8-Invisible")
    print("========================================")

    -- Verificar status de admin
    CheckAdmin()

    -- Anti-detecção básica
    pcall(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)

        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" and self == LocalPlayer then
                Notify("Proteção", "Tentativa de kick detectada e bloqueada!", 5)
                return nil
            end
            return oldNamecall(self, ...)
        end)

        setreadonly(mt, true)
    end)

    -- Reconectar quando respawnar
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        Character = newChar
        Humanoid = newChar:WaitForChild("Humanoid")
        HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")

        -- Restaurar configurações
        if Admin.GodMode then
            Humanoid.MaxHealth = math.huge
            Humanoid.Health = math.huge
        end
        if Admin.Speed ~= 16 then
            Humanoid.WalkSpeed = Admin.Speed
        end
        if Admin.JumpPower ~= 50 then
            Humanoid.JumpPower = Admin.JumpPower
        end

        Notify("Respawn", "Personagem respawnado. Configurações restauradas.", 3)
    end)

    Notify("Sistema", "Admin Panel carregado com sucesso!", 5)
end

-- Iniciar
Initialize()

-- Retornar tabela Admin para uso externo se necessário
return Admin
