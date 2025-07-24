--[[
  🚀 SonicHub PRO MAX - Blox Fruits Script 🚀
  Versão 8.4 | Interface e botões funcionando corretamente
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- Espera o personagem carregar completamente
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local PlayerGui = Player:WaitForChild("PlayerGui")

-- AntiReturn para evitar quedas na hora do teleporte ou voo
local function createAntiReturn()
    local old = Character:FindFirstChild("AntiReturn")
    if old then old:Destroy() end
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "AntiReturn"
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(0, 0, 0)
    bv.Parent = Character:WaitForChild("HumanoidRootPart")
    return bv
end

local AntiReturn = createAntiReturn()

-- Atualiza referências se jogador respawnar
Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = Character:WaitForChild("Humanoid")
    AntiReturn = createAntiReturn()
end)

-- Remove GUI antiga para evitar duplicatas
local existingGUI = PlayerGui:FindFirstChild("SonicHubPROMAX")
if existingGUI then
    existingGUI:Destroy()
end

-- ========== INTERFACE GRÁFICA ==========

local SonicHub = Instance.new("ScreenGui")
SonicHub.Name = "SonicHubPROMAX"
SonicHub.ResetOnSpawn = false
SonicHub.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 450)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = SonicHub

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 10)
UICornerMain.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(8, 120, 255)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local UICornerHeader = Instance.new("UICorner")
UICornerHeader.CornerRadius = UDim.new(0, 10)
UICornerHeader.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "SONIC HUB PRO MAX"
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamSemibold
TitleLabel.TextSize = 20
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 20
CloseButton.AutoButtonColor = false
CloseButton.Parent = Header

local UICornerClose = Instance.new("UICorner")
UICornerClose.CornerRadius = UDim.new(0, 6)
UICornerClose.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
end)

CloseButton.MouseLeave:Connect(function()
    CloseButton.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
end)

CloseButton.MouseButton1Click:Connect(function()
    SonicHub:Destroy()
end)

local ButtonsContainer = Instance.new("ScrollingFrame")
ButtonsContainer.Size = UDim2.new(1, -20, 1, -70)
ButtonsContainer.Position = UDim2.new(0, 10, 0, 60)
ButtonsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ButtonsContainer.ScrollBarThickness = 8
ButtonsContainer.BackgroundTransparency = 1
ButtonsContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ButtonsContainer

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 4)
UIPadding.PaddingBottom = UDim.new(0, 4)
UIPadding.Parent = ButtonsContainer

local function CreateButton(text, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 16
    btn.Text = text
    btn.AutoButtonColor = false

    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim.new(0, 8)
    UICornerBtn.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end)

    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    end)

    btn.MouseButton1Click:Connect(onClick)

    btn.Parent = ButtonsContainer

    return btn
end

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 1, -40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 14
StatusLabel.Text = "AGUARDANDO..."
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Parent = MainFrame

-- ========== LÓGICA DO SCRIPT ==========

local Farming = false
local CurrentQuest = ""
local lastNPCCheck = 0
local Teleporting = false

-- Teleporte com voo suave
local function SafeTeleport(cframe)
    if Teleporting then return end
    Teleporting = true
    pcall(function()
        AntiReturn.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        AntiReturn.Velocity = Vector3.new(0, 25, 0)

        -- Sobe 20 unidades para simular voo
        Character.HumanoidRootPart.CFrame = cframe + Vector3.new(0, 20, 0)
        task.wait(0.5)
        -- Desce próximo ao chão do NPC
        Character.HumanoidRootPart.CFrame = cframe + Vector3.new(0, 3, 0)
        task.wait(0.3)

        AntiReturn.MaxForce = Vector3.new(0, 0, 0)
        AntiReturn.Velocity = Vector3.new(0, 0, 0)
    end)
    Teleporting = false
end

