--[[
    Orion Lib - Script Completo
    Aimlock: Desativado | ESP de Vida: Desativado
]]

-- Carregar a biblioteca Orion
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/DenDenZZZ/Orion-UI-Library/refs/heads/main/source')))()

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configurações padrão
local Settings = {
    Aimbot = {
        Enabled = false,
        Smoothness = 10,      -- 1 = instantâneo, 50 = mais suave
        FOV = 200,            -- Raio de detecção em pixels
        TargetPart = "Head",  -- Cabeça, tronco ou centro
        Keybind = nil         -- Tecla opcional para ativação
    },
    ESP = {
        ShowBox = true,       -- Caixa de contorno (Highlight)
        ShowName = true,      -- Nome do jogador
        TeamColor = true,     -- Azul = aliado, vermelho = inimigo
        OnlyEnemies = false   -- Mostrar apenas oponentes
    }
}

-- Variáveis locais
local AimbotTarget = nil
local espHighlights = {}      -- Caixas (Highlight)
local espNames = {}           -- Nomes (BillboardGui)

-- Verifica se o jogador é inimigo (considera OnlyEnemies e Teams)
local function isEnemy(Player)
    if Player == LocalPlayer then return false end
    if Settings.ESP.OnlyEnemies then
        return LocalPlayer.Team ~= Player.Team
    end
    return true
end

-- Obtém a parte do corpo configurada ou uma alternativa
local function getTargetPart(Character)
    if not Character then return nil end
    local Part = Character:FindFirstChild(Settings.Aimbot.TargetPart)
    if Part then return Part end
    Part = Character:FindFirstChild("UpperTorso")
    if Part then return Part end
    return Character:FindFirstChild("HumanoidRootPart")
end

-- Encontra o inimigo mais próximo do centro da mira
local function getClosestPlayerToCrosshair()
    local ClosestDistance = Settings.Aimbot.FOV
    local ClosestPlayer = nil

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Humanoid = Player.Character:FindFirstChild("Humanoid")
            if Humanoid and Humanoid.Health > 0 then
                local TargetPart = getTargetPart(Player.Character)
                if TargetPart then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
                    if OnScreen then
                        local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                        if Distance < ClosestDistance then
                            ClosestDistance = Distance
                            ClosestPlayer = Player
                        end
                    end
                end
            end
        end
    end
    return ClosestPlayer
end

-- Suavidade para mover a câmera
local function smoothCamera(Part, Smoothness)
    if not Part then return end
    local Smooth = Smoothness or 10
    local CurrentCFrame = Camera.CFrame
    local TargetCFrame = CFrame.new(CurrentCFrame.Position, Part.Position)
    Camera.CFrame = CurrentCFrame:Lerp(TargetCFrame, 1 / Smooth)
end

--- ESP: Cria os elementos visuais para um jogador
local function setupESP(Player)
    if espHighlights[Player] then return end
    local Character = Player.Character
    if not Character then return end

    -- Caixa de contorno (Highlight)
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "ESP_Highlight"
    Highlight.FillTransparency = 1
    Highlight.OutlineTransparency = 0.25
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.Parent = Character

    -- Nome (BillboardGui)
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "ESP_Billboard"
    local Adornee = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Head")
    if not Adornee then return end
    Billboard.Adornee = Adornee
    Billboard.Size = UDim2.new(0, 4, 0, 4)
    Billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    Billboard.AlwaysOnTop = true
    Billboard.MaxDistance = 300

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0, 160, 0, 18)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = Player.Name
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextSize = 14
    NameLabel.TextStrokeTransparency = 0.25
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.Parent = Billboard

    espHighlights[Player] = Highlight
    espNames[Player] = NameLabel
    Billboard.Parent = Character
end

