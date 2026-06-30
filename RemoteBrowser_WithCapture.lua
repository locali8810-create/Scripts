local colorSettings =
{
	["Main"] = {
		["HeaderColor"] = Color3.fromRGB(0, 168, 255),
		["HeaderShadingColor"] = Color3.fromRGB(0, 151, 230),
		["HeaderTextColor"] = Color3.fromRGB(47, 54, 64),
		["MainBackgroundColor"] = Color3.fromRGB(47, 54, 64),
		["InfoScrollingFrameBgColor"] = Color3.fromRGB(47, 54, 64),
		["ScrollBarImageColor"] = Color3.fromRGB(127, 143, 166)
	},
	["RemoteButtons"] = {
		["BorderColor"] = Color3.fromRGB(113, 128, 147),
		["BackgroundColor"] = Color3.fromRGB(53, 59, 72),
		["TextColor"] = Color3.fromRGB(220, 221, 225),
		["NumberTextColor"] = Color3.fromRGB(203, 204, 207)
	},
	["MainButtons"] = {
		["BorderColor"] = Color3.fromRGB(113, 128, 147),
		["BackgroundColor"] = Color3.fromRGB(53, 59, 72),
		["TextColor"] = Color3.fromRGB(220, 221, 225)
	},
	["FilterButtons"] = {
		["ActiveBg"] = Color3.fromRGB(0, 168, 255),
		["ActiveText"] = Color3.fromRGB(47, 54, 64),
		["InactiveBg"] = Color3.fromRGB(53, 59, 72),
		["InactiveText"] = Color3.fromRGB(220, 221, 225)
	},
	["CaptureButton"] = {
		["ActiveBg"] = Color3.fromRGB(46, 213, 115),
		["ActiveText"] = Color3.fromRGB(47, 54, 64),
		["InactiveBg"] = Color3.fromRGB(53, 59, 72),
		["InactiveText"] = Color3.fromRGB(220, 221, 225),
		["RecordingBg"] = Color3.fromRGB(255, 71, 87)
	}
}

function isSynapse()
	if PROTOSMASHER_LOADED then
		return false
	else
		return true
	end
end

function Parent(GUI)
	if syn and syn.protect_gui then
		syn.protect_gui(GUI)
		GUI.Parent = game:GetService("CoreGui")
	elseif PROTOSMASHER_LOADED then
		GUI.Parent = get_hidden_gui()
	else
		GUI.Parent = game:GetService("CoreGui")
	end
end

local client = game.Players.LocalPlayer

local function toUnicode(string)
	local codepoints = "utf8.char("
	for _i, v in utf8.codes(string) do
		codepoints = codepoints .. v .. ', '
	end
	return codepoints:sub(1, -3) .. ')'
end

local function GetFullPathOfAnInstance(instance)
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
				head = '["' .. name:gsub('"', '\\"'):gsub('\\', '\\\\') .. '"'
			elseif #nonAlphaNum ~= 0 and #noPunct > 0 then
				head = '[' .. toUnicode(name) .. ']'
			end
		end
	end

	return GetFullPathOfAnInstance(instance.Parent) .. head
end

local isA = game.IsA
local clone = game.Clone

if game.CoreGui:FindFirstChild("TurtleSpyBrowserGUI") then
	game.CoreGui.TurtleSpyBrowserGUI:Destroy()
end

local functionImage = "http://www.roblox.com/asset/?id=413369623"
local eventImage = "http://www.roblox.com/asset/?id=413369506"

local TurtleSpyBrowserGUI = Instance.new("ScreenGui")
local BrowserHeader = Instance.new("Frame")
local BrowserHeaderFrame = Instance.new("Frame")
local BrowserHeaderText = Instance.new("TextLabel")
local CloseInfoFrame2 = Instance.new("TextButton")
local RemoteBrowserFrame = Instance.new("ScrollingFrame")
local RemoteButton2 = Instance.new("TextButton")
local RemoteName2 = Instance.new("TextLabel")
local RemoteIcon2 = Instance.new("ImageLabel")

local FilterFrame = Instance.new("Frame")
local FilterAllButton = Instance.new("TextButton")
local FilterEventButton = Instance.new("TextButton")
local FilterFunctionButton = Instance.new("TextButton")

-- NOVO: Botão de Captura em Tempo Real
local CaptureButton = Instance.new("TextButton")

