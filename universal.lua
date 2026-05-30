--[[
    Universal Tool – WindUI (Totalmente Corrigido)
    Aimbot Configurável | ESP (Box + Nome)
]]

-- CARREGAR WINDUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Erro", Text = "Falha ao carregar WindUI", Duration = 5})
    return
end

-- SERVIÇOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES
local settings = {
    aimbot = {enabled = false, smoothness = 10, fov = 200, targetPart = "Head", keybind = nil},
    esp = {showBox = true, showName = true, teamColor = true, onlyEnemies = false}
}

-- VARIÁVEIS
local espHighlights = {}
local espNameLabels = {}

-- FUNÇÕES AUXILIARES
local function isEnemy(p)
    if p == LocalPlayer then return false end
    if settings.esp.onlyEnemies then return LocalPlayer.Team ~= p.Team end
    return true
end

local function getTargetPart(char)
    local part = char:FindFirstChild(settings.aimbot.targetPart) or
                 char:FindFirstChild("UpperTorso") or
                 char:FindFirstChild("HumanoidRootPart")
    return part
end

-- AIMBOT
local function getClosestPlayerToCrosshair()
    local closestDist = settings.aimbot.fov
    local closest = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local part = getTargetPart(plr.Character)
            if part then
                local screenPoint, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = plr
                    end
                end
            end
        end
    end
    return closest
end

local function smoothCameraLookAt(pos, smooth)
    if not pos then return end
    local s = smooth or 10
    local current = Camera.CFrame
    local target = CFrame.new(current.Position, pos)
    Camera.CFrame = current:Lerp(target, 1/s)
end

-- ESP (Box + Nome)
local function setupESP(player)
    if espHighlights[player] then return end
    local char = player.Character
    if not char then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0.25
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    billboard.Size = UDim2.new(0, 4, 0, 4)
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 300

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 160, 0, 18)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextStrokeTransparency = 0.25
    nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
    nameLabel.Parent = billboard

    espHighlights[player] = highlight
    espNameLabels[player] = nameLabel
    billboard.Parent = char
end

local function updateESP()
    for player, highlight in pairs(espHighlights) do
        local char = player.Character
        if not char or not isEnemy(player) then
            if highlight then highlight:Destroy() end
            local bill = char and char:FindFirstChild("ESP_Billboard")
            if bill then bill:Destroy() end
            espHighlights[player] = nil
            espNameLabels[player] = nil
        else
            highlight.Enabled = settings.esp.showBox
            if settings.esp.teamColor and LocalPlayer.Team and player.Team then
                highlight.OutlineColor = (LocalPlayer.Team == player.Team) and Color3.fromRGB(0,0,255) or Color3.fromRGB(255,0,0)
            else
                highlight.OutlineColor = Color3.fromRGB(255,255,255)
            end

            local nameLabel = espNameLabels[player]
            if nameLabel then
                nameLabel.Visible = settings.esp.showName
                if settings.esp.teamColor and LocalPlayer.Team and player.Team then
                    nameLabel.TextColor3 = (LocalPlayer.Team == player.Team) and Color3.fromRGB(100,100,255) or Color3.fromRGB(255,100,100)
                else
                    nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
                end
            end
        end
    end
end

-- INICIAR ESP
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        plr.CharacterAdded:Connect(function() task.wait(0.5); if isEnemy(plr) then setupESP(plr) end end)
        if plr.Character and isEnemy(plr) then setupESP(plr) end
    end
end
Players.PlayerAdded:Connect(function(plr)
    if plr == LocalPlayer then return end
    plr.CharacterAdded:Connect(function() task.wait(0.5); if isEnemy(plr) then setupESP(plr) end end)
    if plr.Character and isEnemy(plr) then setupESP(plr) end
end)

-- LOOP PRINCIPAL
RunService.RenderStepped:Connect(function()
    updateESP()
    if settings.aimbot.enabled then
        local key = settings.aimbot.keybind
        if not key or key == "None" or UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            local target = getClosestPlayerToCrosshair()
            if target and target.Character then
                local part = getTargetPart(target.Character)
                if part then smoothCameraLookAt(part.Position, settings.aimbot.smoothness) end
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

if not Window then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Erro", Text = "Falha ao criar janela", Duration = 5})
    return
end

-- Abas (usando tabela com Title e Icon)
local AimbotTab = Window:Tab({Title = "Aimbot", Icon = "crosshair"})
local ESPTab = Window:Tab({Title = "ESP", Icon = "eye"})

-- ==================== ABA AIMBOT ====================
AimbotTab:Section({Title = "Configurações do Aimbot"})
AimbotTab:Toggle({Title = "Ativar Aimbot", Icon = "target", Value = false, Callback = function(v) settings.aimbot.enabled = v end})
AimbotTab:Slider({Title = "Suavidade", Icon = "gauge", Min = 1, Max = 50, Step = 1, Value = 10, Callback = function(v) settings.aimbot.smoothness = v end})
AimbotTab:Slider({Title = "Campo de visão (FOV)", Icon = "radius", Min = 50, Max = 400, Step = 10, Value = 200, Callback = function(v) settings.aimbot.fov = v end})
AimbotTab:Dropdown({Title = "Parte do corpo", Icon = "person-standing", Values = {"Head", "UpperTorso", "HumanoidRootPart"}, Value = "Head", Callback = function(v) settings.aimbot.targetPart = v end})
AimbotTab:Keybind({Title = "Tecla de ativação (opcional)", Icon = "key", Value = "None", Callback = function(key) settings.aimbot.keybind = (key == "None" and nil or key) end})

-- ==================== ABA ESP ====================
ESPTab:Section({Title = "Elementos do ESP"})
ESPTab:Toggle({Title = "Caixa (Box)", Icon = "bounding-box", Value = true, Callback = function(v) settings.esp.showBox = v end})
ESPTab:Toggle({Title = "Nome", Icon = "text", Value = true, Callback = function(v) settings.esp.showName = v end})
ESPTab:Toggle({Title = "Cor por time", Icon = "palette", Value = true, Callback = function(v) settings.esp.teamColor = v end})
ESPTab:Toggle({Title = "Apenas inimigos", Icon = "swords", Value = false, Callback = function(v)
    settings.esp.onlyEnemies = v
    -- Recriar ESP
    for _, h in pairs(espHighlights) do if h then h:Destroy() end end
    for _, n in pairs(espNameLabels) do if n and n.Parent then n.Parent:Destroy() end end
    espHighlights = {}; espNameLabels = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isEnemy(p) then setupESP(p) end
    end
end})
ESPTab:Button({Title = "Fechar UI", Icon = "door-closed", Callback = function() Window:Destroy() end})

-- NOTIFICAÇÃO
WindUI:Notify({Title = "Universal Tool", Icon = "rocket", Content = "Script carregado! Aimbot e ESP prontos.", Duration = 4})