-- Atualiza a aparência de todas as caixas e nomes
local function updateESP()
    for Player, Highlight in pairs(espHighlights) do
        local Character = Player.Character
        if not Character or not isEnemy(Player) then
            if Highlight then Highlight:Destroy() end
            local Billboard = Character and Character:FindFirstChild("ESP_Billboard")
            if Billboard then Billboard:Destroy() end
            espHighlights[Player] = nil
            espNames[Player] = nil
        else
            -- Caixa
            Highlight.Enabled = Settings.ESP.ShowBox
            if Settings.ESP.TeamColor and LocalPlayer.Team and Player.Team then
                Highlight.OutlineColor = (LocalPlayer.Team == Player.Team) and Color3.fromRGB(0, 0, 255) or Color3.fromRGB(255, 0, 0)
            else
                Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            end

            -- Nome
            local NameLabel = espNames[Player]
            if NameLabel then
                NameLabel.Visible = Settings.ESP.ShowName
                if Settings.ESP.TeamColor and LocalPlayer.Team and Player.Team then
                    NameLabel.TextColor3 = (LocalPlayer.Team == Player.Team) and Color3.fromRGB(100, 100, 255) or Color3.fromRGB(255, 100, 100)
                else
                    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end
end

-- Inicializa o ESP para jogadores existentes
local function initPlayerESP(Player)
    if Player == LocalPlayer then return end
    local function onCharacterAdded()
        task.wait(0.5)
        if isEnemy(Player) then setupESP(Player) end
    end
    Player.CharacterAdded:Connect(onCharacterAdded)
    if Player.Character and isEnemy(Player) then
        setupESP(Player)
    end
end

for _, Player in ipairs(Players:GetPlayers()) do
    initPlayerESP(Player)
end
Players.PlayerAdded:Connect(initPlayerESP)

-- Loop principal (Aimbot e ESP)
RunService.RenderStepped:Connect(function()
    updateESP() -- Atualiza caixas e nomes

    if Settings.Aimbot.Enabled then
        local Key = Settings.Aimbot.Keybind
        if not Key or Key == "None" or UserInputService:IsKeyDown(Enum.KeyCode[Key]) then
            local TargetPlayer = getClosestPlayerToCrosshair()
            if TargetPlayer and TargetPlayer.Character then
                local TargetPart = getTargetPart(TargetPlayer.Character)
                if TargetPart then
                    smoothCamera(TargetPart, Settings.Aimbot.Smoothness)
                end
            end
        end
    end
end)

-- ========================= Interface Orion =========================
local Window = OrionLib:MakeWindow({
    Name = "Universal Tool",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "UniversalTool",
    IntroEnabled = true,
    IntroText = "Universal Tool",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998",
    CloseCallback = function()
        print("UI Fechada")
    end
})

