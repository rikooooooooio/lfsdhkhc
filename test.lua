-- Carregar Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "🐕 Doge Hub",
    SubTitle = "rikobby",
    TabWidth = 140,
    Size = UDim2.fromOffset(620, 520),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Abas
local TabAimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" })
local TabVisuals = Window:AddTab({ Title = "Visuals", Icon = "eye" })
local TabMisc = Window:AddTab({ Title = "Misc", Icon = "settings" })

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ========== VARIÁVEIS ==========
-- Aimbot
local AimbotEnabled = true
local AimFOV = 150
local Smoothness = 0.3
local AimPart = "Head"
local TeamCheck = true
local WallCheckEnabled = true
local AimByDistance = false
local MaxDistance = 100
local AimByLowHealth = false
local LowHealthThreshold = 30
local OnlyOnShoot = false
local RandomSmooth = false
local DelayBetweenTargets = false
local DelayTime = 0.2
local lastTarget = nil
local lastTargetTime = 0
local IgnoreFriends = false
local FriendNames = {}
local DistanceLimit = false
local DistanceLimitValue = 200

-- ESP Visuals
local ESPEnabled = true
local ESPBox = true
local ESPSkeleton = true
local ESPLine = true
local ESPHealth = true
local ESPDistance = true
local ShowFOVCircle = true
local FOVCircleColor = Color3.fromRGB(255,255,255)
local FOVCircleTransparency = 0.5

-- Misc
local FlyEnabled = false
local NoclipEnabled = false
local InfiniteJumpEnabled = false
local BunnyHopEnabled = false
local DashEnabled = false
local DashCooldown = 0
local SpeedEnabled = false
local SpeedValue = 16
local TriggerbotEnabled = false
local TriggerDelay = 0.05
local FullBrightEnabled = false
local FOVChanger = false
local FOVValue = 70
local RemoveEffects = false
local LowGraphics = false
local AntiFallEnabled = false
local AntiKickEnabled = false

-- suporte
local flying = false
local bodyVelocity = nil
local noclip = false
local infiniteJumpConn = nil
local antiAfkConn = nil
local originalFOV = Camera.FieldOfView
local originalBrightness = game:GetService("Lighting").Brightness
local originalClockTime = game:GetService("Lighting").ClockTime

-- ========== FUNÇÕES ==========
local function IsEnemy(p)
    if p == LocalPlayer then return false end
    if not p.Character or not p.Character:FindFirstChild("Humanoid") then return false end
    if p.Character.Humanoid.Health <= 0 then return false end
    if TeamCheck and LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team then return false end
    if IgnoreFriends and FriendNames[p.Name] then return false end
    return true
end

local function IsVisible(character, part)
    if not WallCheckEnabled then return true end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character, Camera}
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

local function GetTargetScore(target)
    local char = target.Character
    if not char then return math.huge end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return math.huge end
    local distance = (root.Position - (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new())).Magnitude
    local health = char.Humanoid.Health
    local score = 0
    if AimByDistance then
        if distance > MaxDistance then return math.huge end
        score = score + distance * 1.0
    end
    if AimByLowHealth then
        if health > LowHealthThreshold then score = score + 1000 end
        score = score + (100 - health) * 2
    end
    if not AimByDistance and not AimByLowHealth then
        score = distance
    end
    return score
end

local function GetClosestTarget()
    local bestScore = math.huge
    local best = nil
    local center = Camera.ViewportSize / 2
    for _, p in ipairs(Players:GetPlayers()) do
        if IsEnemy(p) then
            local part = p.Character and p.Character:FindFirstChild(AimPart)
            if part and IsVisible(p.Character, part) then
                local pos, on = Camera:WorldToScreenPoint(part.Position)
                if on then
                    local distToCenter = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if distToCenter <= AimFOV then
                        local score = GetTargetScore(p)
                        if score < bestScore then
                            bestScore = score
                            best = p
                        end
                    end
                end
            end
        end
    end
    return best
end

