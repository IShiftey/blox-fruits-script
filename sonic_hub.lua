--[[
  🚀 SonicHub PRO MAX - Blox Fruits Script 🚀
  Versão 8.5 | Teleporte estável + Auto Farm funcional
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local PlayerGui = Player:WaitForChild("PlayerGui")

-- BodyVelocity para segurar no ar durante voo
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

-- Atualiza referências ao respawn
Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = Character:WaitForChild("Humanoid")
    AntiReturn = createAntiReturn()
end)

-- Remove GUI antiga
local existingGUI = PlayerGui:FindFirstChild("SonicHubPROMAX")
if existingGUI then
    existingGUI:Destroy()
end

-- Criar GUI básica (pode personalizar conforme já fez)
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

-- (Cabeçalho, botões, status label aqui — mantidos de seu código anterior)

-- Variáveis de controle
local Farming = false
local CurrentQuest = ""
local lastNPCCheck = 0
local Teleporting = false

-- Teleporte suave e seguro (voo) para destino, bloqueando comandos de movimento durante ele
local function SafeTeleport(destinationCFrame)
    if Teleporting then return false end
    Teleporting = true

    pcall(function()
        AntiReturn.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        AntiReturn.Velocity = Vector3.new(0, 25, 0)
        -- Sobe 20 para evitar colisão
        Character.HumanoidRootPart.CFrame = destinationCFrame + Vector3.new(0, 20, 0)
        task.wait(0.5)
        -- Desce 3 para perto do chão
        Character.HumanoidRootPart.CFrame = destinationCFrame + Vector3.new(0, 3, 0)
        task.wait(0.3)
        AntiReturn.MaxForce = Vector3.new(0, 0, 0)
        AntiReturn.Velocity = Vector3.new(0, 0, 0)
    end)

    Teleporting = false
    return true
end

-- Função para encontrar o NPC da missão com base no nível e teleporte até ele
local function FindAndFlyToNPC()
    local lvlVal = Player:FindFirstChild("Data") and Player.Data:FindFirstChild("Level")
    if not lvlVal then
        warn("Player.Data.Level não encontrado")
        return nil
    end
    local playerLevel = lvlVal.Value
    local npcsFolder = workspace:FindFirstChild("NPCs")
    if not npcsFolder then
        warn("workspace.NPCs não encontrado")
        return nil
    end

    local closestNPC, minDist = nil, math.huge
    for _, npc in pairs(npcsFolder:GetChildren()) do
        local quest = npc:FindFirstChild("Quest")
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        if quest and quest:FindFirstChild("RequiredLevel") and hrp then
            local npcLevel = quest.RequiredLevel.Value
            if playerLevel >= (npcLevel - 15) and playerLevel <= (npcLevel + 30) then
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

        -- Teleporte seguro até NPC
        if not SafeTeleport(closestNPC.HumanoidRootPart.CFrame.Position and CFrame.new(closestNPC.HumanoidRootPart.Position) or closestNPC.HumanoidRootPart.CFrame) then
            return nil
        end

        -- Espera estar perto para aceitar a missão
        local startTime = tick()
        while (closestNPC.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude > 12 and (tick() - startTime < 15) do
            -- Ajusta suavemente a posição, mas cuidado para não entrar em loop de movimento/teleporte com o loop de farm
            task.wait(0.2)
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
            Text = "Nenhum NPC disponível para seu nível.",
            Duration = 5
        })
    end
    return nil
end

-- Função para ligar/desligar farm automático
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
                    local enemiesFolder = workspace:FindFirstChild("Enemies")
                    if enemiesFolder then
                        local validEnemies = {}
                        for _, enemy in pairs(enemiesFolder:GetChildren()) do
                            local hrp = enemy:FindFirstChild("HumanoidRootPart")
                            local humanoid = enemy:FindFirstChild("Humanoid")
                            if hrp and humanoid and humanoid.Health > 0 and string.find(enemy.Name, CurrentQuest) then
                                table.insert(validEnemies, enemy)
                            end
                        end

                        if #validEnemies > 0 then
                            table.sort(validEnemies, function(a, b)
                                return (a.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude <
                                    (b.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                            end)

                            local target = validEnemies[1]
                            local dist = (target.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude

                            if dist > 50 then
                                -- Teleporte chegando perto, evitar movimentação bruta para não cancelar "voo"
                                Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 10, 10)
                            else
                                Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3)
                                ReplicatedStorage.Remotes.CommF_:InvokeServer("Attack", target)
                            end
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

-- Função para teleporte por botão, controla o estado para evitar conflito
local function OnTeleportClick(locationCFrame)
    if Farming then
        Farming = false -- Para farm para evitar conflito de movimentação
        task.wait(0.5) -- Espera parar
    end

    SafeTeleport(locationCFrame)
end

-- Criar botões GUI com ligação correta às funções
local ButtonsData = {
    {"🔘 TOGGLE AUTO FARM", ToggleFarm},
    {"🏜️ DESERT", function() OnTeleportClick(Locations["Desert"]) end},
    {"🏴‍☠️ PIRATE VILLAGE", function() OnTeleportClick(Locations["Pirate Village"]) end},
    {"🏰 CASTLE ON SEA", function() OnTeleportClick(Locations["Castle on Sea"]) end},
    {"🏘️ MIDDLE TOWN", function() OnTeleportClick(Locations["Middle Town"]) end},
    {"🌴 GREEN ZONE", function() OnTeleportClick(Locations["Green Zone"]) end},
    {"❌ CLOSE HUB", function() SonicHub:Destroy() end}
}

local ButtonsContainer = MainFrame:FindFirstChildWhichIsA("ScrollingFrame") or Instance.new("ScrollingFrame", MainFrame)
-- Caso seu container não tenha sido criado, substituir por seu container correto

for _, info in ipairs(ButtonsData) do
    CreateButton(info[1], info[2])
end

-- Status Label (Atualização aqui --- use o código do seu script)

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

-- Anti-AFK simples
spawn(function()
    while task.wait(30) do
        pcall(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
        end)
    end
end)

-- Notificação inicial
game.StarterGui:SetCore("SendNotification", {
    Title = "SonicHub PRO MAX",
    Text = "Script carregado com sucesso!",
    Duration = 5
})
