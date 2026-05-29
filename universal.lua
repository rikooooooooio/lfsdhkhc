--[[
    Script Universal com Rayfield UI, Aimbot, Aimlock e ESP
    Totalmente configurável e com correções de bugs
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Carregamento seguro do Rayfield
local Rayfield
local success, result = pcall(function()
    local url = "https://sirius.menu/rayfield"
    local code = game:HttpGet(url)
    return loadstring(code)
end)

if success and result then
    Rayfield = result()
else
    -- Fallback: notificação de erro e encerra
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Erro",
        Text = "Falha ao carregar Rayfield. Verifique sua conexão.",
        Duration = 5
    })
    return
end

-- Se chegou aqui, Rayfield está carregado. Continue o script normalmente...

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

-- ==================== VARIÁVEIS GLOBAIS ====================
local aimlockTarget = nil
local isAimlocking = false
local espHighlights = {}  -- Armazena os Highlights de cada jogador
local espBillboards = {}   -- Armazena os BillboardGuis de cada jogador

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
    local cameraCFrame = Camera.CFrame
    local cameraForward = cameraCFrame.LookVector

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local targetPart = getTargetPart(player.Character)
            if targetPart then
                local targetPos = targetPart.Position
                local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPos)
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

-- ==================== ESP (CORRIGIDO) ====================
local function createESP(player)
    if espHighlights[player] then return end

    local character = player.Character
    if not character then return end

    -- Criar BillboardGui para informações
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_GUI"
    billboard.Adornee = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    billboard.Size = UDim2.new(0, 4, 0, 4)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 300
    billboard.Enabled = true  -- Garantir que está ativo

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 140, 0, 60)
    mainFrame.BackgroundTransparency = 0.4
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    mainFrame.Parent = billboard

    -- Nome
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = mainFrame

    -- Barra de vida
    local healthBarBg = Instance.new("Frame")
    healthBarBg.Size = UDim2.new(1, -4, 0, 6)
    healthBarBg.Position = UDim2.new(0, 2, 0, 22)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    healthBarBg.BorderSizePixel = 0
    healthBarBg.Parent = mainFrame

    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBarBg

    -- Distância
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0, 16)
    distLabel.Position = UDim2.new(0, 0, 0, 32)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.TextSize = 12
    distLabel.Parent = mainFrame

    -- Caixa (box) usando um Frame
    local boxFrame = Instance.new("Frame")
    boxFrame.Size = UDim2.new(1, 0, 1, 0)
    boxFrame.BackgroundTransparency = 0.8
    boxFrame.BorderSizePixel = 2
    boxFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    boxFrame.Parent = mainFrame

    -- Criar Highlight para o outline do personagem
    local highlight = Instance.new("Highlight")
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
            -- Atualizar Billboard
            local mainFrame = billboard:FindFirstChild("Frame")
            if mainFrame then
                local humanoid = character:FindFirstChild("Humanoid")
                
    else
        for _, billboard in pairs(espBillboards) do
            if billboard then billboard.Enabled = false end
        end
        for _, highlight in pairs(espHighlights) do
            if highlight then highlight.Enabled = false end
        end
    end
    
    -- Aimlock (tecla Q)
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
    
    -- Aimbot livre
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

-- ==================== UI COM RAYFIELD ====================
local Window = Rayfield:CreateWindow({
    Name = "Universal Tool v2.0",
    LoadingTitle = "Carregando...",
    LoadingSubtitle = "by SeuNome",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "UniversalToolConfig"
    },
    KeySystem = false,
    KeySettings = {
        Key = "Key",
        LoadKey = function() end
    }
})

-- Aba Aimbot
local AimbotTab = Window:CreateTab("🎯 Aimbot", 0)

local AimbotSection = AimbotTab:CreateSection("Configurações do Aimbot")

local AimbotToggle = AimbotTab:CreateToggle({
    Name = "Ativar Aimbot",
    CurrentValue = false,
    Flag = "AimbotEnabled",
    Callback = function(Value)
        settings.aimbot.enabled = Value
    end
})

local SmoothnessSlider = AimbotTab:CreateSlider({
    Name = "Suavidade (Smoothing)",
    Range = {1, 50},
    Increment = 1,
    Suffix = "",
    CurrentValue = 10,
    Flag = "AimbotSmoothness",
    Callback = function(Value)
        settings.aimbot.smoothness = Value
    end
})