local function AimAt(target)
    if not target or not target.Character then return end
    local targetPart = target.Character:FindFirstChild(AimPart) or target.Character:FindFirstChild("Head")
    if not targetPart then return end
    local targetCF = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
    local smooth = Smoothness
    if RandomSmooth then smooth = smooth * (0.8 + math.random() * 0.4) end
    Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 - smooth)
end

-- Loop aimbot
RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end
    if OnlyOnShoot then
        if not (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then
            return
        end
    end
    local target = GetClosestTarget()
    if target then
        if DelayBetweenTargets and lastTarget and lastTarget ~= target then
            if tick() - lastTargetTime < DelayTime then return end
        end
        AimAt(target)
        lastTarget = target
        lastTargetTime = tick()
    end
end)

-- ========== ESP COM DRAWING E BILLBOARD ==========
local espDrawings = {}
local function ClearESPObjects()
    for _, obj in pairs(espDrawings) do if obj then obj:Remove() end end
    espDrawings = {}
end

local function DrawBox(player)
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if not root then return end
    local topPart = char:FindFirstChild("Head") or root
    local bottomPart = root
    local topPos, topOn = Camera:WorldToScreenPoint(topPart.Position + Vector3.new(0, 1, 0))
    local bottomPos, bottomOn = Camera:WorldToScreenPoint(bottomPart.Position - Vector3.new(0, 2, 0))
    if topOn and bottomOn then
        local height = math.abs(topPos.Y - bottomPos.Y)
        local width = height * 0.6
        local box = Drawing.new("Square")
        box.Position = Vector2.new(topPos.X - width/2, topPos.Y)
        box.Size = Vector2.new(width, height)
        box.Color = Color3.fromRGB(255, 0, 0)
        box.Thickness = 2
        box.Filled = false
        box.Transparency = 0.6
        table.insert(espDrawings, box)
    end
end

local function DrawSkeleton(player)
    local char = player.Character
    if not char then return end
    local parts = {
        Head = char:FindFirstChild("Head"),
        UpperTorso = char:FindFirstChild("UpperTorso"),
        LowerTorso = char:FindFirstChild("LowerTorso"),
        HumanoidRootPart = char:FindFirstChild("HumanoidRootPart"),
        LeftUpperArm = char:FindFirstChild("LeftUpperArm"),
        RightUpperArm = char:FindFirstChild("RightUpperArm"),
        LeftLowerArm = char:FindFirstChild("LeftLowerArm"),
        RightLowerArm = char:FindFirstChild("RightLowerArm"),
        LeftUpperLeg = char:FindFirstChild("LeftUpperLeg"),
        RightUpperLeg = char:FindFirstChild("RightUpperLeg"),
        LeftLowerLeg = char:FindFirstChild("LeftLowerLeg"),
        RightLowerLeg = char:FindFirstChild("RightLowerLeg"),
    }
    local connections = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"LowerTorso", "HumanoidRootPart"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"},
    }
    for _, conn in ipairs(connections) do
        local a = parts[conn[1]]
        local b = parts[conn[2]]
        if a and b then
            local posA, onA = Camera:WorldToScreenPoint(a.Position)
            local posB, onB = Camera:WorldToScreenPoint(b.Position)
            if onA and onB then
                local line = Drawing.new("Line")
                line.From = Vector2.new(posA.X, posA.Y)
                line.To = Vector2.new(posB.X, posB.Y)
                line.Color = Color3.fromRGB(255, 255, 255)
                line.Thickness = 2
                line.Transparency = 0.7
                table.insert(espDrawings, line)
            end
        end
    end
end

local function DrawLineToPlayer(player)
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        local pos, on = Camera:WorldToScreenPoint(head.Position)
        if on then
            local center = Camera.ViewportSize / 2
            local line = Drawing.new("Line")
            line.From = Vector2.new(center.X, center.Y)
            line.To = Vector2.new(pos.X, pos.Y)
            line.Color = Color3.fromRGB(255, 0, 0)
            line.Thickness = 1
            line.Transparency = 0.5
            table.insert(espDrawings, line)
        end
    end
