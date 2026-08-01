local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "BRBOX SUPREME",
    Icon = "sword",
    Theme = "Dark",
})

local Tab = Window:Tab({ Title = "Farm", Icon = "zap" })

local farming = false
local bv = nil

-- Variáveis de filtro
local filtroSelecionado = "Todos ouro/XP"
local filtroConfirmado = false

local function setCollision(character, state)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = state
        end
    end
end

local function getTargetPart(obj)
    if obj:IsA("BasePart") then
        return obj
    elseif obj:IsA("Model") then
        local hrp = obj:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:IsA("BasePart") then
            return hrp
        end
        for _, desc in ipairs(obj:GetDescendants()) do
            if desc:IsA("BasePart") then
                return desc
            end
        end
    end
    return nil
end

-- ===== FUNÇÃO DE VERIFICAÇÃO DO FILTRO =====
local function verificarFiltro(obj)
    local target = getTargetPart(obj)
    if not target then return false end

    local cor = target.Color
    local size = target.Size

    -- Cores alvo
    local corOuro = Color3.fromRGB(255, 215, 0)
    local corXP = Color3.fromRGB(163, 75, 75)

    -- Tamanhos alvo
    local sizeGrande = Vector3.new(6, 6, 6)
    local sizePequeno = Vector3.new(2, 2, 2)

    -- Tolerância para comparação de tamanho
    local tolerancia = 0.1

    local function coresIguais(c1, c2)
        local rDiff = math.abs(c1.R * 255 - c2.R * 255)
        local gDiff = math.abs(c1.G * 255 - c2.G * 255)
        local bDiff = math.abs(c1.B * 255 - c2.B * 255)
        return rDiff < 5 and gDiff < 5 and bDiff < 5
    end

    local function tamanhoIgual(s1, s2)
        return math.abs(s1.X - s2.X) < tolerancia 
            and math.abs(s1.Y - s2.Y) < tolerancia 
            and math.abs(s1.Z - s2.Z) < tolerancia
    end

    if filtroSelecionado == "Bolas amarelas (ouro)" then
        return coresIguais(cor, corOuro)

    elseif filtroSelecionado == "Bolas vermelhas (XP)" then
        return coresIguais(cor, corXP)

    elseif filtroSelecionado == "Todos ouro/XP" then
        return coresIguais(cor, corOuro) or coresIguais(cor, corXP)

    elseif filtroSelecionado == "Bolas (grandes)" then
        return tamanhoIgual(size, sizeGrande)

    elseif filtroSelecionado == "Bolas (pequenas)" then
        return tamanhoIgual(size, sizePequeno)

    else
        return true
    end
end

-- ===== DROPDOWN DE FILTRO =====
Tab:Dropdown({
    Title = "Filtro de Bolas",
    Values = {
        "Bolas amarelas (ouro)",
        "Bolas vermelhas (XP)",
        "Todos ouro/XP",
        "Bolas (grandes)",
        "Bolas (pequenas)",
    },
    Value = "Todos ouro/XP",
    Callback = function(value)
        filtroSelecionado = value
        filtroConfirmado = false
    end,
})

-- ===== BOTÃO DE CONFIRMAR =====
Tab:Button({
    Title = "Confirmar Filtro",
    Callback = function()
        filtroConfirmado = true
        WindUI:Notify({
            Title = "Filtro Confirmado",
            Content = "Filtro ativado: " .. filtroSelecionado,
            Duration = 3,
        })
    end,
})

-- ===== TOGGLE AUTO FARM (BETA) =====
Tab:Toggle({
    Title = "Auto Farm (Beta)",
    Value = false,
    Callback = function(state)
        farming = state
        if farming then
            task.spawn(function()
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local hrp = character:WaitForChild("HumanoidRootPart")
                local rs = game:GetService("RunService")

                setCollision(character, false)

                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.zero
                bv.Parent = hrp

                while farming do
                    local folder = nil
                    if workspace:FindFirstChild("Berries") then
                        folder = workspace.Berries
                    elseif workspace:FindFirstChild("Aliens") then
                        folder = workspace.Aliens
                    end

                    if folder then
                        local targets = folder:GetChildren()
                        for _, obj in ipairs(targets) do
                            if not farming then break end

                            -- Verifica se o filtro foi confirmado
                            if not filtroConfirmado then
                                task.wait(0.5)
                                continue
                            end

                            -- Verifica se o objeto passa no filtro
                            if not verificarFiltro(obj) then
                                continue
                            end

                            local target = getTargetPart(obj)
                            if target then
                                while farming and target and target.Parent do
                                    local dist = (target.Position - hrp.Position).Magnitude
                                    if dist < 5 then break end
                                    local direction = (target.Position - hrp.Position).Unit
                                    bv.Velocity = direction * 18
                                    rs.Heartbeat:Wait()
                                end
                                bv.Velocity = Vector3.zero
                                task.wait(0.2)
                            end
                        end
                    else
                        task.wait(1)
                    end
                    task.wait(0.1)
                end

                if bv then
                    bv:Destroy()
                    bv = nil
                end
                setCollision(character, true)
            end)
        else
            if bv then
                bv:Destroy()
                bv = nil
            end
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                setCollision(character, true)
            end
        end
    end,
})

