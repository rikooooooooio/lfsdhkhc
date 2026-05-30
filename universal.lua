--[[
    Universal Tool v4.1 – Fluent UI (Tamanho reduzido)
    Aimbot | Aimlock | ESP (Box, Nome, Vida) | Misc
]]

-- Carregar Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
if not Fluent then
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Erro", Text = "Falha ao carregar Fluent", Duration = 5 })
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configurações
local settings = {
    aimbot = { enabled = false, smoothness = 10, fov = 200, targetPart = "Head", keybind = nil },
    aimlock = { enabled = false, lockKey = "Q", maxDistance = 100 },
    esp = { showBox = true, showName = true, showHealth = true, teamColor = true, onlyEnemies = false }
}

-- Variáveis
local aimlockTarget = nil
local isAimlocking = false
local espHighlights = {}
local espNameLabels = {}
local espHealthBars = {}

-- Funções auxiliares
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

-- Aimlock
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

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 160, 0, 40)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = billboard

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.Parent = mainFrame

    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(1, -20, 0, 5)
    healthBg.Position = UDim2.new(0, 10, 0, 20)
    healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    healthBg.BorderSizePixel = 0
    healthBg.Parent = mainFrame

    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBg

    espHighlights[player] = highlight
    espNameLabels[player] = nameLabel
    espHealthBars[player] = { bg = healthBg, bar = healthBar }
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
            espHealthBars[player] = nil
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

            local health = espHealthBars[player]
            if health and health.bg and health.bar then
                health.bg.Visible = settings.esp.showHealth
                if character and character:FindFirstChild("Humanoid") then
                    local hum = character.Humanoid
                    local percent = hum.Health / hum.MaxHealth
                    health.bar.Size = UDim2.new(percent, 0, 1, 0)
                    health.bar.BackgroundColor3 = Color3.fromRGB(255 - 255 * percent, 255 * percent, 0)
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

-- ==================== FLUENT UI (TAMANHO REDUZIDO) ====================
local Window = Fluent:CreateWindow({
    Title = "Universal Tool",
    SubTitle = "Aimbot | Aimlock | ESP",
    TabWidth = 120,
    Size = UDim2.fromOffset(400, 360),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Abas
local AimbotTab = Window:AddTab({ Title = "Aimbot" })
local AimlockTab = Window:AddTab({ Title = "Aimlock" })
local ESPTab = Window:AddTab({ Title = "ESP" })
local MiscTab = Window:AddTab({ Title = "Misc" })

-- Aimbot
AimbotTab:AddSection("Configurações do Aimbot")
AimbotTab:AddToggle("AimbotEnabled", { Title = "Ativar Aimbot", Default = false, Callback = function(v) settings.aimbot.enabled = v end })
AimbotTab:AddSlider("AimbotSmoothness", { Title = "Suavidade", Default = 10, Min = 1, Max = 50, Rounding = 1, Callback = function(v) settings.aimbot.smoothness = v end })
AimbotTab:AddSlider("AimbotFOV", { Title = "Campo de visão (FOV)", Default = 200, Min = 50, Max = 500, Rounding = 1, Callback = function(v) settings.aimbot.fov = v end })
AimbotTab:AddDropdown("AimbotTargetPart", { Title = "Parte do corpo", Values = {"Head", "UpperTorso", "HumanoidRootPart"}, Default = 1, Multi = false, Callback = function(v) settings.aimbot.targetPart = v end })
AimbotTab:AddKeybind("AimbotKeybind", { Title = "Tecla de ativação", Mode = "Hold", Default = "None", ChangedCallback = function(new) settings.aimbot.keybind = new == "None" and nil or new end })

-- Aimlock
AimlockTab:AddSection("Configurações do Aimlock")
AimlockTab:AddToggle("AimlockEnabled", { Title = "Ativar Aimlock", Default = false, Callback = function(v) settings.aimlock.enabled = v end })
AimlockTab:AddSlider("AimlockDistance", { Title = "Distância máxima", Default = 100, Min = 50, Max = 300, Rounding = 1, Callback = function(v) settings.aimlock.maxDistance = v end })
AimlockTab:AddKeybind("AimlockKeybind", { Title = "Tecla de ativação", Mode = "Hold", Default = "Q", ChangedCallback = function(new) settings.aimlock.lockKey = new end })

-- ESP
ESPTab:AddSection("Elementos do ESP")
ESPTab:AddToggle("ESPBox", { Title = "Caixa (Box)", Default = true, Callback = function(v) settings.esp.showBox = v end })
ESPTab:AddToggle("ESPName", { Title = "Nome", Default = true, Callback = function(v) settings.esp.showName = v end })
ESPTab:AddToggle("ESPHealth", { Title = "Vida", Default = true, Callback = function(v) settings.esp.showHealth = v end })
ESPTab:AddToggle("ESPTeamColor", { Title = "Cor por time", Default = true, Callback = function(v) settings.esp.teamColor = v end })
ESPTab:AddToggle("ESPOnlyEnemies", { Title = "Apenas inimigos", Default = false, Callback = function(v)
    settings.esp.onlyEnemies = v
    for _, h in pairs(espHighlights) do if h then h:Destroy() end end
    for _, name in pairs(espNameLabels) do if name and name.Parent and name.Parent.Parent then name.Parent.Parent:Destroy() end end
    espHighlights = {}; espNameLabels = {}; espHealthBars = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and isEnemy(p) then setupESP(p) end end
end })

-- Misc
MiscTab:AddSection("Interface")
MiscTab:AddButton({ Title = "Alternar tema (Dark/Light)", Callback = function()
    if Fluent.Theme == "Dark" then Fluent:SetTheme("Light") else Fluent:SetTheme("Dark") end
end })
MiscTab:AddSlider({ Title = "Transparência da janela", Default = 1, Min = 0.5, Max = 1, Rounding = 2, Callback = function(v)
    if Window.Frame then Window.Frame.BackgroundTransparency = 1 - v end
end })

MiscTab:AddSection("Configurações do Script")
MiscTab:AddButton({ Title = "Salvar configuração", Callback = function()
    Fluent:Notify({ Title = "Info", Content = "Salvar não implementado nesta versão", Duration = 2 })
end })
MiscTab:AddButton({ Title = "Fechar UI", Callback = function() Window:Destroy() end })
MiscTab:AddParagraph({ Title = "Informações", Content = "Universal Tool v4.1\nFluent UI\nTamanho reduzido" })

-- Notificação
Fluent:Notify({ Title = "Universal Tool", Content = "Script carregado!", SubContent = "Interface reduzida", Duration = 4 })

-- Selecionar primeira aba
Window:SelectTab(1)