-- Buscar e voar até NPC da missão
local function FindAndFlyToNPC()
    local LevelValue = Player:FindFirstChild("Data") and Player.Data:FindFirstChild("Level")
    if not LevelValue then
        warn("Não encontrou Level em Player.Data")
        return nil
    end

    local PlayerLevel = LevelValue.Value
    local closestNPC, minDist = nil, math.huge

    local NPCsFolder = workspace:FindFirstChild("NPCs")
    if not NPCsFolder then
        warn("Pasta 'NPCs' não encontrada em workspace")
        return nil
    end

    for _, npc in pairs(NPCsFolder:GetChildren()) do
        local quest = npc:FindFirstChild("Quest")
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        if quest and quest:FindFirstChild("RequiredLevel") and hrp then
            local npcLevel = quest.RequiredLevel.Value
            if PlayerLevel >= (npcLevel - 15) and PlayerLevel <= (npcLevel + 30) then
                local dist = (hrp.Position - Character.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    closestNPC = npc
                    minDist = dist
                end
            end
        end
    end

    if closestNPC then
        game.StarterGui:SetCore("SendNotification", {
            Title = "NPC ENCONTRADO",
            Text = "Voando até: " .. closestNPC.Name,
            Duration = 4
        })

        SafeTeleport(closestNPC.HumanoidRootPart.Position)

        -- Espera chegar perto para aceitar a missão
        local startTime = tick()
        while (closestNPC.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude > 12 and (tick() - startTime < 15) do
            Character.HumanoidRootPart.CFrame = closestNPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
            task.wait(0.3)
        end

        if (closestNPC.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude <= 15 then
            local success, err = pcall(function()
                return ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", closestNPC.Name, 1)
            end)
            if success then
                return closestNPC.Name
            else
                warn("Erro ao iniciar missão: " .. tostring(err))
            end
        end
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "NPC NÃO ENCONTRADO",
            Text = "Nenhum NPC de missão adequado encontrado.",
            Duration = 5
        })
    end
    return nil
end

local function ToggleFarm()
    Farming = not Farming

    if Farming then
        CurrentQuest = FindAndFlyToNPC()
        if not CurrentQuest then
            Farming = false
            return
        end

        spawn(function()
            while Farming do
                local now = tick()
                if now - lastNPCCheck > 15 then
                    CurrentQuest = FindAndFlyToNPC() or CurrentQuest
                    lastNPCCheck = now
                end

                pcall(function()
                    local ValidEnemies = {}
                    local EnemiesFolder = workspace:FindFirstChild("Enemies")
                    if EnemiesFolder then
                        for _, enemy in pairs(EnemiesFolder:GetChildren()) do
                            local hrp = enemy:FindFirstChild("HumanoidRootPart")
                            local humanoid = enemy:FindFirstChild("Humanoid")
                            if hrp and humanoid and humanoid.Health > 0 and string.find(enemy.Name, CurrentQuest) then
                                table.insert(ValidEnemies, enemy)
                            end
                        end
                    end
                    
                    if #ValidEnemies > 0 then
                        table.sort(ValidEnemies, function(a, b)
                            return (a.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude <
                                (b.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                        end)

                        local Target = ValidEnemies[1]
                        local Distance = (Target.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude

                        if Distance > 50 then
                            Character.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 10, 10)
                        else
                            Character.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3)
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("Attack", Target)
                        end
                    end
                end)

                task.wait(0.3)
            end
        end)
    else
        CurrentQuest = ""
    end
end

-- Locais para teleporte
local Locations = {
    ["Desert"] = CFrame.new(1094.15, 16.84, 1792.70),
    ["Pirate Village"] = CFrame.new(-1163.40, 44.79, 3846.38),
    ["Castle on Sea"] = CFrame.new(-5478.39, 315.63, -3136.26),
    ["Middle Town"] = CFrame.new(-655.83, 15.89, 1435.90),
    ["Green Zone"] = CFrame.new(-2258.69, 73.02, -2696.33)
}

-- Criar os botões da GUI ligados às funções corretas
local ButtonsData = {
    {"🔘 TOGGLE AUTO FARM", ToggleFarm},
    {"🏜️ DESERT", function() SafeTeleport(Locations["Desert"]) end},
    {"🏴‍☠️ PIRATE VILLAGE", function() SafeTeleport(Locations["Pirate Village"]) end},
    {"🏰 CASTLE ON SEA", function() SafeTeleport(Locations["Castle on Sea"]) end},
    {"🏘️ MIDDLE TOWN", function() SafeTeleport(Locations["Middle Town"]) end},
    {"🌴 GREEN ZONE", function() SafeTeleport(Locations["Green Zone"]) end},
    {"❌ CLOSE HUB", function() SonicHub:Destroy() end}
}

for _, info in ipairs(ButtonsData) do
    CreateButton(info[1], info[2])
end

-- Atualização do label de status da farm
spawn(function()
    while task.wait(1) do
        if Farming then
            if CurrentQuest ~= "" then
                StatusLabel.Text = "FARMANDO: " .. CurrentQuest
            else
                StatusLabel.Text = "BUSCANDO NPC..."
            end
        else
            local lvlText = "N/A"
            local data = Player:FindFirstChild("Data")
            if data and data:FindFirstChild("Level") then
                lvlText = tostring(data.Level.Value)
            end
            StatusLabel.Text = "PRONTO - " .. lvlText .. " LVL"
        end
    end
end)

-- Anti-AFK simples, envia F a cada 30 segundos
spawn(function()
    while task.wait(30) do
        pcall(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
        end)
    end
end)

-- Notificação inicial ao carregar script
game.StarterGui:SetCore("SendNotification", {
    Title = "SonicHub PRO MAX",
    Text = "Script carregado com sucesso!",
    Duration = 5
})