-- ============================================================
-- ABA KILL
-- ============================================================

local KillTab = Window:Tab({ Title = "Kill", Icon = "skull" })

local jogadorSelecionado = nil
local killAtivo = false
local bvKill = nil
local previewGui = nil

-- ===== FUNÇÃO PARA PEGAR LISTA DE JOGADORES =====
local function getListaJogadores()
    local lista = {}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer then
            table.insert(lista, plr.Name)
        end
    end
    return lista
end

-- ===== TEXTO DE AVISO =====
KillTab:Paragraph({
    Title = "Aviso",
    Desc = "Essa função não irá servir para bichos com pouca força.",
})

-- ===== DROPDOWN DE JOGADORES =====
local dropdownJogadores

dropdownJogadores = KillTab:Dropdown({
    Title = "Selecionar Jogador",
    Values = getListaJogadores(),
    Value = "",
    Callback = function(value)
        jogadorSelecionado = value
    end,
})

-- ===== ATUALIZAÇÃO AUTOMÁTICA DA LISTA =====
task.spawn(function()
    local Players = game:GetService("Players")

    Players.PlayerAdded:Connect(function()
        local novaLista = getListaJogadores()
        dropdownJogadores:Refresh(novaLista)
    end)

    Players.PlayerRemoving:Connect(function()
        local novaLista = getListaJogadores()
        dropdownJogadores:Refresh(novaLista)

        -- Se o jogador selecionado saiu, limpa a seleção
        if jogadorSelecionado and not Players:FindFirstChild(jogadorSelecionado) then
            jogadorSelecionado = nil
        end
    end)
end)

-- ===== BOTÃO 3D PREVIEW OBJECT =====
KillTab:Button({
    Title = "3D Preview Object",
    Callback = function()
        if not jogadorSelecionado or jogadorSelecionado == "" then
            WindUI:Notify({
                Title = "Erro",
                Content = "Selecione um jogador primeiro!",
                Duration = 3,
            })
            return
        end

        local alvo = game.Players:FindFirstChild(jogadorSelecionado)
        if not alvo or not alvo.Character then
            WindUI:Notify({
                Title = "Erro",
                Content = "Jogador não encontrado ou sem personagem!",
                Duration = 3,
            })
            return
        end

        -- Fecha preview anterior se existir
        if previewGui then
            previewGui:Destroy()
            previewGui = nil
        end

        -- Cria GUI de preview
        previewGui = Instance.new("ScreenGui")
        previewGui.Name = "Preview3D_GUI"
        previewGui.ResetOnSpawn = false
        previewGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 350, 0, 400)
        frame.Position = UDim2.new(0.5, -175, 0.5, -200)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BorderSizePixel = 0
        frame.Parent = previewGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 35)
        title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        title.Text = "3D Preview - " .. jogadorSelecionado
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 16
        title.Parent = frame

        local titleCorner = Instance.new("UICorner")
        titleCorner.CornerRadius = UDim.new(0, 10)
        titleCorner.Parent = title

        local viewport = Instance.new("ViewportFrame")
        viewport.Size = UDim2.new(1, -20, 1, -85)
        viewport.Position = UDim2.new(0, 10, 0, 45)
        viewport.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        viewport.BorderSizePixel = 0
        viewport.Parent = frame

        local viewportCorner = Instance.new("UICorner")
        viewportCorner.CornerRadius = UDim.new(0, 8)
        viewportCorner.Parent = viewport

        local cam = Instance.new("Camera")
        cam.FieldOfView = 50
        viewport.CurrentCamera = cam

        -- Clona o personagem
        local charClone = alvo.Character:Clone()
        charClone.Parent = viewport

        -- Remove scripts e humanoid do clone pra não dar bug
        for _, desc in ipairs(charClone:GetDescendants()) do
            if desc:IsA("Script") or desc:IsA("LocalScript") then
                desc:Destroy()
            end
        end

        local hrpClone = charClone:FindFirstChild("HumanoidRootPart")
        if hrpClone then
            cam.CFrame = CFrame.new(hrpClone.Position + Vector3.new(0, 2, 6), hrpClone.Position)
        end

        -- Botão fechar
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 100, 0, 30)
        closeBtn.Position = UDim2.new(0.5, -50, 1, -40)
        closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        closeBtn.Text = "Fechar"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        closeBtn.Parent = frame

        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 6)
        closeCorner.Parent = closeBtn

        closeBtn.MouseButton1Click:Connect(function()
            if previewGui then
                previewGui:Destroy()
                previewGui = nil
            end
        end)

        -- Animação de rotação
        task.spawn(function()
            local angle = 0
            while previewGui and previewGui.Parent do
                angle = angle + 0.02
                if hrpClone and hrpClone.Parent then
                    cam.CFrame = CFrame.new(
                        hrpClone.Position + Vector3.new(math.sin(angle) * 6, 2, math.cos(angle) * 6),
                        hrpClone.Position
                    )
                end
                task.wait(0.03)
            end
        end)
    end,
})