local FOVSlider = AimbotTab:CreateSlider({
    Name = "Campo de visão (FOV)",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 200,
    Flag = "AimbotFOV",
    Callback = function(Value)
        settings.aimbot.fov = Value
    end
})

local TargetPartDropdown = AimbotTab:CreateDropdown({
    Name = "Parte do corpo",
    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    Flag = "AimbotTargetPart",
    Callback = function(Option)
        settings.aimbot.targetPart = Option[1]
    end
})

local KeybindInput = AimbotTab:CreateInput({
    Name = "Tecla de ativação (deixe vazio para sempre ativo)",
    PlaceholderText = "Ex: Q, E, R, None",
    CurrentValue = "",
    Flag = "AimbotKeybind",
    Callback = function(Text)
        if Text == "" or Text:lower() == "none" then
            settings.aimbot.keybind = nil
        else
            settings.aimbot.keybind = Text:upper()
        end
    end
})

-- Aba Aimlock
local AimlockTab = Window:CreateTab("🔒 Aimlock", 1)

local AimlockSection = AimlockTab:CreateSection("Configurações do Aimlock")

local AimlockToggle = AimlockTab:CreateToggle({
    Name = "Ativar Aimlock",
    CurrentValue = false,
    Flag = "AimlockEnabled",
    Callback = function(Value)
        settings.aimlock.enabled = Value
    end
})

local DistanceSlider = AimlockTab:CreateSlider({
    Name = "Distância máxima",
    Range = {50, 300},
    Increment = 10,
    Suffix = "estuds",
    CurrentValue = 100,
    Flag = "AimlockDistance",
    Callback = function(Value)
        settings.aimlock.maxDistance = Value
    end
})

local KeybindInput2 = AimlockTab:CreateInput({
    Name = "Tecla de ativação (padrão: Q)",
    PlaceholderText = "Ex: Q, E, R",
    CurrentValue = "Q",
    Flag = "AimlockKeybind",
    Callback = function(Text)
        if Text ~= "" then
            settings.aimlock.lockKey = Text:upper()
        end
    end
})

-- Aba ESP
local ESPTab = Window:CreateTab("👁️ ESP", 2)

local ESPSection = ESPTab:CreateSection("Configurações do ESP")

local ESPToggle = ESPTab:CreateToggle({
    Name = "Ativar ESP",
    CurrentValue = false,
    Flag = "ESPEnabled",
    Callback = function(Value)
        settings.esp.enabled = Value
        if Value then
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

local BoxToggle = ESPTab:CreateToggle({
    Name = "Mostrar Caixa (Box)",
    CurrentValue = true,
    Flag = "ESPBox",
    Callback = function(Value)
        settings.esp.showBox = Value
    end
})

local NameToggle = ESPTab:CreateToggle({
    Name = "Mostrar Nome",
    CurrentValue = true,
    Flag = "ESPName",
    Callback = function(Value)
        settings.esp.showName = Value
    end
})

local HealthToggle = ESPTab:CreateToggle({
    Name = "Mostrar Vida",
    CurrentValue = true,
    Flag = "ESPHealth",
    Callback = function(Value)
        settings.esp.showHealth = Value
    end
})

local DistanceToggle = ESPTab:CreateToggle({
    Name = "Mostrar Distância",
    CurrentValue = true,
    Flag = "ESPDistance",
    Callback = function(Value)
        settings.esp.showDistance = Value
    end
})

local TeamColorToggle = ESPTab:CreateToggle({
    Name = "Cor por Time",
    CurrentValue = true,
    Flag = "ESPTeamColor",
    Callback = function(Value)
        settings.esp.teamColor = Value
    end
})

local OnlyEnemiesToggle = ESPTab:CreateToggle({
    Name = "Apenas Inimigos",
    CurrentValue = false,
    Flag = "ESPOnlyEnemies",
    Callback = function(Value)
        settings.esp.onlyEnemies = Value
        -- Recriar ESP
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

-- Notificação de carregamento
Rayfield:Notify({
    Title = "Script Carregado",
    Content = "Todas as funcionalidades estão ativas!",
    Duration = 3,
})

-- Carregar configurações salvas
Rayfield:LoadConfiguration()
