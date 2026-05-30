--[[
    Universal Tool – Fluent Renewed
    Aimbot configurável | ESP (Box + Nome)
]]

-- Carregar Fluent Renewed e os gerenciadores
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau", true))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

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

--- Interface Fluent Renewed
local Window = Library:CreateWindow{
    Title = "Universal Tool",
    SubTitle = "Aimbot Configurável | ESP",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 400),
    Resize = true,
    MinSize = Vector2.new(400, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
}

local Tabs = {
    Aimbot = Window:CreateTab{ Title = "Aimbot", Icon = "target" },
    ESP = Window:CreateTab{ Title = "ESP", Icon = "eye" }
}

-- Registra os gerenciadores (salvar configurações e interface)
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("UniversalTool")
SaveManager:SetFolder("UniversalTool/Configs")

InterfaceManager:BuildInterfaceSection(Tabs.ESP) -- Aba de gerenciamento de interface
SaveManager:BuildConfigSection(Tabs.ESP)        -- Aba para salvar configurações

--- Conteúdo da aba Aimbot
Tabs.Aimbot:CreateSection("Configurações do Aimbot")

-- Ativar/Desativar
local ToggleAimbot = Tabs.Aimbot:CreateToggle("AimbotToggle", {
    Title = "Ativar Aimbot",
    Default = Settings.Aimbot.Enabled,
    Callback = function(Value)
        Settings.Aimbot.Enabled = Value
    end
})

-- Suavidade (Slider)
local SliderSmoothness = Tabs.Aimbot:CreateSlider("SmoothnessSlider", {
    Title = "Suavidade",
    Description = "1 = instantâneo | 50 = mais suave",
    Default = Settings.Aimbot.Smoothness,
    Min = 1,
    Max = 50,
    Rounding = 1,
    Callback = function(Value)
        Settings.Aimbot.Smoothness = Value
    end
})

-- Campo de visão (FOV)
local SliderFOV = Tabs.Aimbot:CreateSlider("FOVSlider", {
    Title = "Campo de visão (FOV)",
    Description = "Raio de detecção em pixels",
    Default = Settings.Aimbot.FOV,
    Min = 50,
    Max = 400,
    Rounding = 1,
    Callback = function(Value)
        Settings.Aimbot.FOV = Value
    end
})

-- Parte do corpo (Dropdown)
local DropdownTargetPart = Tabs.Aimbot:CreateDropdown("TargetPartDropdown", {
    Title = "Parte do corpo",
    Values = { "Head", "UpperTorso", "HumanoidRootPart" },
    Multi = false,
    Default = Settings.Aimbot.TargetPart,
    Callback = function(Value)
        Settings.Aimbot.TargetPart = Value
    end
})

-- Tecla de ativação (opcional)
local KeybindAimbot = Tabs.Aimbot:CreateKeybind("AimbotKeybind", {
    Title = "Tecla de ativação (opcional)",
    Mode = "Hold",
    Default = "None",
    Callback = function(Value) end,  -- Opcional: executar algo ao pressionar
    ChangedCallback = function(NewKey)
        if NewKey == "None" then
            Settings.Aimbot.Keybind = nil
        else
            Settings.Aimbot.Keybind = NewKey
        end
    end
})

--- Conteúdo da aba ESP
Tabs.ESP:CreateSection("Elementos do ESP")

-- Caixa (Box)
local ToggleBox = Tabs.ESP:CreateToggle("ESPBoxToggle", {
    Title = "Caixa (Box)",
    Default = Settings.ESP.ShowBox,
    Callback = function(Value)
        Settings.ESP.ShowBox = Value
    end
})

-- Nome
local ToggleName = Tabs.ESP:CreateToggle("ESPNameToggle", {
    Title = "Nome",
    Default = Settings.ESP.ShowName,
    Callback = function(Value)
        Settings.ESP.ShowName = Value
    end
})

-- Cores por time
local ToggleTeamColor = Tabs.ESP:CreateToggle("ESPTeamColorToggle", {
    Title = "Cor por time",
    Description = "Aliados em azul / Inimigos em vermelho",
    Default = Settings.ESP.TeamColor,
    Callback = function(Value)
        Settings.ESP.TeamColor = Value
    end
})

-- Apenas inimigos
local ToggleOnlyEnemies = Tabs.ESP:CreateToggle("ESPOnlyEnemiesToggle", {
    Title = "Apenas inimigos",
    Description = "Mostrar ESP apenas para jogadores de times diferentes",
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

-- Botão para fechar a interface
Tabs.ESP:CreateButton({
    Title = "Fechar UI",
    Callback = function()
        Window:Destroy()
    end
})

--- Notificação de inicialização (opcional)
Library:Notify({
    Title = "Universal Tool",
    Content = "Script carregado com sucesso!",
    SubContent = "Aimbot e ESP prontos para uso.",
    Duration = 4
})

-- Carrega automaticamente a última configuração salva (se existir)
SaveManager:LoadAutoloadConfig()

-- Seleciona a primeira aba (Aimbot)
Window:SelectTab(1)