-- ===== TOGGLE KILL =====
KillTab:Toggle({
    Title = "Kill (Beta)",
    Value = false,
    Callback = function(state)
        killAtivo = state

        if killAtivo then
            if not jogadorSelecionado or jogadorSelecionado == "" then
                WindUI:Notify({
                    Title = "Erro",
                    Content = "Selecione um jogador no dropdown primeiro!",
                    Duration = 3,
                })
                killAtivo = false
                return
            end

            task.spawn(function()
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local hrp = character:WaitForChild("HumanoidRootPart")
                local rs = game:GetService("RunService")

                setCollision(character, false)

                bvKill = Instance.new("BodyVelocity")
                bvKill.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bvKill.Velocity = Vector3.zero
                bvKill.Parent = hrp

                while killAtivo do
                    local alvo = game.Players:FindFirstChild(jogadorSelecionado)
                    if alvo and alvo.Character then
                        local alvoHrp = alvo.Character:FindFirstChild("HumanoidRootPart")
                        if alvoHrp and alvoHrp.Parent then
                            local dist = (alvoHrp.Position - hrp.Position).Magnitude
                            if dist > 2 then
                                local direction = (alvoHrp.Position - hrp.Position).Unit
                                bvKill.Velocity = direction * 16
                            else
                                -- Travado no HRP do alvo
                                bvKill.Velocity = Vector3.zero
                                hrp.CFrame = alvoHrp.CFrame * CFrame.new(0, 0, 1.5)
                            end
                        else
                            bvKill.Velocity = Vector3.zero
                        end
                    else
                        bvKill.Velocity = Vector3.zero
                        WindUI:Notify({
                            Title = "Aviso",
                            Content = "Jogador alvo não encontrado!",
                            Duration = 2,
                        })
                        break
                    end
                    rs.Heartbeat:Wait()
                end

                if bvKill then
                    bvKill:Destroy()
                    bvKill = nil
                end
                setCollision(character, true)
            end)
        else
            if bvKill then
                bvKill:Destroy()
                bvKill = nil
            end
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                setCollision(character, true)
            end
        end
    end,
})

-- ============================================================
-- ============================================================

-- ============================================================
-- ABA CLIMA - VIBE SELVA / JUNGLE
-- ============================================================

local ClimaTab = Window:Tab({ Title = "Clima", Icon = "cloud" })

local climaAtivo = false
local efeitosSalvos = {}
local partsOriginais = {}

local function salvarEstadoOriginal()
    local Lighting = game:GetService("Lighting")
    efeitosSalvos = {
        Technology = Lighting.Technology,
        GlobalShadows = Lighting.GlobalShadows,
        ShadowSoftness = Lighting.ShadowSoftness,
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ClockTime = Lighting.ClockTime,
        GeographicLatitude = Lighting.GeographicLatitude,
        ExposureCompensation = Lighting.ExposureCompensation,
        FogColor = Lighting.FogColor,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
    }

    efeitosSalvos.filhos = {}
    for _, filho in ipairs(Lighting:GetChildren()) do
        table.insert(efeitosSalvos.filhos, filho:Clone())
    end

    partsOriginais = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players) then
            partsOriginais[obj] = {
                Material = obj.Material,
                Color = obj.Color,
                Reflectance = obj.Reflectance,
                Transparency = obj.Transparency,
                CastShadow = obj.CastShadow,
            }
        end
    end
