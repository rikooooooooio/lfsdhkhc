--[[
    Universal Tool – WindUI (Corrigido)
    Aimbot Configurável | ESP (Box + Nome)
    Interface moderna e totalmente funcional.
]]

-- ==================== CARREGAR WINDUI ====================
local WindUI
local success, errorMsg = pcall(function()
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

-- Notificação de erro caso a biblioteca não carregue
if not success or not WindUI then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Erro",
        Text = "Falha ao carregar WindUI: " .. tostring(errorMsg),
        Duration = 5
    })
    return
end

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
    esp = {
        showBox = true,
        showName = true,
        teamColor = true,
        onlyEnemies = false,
    }
}

-- ==================== VARIÁVEIS ====================
local espHighlights = {}    -- Armazena os Highlights (Box)
local espNameLabels = {}    -- Armazena os BillboardGuis (Nome)

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
           getCharacterPart(character, "HumanoidRootPart")
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
    local currentCFrame = Camera.CFrame
    local targetCFrame = CFrame.new(currentCFrame.Position, targetPosition)
    Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / smooth)
end

-- ==================== ESP ====================
local function setupESP(player)
    if espHighlights[player] then return end

    local character = player.Character
    if not character then return end

    -- Caixa (Box) usando Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0.25
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
    nameLabel.TextStrokeTransparency = 0.25
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
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
local function initializePlayerESP(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if isEnemy(player) then setupESP(player) end
    end)
    if player.Character and isEnemy(player) then
        setupESP(player)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    initializePlayerESP(player)
end

Players.PlayerAdded:Connect(initializePlayerESP)

-- ==================== LOOP PRINCIPAL ====================
RunService.RenderStepped:Connect(function()
    updateESP()

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
    Author = "System",
    Folder = "UniversalTool",
    Icon = "target",
    Theme = "Dark",
    Size = UDim2.fromOffset(420, 380),
    Resizable = true,
    ToggleKey = Enum.KeyCode.RightControl,
    SideBarWidth = 150,
})

-- Verificar se a janela foi criada
if not Window then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Erro", Text = "Falha ao criar janela WindUI", Duration = 5
    })
    return
end

-- Criar abas
local AimbotTab = Window:Tab({ Title = "Aimbot", Icon = "crosshair" })
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })

-- ==================== ABA AIMBOT ====================
AimbotTab:Section({ Title = "Configurações do Aimbot" })

AimbotTab:Toggle({
    Title = "Ativar Aimbot",
    Icon = "target",
    Value = false,
    Callback = function(state)
        settings.aimbot.enabled = state
    end
})

AimbotTab:Slider({
    Title = "Suavidade",
    Icon = "gauge",
    Min = 1,
    Max = 50,
    Step = 1,
    Value = 10,
    Callback = function(value)
        settings.aimbot.smoothness = value
    end
})

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

AimbotTab:Dropdown({
    Title = "Parte do corpo",
    Icon = "person-standing",
    Values = { "Head", "UpperTorso", "HumanoidRootPart" },
    Value = "Head",
    Callback = function(option)
        settings.aimbot.targetPart = option
    end
})

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
ESPTab:Section({ Title = "Elementos do ESP" })

ESPTab:Toggle({
    Title = "Caixa (Box)",
    Icon = "bounding-box",
    Value = true,
    Callback = function(state)
        settings.esp.showBox = state
    end
})

ESPTab:Toggle({
    Title = "Nome",
    Icon = "text",
    Value = true,
    Callback = function(state)
        settings.esp.showName = state
    end
})

ESPTab:Toggle({
    Title = "Cor por time",
    Icon = "palette",
    Value = true,
    Callback = function(state)
        settings.esp.teamColor = state
    end
})

ESPTab:Toggle({
    Title = "Apenas inimigos",
    Icon = "swords",
    Value = false,
    Callback = function(state)
        settings.esp.onlyEnemies = state
        -- Recriar ESP com a nova configuração
        for _, h in pairs(espHighlights) do
            if h then h:Destroy() end
        end
        for _, name in pairs(espNameLabels) do
            if name and name.Parent then name.Parent:Destroy() end
        end
        espHighlights = {}
        espNameLabels = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isEnemy(p) then
                setupESP(p)
            end
        end
    end
})

ESPTab:Button({
    Title = "Fechar UI",
    Icon = "door-closed",
    Callback = function()
        Window:Destroy()
    end
})

-- ==================== NOTIFICAÇÃO ====================
WindUI:Notify({
    Title = "Universal Tool",
    Icon = "rocket",
    Content = "Script carregado com sucesso!\nAimbot e ESP estão prontos.",
    Duration = 4
})