local SearchFrame = Instance.new("Frame")
local SearchBox = Instance.new("TextBox")
local SearchIcon = Instance.new("ImageLabel")

TurtleSpyBrowserGUI.Name = "TurtleSpyBrowserGUI"
Parent(TurtleSpyBrowserGUI)

BrowserHeader.Name = "BrowserHeader"
BrowserHeader.Parent = TurtleSpyBrowserGUI
BrowserHeader.BackgroundColor3 = colorSettings["Main"]["HeaderShadingColor"]
BrowserHeader.BorderColor3 = colorSettings["Main"]["HeaderShadingColor"]
BrowserHeader.Position = UDim2.new(0.5, -103, 0.3, 0)
BrowserHeader.Size = UDim2.new(0, 207, 0, 93)
BrowserHeader.ZIndex = 20
BrowserHeader.Active = true
BrowserHeader.Draggable = true
BrowserHeader.Visible = true

BrowserHeaderFrame.Name = "BrowserHeaderFrame"
BrowserHeaderFrame.Parent = BrowserHeader
BrowserHeaderFrame.BackgroundColor3 = colorSettings["Main"]["HeaderColor"]
BrowserHeaderFrame.BorderColor3 = colorSettings["Main"]["HeaderColor"]
BrowserHeaderFrame.Position = UDim2.new(0, 0, -0.0202544238, 0)
BrowserHeaderFrame.Size = UDim2.new(0, 207, 0, 26)
BrowserHeaderFrame.ZIndex = 21

BrowserHeaderText.Name = "InfoHeaderText"
BrowserHeaderText.Parent = BrowserHeaderFrame
BrowserHeaderText.BackgroundTransparency = 1.000
BrowserHeaderText.Position = UDim2.new(0, 0, -0.00206991332, 0)
BrowserHeaderText.Size = UDim2.new(0, 206, 0, 33)
BrowserHeaderText.ZIndex = 22
BrowserHeaderText.Font = Enum.Font.SourceSans
BrowserHeaderText.Text = "Remote Browser"
BrowserHeaderText.TextColor3 = colorSettings["Main"]["HeaderTextColor"]
BrowserHeaderText.TextSize = 17.000

CloseInfoFrame2.Name = "CloseInfoFrame"
CloseInfoFrame2.Parent = BrowserHeaderFrame
CloseInfoFrame2.BackgroundColor3 = colorSettings["Main"]["HeaderColor"]
CloseInfoFrame2.BorderColor3 = colorSettings["Main"]["HeaderColor"]
CloseInfoFrame2.Position = UDim2.new(0, 185, 0, 2)
CloseInfoFrame2.Size = UDim2.new(0, 22, 0, 22)
CloseInfoFrame2.ZIndex = 38
CloseInfoFrame2.Font = Enum.Font.SourceSansLight
CloseInfoFrame2.Text = "X"
CloseInfoFrame2.TextColor3 = Color3.fromRGB(0, 0, 0)
CloseInfoFrame2.TextSize = 20.000
CloseInfoFrame2.MouseButton1Click:Connect(function()
	TurtleSpyBrowserGUI:Destroy()
end)

FilterFrame.Name = "FilterFrame"
FilterFrame.Parent = BrowserHeader
FilterFrame.BackgroundColor3 = colorSettings["Main"]["MainBackgroundColor"]
FilterFrame.BorderColor3 = colorSettings["Main"]["MainBackgroundColor"]
FilterFrame.Position = UDim2.new(0, 0, 0, 26)
FilterFrame.Size = UDim2.new(0, 207, 0, 30)
FilterFrame.ZIndex = 20

-- Ajustado: Botões de filtro menores para caber o novo botão
FilterAllButton.Name = "FilterAllButton"
FilterAllButton.Parent = FilterFrame
FilterAllButton.BackgroundColor3 = colorSettings["FilterButtons"]["ActiveBg"]
FilterAllButton.BorderColor3 = colorSettings["MainButtons"]["BorderColor"]
FilterAllButton.Position = UDim2.new(0, 5, 0, 3)
FilterAllButton.Size = UDim2.new(0, 46, 0, 24)
FilterAllButton.ZIndex = 21
FilterAllButton.Font = Enum.Font.SourceSans
FilterAllButton.Text = "Todos"
FilterAllButton.TextColor3 = colorSettings["FilterButtons"]["ActiveText"]
FilterAllButton.TextSize = 13.000