end

local function restaurarEstadoOriginal()
    local Lighting = game:GetService("Lighting")

    for prop, valor in pairs(efeitosSalvos) do
        if prop ~= "filhos" and Lighting[prop] ~= nil then
            pcall(function()
                Lighting[prop] = valor
            end)
        end
    end

    for _, filho in ipairs(Lighting:GetChildren()) do
        if filho.Name == "Selva_Effect" then
            filho:Destroy()
        end
    end

    if efeitosSalvos.filhos then
        for _, clone in ipairs(efeitosSalvos.filhos) do
            if not Lighting:FindFirstChild(clone.Name) then
                clone.Parent = Lighting
            end
        end
    end

    for part, dados in pairs(partsOriginais) do
        if part and part.Parent then
            pcall(function()
                part.Material = dados.Material
                part.Color = dados.Color
                part.Reflectance = dados.Reflectance
                part.Transparency = dados.Transparency
                part.CastShadow = dados.CastShadow
            end)
        end
    end

    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    if Terrain then
        pcall(function()
            Terrain.WaterColor = Color3.fromRGB(12, 84, 91)
            Terrain.WaterWaveSize = 0.15
            Terrain.WaterWaveSpeed = 10
            Terrain.WaterTransparency = 0.3
            Terrain.WaterReflectance = 1
        end)
    end
end

