--[[
    Script Universal com Aimbot, Aimlock e ESP
    UI moderna e totalmente configurável
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==================== CONFIGURAÇÕES PADRÃO ====================
local settings = {
    aimbot = {
    enabled = false,
    smoothness = 10,     -- 1 = instantâneo, 50 = muito suave
    fov = 200,           -- pixels
    targetPart = "Head", -- "Head", "UpperTorso", "HumanoidRootPart"
    keybind = nil,       -- nil = sempre ativo; ou use Enum.KeyCode.Q, etc.
},
    aimlock = {
        enabled = false,
        lockKey = Enum.KeyCode.Q,
        maxDistance = 100,
    },
    esp = {
        enabled = true,
        showBox = true,
        showName = true,
        showHealth = true,
        showDistance = true,
        teamColor = true,    -- se true, time aliado = azul, inimigo = vermelho
        onlyEnemies = false,
    }
}

-- ==================== VARIÁVEIS GLOBAIS ====================
local aimbotTarget = nil
local aimlockTarget = nil
local isAimlocking = false
local espObjects = {} -- cada jogador terá seu ESP

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

-- ==================== AIMBOT (ROTAÇÃO DA CÂMERA) ====================
local function getClosestPlayerToCrosshair()
    local closestDistance = settings.aimbot.fov
    local closestPlayer = nil
    local cameraCFrame = Camera.CFrame
    local cameraPos = cameraCFrame.Position
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
    -- Interpolação linear de CFrame
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

-- ==================== ESP (BILLBOARDGUI) ====================
local function createESP(player)
    if espObjects[player] then return end

    local character = player.Character
    if not character then return end

    local espGui = Instance.new("BillboardGui")
    espGui.Name = "ESP_GUI"
    espGui.Adornee = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    espGui.Size = UDim2.new(0, 4, 0, 4)
    espGui.StudsOffset = Vector3.new(0, 2, 0)
    espGui.AlwaysOnTop = true
    espGui.MaxDistance = 300
    espGui.ExtentsOffset = Vector3.new(0, 3, 0)

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 120, 0, 50)
    mainFrame.BackgroundTransparency = 0.5
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    mainFrame.Parent = espGui

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

    -- Caixa (opcional, pode ser um Frame arredondado)
    local boxFrame = Instance.new("Frame")
    boxFrame.Size = UDim2.new(1, 0, 1, 0)
    boxFrame.BackgroundTransparency = 0.8
    boxFrame.BorderSizePixel = 2
    boxFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    boxFrame.Parent = mainFrame

    espObjects[player] = {
        gui = espGui,
        name = nameLabel,
        healthBar = healthBar,
        distance = distLabel,
        box = boxFrame,
        frame = mainFrame
    }

    espGui.Parent = character
end

local function updateESP()
    for player, data in pairs(espObjects) do
        local character = player.Character
        if not character or not isEnemy(player) then
            if data.gui then data.gui:Destroy() end
            espObjects[player] = nil
        else
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                data.healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
                data.healthBar.BackgroundColor3 = Color3.fromRGB(255 - 255 * healthPercent, 255 * healthPercent, 0)
                
                if settings.esp.showDistance then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        data.distance.Text = math.floor(dist) .. "m"
                        data.distance.Visible = true
                    else
                        data.distance.Visible = false
                    end
                else
                    data.distance.Visible = false
                end
                
                -- Cores por time
                if settings.esp.teamColor and LocalPlayer.Team and player.Team then
                    if LocalPlayer.Team == player.Team then
                        data.box.BorderColor3 = Color3.fromRGB(0, 0, 255)
                        data.name.TextColor3 = Color3.fromRGB(0, 0, 255)
                    else
                        data.box.BorderColor3 = Color3.fromRGB(255, 0, 0)
                        data.name.TextColor3 = Color3.fromRGB(255, 0, 0)
                    end
                else
                    data.box.BorderColor3 = Color3.fromRGB(255, 255, 255)
                    data.name.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
                
                data.box.Visible = settings.esp.showBox
                data.name.Visible = settings.esp.showName
                data.healthBar.Parent.Visible = settings.esp.showHealth
            end
        end
    end
end

-- ==================== CRIAR NOVOS ESP AO APARECER PERSONAGEM ====================
local function onCharacterAdded(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(character)
        wait(0.5)
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
    if espObjects[player] and espObjects[player].gui then
        espObjects[player].gui:Destroy()
        espObjects[player] = nil
    end
end)

-- ==================== LOOP PRINCIPAL ====================
RunService.RenderStepped:Connect(function()
    -- Atualizar ESP
    if settings.esp.enabled then
        updateESP()
    else
        for _, data in pairs(espObjects) do
            if data.gui then data.gui.Visible = false end
        end
    end
    
    -- Aimlock
    if settings.aimlock.enabled and UserInputService:IsKeyDown(settings.aimlock.lockKey) then
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
    
    -- Aimbot livre (se aimlock não estiver ativo)
    if settings.aimbot.enabled and not isAimlocking then
    if not settings.aimbot.keybind or UserInputService:IsKeyDown(settings.aimbot.keybind) then
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

-- ==================== UI MODERNA ====================
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdvancedGUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    titleBar.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -30, 1, 0)
    titleLabel.Position = UDim2.new(0, 5, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "  ⚡ Universal Tool"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 1, 0)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)
    
    -- Abas
    local tabButtons = {}
    local tabContents = {}
    
    local function createTab(name, buttonText)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 0, 30)
        btn.Position = UDim2.new(0, 10 + (#tabButtons * 110), 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        btn.Text = buttonText
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = mainFrame
        
        local content = Instance.new("ScrollingFrame")
        content.Size = UDim2.new(1, -20, 1, -80)
        content.Position = UDim2.new(0, 10, 0, 70)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.ScrollBarThickness = 6
        content.Visible = false
        content.Parent = mainFrame
        
        table.insert(tabButtons, {btn=btn, content=content, name=name})
        return content
    end
    
    local function selectTab(index)
        for i, tab in ipairs(tabButtons) do
            tab.content.Visible = (i == index)
            tab.btn.BackgroundColor3 = (i == index) and Color3.fromRGB(80, 80, 120) or Color3.fromRGB(60, 60, 80)
        end
    end
    
    -- Criar abas
    local aimbotTab = createTab("Aimbot", "🎯 Aimbot")
    local espTab = createTab("ESP", "👁️ ESP")
    local settingsTab = createTab("Settings", "⚙️ Config")
    
    -- Helper para adicionar checkbox
    local function addCheckbox(parent, text, getter, setter, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 30)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local check = Instance.new("TextButton")
        check.Size = UDim2.new(0, 25, 0, 25)
        check.BackgroundColor3 = getter() and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
        check.Text = getter() and "✔" or ""
        check.TextColor3 = Color3.fromRGB(255, 255, 255)
        check.Font = Enum.Font.GothamBold
        check.TextSize = 18
        check.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -35, 1, 0)
        label.Position = UDim2.new(0, 35, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = frame
        
        check.MouseButton1Click:Connect(function()
            local newVal = not getter()
            setter(newVal)
            check.BackgroundColor3 = newVal and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
            check.Text = newVal and "✔" or ""
        end)
        return frame
    end
    
    -- Helper para slider
    local function addSlider(parent, text, minVal, maxVal, getter, setter, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 50)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. tostring(getter())
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = frame
        
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, 0, 0, 4)
        slider.Position = UDim2.new(0, 0, 0, 25)
        slider.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        slider.BorderSizePixel = 0
        slider.Parent = frame
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((getter() - minVal) / (maxVal - minVal), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        fill.BorderSizePixel = 0
        fill.Parent = slider
        
        local valueBtn = Instance.new("TextButton")
        valueBtn.Size = UDim2.new(0, 30, 0, 20)
        valueBtn.Position = UDim2.new((getter() - minVal) / (maxVal - minVal), -15, 0, -8)
        valueBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        valueBtn.Text = tostring(getter())
        valueBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        valueBtn.Font = Enum.Font.GothamBold
        valueBtn.TextSize = 12
        valueBtn.Parent = frame
        
        local dragging = false
        local function updateSlider(input)
            local pos = input.Position.X - slider.AbsolutePosition.X
            local newPercent = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
            local newValue = minVal + (maxVal - minVal) * newPercent
            newValue = math.floor(newValue)
            setter(newValue)
            fill.Size = UDim2.new(newPercent, 0, 1, 0)
            valueBtn.Position = UDim2.new(newPercent, -15, 0, -8)
            valueBtn.Text = tostring(newValue)
            label.Text = text .. ": " .. tostring(newValue)
        end
        
        valueBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        return frame
    end
    
    -- Helper para dropdown de partes do corpo
    local function addDropdown(parent, text, options, getter, setter, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 40)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 25)
        btn.Position = UDim2.new(0, 0, 0, 20)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        btn.Text = getter()
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = frame
        
        local dropdown = Instance.new("Frame")
        dropdown.Size = UDim2.new(1, 0, 0, #options * 25)
        dropdown.Position = UDim2.new(0, 0, 0, 45)
        dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        dropdown.BorderSizePixel = 1
        dropdown.Visible = false
        dropdown.Parent = frame
        
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 25)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1)*25)
            optBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            optBtn.Text = opt
            optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 14
            optBtn.Parent = dropdown
            optBtn.MouseButton1Click:Connect(function()
                setter(opt)
                btn.Text = opt
                dropdown.Visible = false
            end)
        end
        
        btn.MouseButton1Click:Connect(function()
            dropdown.Visible = not dropdown.Visible
        end)
        return frame
    end
    
    -- Preencher aba Aimbot
    local y = 10
    addCheckbox(aimbotTab, "Ativar Aimbot", function() return settings.aimbot.enabled end, function(v) settings.aimbot.enabled = v end, y); y = y + 35
    addSlider(aimbotTab, "Suavidade (Smoothing)", 1, 50, function() return settings.aimbot.smoothness end, function(v) settings.aimbot.smoothness = v end, y); y = y + 55
    addSlider(aimbotTab, "Campo de visão (FOV)", 50, 500, function() return settings.aimbot.fov end, function(v) settings.aimbot.fov = v end, y); y = y + 55
    addDropdown(aimbotTab, "Parte do corpo", {"Head", "UpperTorso", "HumanoidRootPart"}, function() return settings.aimbot.targetPart end, function(v) settings.aimbot.targetPart = v end, y); y = y + 50
    -- Keybind seria mais complexo, omitido para simplificar
    
    -- Aba ESP
    y = 10
    addCheckbox(espTab, "Ativar ESP", function() return settings.esp.enabled end, function(v) settings.esp.enabled = v end, y); y = y + 35
    addCheckbox(espTab, "Mostrar Caixa (Box)", function() return settings.esp.showBox end, function(v) settings.esp.showBox = v end, y); y = y + 35
    addCheckbox(espTab, "Mostrar Nome", function() return settings.esp.showName end, function(v) settings.esp.showName = v end, y); y = y + 35
    addCheckbox(espTab, "Mostrar Vida", function() return settings.esp.showHealth end, function(v) settings.esp.showHealth = v end, y); y = y + 35
    addCheckbox(espTab, "Mostrar Distância", function() return settings.esp.showDistance end, function(v) settings.esp.showDistance = v end, y); y = y + 35
    addCheckbox(espTab, "Cor por Time", function() return settings.esp.teamColor end, function(v) settings.esp.teamColor = v end, y); y = y + 35
    addCheckbox(espTab, "Apenas Inimigos", function() return settings.esp.onlyEnemies end, function(v) settings.esp.onlyEnemies = v; --[[recriar ESP]] for p in pairs(espObjects) do if espObjects[p].gui then espObjects[p].gui:Destroy() end end espObjects = {} for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then onCharacterAdded(plr) end end end, y)
    
    -- Aba Configurações (Aimlock)
    y = 10
    addCheckbox(settingsTab, "Ativar Aimlock", function() return settings.aimlock.enabled end, function(v) settings.aimlock.enabled = v end, y); y = y + 35
    addSlider(settingsTab, "Distância máxima", 50, 300, function() return settings.aimlock.maxDistance end, function(v) settings.aimlock.maxDistance = v end, y); y = y + 55
    -- Obs: tecla de aimlock fixa em Q, poderia ser configurável mas para simplicidade deixamos fixo
    
    -- Ajustar canvas size das abas
    for _, tab in ipairs(tabButtons) do
        tab.content.CanvasSize = UDim2.new(0, 0, 0, math.max(y + 20, 400))
    end
    
    -- Selecionar primeira aba
    selectTab(1)
    for i, tab in ipairs(tabButtons) do
        tab.btn.MouseButton1Click:Connect(function() selectTab(i) end)
    end
    
    -- Sistema de arrastar janela
    local dragStart, dragFrameStart, draggingWin = nil, nil, false
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingWin = true
            dragStart = input.Position
            dragFrameStart = mainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingWin and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(dragFrameStart.X.Scale, dragFrameStart.X.Offset + delta.X, dragFrameStart.Y.Scale, dragFrameStart.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingWin = false
        end
    end)
end

-- Iniciar UI
createUI()
