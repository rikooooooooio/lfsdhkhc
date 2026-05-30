--[[
    Universal Tool - WindUI
    Funcionalidades: Aimbot configurável, ESP (Box + Nome)
    Interface moderna com a biblioteca WindUI
]]

-- Carregar a biblioteca WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Inicializar serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==================== CONFIGURAÇÕES ====================
local settings = {
    aimbot = {
        enabled = false,
        smoothness = 10,     -- 1 = instantâneo, 50 = muito suave
        fov = 200,           -- raio de detecção em pixels
        targetPart = "Head", -- "Head", "UpperTorso", "HumanoidRootPart"
        keybind = nil,       -- tecla opcional (nil = sempre ativo)
    },
    esp = {
        showBox = true,      -- caixa ao redor do personagem
        showName = true,     -- nome acima da cabeça
        teamColor = true,    -- cores por time (aliado azul / inimigo vermelho)
        onlyEnemies = false, -- mostrar apenas inimigos
    }
}

-- ==================== VARIÁVEIS GLOBAIS ====================
local espHighlights = {}    -- armazena caixas (Highlight)
local espNameLabels = {}    -- armazena nomes (BillboardGui)

-- ==================== FUNÇÕES AUXILIARES ====================
local function isEnemy(player)
    if player == LocalPlayer then return false end
    if settings.esp.onlyEnemies then
        return LocalPlayer.Team ~= player.Team
    end
    return true
end

local function getCharacterPart(character, partName)
    return character and character:FindFirstChild(partName)
end

local function getTargetPart(character)
    return getCharacterPart(character, settings.aimbot.targetPart) or
           getCharacterPart(character, "UpperTorso") or
           getCharacterPart(character, "HumanoidRootPart") or
           (character and character:FindFirstChildWhichIsA("BasePart"))
end

-- ==================== AIMBOT ====================
local function getClosestPlayerToCrosshair()
    local closestDistance = tonumber(settings.aimbot.fov) or 200
    local closestPlayer = nil

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local targetPart = getTargetPart(player.Character)
            if targetPart then
                local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    -- Distância do centro da tela
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
    local smooth = tonumber(smoothness) or 10
    local current = Camera.CFrame
    local targetCF = CFrame.new(current.Position, targetPosition)
    Camera.CFrame = current:Lerp(targetCF, 1 / smooth)
end

-- ==================== ESP SIMPLIFICADO ====================
local function setupESP(player)
    if espHighlights[player] then return end
    local character = player.Character
    if not character then return end

    -- Caixa (Highlight) ao redor do personagem
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    -- Billboard para o nome
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    billboard.Size = UDim2.new(0, 4, 0, 4)
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 300

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 160, 0, 18)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.Parent = billboard

    espHighlights[player] = highlight
    espNameLabels[player] = nameLabel
    billboard.Parent = character
end

local function updateESP()
    for player, highlight in pairs(espHighlights) do
        local character = player.Character
        if not character or not isEnemy(player) then
            if highlight then highlight:Destroy() end
            local bill = character and character:FindFirstChild("ESP_Billboard")
            if bill then bill:Destroy() end
            espHighlights[player] = nil
            espNameLabels[player] = nil
        else
            -- Atualizar caixa
            highlight.Enabled = settings.esp.showBox
            if settings.esp.teamColor and LocalPlayer.Team and player.Team then
                highlight.OutlineColor = (LocalPlayer.Team == player.Team) and Color3.fromRGB(0, 0, 255) or Color3.fromRGB(255, 0, 0)
            else
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            end

            -- Atualizar nome
            local nameLabel = espNameLabels[player]
            if nameLabel then
                nameLabel.Visible = settings.esp.showName
                if settings.esp.teamColor and LocalPlayer.Team and player.Team then
                    nameLabel.TextColor3 = (LocalPlayer.Team == player.Team) and Color3.fromRGB(100, 100, 255) or Color3.fromRGB(255, 100, 100)
                else
                    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end
end

-- Inicializar ESP para jogadores já existentes e futuros
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if isEnemy(player) then setupESP(player) end
        end)
        if player.Character and isEnemy(player) then
            setupESP(player)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if isEnemy(player) then setupESP(player) end
    end)
    if player.Character and isEnemy(player) then
        setupESP(player)
    end
end)