local function aplicarClimaSelva()
    local Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass("Terrain")

    -- ===== ILUMINACAO DE SELVA =====
    Lighting.Technology = Enum.Technology.Future
    Lighting.GlobalShadows = true
    Lighting.ShadowSoftness = 0.25
    Lighting.Brightness = 0.7
    Lighting.Ambient = Color3.fromRGB(25, 40, 20)
    Lighting.OutdoorAmbient = Color3.fromRGB(55, 75, 35)
    Lighting.ClockTime = 13.5
    Lighting.GeographicLatitude = 0
    Lighting.ExposureCompensation = -0.3

    -- ===== ATMOSFERA UMIDA DE SELVA =====
    local Atmosphere = Instance.new("Atmosphere")
    Atmosphere.Name = "Selva_Effect"
    Atmosphere.Density = 0.55
    Atmosphere.Offset = 0.3
    Atmosphere.Color = Color3.fromRGB(75, 95, 45)
    Atmosphere.Decay = Color3.fromRGB(35, 55, 20)
    Atmosphere.Glare = 0.2
    Atmosphere.Haze = 3.5
    Atmosphere.Parent = Lighting

    -- ===== BLOOM SUAVE =====
    local Bloom = Instance.new("BloomEffect")
    Bloom.Name = "Selva_Effect"
    Bloom.Intensity = 0.35
    Bloom.Size = 20
    Bloom.Threshold = 0.88
    Bloom.Enabled = true
    Bloom.Parent = Lighting

    -- ===== CORRECAO DE COR - TOM VERDE-AMBAR =====
    local ColorCorrection = Instance.new("ColorCorrectionEffect")
    ColorCorrection.Name = "Selva_Effect"
    ColorCorrection.Brightness = -0.05
    ColorCorrection.Contrast = 0.12
    ColorCorrection.Saturation = 0.35
    ColorCorrection.TintColor = Color3.fromRGB(195, 215, 160)
    ColorCorrection.Enabled = true
    ColorCorrection.Parent = Lighting

    -- ===== RAIOS DE SOL FILTRADOS =====
    local SunRays = Instance.new("SunRaysEffect")
    SunRays.Name = "Selva_Effect"
    SunRays.Intensity = 0.15
    SunRays.Spread = 0.4
    SunRays.Enabled = true
    SunRays.Parent = Lighting

    -- ===== PROFUNDIDADE DE CAMPO =====
    local DepthOfField = Instance.new("DepthOfFieldEffect")
    DepthOfField.Name = "Selva_Effect"
    DepthOfField.FarIntensity = 0.25
    DepthOfField.FocusDistance = 40
    DepthOfField.InFocusRadius = 15
    DepthOfField.NearIntensity = 0.15
    DepthOfField.Enabled = true
    DepthOfField.Parent = Lighting

    -- ===== BLUR LEVE =====
    local MotionBlur = Instance.new("BlurEffect")
    MotionBlur.Name = "Selva_Effect"
    MotionBlur.Size = 1
    MotionBlur.Enabled = true
    MotionBlur.Parent = Lighting

    -- ===== NUVENS DENSAS DE SELVA TROPICAL =====
    if Terrain then
        local Clouds = Instance.new("Clouds")
        Clouds.Name = "Selva_Effect"
        Clouds.Cover = 0.85
        Clouds.Density = 0.9
        Clouds.Color = Color3.fromRGB(170, 180, 160)
        Clouds.Parent = Terrain

        Terrain.WaterColor = Color3.fromRGB(25, 45, 22)
        Terrain.WaterWaveSize = 0.25
        Terrain.WaterWaveSpeed = 14
        Terrain.WaterTransparency = 0.5
        Terrain.WaterReflectance = 0.7
    end

    -- ===== NEBLINA VERDE NO CHAO =====
    Lighting.FogColor = Color3.fromRGB(50, 65, 35)
    Lighting.FogStart = 25
    Lighting.FogEnd = 220

    -- ===== MUDANCA MASSIVA NAS TEXTURAS - VIBE SELVA =====
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players) then
            pcall(function()
                obj.CastShadow = true
                obj.Reflectance = math.min(obj.Reflectance + 0.05, 0.25)

                local cor = obj.Color
                local r, g, b = cor.R * 255, cor.G * 255, cor.B * 255

                if g > r + 25 and g > b + 25 then
                    obj.Material = Enum.Material.LeafyGrass
                    obj.Color = Color3.fromRGB(math.max(r - 10, 0), math.min(g + 15, 255), math.max(b - 10, 0))
                elseif r > 70 and g > 45 and b < 55 then
                    obj.Material = Enum.Material.Mud
                    obj.Color = Color3.fromRGB(math.min(r + 5, 255), math.max(g - 10, 0), math.max(b - 5, 0))
                elseif math.abs(r - g) < 25 and math.abs(g - b) < 25 and r < 140 then
                    obj.Material = Enum.Material.Slate
                    obj.Color = Color3.fromRGB(r + 3, g + 8, b + 2)
                elseif math.abs(r - g) < 25 and math.abs(g - b) < 25 and r >= 140 then
                    obj.Material = Enum.Material.Concrete
                elseif b > r + 25 and b > g + 15 then
                    obj.Material = Enum.Material.Ice
                    obj.Color = Color3.fromRGB(20, 40, 35)
                    obj.Reflectance = 0.3
                elseif r > 200 and g > 200 and b > 200 then
                    obj.Material = Enum.Material.Rock
                    obj.Color = Color3.fromRGB(210, 215, 200)
                elseif r > g + 35 and r > b + 35 then
                    obj.Material = Enum.Material.Brick
                elseif r > 100 and g > 70 and b < 70 then
                    obj.Material = Enum.Material.WoodPlanks
                    obj.Color = Color3.fromRGB(math.min(r + 10, 255), math.max(g - 5, 0), math.max(b - 10, 0))
                elseif r > 140 and g > 140 and b > 140 then
                    obj.Material = Enum.Material.Metal
                    obj.Reflectance = 0.4
                else
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0.05
                end
            end)
        end
    end

    -- ===== SKYBOX DE SELVA =====
    for _, filho in ipairs(Lighting:GetChildren()) do
        if filho:IsA("Sky") then
            filho.Name = "Selva_Effect_OLD"
            filho:Destroy()
        end
    end

    local Sky = Instance.new("Sky")
    Sky.Name = "Selva_Effect"
    Sky.SkyboxBk = "rbxassetid://6414217092"
    Sky.SkyboxDn = "rbxassetid://6414217092"
    Sky.SkyboxFt = "rbxassetid://6414217092"
    Sky.SkyboxLf = "rbxassetid://6414217092"
    Sky.SkyboxRt = "rbxassetid://6414217092"
    Sky.SkyboxUp = "rbxassetid://6414217092"
    Sky.StarCount = 0
    Sky.SunAngularSize = 8
    Sky.SunTextureId = "rbxassetid://6196665106"
    Sky.MoonTextureId = "rbxassetid://6196668026"
    Sky.MoonAngularSize = 8
    Sky.Parent = Lighting
end

