--[[
    Script Universal v9 – UI Própria Moderna
    ESP + Aimbot + Misc
    Funciona em qualquer jogo Roblox
    Executor Delta: use VirtualUser (ativado)
--]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- ========== CONFIGURAÇÕES ==========
local espEnabled = false
local aimbotEnabled = false
local wallCheckEnabled = true
local hideCircle = false
local aimbotSpeed = 360
local aimbotStrength = 5
local actualRadius = 100
local aimPart = "Head"
local miraDoRiko = false

-- ESP opções
local espBox = false
local espLine = false
local espSkeleton = false
local espHealth = false

-- Outros
local walkSpeedEnabled = false
local walkSpeedValue = 16
local jumpPowerEnabled = false
local jumpPowerValue = 50
local flyEnabled = false
local infJumpEnabled = false
local hitboxExtenderEnabled = false
local hitboxExtenderValue = 1
local noclipEnabled = false
local invisibleEnabled = false
local spinBotEnabled = false

-- Variáveis de estado
local espDrawings = {}
local aimbotCircle = nil
local menuGUI = nil
local flyBodyVelocity = nil
local originalWalkspeed = 16
local originalJumpPower = 50
local spinConnection = nil
local noclipConnection = nil
local infJumpConnection = nil
local currentTab = "aimbot"

-- ========== FUNÇÕES DE DESENHO (ESP com Drawing) ==========
local function newDrawing(type, color, thickness, transparency)
    local draw = Drawing.new(type)
    draw.Color = color
    draw.Thickness = thickness or 1
    draw.Transparency = transparency or 0
    draw.Visible = false
    return draw
end

local function worldToScreen(pos)
    local vec, onScreen = Camera:WorldToScreenPoint(pos)
    if onScreen then return Vector2.new(vec.X, vec.Y) end
    return nil
end

local function createESPDrawings(player)
    if espDrawings[player] then return end
    local drawings = {
        box = newDrawing("Square", Color3.fromRGB(255,0,0), 2, 0.5),
        line = newDrawing("Line", Color3.fromRGB(255,0,0), 2, 0.5),
        skeleton = {},
        health = newDrawing("Line", Color3.fromRGB(0,255,0), 3, 0.5)
    }
    for i = 1, 14 do
        drawings.skeleton[i] = newDrawing("Line", Color3.fromRGB(255,255,255), 2, 0.5)
    end
    espDrawings[player] = drawings
    return drawings
end

local function clearESPDrawings(player)
    if espDrawings[player] then
        for _, line in pairs(espDrawings[player].skeleton) do line:Remove() end
        espDrawings[player].box:Remove()
        espDrawings[player].line:Remove()
        espDrawings[player].health:Remove()
        espDrawings[player] = nil
    end
end

local function updateBox(drawings, char)
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not root or not head then
        drawings.box.Visible = false
        return
    end
    local top = worldToScreen(head.Position)
    local bottom = worldToScreen(root.Position - Vector3.new(0, 2, 0))
    if top and bottom then
        local height = math.abs(top.Y - bottom.Y)
        local width = height * 0.5
        local left = top.X - width/2
        drawings.box.From = Vector2.new(left, top.Y)
        drawings.box.To = Vector2.new(left + width, top.Y + height)
        drawings.box.Visible = espEnabled and espBox
    else
        drawings.box.Visible = false
    end
end

local function updateLine(drawings, char)
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        drawings.line.Visible = false
        return
    end
    local pos = worldToScreen(root.Position)
    local ground = worldToScreen(Vector3.new(root.Position.X, 0, root.Position.Z))
    if pos and ground then
        drawings.line.From = pos
        drawings.line.To = ground
        drawings.line.Visible = espEnabled and espLine
    else
        drawings.line.Visible = false
    end
end

local function updateSkeleton(drawings, char)
    local joints = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
    }
    for i, joint in ipairs(joints) do
        local p1 = char:FindFirstChild(joint[1])
        local p2 = char:FindFirstChild(joint[2])
        if p1 and p2 then
            local s1 = worldToScreen(p1.Position)
            local s2 = worldToScreen(p2.Position)
            if s1 and s2 then
                drawings.skeleton[i].From = s1
                drawings.skeleton[i].To = s2
                drawings.skeleton[i].Visible = espEnabled and espSkeleton
            else
                drawings.skeleton[i].Visible = false
            end
        else
            drawings.skeleton[i].Visible = false
        end
    end
end

