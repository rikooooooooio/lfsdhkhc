--[[
    Script Universal com Aimbot, Aimlock e ESP
    UI com Fluent Library
]]

-- ==================== CARREGAR FLUENT ====================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ==================== SERVIÇOS ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==================== CONFIGURAÇÕES ====================
local settings = {
    aimbot = {
        enabled = false,
        smoothness = 10,
        fov = 200,
        targetPart = "Head",
        keybind = nil,
    },
    aimlock = {
        enabled = false,
        lockKey = "Q",
        maxDistance = 100,
    },
    esp = {
        enabled = false,
        showBox = true,
        showName = true,
        showHealth = true,
        showDistance = true,
        teamColor = true,
        onlyEnemies = false,
    }
}

-- ==================== VARIÁVEIS ====================
local aimlockTarget = nil
local isAimlocking = false
local espBillboards = {}
local espHighlights = {}

-- ==================== FUNÇÕES AUXILIARES ====================
local function isEnemy(player)
    if player == LocalPlayer then return false end
    if settings.esp.onlyEnemies then
        return LocalPlayer.Team ~= player.Team
    end
    return true
end

local function getCharacterPart(character, partName)
    if not character then return nil end
    return character:FindFirstChild(partName)
end

local function getTargetPart(character)
    return getCharacterPart(character, settings.aimbot.targetPart) or
           getCharacterPart(character, "UpperTorso") or
           getCharacterPart(character, "HumanoidRootPart") or
           (character:FindFirstChildWhichIsA("BasePart"))
end

-- ==================== AIMBOT ====================
local function getClosestPlayerToCrosshair()
    local closestDistance = settings.aimbot.fov
    local closestPlayer = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local targetPart = getTargetPart(player.Character)
            if targetPart then
                local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function smoothCameraLookAt(targetPosition, smoothness)
    if not targetPosition then return end
    local currentCFrame = Camera.CFrame
    local targetCFrame = CFrame.new(currentCFrame.Position, targetPosition)
    local newCFrame = currentCFrame:Lerp(targetCFrame, 1 / smoothness)
    Camera.CFrame = newCFrame
end

-- ==================== AIMLOCK ====================
local function getNearestPlayerInRange()
    local nearest = nil
    local minDist = settings.aimlock.maxDistance
    local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not playerPos then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (root.Position - playerPos).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = player
                end
            end
        end
    end
    return nearest
end

-- ==================== ESP ====================
local function createESP(player)
    if espBillboards[player] then return end

    local character = player.Character
    if not character then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_GUI"
    billboard.Adornee = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    billboard.Size = UDim2.new(0, 4, 0, 4)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 300
    billboard.Enabled = true

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 140, 0, 60)
    mainFrame.BackgroundTransparency = 0.4
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    mainFrame.Parent = billboard

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = mainFrame

    local healthBarBg = Instance.new("Frame")
    healthBarBg.Name = "HealthBarBg"
    healthBarBg.Size = UDim2.new(1, -4, 0, 6)
    healthBarBg.Position = UDim2.new(0, 2, 0, 22)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    healthBarBg.BorderSizePixel = 0
    healthBarBg.Parent = mainFrame

    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBarBg

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistanceLabel"
    distLabel.Size = UDim2.new(1, 0, 0, 16)
    distLabel.Position = UDim2.new(0, 0, 0, 32)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.TextSize = 12
    distLabel.Parent = mainFrame

    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "BoxFrame"
    boxFrame.Size = UDim2.new(1, 0, 1, 0)
    boxFrame.BackgroundTransparency = 0.8
    boxFrame.BorderSizePixel = 2
    boxFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    boxFrame.Parent = mainFrame

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    espBillboards[player] = billboard
    espHighlights[player] = highlight
    billboard.Parent = character
end