ClimaTab:Toggle({
    Title = "Gráficos",
    Desc = "Ah pois já tive essa função o céu irá ficar bugado após desativar isso pode causar (lag) um pouco",
    Value = false,
    Callback = function(state)
        climaAtivo = state
        if climaAtivo then
            task.spawn(function()
                salvarEstadoOriginal()
                task.wait(0.1)
                aplicarClimaSelva()
            end)
        else
            task.spawn(function()
                restaurarEstadoOriginal()
            end)
        end
    end,
})

-- ============================================================
-- ============================================================

-- ============================================================
-- ABA PLAYER
-- ============================================================

local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })

local infiniteJumpAtivo = false
local jumpConnection = nil
local ultimoPulo = 0
local cooldownPulo = 0.12

local function getHumanoid()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        return character:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function ativarInfiniteJump()
    local player = game.Players.LocalPlayer
    local UserInputService = game:GetService("UserInputService")

    -- Gravidade do espaço (quase zero) - cai devagarzinho como uma pena
    jumpConnection = UserInputService.JumpRequest:Connect(function()
        if not infiniteJumpAtivo then return end

        local agora = tick()
        if agora - ultimoPulo < cooldownPulo then return end
        ultimoPulo = agora

        local humanoid = getHumanoid()
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function desativarInfiniteJump()
    if jumpConnection then
        jumpConnection:Disconnect()
        jumpConnection = nil
    end
    -- Restaura gravidade original
end

-- Atualiza quando respawnar
local player = game.Players.LocalPlayer
player.CharacterAdded:Connect(function(char)
    if infiniteJumpAtivo then
        task.wait(0.3)
    end
end)

PlayerTab:Toggle({
    Title = "Infinite Jump",
    Desc = "18% útil",
    Value = false,
    Callback = function(state)
        infiniteJumpAtivo = state
        if infiniteJumpAtivo then
            ativarInfiniteJump()
            WindUI:Notify({
                Title = "Infinite Jump Ativado",
                Content = "Aperte ESPAÇO repetidamente no ar! Gravidade: espaço.",
                Duration = 3,
            })
        else
            desativarInfiniteJump()
            WindUI:Notify({
                Title = "Infinite Jump Desativado",
                Content = "Pulo normal e gravidade restaurados.",
                Duration = 3,
            })
        end
    end,
})

-- ============================================================
-- ============================================================

-- ============================================================
-- ABA COLOR - PERSONAGEM COLORIDO (TODAS AS PARTES/BLOCOS)
-- ============================================================

local ColorTab = Window:Tab({ Title = "Color", Icon = "palette" })

local colorAtivo = false
local colorConnection = nil
local coresOriginais = {}

-- Salva as cores originais de TODAS as BaseParts do personagem
local function salvarCoresOriginais(character)
    coresOriginais = {}
    for _, parte in ipairs(character:GetDescendants()) do
        if parte:IsA("BasePart") then
            coresOriginais[parte] = parte.Color
        end
    end
end

-- Aplica efeito arco-íris em TODAS as BaseParts do personagem
local function aplicarCoresArcoIris(character, hue)
    local partes = {}
    for _, parte in ipairs(character:GetDescendants()) do
        if parte:IsA("BasePart") then
            table.insert(partes, parte)
        end
    end

    for i, parte in ipairs(partes) do
        -- Cada parte tem uma cor ligeiramente diferente no espectro
        local offsetHue = (hue + (i * 0.08)) % 1
        local cor = Color3.fromHSV(offsetHue, 1, 1)
        parte.Color = cor
    end
end

-- Restaura as cores originais de TODAS as BaseParts
local function restaurarCoresOriginais(character)
    for parte, corOriginal in pairs(coresOriginais) do
        if parte and parte.Parent then
            parte.Color = corOriginal
        end
    end
end

-- Inicia o loop de cores
local function iniciarColorEffect()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end

    salvarCoresOriginais(character)

    local hue = 0
    colorConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not colorAtivo then return end
        hue = (hue + 0.008) % 1
        local char = player.Character
        if char then
            aplicarCoresArcoIris(char, hue)
        end
    end)
end

-- Para o efeito e restaura
local function pararColorEffect()
    if colorConnection then
        colorConnection:Disconnect()
        colorConnection = nil
    end
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        restaurarCoresOriginais(character)
    end
end

-- Atualiza quando o personagem respawnar
local player = game.Players.LocalPlayer
player.CharacterAdded:Connect(function(newChar)
    if colorAtivo then
        task.wait(0.5)
        salvarCoresOriginais(newChar)
    end
end)