FilterEventButton.Name = "FilterEventButton"
FilterEventButton.Parent = FilterFrame
FilterEventButton.BackgroundColor3 = colorSettings["FilterButtons"]["InactiveBg"]
FilterEventButton.BorderColor3 = colorSettings["MainButtons"]["BorderColor"]
FilterEventButton.Position = UDim2.new(0, 55, 0, 3)
FilterEventButton.Size = UDim2.new(0, 46, 0, 24)
FilterEventButton.ZIndex = 21
FilterEventButton.Font = Enum.Font.SourceSans
FilterEventButton.Text = "Event"
FilterEventButton.TextColor3 = colorSettings["FilterButtons"]["InactiveText"]
FilterEventButton.TextSize = 13.000

FilterFunctionButton.Name = "FilterFunctionButton"
FilterFunctionButton.Parent = FilterFrame
FilterFunctionButton.BackgroundColor3 = colorSettings["FilterButtons"]["InactiveBg"]
FilterFunctionButton.BorderColor3 = colorSettings["MainButtons"]["BorderColor"]
FilterFunctionButton.Position = UDim2.new(0, 105, 0, 3)
FilterFunctionButton.Size = UDim2.new(0, 46, 0, 24)
FilterFunctionButton.ZIndex = 21
FilterFunctionButton.Font = Enum.Font.SourceSans
FilterFunctionButton.Text = "Function"
FilterFunctionButton.TextColor3 = colorSettings["FilterButtons"]["InactiveText"]
FilterFunctionButton.TextSize = 12.000

-- NOVO: Botão de Captura em Tempo Real
CaptureButton.Name = "CaptureButton"
CaptureButton.Parent = FilterFrame
CaptureButton.BackgroundColor3 = colorSettings["CaptureButton"]["InactiveBg"]
CaptureButton.BorderColor3 = colorSettings["MainButtons"]["BorderColor"]
CaptureButton.Position = UDim2.new(0, 155, 0, 3)
CaptureButton.Size = UDim2.new(0, 46, 0, 24)
CaptureButton.ZIndex = 21
CaptureButton.Font = Enum.Font.SourceSans
CaptureButton.Text = "REC"
CaptureButton.TextColor3 = colorSettings["CaptureButton"]["InactiveText"]
CaptureButton.TextSize = 13.000

SearchFrame.Name = "SearchFrame"
SearchFrame.Parent = BrowserHeader
SearchFrame.BackgroundColor3 = colorSettings["Main"]["MainBackgroundColor"]
SearchFrame.BorderColor3 = colorSettings["Main"]["MainBackgroundColor"]
SearchFrame.Position = UDim2.new(0, 0, 0, 56)
SearchFrame.Size = UDim2.new(0, 207, 0, 30)
SearchFrame.ZIndex = 20

SearchBox.Name = "SearchBox"
SearchBox.Parent = SearchFrame
SearchBox.BackgroundColor3 = colorSettings["RemoteButtons"]["BackgroundColor"]
SearchBox.BorderColor3 = colorSettings["MainButtons"]["BorderColor"]
SearchBox.Position = UDim2.new(0, 5, 0, 3)
SearchBox.Size = UDim2.new(0, 197, 0, 24)
SearchBox.ZIndex = 21
SearchBox.Font = Enum.Font.SourceSans
SearchBox.PlaceholderText = "Search..."
SearchBox.Text = ""
SearchBox.TextColor3 = colorSettings["RemoteButtons"]["TextColor"]
SearchBox.TextSize = 14.000
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false

SearchIcon.Name = "SearchIcon"
SearchIcon.Parent = SearchBox
SearchIcon.BackgroundTransparency = 1.000
SearchIcon.Position = UDim2.new(1, -22, 0, 2)
SearchIcon.Size = UDim2.new(0, 20, 0, 20)
SearchIcon.ZIndex = 22
SearchIcon.Image = "http://www.roblox.com/asset/?id=6034407084"
SearchIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)