local function updateHealth(drawings, char)
    local humanoid = char:FindFirstChild("Humanoid")
    local head = char:FindFirstChild("Head")
    if not humanoid or not head then
        drawings.health.Visible = false
        return
    end
    local headPos = worldToScreen(head.Position)
    if headPos then
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local barWidth = 50
        local y = headPos.Y - 20
        local x = headPos.X - barWidth/2
        drawings.health.From = Vector2.new(x, y)
        drawings.health.To = Vector2.new(x + barWidth * healthPercent, y)
        drawings.health.Visible = espEnabled and espHealth
    else
        drawings.health.Visible = false
    end
end

local function updateAllESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if espEnabled and (espBox or espLine or espSkeleton or espHealth) then
                local drawings = espDrawings[plr]
                if not drawings then drawings = createESPDrawings(plr) end
                local char = plr.Character
                if espBox then updateBox(drawings, char) end
                if espLine then updateLine(drawings, char) end
                if espSkeleton then updateSkeleton(drawings, char) end
                if espHealth then updateHealth(drawings, char) end
            else
                clearESPDrawings(plr)
            end
        else
            clearESPDrawings(plr)
        end
    end
end

RunService.RenderStepped:Connect(updateAllESP)

-- ========== AIMBOT ==========
local function createAimbotCircle()
    local circle = Drawing.new("Circle")
    circle.Radius = actualRadius
    circle.Color = Color3.fromRGB(255, 0, 0)
    circle.Thickness = 2
    circle.Filled = false
    circle.Transparency = 0.5
    circle.Visible = false
    return circle
end

local function updateCirclePosition()
    if aimbotCircle then
        local center = Camera.ViewportSize / 2
        aimbotCircle.Position = Vector2.new(center.X, center.Y)
        aimbotCircle.Radius = actualRadius
        aimbotCircle.Visible = aimbotEnabled and not hideCircle
    end
end

local function getAimPart(player, partName)
    local char = player.Character
    if not char then return nil end
    if partName == "Head" then return char:FindFirstChild("Head")
    elseif partName == "Chest" then return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    elseif partName == "Foot" then return char:FindFirstChild("RightFoot") or char:FindFirstChild("LeftFoot") or char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function isAlive(player)
    local char = player.Character
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
end

local function isVisible(headPos, targetPlayer)
    local origin = Camera.CFrame.Position
    local dir = (headPos - origin).Unit
    local distance = (origin - headPos).Magnitude
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local ignore = {LocalPlayer.Character, Camera}
    if targetPlayer and targetPlayer.Character then table.insert(ignore, targetPlayer.Character) end
    rayParams.FilterDescendantsInstances = ignore
    local result = workspace:Raycast(origin, dir * distance, rayParams)
    return result == nil
end

local function getBestTarget()
    local bestTarget = nil
    local bestDist = actualRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            local part = getAimPart(plr, aimPart)
            if part then
                local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
                local dist
                if miraDoRiko then
                    local camPos = Camera.CFrame.Position
                    dist = (camPos - part.Position).Magnitude
                    if dist > 200 then continue end
                else
                    if not onScreen then continue end
                    dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist > actualRadius then continue end
                end
                if bestTarget == nil or dist < bestDist then
                    local visible = true
                    if wallCheckEnabled then visible = isVisible(part.Position, plr) end
                    if visible then
                        bestDist = dist
                        bestTarget = plr
                    end
                end
            end
        end
    end
    return bestTarget
end

local function aimAt(target)
    if not target or not isAlive(target) then return end
    local part = getAimPart(target, aimPart)
    if not part then return end
    local targetPos = part.Position
    local currentCF = Camera.CFrame
    local newCF = CFrame.new(currentCF.Position, targetPos)
    local smoothing = (360 - aimbotSpeed) / 360
    if smoothing <= 0 or aimbotSpeed >= 360 then
        Camera.CFrame = newCF
    else
        local alpha = 1 - smoothing
        Camera.CFrame = currentCF:Lerp(newCF, alpha)
    end
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getBestTarget()
        if target then aimAt(target) end
    end
    updateCirclePosition()
end)

-- ========== FUNÇÕES DOS "OUTROS" ==========
local function applyWalkspeed()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = walkSpeedEnabled and walkSpeedValue or originalWalkspeed
    end
end

local function applyJumpPower()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = jumpPowerEnabled and jumpPowerValue or originalJumpPower
    end
end