ColorTab:Toggle({
    Title = "Rainbow",
    Desc = "arco-íris 🌈",
    Value = false,
    Callback = function(state)
        colorAtivo = state
        if colorAtivo then
            iniciarColorEffect()
            WindUI:Notify({
                Title = "Color Ativado",
                Content = "Todas as partes do seu personagem estão coloridas!",
                Duration = 3,
            })
        else
            pararColorEffect()
            WindUI:Notify({
                Title = "Color Desativado",
                Content = "Cores originais restauradas em todas as partes.",
                Duration = 3,
            })
        end
    end,
})

-- ============================================================
-- ============================================================

-- ============================================================
-- ABA UI - CONTROLE DE INTERFACES
-- ============================================================

local UITab = Window:Tab({ Title = "UI", Icon = "layout" })

-- Estados
local uiRobloxAtivo = true
local uiJogoAtivo = true

-- Tabelas para salvar estados originais
local estadosCoreGui = {}
local estadosJogoGUI = {}

-- Lista de CoreGuiTypes que serão controlados
local tiposCoreGui = {
    Enum.CoreGuiType.Chat,
    Enum.CoreGuiType.PlayerList,
    Enum.CoreGuiType.EmotesMenu,
    Enum.CoreGuiType.Backpack,
    Enum.CoreGuiType.Health,
}

-- Função para verificar se uma GUI é essencial de controle (mobile)
local function isGUIEssencial(gui)
    local nome = gui.Name:lower()
    local nomesEssenciais = {
        "touchgui",
        "touchcontrol",
        "jumpbutton",
        "thumbstick",
        "dynamicthumbstick",
        "mobile",
        "virtual",
        "control",
    }
    for _, essencial in ipairs(nomesEssenciais) do
        if string.find(nome, essencial, 1, true) then
            return true
        end
    end
    -- Verifica se algum descendente tem nome de controle essencial
    for _, desc in ipairs(gui:GetDescendants()) do
        local descNome = desc.Name:lower()
        for _, essencial in ipairs(nomesEssenciais) do
            if string.find(descNome, essencial, 1, true) then
                return true
            end
        end
    end
    return false
end

-- Salva estado atual da UI do Roblox
local function salvarEstadoUIRoblox()
    local StarterGui = game:GetService("StarterGui")
    for _, tipo in ipairs(tiposCoreGui) do
        pcall(function()
            -- Não há método direto de "get", então assumimos true como padrão
            estadosCoreGui[tipo] = true
        end)
    end
end

-- Salva estado atual das GUIs do jogo
local function salvarEstadoUIJogo()
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    estadosJogoGUI = {}
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") or gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
            if not isGUIEssencial(gui) then
                estadosJogoGUI[gui] = gui.Enabled
            end
        end
    end
end

-- Desliga UI do Roblox
local function desligarUIRoblox()
    local StarterGui = game:GetService("StarterGui")
    for _, tipo in ipairs(tiposCoreGui) do
        pcall(function()
            StarterGui:SetCoreGuiEnabled(tipo, false)
        end)
    end
    -- Tenta esconder também a barra superior (menu de esc) via notificação silenciosa
    pcall(function()
        StarterGui:SetCore("TopbarEnabled", false)
    end)
end

-- Liga UI do Roblox
local function ligarUIRoblox()
    local StarterGui = game:GetService("StarterGui")
    for _, tipo in ipairs(tiposCoreGui) do
        pcall(function()
            StarterGui:SetCoreGuiEnabled(tipo, true)
        end)
    end
    pcall(function()
        StarterGui:SetCore("TopbarEnabled", true)
    end)
end

-- Desliga UI do jogo
local function desligarUIJogo()
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") or gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
            if not isGUIEssencial(gui) then
                gui.Enabled = false
            end
        end
    end
end

-- Liga UI do jogo
local function ligarUIJogo()
    for gui, estadoOriginal in pairs(estadosJogoGUI) do
        if gui and gui.Parent then
            gui.Enabled = estadoOriginal
        end
    end
end

-- Monitora novas GUIs que podem aparecer enquanto a UI do jogo está "desligada"
local playerGuiConnection = nil

local function iniciarMonitorJogo()
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    playerGuiConnection = playerGui.ChildAdded:Connect(function(gui)
        if not uiJogoAtivo then
            if (gui:IsA("ScreenGui") or gui:IsA("BillboardGui") or gui:IsA("SurfaceGui")) and not isGUIEssencial(gui) then
                estadosJogoGUI[gui] = gui.Enabled
                gui.Enabled = false
            end
        end
    end)
end

iniciarMonitorJogo()