RemoteBrowserFrame.Name = "RemoteBrowserFrame"
RemoteBrowserFrame.Parent = BrowserHeader
RemoteBrowserFrame.Active = true
RemoteBrowserFrame.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
RemoteBrowserFrame.BorderColor3 = Color3.fromRGB(47, 54, 64)
RemoteBrowserFrame.Position = UDim2.new(-0.004540205, 0, 0, 86)
RemoteBrowserFrame.Size = UDim2.new(0, 207, 0, 256)
RemoteBrowserFrame.ZIndex = 19
RemoteBrowserFrame.CanvasSize = UDim2.new(0, 0, 0, 287)
RemoteBrowserFrame.ScrollBarThickness = 8
RemoteBrowserFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
RemoteBrowserFrame.ScrollBarImageColor3 = colorSettings["Main"]["ScrollBarImageColor"]

RemoteButton2.Name = "RemoteButton"
RemoteButton2.Parent = RemoteBrowserFrame
RemoteButton2.BackgroundColor3 = colorSettings["RemoteButtons"]["BackgroundColor"]
RemoteButton2.BorderColor3 = colorSettings["RemoteButtons"]["BorderColor"]
RemoteButton2.Position = UDim2.new(0, 17, 0, 10)
RemoteButton2.Size = UDim2.new(0, 182, 0, 26)
RemoteButton2.ZIndex = 20
RemoteButton2.Selected = true
RemoteButton2.Font = Enum.Font.SourceSans
RemoteButton2.Text = ""
RemoteButton2.TextSize = 18.000
RemoteButton2.TextStrokeTransparency = 123.000
RemoteButton2.TextWrapped = true
RemoteButton2.TextXAlignment = Enum.TextXAlignment.Left
RemoteButton2.Visible = false

RemoteName2.Name = "RemoteName2"
RemoteName2.Parent = RemoteButton2
RemoteName2.BackgroundTransparency = 1.000
RemoteName2.Position = UDim2.new(0, 5, 0, 0)
RemoteName2.Size = UDim2.new(0, 155, 0, 26)
RemoteName2.ZIndex = 21
RemoteName2.Font = Enum.Font.SourceSans
RemoteName2.Text = "RemoteEvent"
RemoteName2.TextColor3 = colorSettings["RemoteButtons"]["TextColor"]
RemoteName2.TextSize = 16.000
RemoteName2.TextXAlignment = Enum.TextXAlignment.Left
RemoteName2.TextTruncate = 1

RemoteIcon2.Name = "RemoteIcon2"
RemoteIcon2.Parent = RemoteButton2
RemoteIcon2.BackgroundTransparency = 1.000
RemoteIcon2.Position = UDim2.new(0.840260386, 0, 0.0225472748, 0)
RemoteIcon2.Size = UDim2.new(0, 24, 0, 24)
RemoteIcon2.ZIndex = 21
RemoteIcon2.Image = functionImage

-- NOVO: Label para contador de captura
local CaptureCountLabel = Instance.new("TextLabel")
CaptureCountLabel.Name = "CaptureCountLabel"
CaptureCountLabel.Parent = SearchFrame
CaptureCountLabel.BackgroundTransparency = 1.000
CaptureCountLabel.Position = UDim2.new(0, 5, 0, 3)
CaptureCountLabel.Size = UDim2.new(0, 197, 0, 24)
CaptureCountLabel.ZIndex = 21
CaptureCountLabel.Font = Enum.Font.SourceSans
CaptureCountLabel.Text = ""
CaptureCountLabel.TextColor3 = Color3.fromRGB(46, 213, 115)
CaptureCountLabel.TextSize = 14.000
CaptureCountLabel.TextXAlignment = Enum.TextXAlignment.Center
CaptureCountLabel.Visible = false

local allRemotes = {}
local remoteButtons = {}
local browsedConnections = {}

local currentFilter = "All"
local currentSearch = ""

-- NOVO: Variáveis de captura em tempo real
local isCapturing = false
local capturedRemotes = {} -- SÓ eventos que foram REALMENTE chamados
local captureConnections = {}
local originalFireServer = {}
local originalInvokeServer = {}
local captureRenderConnection = nil
local hookedInstances = {} -- Rastreia quais já foram hookados