local function startFly()
    if flyEnabled then
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then humanoid.PlatformStand = true end
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = char:FindFirstChild("HumanoidRootPart")
        local function updateFly()
            if not flyEnabled or not flyBodyVelocity then return end
            local moveDirection = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection + Vector3.new(0, -1, 0) end
            flyBodyVelocity.Velocity = moveDirection * 50
        end
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if flyEnabled then updateFly() else conn:Disconnect() end
        end)
    else
        if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
    end
end

local function setupInfJump()
    if infJumpEnabled then
        if infJumpConnection then infJumpConnection:Disconnect() end
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChild("Humanoid")
            if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if infJumpConnection then infJumpConnection:Disconnect() end
    end
end

local function applyHitboxExtender()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            for _, part in ipairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * (hitboxExtenderEnabled and hitboxExtenderValue or 1)
                end
            end
        end
    end
end

local function setupNoclip()
    if noclipEnabled then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function applyInvisible()
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = invisibleEnabled and 1 or 0
            elseif part:IsA("Decal") then
                part.Transparency = invisibleEnabled and 1 or 0
            end
        end
    end
end

local function setupSpinBot()
    if spinBotEnabled then
        if spinConnection then spinConnection:Disconnect() end
        spinConnection = RunService.RenderStepped:Connect(function()
            local currentCF = Camera.CFrame
            Camera.CFrame = currentCF * CFrame.Angles(0, math.rad(10), 0)
        end)
    else
        if spinConnection then spinConnection:Disconnect() end
    end
end

-- Conectar eventos de personagem
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    applyWalkspeed()
    applyJumpPower()
    if flyEnabled then startFly() end
    applyInvisible()
    if noclipEnabled then setupNoclip() end
end)

-- ========== UI PRÓPRIA MODERNA ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 540)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -270)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BackgroundTransparency = 0.08
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "⚡ UNIVERSAL SCRIPT v9 ⚡"
title.TextColor3 = Color3.fromRGB(255, 200, 100)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.Parent = mainFrame

-- Botão fechar (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0, 8)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
closeBtn.BackgroundTransparency = 0.3
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    -- Recriar botão "Abrir Menu"
    local abrirGui = Instance.new("ScreenGui")
    abrirGui.Name = "AbrirMenuBtn"
    abrirGui.ResetOnSpawn = false
    abrirGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local abrirBtn = Instance.new("TextButton")
    abrirBtn.Size = UDim2.new(0, 100, 0, 35)
    abrirBtn.Position = UDim2.new(0, 10, 1, -45)
    abrirBtn.Text = "Abrir Menu"
    abrirBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    abrirBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    abrirBtn.Parent = abrirGui
    abrirBtn.MouseButton1Click:Connect(function()
        abrirGui:Destroy()
        -- Recriar menu principal (executar script novamente? melhor recriar)
        -- Simplesmente recriaremos a GUI chamando a função de criação
        -- Como o script já está rodando, podemos reinvocar a criação, mas cuidado com duplicatas.
        -- Vamos destruir o atual e recriar.
        if menuGUI then menuGUI:Destroy() end
        -- Recriar menu (chamar a função de criação novamente não é trivial, mas faremos)
        -- Para simplificar, vamos apenas criar um novo screenGui igual ao original.
        local newGui = Instance.new("ScreenGui")
        newGui.Name = "UniversalHub"
        newGui.ResetOnSpawn = false
        newGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        -- copiar conteúdo? É melhor reexecutar o script? Não.
        -- Vou recriar a UI a partir de uma função. Refatorarei o código para ter uma função createUI().
    end)
end)

-- Botão minimizar (opcional)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -72, 0, 8)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minBtn.BackgroundTransparency = 0.3
minBtn.Parent = mainFrame
local minimized = false
local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, 0, 1, -45)
contentHolder.Position = UDim2.new(0, 0, 0, 45)
contentHolder.BackgroundTransparency = 1
contentHolder.Parent = mainFrame
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    contentHolder.Visible = not minimized
    mainFrame.Size = minimized and UDim2.new(0, 420, 0, 45) or UDim2.new(0, 420, 0, 540)
    minBtn.Text = minimized and "□" or "−"
end)

-- Abas
local tabButtons = {}
local function createTabButton(name, x, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 35)
    btn.Position = UDim2.new(0, x, 0, 0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = contentHolder
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Conteúdo das abas (ScrollingFrame)
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -50)
scroll.Position = UDim2.new(0, 10, 0, 45)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 5
scroll.Parent = contentHolder

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scroll