-- Toggle UI do Roblox
UITab:Toggle({
    Title = "UI do Roblox",
    Value = true,
    Callback = function(state)
        uiRobloxAtivo = state
        if uiRobloxAtivo then
            ligarUIRoblox()
            WindUI:Notify({
                Title = "UI Roblox",
                Content = "GUI do Roblox foi ativada",
                Duration = 3,
            })
        else
            salvarEstadoUIRoblox()
            desligarUIRoblox()
            WindUI:Notify({
                Title = "UI Roblox",
                Content = "GUI do Roblox foi desativada",
                Duration = 3,
            })
        end
    end,
})

-- Toggle UI do Jogo
UITab:Toggle({
    Title = "UI do Jogo",
    Value = true,
    Callback = function(state)
        uiJogoAtivo = state
        if uiJogoAtivo then
            ligarUIJogo()
            WindUI:Notify({
                Title = "UI do Jogo",
                Content = "GUI do jogo foi ativada",
                Duration = 3,
            })
        else
            salvarEstadoUIJogo()
            desligarUIJogo()
            WindUI:Notify({
                Title = "UI do Jogo",
                Content = "GUI do jogo foi desativada",
                Duration = 3,
            })
        end
    end,
})

-- ============================================================
-- ============================================================


-- ============================================================
-- ABA SERVER - TELEPORTE PARA SERVIDOR COM POUCOS JOGADORES
-- ============================================================

local ServerTab = Window:Tab({ Title = "Server", Icon = "server" })

ServerTab:Paragraph({
    Title = "Server Hop",
    Desc = "Teleporta você automaticamente para um servidor com poucos jogadores",
})

ServerTab:Button({
    Title = "Teleportar para Servidor Vazio",
    Desc = "Busca e teleporta para um servidor com o menor número de jogadores possível.",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        WindUI:Notify({
            Title = "Buscando...",
            Content = "Procurando servidor com poucos jogadores...",
            Duration = 5,
        })

        task.spawn(function()
            local placeId = game.PlaceId
            local jobId = game.JobId
            local success, servers = pcall(function()
                local response = HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
                ))
                return response
            end)

            if success and servers and servers.data then
                local melhorServidor = nil
                local menorCount = math.huge

                for _, server in ipairs(servers.data) do
                    if server.id ~= jobId and server.playing < server.maxPlayers then
                        if server.playing < menorCount then
                            menorCount = server.playing
                            melhorServidor = server
                        end
                    end
                end

                if melhorServidor then
                    WindUI:Notify({
                        Title = "Servidor Encontrado!",
                        Content = "Jogadores: " .. tostring(melhorServidor.playing) .. "/" .. tostring(melhorServidor.maxPlayers) .. " | Teleportando...",
                        Duration = 4,
                    })
                    task.wait(1.5)
                    TeleportService:TeleportToPlaceInstance(placeId, melhorServidor.id, LocalPlayer)
                else
                    WindUI:Notify({
                        Title = "Erro",
                        Content = "Nenhum servidor disponível encontrado.",
                        Duration = 4,
                    })
                end
            else
                WindUI:Notify({
                    Title = "Erro",
                    Content = "Falha ao buscar servidores. Tente novamente.",
                    Duration = 4,
                })
            end
        end)
    end,
})

-- ============================================================
-- ============================================================

-- ============================================================
-- ABA SETTINGS - APENAS TEMA DA JANELA
-- ============================================================

local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

SettingsTab:Dropdown({
    Title = "Tema da Janela",
    Values = { "Dark", "Light", "Rose", "Plant", "Indigo", "Sky", "Violet", "Amber" },
    Value = "Dark",
    Callback = function(value)
        WindUI:SetTheme(value)
        WindUI:Notify({
            Title = "Tema Alterado",
            Content = "Novo tema aplicado: " .. value,
            Duration = 2,
        })
    end,
})

-- ============================================================
-- ============================================================

-- ============================================================
-- ABA CREDITS - CRÉDITOS DO SCRIPT
-- ============================================================

local CreditsTab = Window:Tab({ Title = "Credits", Icon = "heart" })

CreditsTab:Paragraph({
    Title = "Seja bem-vindo ao nosso script!",
    Desc = "Obrigado por usar o BRBOX SUPREME. Aproveite todas as funcionalidades!",
})

CreditsTab:Paragraph({
    Title = "Créditos",
    Desc = "Os créditos do script vão para\n\nby: 908\n\nby: Otarico_Darrat",
})