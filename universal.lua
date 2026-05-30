--[[
    Universal Tool v3.0
    Aimbot | Aimlock | ESP (Box, Nome, Vida) | Misc
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
        showBox = true,
        showName = true,
        showHealth = true,
        teamColor = true,
        onlyEnemies = false,
    }
}

-- ==================== VARIÁVEIS ====================
local aimlockTarget = nil
local isAimlocking = false
local espHighlights = {}  -- para o box (Highlight)
local espNameLabels = {}   -- para os nomes (BillboardGui)
local espHealthBars = {}   -- para as vidas (BillboardGui)

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
    local newCFrame = currentCFrame:Lerp(targetCFrame, 1 / smooth)
    Camera.CFrame = newCFrame
end

-- ==================== AIMLOCK ====================
local function getNearestPlayerInRange()
    local nearest = nil
    local minDist = tonumber(settings.aimlock.maxDistance) or 100
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

-- ==================== ESP (SIMPLIFICADO) ====================
-- Cria os elementos visuais para um jogador
local function setupESP(player)
    if espHighlights[player] then return end

    local character = player.Character
    if not character then return end

    -- Box: Highlight ao redor do personagem
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    -- Billboard para nome e vida
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    billboard.Size = UDim2.new(0, 4, 0, 4)
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 300

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 180, 0, 45)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = billboard

    -- Nome
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = mainFrame

    -- Fundo da barra de vida
    local healthBg = Instance.new("Frame")
    healthBg.Name = "HealthBg"
    healthBg.Size = UDim2.new(1, -20, 0, 6)
    healthBg.Position = UDim2.new(0, 10, 0, 22)
    healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    healthBg.BorderSizePixel = 0
    healthBg.Parent = mainFrame

    -- Barra de vida
    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBg

    espHighlights[player] = highlight
    espNameLabels[player] = nameLabel
    espHealthBars[player] = {bg = healthBg, bar = healthBar}
    billboard.Parent = character
end

-- Atualiza a aparência do ESP para todos os jogadores
local function updateESP()
    for player, highlight in pairs(espHighlights) do
        local character = player.Character
        if not character or not isEnemy(player) then
            -- Remove se o personagem não existe ou não é inimigo
            if highlight then highlight:Destroy() end
            local billboard = character and character:FindFirstChild("ESP_Billboard")
            if billboard then billboard:Destroy() end
            espHighlights[player] = nil
            espNameLabels[player] = nil
            espHealthBars[player] = nil
        else
            -- Atualiza o Highlight (Box)
            highlight.Enabled = settings.esp.showBox
            if settings.esp.teamColor and LocalPlayer.Team and player.Team then
                highlight.OutlineColor = (LocalPlayer.Team == player.Team) and Color3.fromRGB(0, 0, 255) or Color3.fromRGB(255, 0, 0)
            else
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            end

            -- Atualiza o nome
            local nameLabel = espNameLabels[player]
            if nameLabel then
                nameLabel.Visible = settings.esp.showName
                if settings.esp.teamColor and LocalPlayer.Team and player.Team then
                    nameLabel.TextColor3 = (LocalPlayer.Team == player.Team) and Color3.fromRGB(100, 100, 255) or Color3.fromRGB(255, 100, 100)
                else
                    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
            end

            -- Atualiza a barra de vida
            local health = espHealthBars[player]
            if health and health.bar and health.bg then
                health.bg.Visible = settings.esp.showHealth
                if character and character:FindFirstChild("Humanoid") then
                    local humanoid = character.Humanoid
                    local percent = humanoid.Health / humanoid.MaxHealth
                    health.bar.Size = UDim2.new(percent, 0, 1, 0)
                    local r = 255 - 255 * percent
                    local g = 255 * percent
                    health.bar.BackgroundColor3 = Color3.fromRGB(r, g, 0)
                end
            end
        end
    end
end

-- Detecta novos jogadores e configura ESP automaticamente
Players.PlayerAdded:Connect(function(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if isEnemy(player) then
            setupESP(player)
        end
    end)
    if player.Character and isEnemy(player) then
        setupESP(player)
    end
end)