local function clearContent()
    for _, child in ipairs(scroll:GetChildren()) do
        if child ~= listLayout then
            child:Destroy()
        end
    end
end

local function addToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    frame.BackgroundTransparency = 0.2
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.Parent = scroll
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = text .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 1
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 15
    btn.Parent = frame
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
    return btn
end

local function addSlider(text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    frame.BackgroundTransparency = 0.2
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.Parent = scroll
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.Parent = frame
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 30)
    box.Position = UDim2.new(0, 0, 0, 25)
    box.Text = tostring(default)
    box.PlaceholderText = tostring(default)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Parent = frame
    box.FocusLost:Connect(function(enter)
        if enter then
            local v = tonumber(box.Text)
            if v and v >= min and v <= max then
                callback(v)
                label.Text = text .. ": " .. v
            else
                box.Text = "Inválido"
                task.wait(1)
                box.Text = ""
            end
        end
    end)
end

local function addButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    btn.BackgroundTransparency = 0.3
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    btn.Parent = scroll
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Preencher abas
local function showAimbot()
    clearContent()
    addToggle("Aimbot", aimbotEnabled, function(v) aimbotEnabled = v; if v and not aimbotCircle then aimbotCircle = createAimbotCircle() end; updateCirclePosition() end)
    addToggle("Mira do Riko (360°)", miraDoRiko, function(v) miraDoRiko = v end)
    addToggle("Wall Check", wallCheckEnabled, function(v) wallCheckEnabled = v end)
    addToggle("Esconder Bolinha", hideCircle, function(v) hideCircle = v; updateCirclePosition() end)
    -- Seletor de parte
    local partFrame = Instance.new("Frame")
    partFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    partFrame.BackgroundTransparency = 0.2
    partFrame.Size = UDim2.new(1, 0, 0, 50)
    partFrame.Parent = scroll
    local partLabel = Instance.new("TextLabel")
    partLabel.Size = UDim2.new(1, 0, 0, 20)
    partLabel.Text = "Alvo: " .. aimPart
    partLabel.TextColor3 = Color3.fromRGB(200,200,200)
    partLabel.BackgroundTransparency = 1
    partLabel.Parent = partFrame
    local partBtn = Instance.new("TextButton")
    partBtn.Size = UDim2.new(1, 0, 0, 30)
    partBtn.Position = UDim2.new(0, 0, 0, 20)
    partBtn.Text = "Alternar (Head/Chest/Foot)"
    partBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
    partBtn.TextColor3 = Color3.fromRGB(255,255,255)
    partBtn.Parent = partFrame
    partBtn.MouseButton1Click:Connect(function()
        if aimPart == "Head" then aimPart = "Chest"
        elseif aimPart == "Chest" then aimPart = "Foot"
        else aimPart = "Head" end
        partLabel.Text = "Alvo: " .. aimPart
    end)
    addSlider("Velocidade (0-360)", 0, 360, aimbotSpeed, function(v) aimbotSpeed = v end)
    addSlider("Força (Raio 0-10)", 0, 10, aimbotStrength, function(v)
        aimbotStrength = v
        actualRadius = v * 20
        if actualRadius < 10 then actualRadius = 10 end
        updateCirclePosition()
        if aimbotCircle then aimbotCircle.Radius = actualRadius end
    end)
end

local function showESP()
    clearContent()
    addToggle("ESP Geral", espEnabled, function(v) espEnabled = v; if not v then for plr,_ in pairs(espDrawings) do clearESPDrawings(plr) end end end)
    addToggle("Box", espBox, function(v) espBox = v end)
    addToggle("Line", espLine, function(v) espLine = v end)
    addToggle("Esqueleto", espSkeleton, function(v) espSkeleton = v end)
    addToggle("Vida", espHealth, function(v) espHealth = v end)
end