end

local fovCircle = nil
local function UpdateFOVCircle()
    if not ShowFOVCircle then
        if fovCircle then fovCircle:Remove(); fovCircle = nil end
        return
    end
    if not fovCircle then
        fovCircle = Drawing.new("Circle")
        fovCircle.NumSides = 64
        fovCircle.Thickness = 2
        fovCircle.Filled = false
    end
    local mousePos = UserInputService:GetMouseLocation()
    fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    fovCircle.Radius = AimFOV
    fovCircle.Color = FOVCircleColor
    fovCircle.Transparency = FOVCircleTransparency
    fovCircle.Visible = true
end

RunService.RenderStepped:Connect(function()
    UpdateFOVCircle()
    if not ESPEnabled then ClearESPObjects(); return end
    ClearESPObjects()
    for _, p in ipairs(Players:GetPlayers()) do
        if IsEnemy(p) and p.Character then
            if ESPBox then DrawBox(p) end
            if ESPSkeleton then DrawSkeleton(p) end
            if ESPLine then DrawLineToPlayer(p) end
        end
    end
end)

-- Billboard para vida e distância
local function CreateESPBillboard(player)
    if not player or not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    local old = head:FindFirstChild("MobileESP")
    if old then old:Destroy() end
    if not ESPHealth and not ESPDistance then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MobileESP"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 120, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head
    if ESPHealth then
        local healthLabel = Instance.new("TextLabel")
        healthLabel.Name = "Health"
        healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        healthLabel.TextStrokeTransparency = 0.5
        healthLabel.Font = Enum.Font.GothamBold
        healthLabel.TextSize = 12
        healthLabel.Parent = billboard
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local function updateHealth()
                healthLabel.Text = "❤️ " .. math.floor(humanoid.Health)
            end
            updateHealth()
            humanoid.HealthChanged:Connect(updateHealth)
        end
    end
    if ESPDistance then
        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "Distance"
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextSize = 10
        distLabel.Parent = billboard
        local function updateDistance()
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and myRoot then
                local dist = math.floor((root.Position - myRoot.Position).Magnitude)
                distLabel.Text = dist .. "m"
            end
        end
        updateDistance()
        RunService.Heartbeat:Connect(updateDistance)
    end
end

local function ClearAllESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local esp = head:FindFirstChild("MobileESP")
            if esp then esp:Destroy() end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not ESPEnabled then ClearAllESP(); return end
    for _, p in ipairs(Players:GetPlayers()) do
        if IsEnemy(p) and p.Character and p.Character:FindFirstChild("Head") then
            CreateESPBillboard(p)
        end
    end
end)
Players.PlayerRemoving:Connect(ClearAllESP)

-- ========== MISC FUNÇÕES (simplificadas) ==========
local function setFly(on)
    flying = on
    local char = LocalPlayer.Character
    if not char then return end
    if on then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = true end
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bodyVelocity.Parent = char:FindFirstChild("HumanoidRootPart")
        local function updateFly()
            if not flying or not bodyVelocity then return end
            local moveDirection = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
            bodyVelocity.Velocity = moveDirection * 50
        end
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not flying then conn:Disconnect() end
            updateFly()
        end)
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

local function setNoclip(on)
    noclip = on
    local function noclipLoop()
        if not noclip then return end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
    local conn
    conn = RunService.Stepped:Connect(function()
        if not noclip then conn:Disconnect() end
        noclipLoop()
    end)
end

local function setInfiniteJump(on)
    if on then
        if infiniteJumpConn then infiniteJumpConn:Disconnect() end
        infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if infiniteJumpConn then infiniteJumpConn:Disconnect() end
    end
end

local function dash()
    if DashCooldown > tick() then return end
    DashCooldown = tick() + 1
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local direction = Camera.CFrame.LookVector * 30
        hrp.Velocity = Vector3.new(direction.X, 0, direction.Z)
    end
end

