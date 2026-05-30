--[[
    Universal Tool - WindUI (Versão Corrigida)
    Funcionalidades: Aimbot configurável, ESP (Box + Nome)
]]

-- Carregar WindUI com verificação de erro
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Erro", Text = "Falha ao carregar WindUI", Duration = 5
    })
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configurações
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

-- Variáveis
local espHighlights = {}
local espNameLabels = {}

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

-- Aimbot
local function getClosestPlayerToCrosshair()
    local closestDistance = tonumber(settings.aimbot.fov) or 200
    local closestPlayer = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local part = getTargetPart(player.Character)
            if part then
                local screenPoint, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
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

-- ESP
local function setupESP(player)
    if espHighlights[player] then return end
    local character = player.Character
    if not character then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

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
            highlight.Enabled = settings.esp.showBox
            if settings.esp.teamColor and LocalPlayer.Team and player.Team then
                highlight.OutlineColor = (LocalPlayer.Team == player.Team) and Color3.fromRGB(0, 0, 255) or Color3.fromRGB(255, 0, 0)
            else
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            end

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

-- Inicializar ESP
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

-- Loop principal
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

-- ==================== INTERFACE WINDUI (Sintaxe Corrigida) ====================
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
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Erro", Text = "Falha ao criar janela WindUI", Duration = 5 })
    return
end

-- Criar abas usando o método correto (strings simples, sem tabela)
-- Baseado na documentação: window:Tab("Title", "icon")
local AimbotTab = Window:Tab("Aimbot", "crosshair")
local ESPTab = Window:Tab("ESP", "eye")

-- Se as abas não forem criadas, tentar sintaxe alternativa
if not AimbotTab or not ESPTab then
    -- Fallback: usar método com tabela
    AimbotTab = Window:Tab({ Title = "Aimbot", Icon = "crosshair" })
    ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })
end

-- Aimbot
AimbotTab:Section("Configurações do Aimbot")

AimbotTab:Toggle({
    Title = "Ativar Aimbot",
    Icon = "target",
    Value = false,
    Callback = function(state) settings.aimbot.enabled = state end
})

AimbotTab:Slider({
    Title = "Suavidade",
    Icon = "gauge",
    Min = 1,
    Max = 50,
    Step = 1,
    Value = 10,
    Callback = function(v) settings.aimbot.smoothness = v end
})

AimbotTab:Slider({
    Title = "Campo de visão (FOV)",
    Icon = "radius",
    Min = 50,
    Max = 400,
    Step = 10,
    Value = 200,
    Callback = function(v) settings.aimbot.fov = v end
})

AimbotTab:Dropdown({
    Title = "Parte do corpo",
    Icon = "person-standing",
    Options = { "Head", "UpperTorso", "HumanoidRootPart" },
    Value = "Head",
    Callback = function(opt) settings.aimbot.targetPart = opt end
})

AimbotTab:Keybind({
    Title = "Tecla de ativação (opcional)",
    Icon = "key",
    Value = "None",
    Callback = function(key)
        if key == "None" then settings.aimbot.keybind = nil else settings.aimbot.keybind = key end
    end
})

-- ESP
ESPTab:Section("Elementos do ESP")

ESPTab:Toggle({
    Title = "Caixa (Box)",
    Icon = "bounding-box",
    Value = true,
    Callback = function(state) settings.esp.showBox = state end
})

ESPTab:Toggle({
    Title = "Nome",
    Icon = "text",
    Value = true,
    Callback = function(state) settings.esp.showName = state end
})

ESPTab:Toggle({
    Title = "Cor por time",
    Icon = "palette",
    Value = true,
    Callback = function(state) settings.esp.teamColor = state end
})

ESPTab:Toggle({
    Title = "Apenas inimigos",
    Icon = "swords",
    Value = false,
    Callback = function(state)
        settings.esp.onlyEnemies = state
        for _, h in pairs(espHighlights) do if h then h:Destroy() end end
        for _, name in pairs(espNameLabels) do if name and name.Parent then name.Parent:Destroy() end end
        espHighlights = {}
        espNameLabels = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isEnemy(p) then setupESP(p) end
        end
    end
})

ESPTab:Button({
    Title = "Fechar UI",
    Icon = "door-closed",
    Callback = function() Window:Destroy() end
})

-- Notificação
WindUI:Popup({
    Title = "Universal Tool",
    Icon = "rocket",
    Content = "Script carregado com sucesso!\nAimbot e ESP prontos.",
    Duration = 4
})