-- ==================== LOOP PRINCIPAL ====================
RunService.RenderStepped:Connect(function()
    -- Atualizar ESP a cada frame
    updateESP()

    -- Aimbot (sem aimlock)
    if settings.aimbot.enabled then
        local key = settings.aimbot.keybind
        if not key or key == "None" or UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            local target = getClosestPlayerToCrosshair()
            if target and target.Character then
                local part = getTargetPart(target.Character)
                if part then
                    smoothCameraLookAt(part.Position, settings.aimbot.smoothness)
                end
            end
        end
    end
end)

-- ==================== INTERFACE WINDUI ====================
local Window = WindUI:CreateWindow({
    Title = "Universal Tool",
    Author = "by System",
    Folder = "UniversalTool",
    Icon = "target",
    Theme = "Dark",
    Size = UDim2.fromOffset(420, 380),
    MinSize = Vector2.new(380, 340),
    MaxSize = Vector2.new(600, 500),
    Resizable = true,
    ToggleKey = Enum.KeyCode.RightControl,
    HideSearchBar = true,
    SideBarWidth = 160,
})

-- Criar abas
local AimbotTab = Window:Tab({ Title = "Aimbot", Icon = "crosshair" })
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })

-- ==================== ABA AIMBOT ====================
AimbotTab:Section("Configurações do Aimbot")

-- Toggle para ativar/desativar
AimbotTab:Toggle({
    Title = "Ativar Aimbot",
    Icon = "target",
    Value = false,
    Callback = function(state)
        settings.aimbot.enabled = state
    end
})

-- Slider para suavidade
AimbotTab:Slider({
    Title = "Suavidade (Smoothing)",
    Icon = "gauge",
    Min = 1,
    Max = 50,
    Step = 1,
    Value = 10,
    Callback = function(value)
        settings.aimbot.smoothness = value
    end
})

-- Slider para campo de visão (FOV)
AimbotTab:Slider({
    Title = "Campo de visão (FOV)",
    Icon = "radius",
    Min = 50,
    Max = 400,
    Step = 10,
    Value = 200,
    Callback = function(value)
        settings.aimbot.fov = value
    end
})

-- Dropdown para selecionar parte do corpo
AimbotTab:Dropdown({
    Title = "Parte do corpo",
    Icon = "person-standing",
    Options = { "Head", "UpperTorso", "HumanoidRootPart" },
    Value = "Head",
    Callback = function(option)
        settings.aimbot.targetPart = option
    end
})

-- Keybind para tecla de ativação (opcional)
AimbotTab:Keybind({
    Title = "Tecla de ativação (opcional)",
    Icon = "key",
    Value = "None",
    Callback = function(key)
        if key == "None" then
            settings.aimbot.keybind = nil
        else
            settings.aimbot.keybind = key
        end
    end
})

-- ==================== ABA ESP ====================
ESPTab:Section("Elementos do ESP")

-- Toggle para caixa (box)
ESPTab:Toggle({
    Title = "Caixa (Box)",
    Icon = "bounding-box",
    Value = true,
    Callback = function(state)
        settings.esp.showBox = state
    end
})

-- Toggle para nome
ESPTab:Toggle({
    Title = "Nome",
    Icon = "text",
    Value = true,
    Callback = function(state)
        settings.esp.showName = state
    end
})

-- Toggle para cores por time
ESPTab:Toggle({
    Title = "Cor por time (Azul = Aliado | Vermelho = Inimigo)",
    Icon = "palette",
    Value = true,
    Callback = function(state)
        settings.esp.teamColor = state
    end
})

-- Toggle para mostrar apenas inimigos
ESPTab:Toggle({
    Title = "Apenas inimigos",
    Icon = "swords",
    Value = false,
    Callback = function(state)
        settings.esp.onlyEnemies = state
        -- Recriar ESP com a nova configuração
        for _, h in pairs(espHighlights) do if h then h:Destroy() end end
        for _, name in pairs(espNameLabels) do if name and name.Parent then name.Parent:Destroy() end end
        espHighlights = {}
        espNameLabels = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isEnemy(p) then setupESP(p) end
        end
    end
})

-- Botão para fechar a UI
ESPTab:Button({
    Title = "Fechar UI",
    Icon = "door-closed",
    Callback = function()
        Window:Destroy()
    end
})

-- ==================== NOTIFICAÇÃO ====================
WindUI:Popup({
    Title = "Universal Tool",
    Icon = "rocket",
    Content = "Script carregado com sucesso!\nAimbot e ESP estão prontos para uso.",
    Duration = 4
})