local function updateFilterButtons()
	local activeBg = colorSettings["FilterButtons"]["ActiveBg"]
	local activeText = colorSettings["FilterButtons"]["ActiveText"]
	local inactiveBg = colorSettings["FilterButtons"]["InactiveBg"]
	local inactiveText = colorSettings["FilterButtons"]["InactiveText"]

	if currentFilter == "All" then
		FilterAllButton.BackgroundColor3 = activeBg
		FilterAllButton.TextColor3 = activeText
		FilterEventButton.BackgroundColor3 = inactiveBg
		FilterEventButton.TextColor3 = inactiveText
		FilterFunctionButton.BackgroundColor3 = inactiveBg
		FilterFunctionButton.TextColor3 = inactiveText
	elseif currentFilter == "Event" then
		FilterAllButton.BackgroundColor3 = inactiveBg
		FilterAllButton.TextColor3 = inactiveText
		FilterEventButton.BackgroundColor3 = activeBg
		FilterEventButton.TextColor3 = activeText
		FilterFunctionButton.BackgroundColor3 = inactiveBg
		FilterFunctionButton.TextColor3 = inactiveText
	else
		FilterAllButton.BackgroundColor3 = inactiveBg
		FilterAllButton.TextColor3 = inactiveText
		FilterEventButton.BackgroundColor3 = inactiveBg
		FilterEventButton.TextColor3 = inactiveText
		FilterFunctionButton.BackgroundColor3 = activeBg
		FilterFunctionButton.TextColor3 = activeText
	end
end

local function renderButtons()
	for _, btnData in pairs(remoteButtons) do
		btnData.Button:Destroy()
	end
	remoteButtons = {}

	local searchLower = currentSearch:lower()
	local browsedButtonOffset = 10
	local visibleCount = 0

	for _, remoteData in ipairs(allRemotes) do
		local shouldShow = false
		if currentFilter == "All" then
			shouldShow = true
		elseif currentFilter == "Event" and remoteData.Type == "RemoteEvent" then
			shouldShow = true
		elseif currentFilter == "Function" and remoteData.Type == "RemoteFunction" then
			shouldShow = true
		end

		if shouldShow and currentSearch ~= "" then
			shouldShow = remoteData.Instance.Name:lower():find(searchLower, 1, true) ~= nil
		end

		if shouldShow then
			local bButton = clone(RemoteButton2)
			bButton.Parent = RemoteBrowserFrame
			bButton.Visible = true
			bButton.Position = UDim2.new(0, 17, 0, browsedButtonOffset)
			bButton.RemoteName2.Text = remoteData.Instance.Name

			if remoteData.Type == "RemoteEvent" then
				bButton.RemoteIcon2.Image = eventImage
			else
				bButton.RemoteIcon2.Image = functionImage
			end

			local connection = bButton.MouseButton1Click:Connect(function()
				setclipboard(remoteData.Path .. remoteData.FireFunction)
			end)

			table.insert(browsedConnections, connection)
			table.insert(remoteButtons, {Button = bButton, Type = remoteData.Type})

			browsedButtonOffset = browsedButtonOffset + 35
			visibleCount = visibleCount + 1
		end
	end

	if visibleCount > 7 then
		RemoteBrowserFrame.CanvasSize = UDim2.new(0, 0, 0, 256 + (visibleCount - 7) * 35)
	else
		RemoteBrowserFrame.CanvasSize = UDim2.new(0, 0, 0, 257)
	end
end

