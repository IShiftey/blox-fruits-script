--[[
  🚀 SonicHub PRO MAX - Blox Fruits Script 🚀
  Versão 8.1 | Auto-NPC Aprimorado | Interface no PlayerGui
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- Espera o personagem carregar direito
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Configuração Anti-Return
local AntiReturn = Instance.new("BodyVelocity")
AntiReturn.Name = "AntiReturn"
AntiReturn.Velocity = Vector3.new(0, 0, 0)
AntiReturn.MaxForce = Vector3.new(0, 0, 0)
AntiReturn.Parent = Character:WaitForChild("HumanoidRootPart")

-- Atualiza AntiReturn e referências após respawn do personagem
Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = Character:WaitForChild("Humanoid")
    -- Remove AntiReturn antigo se existir
    local old = Character:FindFirstChild("AntiReturn")
    if old then old:Destroy() end
    AntiReturn = Instance.new("BodyVelocity")
    AntiReturn.Name = "AntiReturn"
    AntiReturn.Velocity = Vector3.new(0, 0, 0)
    AntiReturn.MaxForce = Vector3.new(0, 0, 0)
    AntiReturn.Parent = Character:WaitForChild("HumanoidRootPart")
end)

-- Remove GUI antiga para evitar duplicidade
local existingGUI = PlayerGui:FindFirstChild("SonicHubPROMAX")
if existingGUI then
    existingGUI:Destroy()
end

-- Criação da interface
local SonicHub = Instance.new("ScreenGui")
SonicHub.Name = "SonicHubPROMAX"
SonicHub.ResetOnSpawn = false
SonicHub.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 500)  -- Largura aumentada
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)  -- Centralizado
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = SonicHub

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "SONIC HUB PRO MAX"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

-- Função para encontrar o NPC adequado automaticamente
local function FindAndGoToNPC()
    local PlayerLevel = Player:WaitForChild("Data"):WaitForChild("Level").Value
    local closestNPC, minDist = nil, math.huge

    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        local quest = npc:FindFirstChild("Quest")
        if quest and quest:FindFirstChild("RequiredLevel") then
            local npcLevel = quest.RequiredLevel.Value

            -- Permite aceitar NPCs com nível desde 15 abaixo até 30 acima do player
            if PlayerLevel >= (npcLevel - 15) and PlayerLevel <= (npcLevel + 30) then
                local dist = (npc.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
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
            Text = "Indo até: " .. closestNPC.Name,
            Duration = 3
        })

        local startTime = tick()
        -- Move até perto do NPC para aceitar missão
        while (closestNPC.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude > 10 and (tick() - startTime < 15) do
            Character.HumanoidRootPart.CFrame = closestNPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
            task.wait(0.3)
        end

        if (closestNPC.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude <= 15 then
            local success, err = pcall(function()
                return ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", closestNPC.Name, 1)
            end)
            if success then
                return closestNPC.Name
            else
                warn("Erro ao aceitar a missão: " .. tostring(err))
            end
        end
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "NPC NÃO ENCONTRADO",
            Text = "Nenhum NPC de missão adequado para seu nível.",
            Duration = 5
        })
    end
    return nil
end

-- Variáveis de controle do farm
local Farming = false
local CurrentQuest = ""
local lastNPCCheck = 0

-- Função principal para ligar/desligar farm automático
local function ToggleFarm()
    Farming = not Farming

    if Farming then
        -- Primeira tentativa de aceitar missão
        CurrentQuest = FindAndGoToNPC()
        if not CurrentQuest then
            Farming = false
            return
        end

        spawn(function()
            while Farming do
                local now = tick()
                -- Atualiza NPC/Quest a cada 15 segundos
                if now - lastNPCCheck > 15 then
                    CurrentQuest = FindAndGoToNPC() or CurrentQuest
                    lastNPCCheck = now
                end

                pcall(function()
                    -- Busca inimigos da missão atual
                    local ValidEnemies = {}
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if string.find(enemy.Name, CurrentQuest) and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            table.insert(ValidEnemies, enemy)
                        end
                    end

                    if #ValidEnemies > 0 then
                        -- Ordena pelo mais próximo
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

-- Função para safe teleportar
local Teleporting = false
local function SafeTeleport(cframe)
    if Teleporting then return end
    Teleporting = true

    pcall(function()
        AntiReturn.MaxForce = Vector3.new(math.huge, 0, math.huge)
        AntiReturn.Velocity = Vector3.new(0, 25, 0)
        Character.HumanoidRootPart.CFrame = cframe
        task.wait(0.5)
        AntiReturn.MaxForce = Vector3.new(0, 0, 0)
    end)

    Teleporting = false
end

-- Tabela de locais para teleporte
local Locations = {
    ["Desert"] = CFrame.new(1094.15, 16.84, 1792.70),
    ["Pirate Village"] = CFrame.new(-1163.40, 44.79, 3846.38),
    ["Castle on Sea"] = CFrame.new(-5478.39, 315.63, -3136.26),
    ["Middle Town"] = CFrame.new(-655.83, 15.89, 1435.90),
    ["Green Zone"] = CFrame.new(-2258.69, 73.02, -2696.33)
}

-- Criação de botões da GUI em layout simples
local ButtonLayout = {
    {"🔘 TOGGLE AUTO FARM", UDim2.new(0.15, 0, 0.1, 0), ToggleFarm},
    {"🏜️ DESERT", UDim2.new(0.15, 0, 0.55, 0), function() SafeTeleport(Locations["Desert"]) end},
    {"🏴‍☠️ PIRATE VILLAGE", UDim2.new(0.3, 0, 0.1, 0), function() SafeTeleport(Locations["Pirate Village"]) end},
    {"🏰 CASTLE ON SEA", UDim2.new(0.3, 0, 0.55, 0), function() SafeTeleport(Locations["Castle on Sea"]) end},
    {"🏘️ MIDDLE TOWN", UDim2.new(0.45, 0, 0.1, 0), function() SafeTeleport(Locations["Middle Town"]) end},
    {"🌴 GREEN ZONE", UDim2.new(0.45, 0, 0.55, 0), function() SafeTeleport(Locations["Green Zone"]) end},
    {"❌ CLOSE HUB", UDim2.new(0.6, 0, 0.325, 0), function() SonicHub:Destroy() end}
}

for _, btnData in ipairs(ButtonLayout) do
    local btn = Instance.new("TextButton")
    btn.Text = btnData[1]
    btn.Size = UDim2.new(0.4, 0, 0, 40)
    btn.Position = btnData[2]
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(btnData[3])
    btn.Parent = MainFrame
end

-- Label para status do farm na GUI
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "AGUARDANDO..."
StatusLabel.Size = UDim2.new(0.9, 0, 0, 30)
StatusLabel.Position = UDim2.new(0.05, 0, 0.8, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- Atualização do texto de status continuamente
spawn(function()
    while task.wait(1) do
        if Farming then
            if CurrentQuest ~= "" then
                StatusLabel.Text = "FARMANDO: " .. CurrentQuest
            else
                StatusLabel.Text = "BUSCANDO NPC..."
            end
        else
            StatusLabel.Text = "PRONTO - " .. tostring(Player:WaitForChild("Data"):WaitForChild("Level").Value) .. " LVL"
        end
    end
end)

-- Sistema simples anti-AFK
spawn(function()
    while task.wait(30) do
        pcall(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
        end)
    end
end)

-- Notificação inicial carregada
game.StarterGui:SetCore("SendNotification", {
    Title = "SonicHub PRO MAX",
    Text = "Script carregado com sucesso!",
    Duration = 5
})