local function updateESP()
    for player, billboard in pairs(espBillboards) do
        local character = player.Character
        if not character or not isEnemy(player) then
            if billboard then billboard:Destroy() end
            if espHighlights[player] then espHighlights[player]:Destroy() end
            espBillboards[player] = nil
            espHighlights[player] = nil
        else
            local mainFrame = billboard:FindFirstChild("MainFrame")
            if mainFrame then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local healthBarBg = mainFrame:FindFirstChild("HealthBarBg")
                    if healthBarBg then
                        local healthBar = healthBarBg:FindFirstChild("HealthBar")
                        if healthBar then
                            healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
                            healthBar.BackgroundColor3 = Color3.fromRGB(255 - 255 * healthPercent, 255 * healthPercent, 0)
                        end
                    end

                    if settings.esp.showDistance then
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        local distLabel = mainFrame:FindFirstChild("DistanceLabel")
                        if rootPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and distLabel then
                            local dist = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            distLabel.Text = math.floor(dist) .. "m"
                            distLabel.Visible = true
                        elseif distLabel then
                            distLabel.Visible = false
                        end
                    else
                        local distLabel = mainFrame:FindFirstChild("DistanceLabel")
                        if distLabel then distLabel.Visible = false end
                    end

                    if settings.esp.teamColor and LocalPlayer.Team and player.Team then
                        local boxFrame = mainFrame:FindFirstChild("BoxFrame")
                        local nameLabel = mainFrame:FindFirstChild("NameLabel")
                        if LocalPlayer.Team == player.Team then
                            if boxFrame then boxFrame.BorderColor3 = Color3.fromRGB(0, 0, 255) end
                            if nameLabel then nameLabel.TextColor3 = Color3.fromRGB(0, 0, 255) end
                            if espHighlights[player] then espHighlights[player].OutlineColor = Color3.fromRGB(0, 0, 255) end
                        else
                            if boxFrame then boxFrame.BorderColor3 = Color3.fromRGB(255, 0, 0) end
                            if nameLabel then nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0) end
                            if espHighlights[player] then espHighlights[player].OutlineColor = Color3.fromRGB(255, 0, 0) end
                        end
                    else
                        local boxFrame = mainFrame:FindFirstChild("BoxFrame")
                        local nameLabel = mainFrame:FindFirstChild("NameLabel")
                        if boxFrame then boxFrame.BorderColor3 = Color3.fromRGB(255, 255, 255) end
                        if nameLabel then nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255) end
                        if espHighlights[player] then espHighlights[player].OutlineColor = Color3.fromRGB(255, 255, 255) end
                    end

                    local boxFrame = mainFrame:FindFirstChild("BoxFrame")
                    local nameLabel = mainFrame:FindFirstChild("NameLabel")
                    local healthBarBg = mainFrame:FindFirstChild("HealthBarBg")
                    if boxFrame then boxFrame.Visible = settings.esp.showBox end
                    if nameLabel then nameLabel.Visible = settings.esp.showName end
                    if healthBarBg then healthBarBg.Visible = settings.esp.showHealth end
                    if espHighlights[player] then espHighlights[player].Enabled = settings.esp.showBox end
                end
            end
            billboard.Enabled = settings.esp.enabled
        end
    end
end

-- ==================== DETECTAR NOVOS JOGADORES ====================
local function onCharacterAdded(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if isEnemy(player) and settings.esp.enabled then
            createESP(player)
        end
    end)
    if player.Character and isEnemy(player) and settings.esp.enabled then
        createESP(player)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        onCharacterAdded(player)
    end
end

Players.PlayerAdded:Connect(onCharacterAdded)
Players.PlayerRemoving:Connect(function(player)
    if espBillboards[player] then
        espBillboards[player]:Destroy()
        espBillboards[player] = nil
    end
    if espHighlights[player] then
        espHighlights[player]:Destroy()
        espHighlights[player] = nil
    end
end)