-- NOVO: Função para renderizar APENAS eventos que foram chamados
local function renderCaptureButtons()
	for _, btnData in pairs(remoteButtons) do
		btnData.Button:Destroy()
	end
	remoteButtons = {}

	local browsedButtonOffset = 10
	local visibleCount = 0

	-- Ordena por quantidade de chamadas (mais ativos primeiro)
	local sortedCaptured = {}
	for path, data in pairs(capturedRemotes) do
		table.insert(sortedCaptured, data)
	end
	table.sort(sortedCaptured, function(a, b)
		return a.Count > b.Count
	end)

	for _, remoteData in ipairs(sortedCaptured) do
		local bButton = clone(RemoteButton2)
		bButton.Parent = RemoteBrowserFrame
		bButton.Visible = true
		bButton.Position = UDim2.new(0, 17, 0, browsedButtonOffset)

		-- Mostra nome + contador de chamadas
		local displayName = remoteData.Instance.Name
		if remoteData.Count > 1 then
			displayName = displayName .. " [" .. remoteData.Count .. "x]"
		end
		bButton.RemoteName2.Text = displayName
		bButton.RemoteName2.TextColor3 = Color3.fromRGB(46, 213, 115) -- Verde para indicar ativo

		if remoteData.Type == "RemoteEvent" then
			bButton.RemoteIcon2.Image = eventImage
		else
			bButton.RemoteIcon2.Image = functionImage
		end

		local connection = bButton.MouseButton1Click:Connect(function()
			-- Copia o código com os argumentos da última chamada
			local argsStr = ""
			if remoteData.LastArgs and #remoteData.LastArgs > 0 then
				local argParts = {}
				for i, arg in ipairs(remoteData.LastArgs) do
					local argType = typeof(arg)
					if argType == "string" then
						table.insert(argParts, '"' .. arg:gsub('"', '\\"') .. '"')
					elseif argType == "number" or argType == "boolean" then
						table.insert(argParts, tostring(arg))
					elseif argType == "Instance" then
						table.insert(argParts, GetFullPathOfAnInstance(arg))
					elseif argType == "Vector3" then
						table.insert(argParts, "Vector3.new(" .. tostring(arg) .. ")")
					elseif argType == "CFrame" then
						table.insert(argParts, "CFrame.new(" .. tostring(arg) .. ")")
					elseif argType == "Color3" then
						table.insert(argParts, "Color3.fromRGB(" .. math.floor(arg.R * 255) .. ", " .. math.floor(arg.G * 255) .. ", " .. math.floor(arg.B * 255) .. ")")
					elseif argType == "table" then
						table.insert(argParts, "{}")
					else
						table.insert(argParts, tostring(arg))
					end
				end
				argsStr = table.concat(argParts, ", ")
			end

			local fullCode = remoteData.Path .. remoteData.FireFunction:gsub("%(%)", "(" .. argsStr .. ")")
			setclipboard(fullCode)
		end)

		table.insert(browsedConnections, connection)
		table.insert(remoteButtons, {Button = bButton, Type = remoteData.Type})

		browsedButtonOffset = browsedButtonOffset + 35
		visibleCount = visibleCount + 1
	end

	if visibleCount > 7 then
		RemoteBrowserFrame.CanvasSize = UDim2.new(0, 0, 0, 256 + (visibleCount - 7) * 35)
	else
		RemoteBrowserFrame.CanvasSize = UDim2.new(0, 0, 0, 257)
	end

	-- Atualiza contador
	if visibleCount > 0 then
		CaptureCountLabel.Text = "Capturados: " .. visibleCount
	else
		CaptureCountLabel.Text = "Aguardando eventos..."
	end
end

-- NOVO: Função para fazer hook em um RemoteEvent
local function hookRemoteEvent(instance)
	if hookedInstances[instance] then return end
	hookedInstances[instance] = true

	local success, original = pcall(function()
		return instance.FireServer
	end)

	if success and original then
		originalFireServer[instance] = original
		instance.FireServer = function(self, ...)
			if self == instance then
				local path = GetFullPathOfAnInstance(instance)
				if not capturedRemotes[path] then
					capturedRemotes[path] = {
						Instance = instance,
						Type = "RemoteEvent",
						Path = path,
						FireFunction = ":FireServer()",
						Count = 0,
						LastArgs = {...}
					}
				end
				capturedRemotes[path].Count = capturedRemotes[path].Count + 1
				capturedRemotes[path].LastArgs = {...}
				capturedRemotes[path].LastTime = tick()
			end
			return original(self, ...)
		end
	end
end

-- NOVO: Função para fazer hook em um RemoteFunction
local function hookRemoteFunction(instance)
	if hookedInstances[instance] then return end
	hookedInstances[instance] = true

	local success, original = pcall(function()
		return instance.InvokeServer
	end)

	if success and original then
		originalInvokeServer[instance] = original
		instance.InvokeServer = function(self, ...)
			if self == instance then
				local path = GetFullPathOfAnInstance(instance)
				if not capturedRemotes[path] then
					capturedRemotes[path] = {
						Instance = instance,
						Type = "RemoteFunction",
						Path = path,
						FireFunction = ":InvokeServer()",
						Count = 0,
						LastArgs = {...}
					}
				end
				capturedRemotes[path].Count = capturedRemotes[path].Count + 1
				capturedRemotes[path].LastArgs = {...}
				capturedRemotes[path].LastTime = tick()
			end
			return original(self, ...)
		end
	end
end