-- Aba Aimbot
local AimbotTab = Window:MakeTab({
    Name = "Aimbot",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Seção de Configurações do Aimbot
AimbotTab:AddSection({
    Name = "Configurações do Aimbot"
})

-- Toggle Ativar Aimbot
local ToggleAimbot = AimbotTab:AddToggle({
    Name = "Ativar Aimbot",
    Default = Settings.Aimbot.Enabled,
    Callback = function(Value)
        Settings.Aimbot.Enabled = Value
    end
})

-- Slider Suavidade
local SliderSmoothness = AimbotTab:AddSlider({
    Name = "Suavidade",
    Min = 1,
    Max = 50,
    Default = Settings.Aimbot.Smoothness,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "",
    Callback = function(Value)
        Settings.Aimbot.Smoothness = Value
    end
})

-- Slider Campo de visão (FOV)
local SliderFOV = AimbotTab:AddSlider({
    Name = "Campo de visão (FOV)",
    Min = 50,
    Max = 400,
    Default = Settings.Aimbot.FOV,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 10,
    ValueName = "px",
    Callback = function(Value)
        Settings.Aimbot.FOV = Value
    end
})

-- Dropdown Parte do corpo
local DropdownTargetPart = AimbotTab:AddDropdown({
    Name = "Parte do corpo",
    Default = Settings.Aimbot.TargetPart,
    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    Callback = function(Value)
        Settings.Aimbot.TargetPart = Value
    end
})

-- Keybind Tecla de ativação
-- Keybind Tecla de ativação (corrigido)
local KeybindAimbot = AimbotTab:AddBind({
    Name = "Tecla de ativação (opcional)",
    Default = Enum.KeyCode.Unknown,  -- ← trocado de None para Unknown
    Hold = true,
    Callback = function(Value)
        if Value then
            -- O callback é chamado quando a tecla é pressionada (Hold = true)
            -- Não precisa fazer nada aqui, pois o aimbot já verifica a tecla no loop
        end
    end
})

-- Atualiza a tecla quando ela for alterada pelo usuário
-- (O Orion não tem um evento direto, mas podemos ler o valor atual quando necessário)
-- Para simplificar, vamos apenas armazenar o valor quando o usuário mudar a tecla.
-- Infelizmente o Orion não fornece um callback de mudança, então faremos uma verificação periódica simples.
task.spawn(function()
    while true do
        task.wait(0.5)
        local currentKey = KeybindAimbot.Value  -- Tenta obter o valor atual (pode variar conforme versão)
        if currentKey and currentKey ~= Enum.KeyCode.Unknown then
            if currentKey == Enum.KeyCode.Unknown then
                Settings.Aimbot.Keybind = nil
            else
                Settings.Aimbot.Keybind = currentKey.Name
            end
        end
    end
end)

-- Função para atualizar a tecla quando ela for alterada
local function onKeybindChanged(Key)
    if Key == Enum.KeyCode.None then
        Settings.Aimbot.Keybind = nil
    else
        Settings.Aimbot.Keybind = Key.Name
    end
end

-- Como o Orion não tem um callback específico para mudança de keybind, faremos uma verificação periódica
-- Mas isso pode ser ignorado, o usuário pode simplesmente usar o aimbot sem tecla

-- Aba ESP
local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Seção de Elementos do ESP
ESPTab:AddSection({
    Name = "Elementos do ESP"
})

-- Toggle Caixa (Box)
local ToggleBox = ESPTab:AddToggle({
    Name = "Caixa (Box)",
    Default = Settings.ESP.ShowBox,
    Callback = function(Value)
        Settings.ESP.ShowBox = Value
    end
})

-- Toggle Nome
local ToggleName = ESPTab:AddToggle({
    Name = "Nome",
    Default = Settings.ESP.ShowName,
    Callback = function(Value)
        Settings.ESP.ShowName = Value
    end
})

-- Toggle Cor por time
local ToggleTeamColor = ESPTab:AddToggle({
    Name = "Cor por time",
    Default = Settings.ESP.TeamColor,
    Callback = function(Value)
        Settings.ESP.TeamColor = Value
    end
})

-- Toggle Apenas inimigos
local ToggleOnlyEnemies = ESPTab:AddToggle({
    Name = "Apenas inimigos",
    Default = Settings.ESP.OnlyEnemies,
    Callback = function(Value)
        Settings.ESP.OnlyEnemies = Value
        -- Recria os elementos do ESP para aplicar o novo filtro
        for _, Highlight in pairs(espHighlights) do
            if Highlight then Highlight:Destroy() end
        end
        for _, NameLabel in pairs(espNames) do
            if NameLabel and NameLabel.Parent then NameLabel.Parent:Destroy() end
        end
        espHighlights = {}
        espNames = {}
        for _, Player in ipairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and isEnemy(Player) then
                setupESP(Player)
            end
        end
    end
})

-- Botão Fechar UI
ESPTab:AddButton({
    Name = "Fechar UI",
    Callback = function()
        OrionLib:Destroy()
    end
})

-- Notificação de inicialização (opcional)
OrionLib:MakeNotification({
    Name = "Universal Tool",
    Content = "Script carregado com sucesso!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- Finaliza a inicialização da biblioteca (OBRIGATÓRIO)
OrionLib:Init()