-- ==================== LOOP PRINCIPAL ====================
RunService.RenderStepped:Connect(function()
    if settings.esp.enabled then
        updateESP()
    else
        for _, billboard in pairs(espBillboards) do
            if billboard then billboard.Enabled = false end
        end
        for _, highlight in pairs(espHighlights) do
            if highlight then highlight.Enabled = false end
        end
    end

    if settings.aimlock.enabled and UserInputService:IsKeyDown(Enum.KeyCode[settings.aimlock.lockKey]) then
        if not isAimlocking then
            aimlockTarget = getNearestPlayerInRange()
            isAimlocking = true
        end
        if aimlockTarget and aimlockTarget.Character then
            local part = getTargetPart(aimlockTarget.Character)
            if part then
                smoothCameraLookAt(part.Position, settings.aimbot.smoothness)
            end
        end
    else
        isAimlocking = false
        aimlockTarget = nil
    end

    if settings.aimbot.enabled and not isAimlocking then
        if not settings.aimbot.keybind or UserInputService:IsKeyDown(Enum.KeyCode[settings.aimbot.keybind]) then
            local targetPlayer = getClosestPlayerToCrosshair()
            if targetPlayer and targetPlayer.Character then
                local part = getTargetPart(targetPlayer.Character)
                if part then
                    smoothCameraLookAt(part.Position, settings.aimbot.smoothness)
                end
            end
        end
    end
end)