-- Configura ESP para jogadores já existentes
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and isEnemy(player) then
        setupESP(player)
    end
end

-- ==================== LOOP PRINCIPAL ====================
RunService.RenderStepped:Connect(function()
    -- Atualiza ESP a cada frame
    updateESP()

    -- Aimlock
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
        local key = settings.aimbot.keybind
        if not key or key == "None" or UserInputService:IsKeyDown(Enum.KeyCode[key]) then
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

-- ==================== UI COM FLUENT (CORRIGIDO) ====================
-- Verificar se Fluent foi carregado
if not Fluent or not Fluent.CreateWindow then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Erro",
        Text = "Falha ao carregar Fluent UI. Verifique sua conexão.",
        Duration = 5
    })
    return
end

local Window = Fluent:CreateWindow({
    Title = "Universal Tool",
    SubTitle = "Aimbot | Aimlock | ESP",
    TabWidth = 140,
    Size = UDim2.fromOffset(450, 400),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Criar abas ANTES de qualquer operação
local AimbotTab = Window:AddTab({ Title = "Aimbot", Icon = "target" })
local AimlockTab = Window:AddTab({ Title = "Aimlock", Icon = "lock" })
local ESPTab = Window:AddTab({ Title = "ESP", Icon = "eye" })
local MiscTab = Window:AddTab({ Title = "Misc", Icon = "settings" })

-- Configurar SaveManager (apenas se disponível)
if SaveManager and InterfaceManager then
    pcall(function()
        SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)
        SaveManager:IgnoreThemeSettings()
        InterfaceManager:SetFolder("UniversalTool")
        SaveManager:SetFolder("UniversalTool")
        SaveManager:BuildConfigSection(AimbotTab)
        SaveManager:BuildConfigSection(AimlockTab)
        SaveManager:BuildConfigSection(ESPTab)
        SaveManager:BuildConfigSection(MiscTab)
    end)
end

-- ==================== ABA AIMBOT ====================
AimbotTab:AddSection("Configurações do Aimbot")

AimbotTab:AddToggle("AimbotEnabled", {
    Title = "Ativar Aimbot",
    Description = "Ativa o sistema de mira automática",
    Default = false,
    Callback = function(v) settings.aimbot.enabled = v end
})

AimbotTab:AddSlider("AimbotSmoothness", {
    Title = "Suavidade",
    Description = "1 = instantâneo | 50 = muito suave",
    Default = 10, Min = 1, Max = 50, Rounding = 1,
    Callback = function(v) settings.aimbot.smoothness = v end
})

AimbotTab:AddSlider("AimbotFOV", {
    Title = "Campo de visão (FOV)",
    Description = "Raio de detecção em pixels",
    Default = 200, Min = 50, Max = 500, Rounding = 1,
    Callback = function(v) settings.aimbot.fov = v end
})

AimbotTab:AddDropdown("AimbotTargetPart", {
    Title = "Parte do corpo",
    Values = {"Head", "UpperTorso", "HumanoidRootPart"},
    Default = 1, Multi = false,
    Callback = function(v) settings.aimbot.targetPart = v end
})

AimbotTab:AddKeybind("AimbotKeybind", {
    Title = "Tecla de ativação",
    Mode = "Hold", Default = "None",
    ChangedCallback = function(new)
        if new == "None" then settings.aimbot.keybind = nil else settings.aimbot.keybind = new end
    end
})

-- ==================== ABA AIMLOCK ====================
AimlockTab:AddSection("Configurações do Aimlock")

AimlockTab:AddToggle("AimlockEnabled", {
    Title = "Ativar Aimlock",
    Description = "Trava a mira no inimigo mais próximo",
    Default = false,
    Callback = function(v) settings.aimlock.enabled = v end
})

AimlockTab:AddSlider("AimlockDistance", {
    Title = "Distância máxima",
    Description = "Em studs",
    Default = 100, Min = 50, Max = 300, Rounding = 1,
    Callback = function(v) settings.aimlock.maxDistance = v end
})

AimlockTab:AddKeybind("AimlockKeybind", {
    Title = "Tecla de ativação",
    Mode = "Hold", Default = "Q",
    ChangedCallback = function(new) settings.aimlock.lockKey = new end
})

-- ==================== ABA ESP ====================
ESPTab:AddSection("Elementos do ESP")

ESPTab:AddToggle("ESPBox", {
    Title = "Caixa (Box)",
    Description = "Contorno colorido ao redor do personagem",
    Default = true,
    Callback = function(v) settings.esp.showBox = v end
})

ESPTab:AddToggle("ESPName", {
    Title = "Nome",
    Description = "Exibe o nome acima da cabeça",
    Default = true,
    Callback = function(v) settings.esp.showName = v end
})

ESPTab:AddToggle("ESPHealth", {
    Title = "Vida",
    Description = "Exibe a barra de vida",
    Default = true,
    Callback = function(v) settings.esp.showHealth = v end
})

ESPTab:AddToggle("ESPTeamColor", {
    Title = "Cor por time",
    Description = "Aliados azul, inimigos vermelho",
    Default = true,
    Callback = function(v) settings.esp.teamColor = v end
})

ESPTab:AddToggle("ESPOnlyEnemies", {
    Title = "Apenas inimigos",
    Description = "Mostra ESP só para oponentes",
    Default = false,
    Callback = function(v)
        settings.esp.onlyEnemies = v
        -- Recriar ESP
        for _, h in pairs(espHighlights) do if h then h:Destroy() end end
        for _, name in pairs(espNameLabels) do
            if name and name.Parent and name.Parent.Parent then name.Parent.Parent:Destroy() end
        end
        espHighlights = {}
        espNameLabels = {}
        espHealthBars = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isEnemy(p) then setupESP(p) end
        end
    end
})

-- ==================== ABA MISC ====================
MiscTab:AddSection("Interface")

MiscTab:AddButton({
    Title = "Alternar tema (Dark/Light)",
    Callback = function()
        if Fluent.Theme == "Dark" then Fluent:SetTheme("Light") else Fluent:SetTheme("Dark") end
    end
})

MiscTab:AddSlider({
    Title = "Transparência da janela",
    Default = 1, Min = 0.5, Max = 1, Rounding = 2,
    Callback = function(v)
        local frame = Window.Frame
        if frame then frame.BackgroundTransparency = 1 - v end
    end
})

MiscTab:AddSection("Configurações do Script")

MiscTab:AddButton({
    Title = "Salvar configuração",
    Callback = function()
        pcall(function() if SaveManager then SaveManager:Save() end end)
        Fluent:Notify({ Title = "Sucesso", Content = "Configurações salvas!", Duration = 2 })
    end
})

MiscTab:AddButton({
    Title = "Carregar configuração",
    Callback = function()
        pcall(function() if SaveManager then SaveManager:Load() end end)
        Fluent:Notify({ Title = "Sucesso", Content = "Configurações carregadas!", Duration = 2 })
    end
})

MiscTab:AddButton({
    Title = "Resetar configurações",
    Callback = function()
        pcall(function() if SaveManager then SaveManager:Reset() end end)
        Fluent:Notify({ Title = "Aviso", Content = "Configurações resetadas!", Duration = 2 })
    end
})

MiscTab:AddButton({
    Title = "Fechar UI",
    Callback = function() Window:Destroy() end
})

MiscTab:AddParagraph({
    Title = "Informações",
    Content = "Universal Tool v3.0\nDesenvolvido com Fluent UI\nESP simplificado"
})

-- Notificação inicial
Fluent:Notify({
    Title = "Universal Tool",
    Content = "Script carregado!",
    SubContent = "Use as abas para configurar",
    Duration = 4
})

-- Carregar configurações salvas
pcall(function() if SaveManager then SaveManager:LoadAutoloadConfig() end end)
Window:SelectTab(1)