local function setFullBright(on)
    local lighting = game:GetService("Lighting")
    if on then
        originalBrightness = lighting.Brightness
        originalClockTime = lighting.ClockTime
        lighting.Brightness = 2
        lighting.ClockTime = 12
        lighting.FogEnd = 100000
    else
        lighting.Brightness = originalBrightness
        lighting.ClockTime = originalClockTime
        lighting.FogEnd = 100000
    end
end

local function setFOVChanger(on)
    if on then Camera.FieldOfView = FOVValue else Camera.FieldOfView = originalFOV end
end

-- Triggerbot
RunService.RenderStepped:Connect(function()
    if not TriggerbotEnabled then return end
    local target = GetClosestTarget()
    if target then
        mouse1click()
        task.wait(TriggerDelay)
    end
end)

-- Velocidade loop
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and SpeedEnabled then
            hum.WalkSpeed = SpeedValue
        end
    end
end)

-- ========== INTERFACE FLUENT ==========
local SecAimbot = TabAimbot:AddSection("Configurações principais")
local ToggleAimbot = SecAimbot:AddToggle("ToggleAimbot", { Title = "Ativar Aimbot", Default = true })
ToggleAimbot:OnChanged(function(v) AimbotEnabled = v end)
local FOVSlider = SecAimbot:AddSlider("FOVSlider", { Title = "Campo de visão (pixels)", Default = 150, Min = 50, Max = 300, Rounding = 0 })
FOVSlider:OnChanged(function(v) AimFOV = v end)
local SmoothSlider = SecAimbot:AddSlider("SmoothSlider", { Title = "Suavidade", Default = 0.3, Min = 0, Max = 0.9, Rounding = 2 })
SmoothSlider:OnChanged(function(v) Smoothness = v end)
local BodyPart = SecAimbot:AddDropdown("BodyPart", { Title = "Parte do corpo", Values = { "Head", "HumanoidRootPart", "Torso" }, Default = "Head" })
BodyPart:OnChanged(function(v) AimPart = v end)
local TeamToggle = SecAimbot:AddToggle("TeamToggle", { Title = "Ignorar aliados", Default = true })
TeamToggle:OnChanged(function(v) TeamCheck = v end)
local WallToggle = SecAimbot:AddToggle("WallToggle", { Title = "Wall Check", Default = true })
WallToggle:OnChanged(function(v) WallCheckEnabled = v end)

local SecAdv = TabAimbot:AddSection("Seleção de alvo")
local DistToggle = SecAdv:AddToggle("DistToggle", { Title = "Aimbot por distância", Default = false })
DistToggle:OnChanged(function(v) AimByDistance = v end)
local DistSlider = SecAdv:AddSlider("DistSlider", { Title = "Distância máxima (m)", Default = 100, Min = 10, Max = 500, Rounding = 0 })
DistSlider:OnChanged(function(v) MaxDistance = v end)
local HealthToggle = SecAdv:AddToggle("HealthToggle", { Title = "Priorizar menor vida", Default = false })
HealthToggle:OnChanged(function(v) AimByLowHealth = v end)
local HealthSlider = SecAdv:AddSlider("HealthSlider", { Title = "Vida limite", Default = 30, Min = 1, Max = 100, Rounding = 0 })
HealthSlider:OnChanged(function(v) LowHealthThreshold = v end)
local OnlyShoot = SecAdv:AddToggle("OnlyShoot", { Title = "Somente ao atirar", Default = false })
OnlyShoot:OnChanged(function(v) OnlyOnShoot = v end)
local RandSmooth = SecAdv:AddToggle("RandSmooth", { Title = "Smooth aleatório", Default = false })
RandSmooth:OnChanged(function(v) RandomSmooth = v end)
local DelayToggleAdv = SecAdv:AddToggle("DelayToggleAdv", { Title = "Delay entre alvos", Default = false })
DelayToggleAdv:OnChanged(function(v) DelayBetweenTargets = v end)
local DelaySliderAdv = SecAdv:AddSlider("DelaySliderAdv", { Title = "Delay (s)", Default = 0.2, Min = 0.05, Max = 1, Rounding = 2 })
DelaySliderAdv:OnChanged(function(v) DelayTime = v end)
local IgnoreFriendsToggle = SecAdv:AddToggle("IgnoreFriendsToggle", { Title = "Ignorar amigos", Default = false })
IgnoreFriendsToggle:OnChanged(function(v) IgnoreFriends = v end)
local FriendInput = SecAdv:AddInput("FriendInput", { Title = "Nomes (vírgula)", Default = "", Placeholder = "João, Maria" })
FriendInput:OnChanged(function(v)
    FriendNames = {}
    for name in string.gmatch(v, "[^,]+") do
        FriendNames[name:gsub("^%s*(.-)%s*$", "%1")] = true
    end
end)