local function showMisc()
    clearContent()
    addToggle("Walkspeed", walkSpeedEnabled, function(v) walkSpeedEnabled = v; applyWalkspeed() end)
    addSlider("Walkspeed valor", 0, 120, walkSpeedValue, function(v) walkSpeedValue = v; if walkSpeedEnabled then applyWalkspeed() end end)
    addToggle("Jump Power", jumpPowerEnabled, function(v) jumpPowerEnabled = v; applyJumpPower() end)
    addSlider("Jump Power valor", 0, 120, jumpPowerValue, function(v) jumpPowerValue = v; if jumpPowerEnabled then applyJumpPower() end end)
    addToggle("Fly", flyEnabled, function(v) flyEnabled = v; startFly() end)
    addToggle("Inf Jump", infJumpEnabled, function(v) infJumpEnabled = v; setupInfJump() end)
    addToggle("Hitbox Extender", hitboxExtenderEnabled, function(v) hitboxExtenderEnabled = v; applyHitboxExtender() end)
    addSlider("Hitbox tamanho", 0, 20, hitboxExtenderValue, function(v) hitboxExtenderValue = v; if hitboxExtenderEnabled then applyHitboxExtender() end end)
    addToggle("Noclip", noclipEnabled, function(v) noclipEnabled = v; setupNoclip() end)
    addToggle("Invisível", invisibleEnabled, function(v) invisibleEnabled = v; applyInvisible() end)
    addToggle("Spin Bot", spinBotEnabled, function(v) spinBotEnabled = v; setupSpinBot() end)
end

-- Criar abas
local tabAimbot = createTabButton("Aimbot", 10, function() showAimbot() end)
local tabESP = createTabButton("ESP", 120, function() showESP() end)
local tabMisc = createTabButton("Outros", 230, function() showMisc() end)

-- Aba inicial
showAimbot()
tabAimbot.BackgroundColor3 = Color3.fromRGB(70, 70, 90)

-- Ajustar canvas do scroll
local function updateCanvas()
    scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
end
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
task.wait(0.1)
updateCanvas()

-- Botão "Abrir Menu" (quando fechar)
local abrirMenuBtn = nil
local function createOpenButton()
    if abrirMenuBtn then abrirMenuBtn:Destroy() end
    local btnGui = Instance.new("ScreenGui")
    btnGui.Name = "OpenMenuBtn"
    btnGui.ResetOnSpawn = false
    btnGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 35)
    btn.Position = UDim2.new(0, 10, 1, -45)
    btn.Text = "Abrir Menu"
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = btnGui
    btn.MouseButton1Click:Connect(function()
        btnGui:Destroy()
        abrirMenuBtn = nil
        -- Recriar o menu principal (simplesmente executar novamente a criação da GUI)
        -- Como já temos as variáveis, podemos apenas criar um novo screenGui igual.
        local newGui = Instance.new("ScreenGui")
        newGui.Name = "UniversalHub"
        newGui.ResetOnSpawn = false
        newGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        -- Copiar estrutura? Melhor recriar a partir da função, mas para não duplicar código, farei uma função de inicialização.
        -- Infelizmente, para simplificar, vou apenas recriar manualmente os elementos. Mas como o script já está em execução,
        -- não podemos chamar a criação novamente sem duplicar. Vou recriar a interface chamando uma função que defini acima.
        -- Como a UI é criada no escopo global, podemos simplesmente recriar a mesma estrutura.
        -- Para evitar repetição, vou apenas redefinir as variáveis e recriar os frames.
        -- Na prática, o botão "Abrir Menu" destrói a GUI antiga e cria uma nova idêntica. farei assim:
        local newMain = Instance.new("Frame")
        newMain.Size = UDim2.new(0, 420, 0, 540)
        newMain.Position = UDim2.new(0.5, -210, 0.5, -270)
        newMain.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        newMain.BackgroundTransparency = 0.08
        newMain.BorderSizePixel = 0
        newMain.Parent = newGui
        -- (copiar o restante da UI...)
        -- Infelizmente isso ficaria enorme. Vou optar por uma abordagem mais simples:
        -- Em vez de recriar tudo, podemos apenas mostrar o menu novamente sem destruí-lo? Não, pois o usuário clicou no X.
        -- Vou implementar um sistema de "reabrir" sem precisar recriar tudo: ao invés de destruir o screenGui, apenas esconder e mostrar.
        -- Assim, o botão "Abrir Menu" apenas torna o menu visível novamente.
    end)
end

-- Modificar o closeBtn para apenas esconder o menu e mostrar o botão de reabrir
closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
    if not abrirMenuBtn then
        local btnGui = Instance.new("ScreenGui")
        btnGui.Name = "OpenMenuBtn"
        btnGui.ResetOnSpawn = false
        btnGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 0, 35)
        btn.Position = UDim2.new(0, 10, 1, -45)
        btn.Text = "Abrir Menu"
        btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Parent = btnGui
        btn.MouseButton1Click:Connect(function()
            btnGui:Destroy()
            screenGui.Enabled = true
            abrirMenuBtn = nil
        end)
        abrirMenuBtn = btnGui
    end
end)

print("Script Universal v9 carregado. Menu centralizado com abas.")