-- NOVO: Função para iniciar/parar captura
local function toggleCapture()
	isCapturing = not isCapturing

	if isCapturing then
		-- Inicia captura
		CaptureButton.BackgroundColor3 = colorSettings["CaptureButton"]["RecordingBg"]
		CaptureButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		CaptureButton.Text = "STOP"

		SearchBox.Visible = false
		CaptureCountLabel.Visible = true
		CaptureCountLabel.Text = "Aguardando eventos..."

		-- Limpa TUDO - começa do zero!
		capturedRemotes = {}
		hookedInstances = {}

		-- Hook nos RemoteEvents/RemoteFunctions existentes (mas NÃO mostra na lista ainda)
		for _, remoteData in ipairs(allRemotes) do
			local instance = remoteData.Instance
			if remoteData.Type == "RemoteEvent" then
				hookRemoteEvent(instance)
			else
				hookRemoteFunction(instance)
			end
		end

		-- Hook em novos RemoteEvents/RemoteFunctions que forem criados
		local descendantAddedConnection = game.DescendantAdded:Connect(function(descendant)
			if isA(descendant, "RemoteEvent") then
				-- Adiciona à lista geral
				table.insert(allRemotes, {
					Instance = descendant,
					Type = "RemoteEvent",
					Path = GetFullPathOfAnInstance(descendant),
					FireFunction = ":FireServer()"
				})
				-- Hook automaticamente (mas só aparece quando for chamado)
				hookRemoteEvent(descendant)

			elseif isA(descendant, "RemoteFunction") then
				-- Adiciona à lista geral
				table.insert(allRemotes, {
					Instance = descendant,
					Type = "RemoteFunction",
					Path = GetFullPathOfAnInstance(descendant),
					FireFunction = ":InvokeServer()"
				})
				-- Hook automaticamente (mas só aparece quando for chamado)
				hookRemoteFunction(descendant)
			end
		end)
		table.insert(captureConnections, descendantAddedConnection)

		-- Atualiza a lista em tempo real
		captureRenderConnection = game:GetService("RunService").Heartbeat:Connect(function()
			renderCaptureButtons()
		end)

	else
		-- Para captura
		CaptureButton.BackgroundColor3 = colorSettings["CaptureButton"]["InactiveBg"]
		CaptureButton.TextColor3 = colorSettings["CaptureButton"]["InactiveText"]
		CaptureButton.Text = "REC"

		SearchBox.Visible = true
		CaptureCountLabel.Visible = false

		-- Restaura funções originais
		for instance, original in pairs(originalFireServer) do
			pcall(function()
				instance.FireServer = original
			end)
		end
		originalFireServer = {}

		for instance, original in pairs(originalInvokeServer) do
			pcall(function()
				instance.InvokeServer = original
			end)
		end
		originalInvokeServer = {}

		-- Desconecta conexões
		for _, conn in ipairs(captureConnections) do
			pcall(function()
				conn:Disconnect()
			end)
		end
		captureConnections = {}

		if captureRenderConnection then
			captureRenderConnection:Disconnect()
			captureRenderConnection = nil
		end

		-- Limpa capturas
		capturedRemotes = {}
		hookedInstances = {}

		-- Volta para o modo normal
		renderButtons()
	end
end

FilterAllButton.MouseButton1Click:Connect(function()
	if isCapturing then return end
	currentFilter = "All"
	updateFilterButtons()
	renderButtons()
end)

FilterEventButton.MouseButton1Click:Connect(function()
	if isCapturing then return end
	currentFilter = "Event"
	updateFilterButtons()
	renderButtons()
end)

FilterFunctionButton.MouseButton1Click:Connect(function()
	if isCapturing then return end
	currentFilter = "Function"
	updateFilterButtons()
	renderButtons()
end)

-- NOVO: Conexão do botão de captura
CaptureButton.MouseButton1Click:Connect(function()
	toggleCapture()
end)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	if isCapturing then return end
	currentSearch = SearchBox.Text
	renderButtons()
end)

for i, v in pairs(game:GetDescendants()) do
	if isA(v, "RemoteEvent") or isA(v, "RemoteFunction") then
		local remoteType = isA(v, "RemoteEvent") and "RemoteEvent" or "RemoteFunction"
		local fireFunction = isA(v, "RemoteEvent") and ":FireServer()" or ":InvokeServer()"

		table.insert(allRemotes, {
			Instance = v,
			Type = remoteType,
			Path = GetFullPathOfAnInstance(v),
			FireFunction = fireFunction
		})
	end
end

renderButtons()