-- Aba Visuals
local SecVis = TabVisuals:AddSection("ESP Visual")
local ESPEnable = SecVis:AddToggle("ESPEnable", { Title = "Ativar ESP", Default = true })
ESPEnable:OnChanged(function(v) ESPEnabled = v; if not v then ClearAllESP(); ClearESPObjects() end end)
local BoxVis = SecVis:AddToggle("BoxVis", { Title = "Box ESP", Default = true })
BoxVis:OnChanged(function(v) ESPBox = v end)
local SkeletonVis = SecVis:AddToggle("SkeletonVis", { Title = "Esqueleto", Default = true })
SkeletonVis:OnChanged(function(v) ESPSkeleton = v end)
local LineVis = SecVis:AddToggle("LineVis", { Title = "Linha de mira", Default = true })
LineVis:OnChanged(function(v) ESPLine = v end)
local HealthVis = SecVis:AddToggle("HealthVis", { Title = "Vida (texto)", Default = true })
HealthVis:OnChanged(function(v) ESPHealth = v end)
local DistVis = SecVis:AddToggle("DistVis", { Title = "Distância (texto)", Default = true })
DistVis:OnChanged(function(v) ESPDistance = v end)
local CircleVis = SecVis:AddToggle("CircleVis", { Title = "Círculo de FOV", Default = true })
CircleVis:OnChanged(function(v) ShowFOVCircle = v end)
local CircleColorVis = SecVis:AddDropdown("CircleColorVis", { Title = "Cor do círculo", Values = { "Branco", "Vermelho", "Verde", "Azul" }, Default = "Branco" })
CircleColorVis:OnChanged(function(v)
    if v == "Vermelho" then FOVCircleColor = Color3.fromRGB(255,0,0)
    elseif v == "Verde" then FOVCircleColor = Color3.fromRGB(0,255,0)
    elseif v == "Azul" then FOVCircleColor = Color3.fromRGB(0,0,255)
    else FOVCircleColor = Color3.fromRGB(255,255,255) end
end)
local CircleTranspVis = SecVis:AddSlider("CircleTranspVis", { Title = "Transparência", Default = 0.5, Min = 0, Max = 1, Rounding = 1 })
CircleTranspVis:OnChanged(function(v) FOVCircleTransparency = v end)

-- Aba Misc
local SecMove = TabMisc:AddSection("Movimento")
local FlyMisc = SecMove:AddToggle("FlyMisc", { Title = "Fly", Default = false })
FlyMisc:OnChanged(setFly)
local NoclipMisc = SecMove:AddToggle("NoclipMisc", { Title = "Noclip", Default = false })
NoclipMisc:OnChanged(setNoclip)
local InfJumpMisc = SecMove:AddToggle("InfJumpMisc", { Title = "Pulo infinito", Default = false })
InfJumpMisc:OnChanged(setInfiniteJump)
local DashButtonMisc = SecMove:AddButton({ Title = "Dash", Callback = dash })
local SpeedMisc = SecMove:AddToggle("SpeedMisc", { Title = "Super Velocidade", Default = false })
SpeedMisc:OnChanged(function(v) SpeedEnabled = v end)
local SpeedSliderMisc = SecMove:AddSlider("SpeedSliderMisc", { Title = "Velocidade", Default = 16, Min = 16, Max = 250, Rounding = 0 })
SpeedSliderMisc:OnChanged(function(v) SpeedValue = v; if SpeedEnabled and LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = v end end)