-- ==================== UI COM FLUENT ====================
local Window = Fluent:CreateWindow({
    Title = "Universal Tool " .. Fluent.Version,
    SubTitle = "Aimbot | Aimlock | ESP",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 480),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Criar abas
local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
    Aimlock = Window:AddTab({ Title = "Aimlock", Icon = "lock" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" })
}

-- Carregar SaveManager e InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Aimbot)
InterfaceManager:BuildInterfaceSection(Tabs.Aimlock)
InterfaceManager:BuildInterfaceSection(Tabs.ESP)
SaveManager:BuildConfigSection(Tabs.Aimbot)
SaveManager:BuildConfigSection(Tabs.Aimlock)
SaveManager:BuildConfigSection(Tabs.ESP)

-- ==================== ABA AIMBOT ====================
local aimbotSection = Tabs.Aimbot:AddSection("Configurações do Aimbot")

local aimbotToggle = Tabs.Aimbot:AddToggle("AimbotEnabled", {
    Title = "Ativar Aimbot",
    Description = "Ativa o sistema de mira automática",
    Default = false,
    Callback = function(value)
        settings.aimbot.enabled = value
    end
})

local smoothnessSlider = Tabs.Aimbot:AddSlider("AimbotSmoothness", {
    Title = "Suavidade",
    Description = "Define a suavidade da mira (1 = instantâneo, 50 = muito suave)",
    Default = 10,
    Min = 1,
    Max = 50,
    Rounding = 1,
    Callback = function(value)
        settings.aimbot.smoothness = value
    end
})

local fovSlider = Tabs.Aimbot:AddSlider("AimbotFOV", {
    Title = "Campo de visão (FOV)",
    Description = "Define o raio de detecção dos alvos em pixels",
    Default = 200,
    Min = 50,
    Max = 500,
    Rounding = 1,
    Callback = function(value)
        settings.aimbot.fov = value
    end
})

local targetPartDropdown = Tabs.Aimbot:AddDropdown("AimbotTargetPart", {
    Title = "Parte do corpo",
    Description = "Seleciona a parte do corpo onde o aimbot mira",
    Values = {"Head", "UpperTorso", "HumanoidRootPart"},
    Default = 1,
    Multi = false,
    Callback = function(value)
        settings.aimbot.targetPart = value
    end
})

local aimbotKeybind = Tabs.Aimbot:AddKeybind("AimbotKeybind", {
    Title = "Tecla de ativação",
    Description = "Tecla para ativar o aimbot (deixe vazio para sempre ativo)",
    Mode = "Hold",
    Default = "None",
    Callback = function(value)
        if value then
            -- Tecla pressionada
        end
    end,
    ChangedCallback = function(newKey)
        if newKey == "None" then
            settings.aimbot.keybind = nil
        else
            settings.aimbot.keybind = newKey
        end
    end
})

-- ==================== ABA AIMLOCK ====================
local aimlockSection = Tabs.Aimlock:AddSection("Configurações do Aimlock")

local aimlockToggle = Tabs.Aimlock:AddToggle("AimlockEnabled", {
    Title = "Ativar Aimlock",
    Description = "Ativa o sistema de travamento de mira",
    Default = false,
    Callback = function(value)
        settings.aimlock.enabled = value
    end
})

local distanceSlider = Tabs.Aimlock:AddSlider("AimlockDistance", {
    Title = "Distância máxima",
    Description = "Distância máxima para detectar alvos (estuds)",
    Default = 100,
    Min = 50,
    Max = 300,
    Rounding = 1,
    Callback = function(value)
        settings.aimlock.maxDistance = value
    end
})

local aimlockKeybind = Tabs.Aimlock:AddKeybind("AimlockKeybind", {
    Title = "Tecla de ativação",
    Description = "Tecla para travar no alvo (segurar)",
    Mode = "Hold",
    Default = "Q",
    Callback = function(value)
        if value then
            -- Tecla pressionada
        end
    end,
    ChangedCallback = function(newKey)
        settings.aimlock.lockKey = newKey
    end
})

-- ==================== ABA ESP ====================
local espSection = Tabs.ESP:AddSection("Configurações do ESP")

local espToggle = Tabs.ESP:AddToggle("ESPEnabled", {
    Title = "Ativar ESP",
    Description = "Ativa todas as funções do ESP",
    Default = false,
    Callback = function(value)
        settings.esp.enabled = value
        if value then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and isEnemy(player) then
                    createESP(player)
                end
            end
        else
            for _, billboard in pairs(espBillboards) do
                if billboard then billboard:Destroy() end
            end
            for _, highlight in pairs(espHighlights) do
                if highlight then highlight:Destroy() end
            end
            espBillboards = {}
            espHighlights = {}
        end
    end
})

local boxToggle = Tabs.ESP:AddToggle("ESPBox", {
    Title = "Mostrar Caixa (Box)",
    Description = "Exibe um contorno colorido ao redor do jogador",
    Default = true,
    Callback = function(value)
        settings.esp.showBox = value
    end
})

local nameToggle = Tabs.ESP:AddToggle("ESPName", {
    Title = "Mostrar Nome",
    Description = "Exibe o nome do jogador acima do personagem",
    Default = true,
    Callback = function(value)
        settings.esp.showName = value
    end
})

local healthToggle = Tabs.ESP:AddToggle("ESPHealth", {
    Title = "Mostrar Vida",
    Description = "Exibe a barra de vida do jogador",
    Default = true,
    Callback = function(value)
        settings.esp.showHealth = value
    end
})

local distanceToggle = Tabs.ESP:AddToggle("ESPDistance", {
    Title = "Mostrar Distância",
    Description = "Exibe a distância até o jogador",
    Default = true,
    Callback = function(value)
        settings.esp.showDistance = value
    end
})

local teamColorToggle = Tabs.ESP:AddToggle("ESPTeamColor", {
    Title = "Cor por Time",
    Description = "Aliados aparecem em azul, inimigos em vermelho",
    Default = true,
    Callback = function(value)
        settings.esp.teamColor = value
    end
})

local onlyEnemiesToggle = Tabs.ESP:AddToggle("ESPOnlyEnemies", {
    Title = "Apenas Inimigos",
    Description = "Mostra ESP apenas para jogadores de times opostos",
    Default = false,
    Callback = function(value)
        settings.esp.onlyEnemies = value
        for _, billboard in pairs(espBillboards) do
            if billboard then billboard:Destroy() end
        end
        for _, highlight in pairs(espHighlights) do
            if highlight then highlight:Destroy() end
        end
        espBillboards = {}
        espHighlights = {}
        if settings.esp.enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and isEnemy(player) then
                    createESP(player)
                end
            end
        end
    end
})

-- ==================== NOTIFICAÇÃO INICIAL ====================
Fluent:Notify({
    Title = "Universal Tool",
    Content = "Script carregado com sucesso!",
    SubContent = "Use a interface para configurar",
    Duration = 5
})

-- ==================== CARREGAR CONFIGURAÇÕES ====================
SaveManager:LoadAutoloadConfig()
Window:SelectTab(1)