local SecCombat = TabMisc:AddSection("Combate")
local TriggerMisc = SecCombat:AddToggle("TriggerMisc", { Title = "Triggerbot", Default = false })
TriggerMisc:OnChanged(function(v) TriggerbotEnabled = v end)
local TriggerDelayMisc = SecCombat:AddSlider("TriggerDelayMisc", { Title = "Delay (s)", Default = 0.05, Min = 0, Max = 0.5, Rounding = 2 })
TriggerDelayMisc:OnChanged(function(v) TriggerDelay = v end)

local SecVisualMisc = TabMisc:AddSection("Visuais")
local FullBrightMisc = SecVisualMisc:AddToggle("FullBrightMisc", { Title = "Full Bright", Default = false })
FullBrightMisc:OnChanged(setFullBright)
local FOVChangerMisc = SecVisualMisc:AddToggle("FOVChangerMisc", { Title = "FOV Changer", Default = false })
FOVChangerMisc:OnChanged(setFOVChanger)
local FOVValueMisc = SecVisualMisc:AddSlider("FOVValueMisc", { Title = "FOV", Default = 70, Min = 70, Max = 120, Rounding = 0 })
FOVValueMisc:OnChanged(function(v) FOVValue = v; if FOVChanger then Camera.FieldOfView = v end end)

local SecSafety = TabMisc:AddSection("Segurança")
local AntiFallMisc = SecSafety:AddToggle("AntiFallMisc", { Title = "Anti-Fall", Default = false })
AntiFallMisc:OnChanged(function(v) AntiFallEnabled = v end)
local AntiKickMisc = SecSafety:AddToggle("AntiKickMisc", { Title = "Anti-Kick", Default = false })
AntiKickMisc:OnChanged(function(v)
    AntiKickEnabled = v
    if v then
        if antiAfkConn then antiAfkConn:Disconnect() end
        antiAfkConn = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0,0,0.01)
                task.wait(30)
                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame - Vector3.new(0,0,0.01)
            end
        end)
    else
        if antiAfkConn then antiAfkConn:Disconnect() end
    end
end)

-- Botão descarregar
SecSafety:AddButton({ Title = "Descarregar Doge Hub", Callback = function()
    ClearAllESP()
    ClearESPObjects()
    if fovCircle then fovCircle:Remove() end
    if bodyVelocity then bodyVelocity:Destroy() end
    if infiniteJumpConn then infiniteJumpConn:Disconnect() end
    if antiAfkConn then antiAfkConn:Disconnect() end
    Fluent:Destroy()
    local gui = game:GetService("CoreGui"):FindFirstChild("FloatingIcon")
    if gui then gui:Destroy() end
end })

-- ========== ÍCONE FLUTUANTE ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FloatingIcon"
screenGui.Parent = game:GetService("CoreGui")
local iconBtn = Instance.new("ImageButton")
iconBtn.Size = UDim2.new(0, 50, 0, 50)
iconBtn.Position = UDim2.new(0, 10, 0, 10)
iconBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
iconBtn.BackgroundTransparency = 0.3
iconBtn.Image = "rbxassetid://6031088679"
iconBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
iconBtn.Parent = screenGui
local dragging = false
local dragStart, btnStart
iconBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = inp.Position
        btnStart = iconBtn.Position
    end
end)
iconBtn.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = inp.Position - dragStart
        iconBtn.Position = UDim2.new(btnStart.X.Scale, btnStart.X.Offset + delta.X, btnStart.Y.Scale, btnStart.Y.Offset + delta.Y)
    end
end)
iconBtn.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
iconBtn.MouseButton1Click:Connect(function()
    Window:Toggle()
end)

-- Notificação
Fluent:Notify({ Title = "Doge Hub", Content = "Carregado! Menu: Left Control ou ícone.", Duration = 4 })