--[[
  🚀 SonicHub ELITE - Blox Fruits Script 🚀
  Versão 12.0 | Farm Infalível | Teleporte Perfeito
  Baseado nos melhores scripts da comunidade
]]

-- Configuração à prova de erros
repeat task.wait() until game:IsLoaded()
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Sistema Anti-Return Aprimorado
local AntiReturn = Instance.new("BodyVelocity")
AntiReturn.Velocity = Vector3.new(0, 0, 0)
AntiReturn.MaxForce = Vector3.new(0, 0, 0)
AntiReturn.Parent = Character:WaitForChild("HumanoidRootPart")

-- Atualização de personagem
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    AntiReturn = Instance.new("BodyVelocity")
    AntiReturn.Velocity = Vector3.new(0, 0, 0)
    AntiReturn.MaxForce = Vector3.new(0, 0, 0)
    AntiReturn.Parent = Character:WaitForChild("HumanoidRootPart")
end)

-- Remove GUI antiga
if game:GetService("CoreGui"):FindFirstChild("SonicHubElite") then
    game:GetService("CoreGui").SonicHubElite:Destroy()
end

-- Interface Premium
local SonicHub = Instance.new("ScreenGui")
SonicHub.Name = "SonicHubElite"
SonicHub.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 500)
MainFrame.Position = UDim2.new(0.05, 0, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "SONIC HUB ELITE"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

MainFrame.Parent = SonicHub

-- ========== SISTEMA DE MISSÕES INFALÍVEL ==========
local function FindQuestNPC()
    local PlayerLevel = Player.Data.Level.Value
    local closestNPC, minDist = nil, math.huge
    
    -- Lista prioritária de NPCs por região
    local priorityNPCs = {
        "Bandit Quest Giver",          -- Starter Island
        "Marine Quest Giver",          -- Starter Island
        "Desert Bandit Quest Giver",   -- Desert
        "Snow Bandit Quest Giver",     -- Snow Village
        "Forest Pirate Quest Giver",   -- Jungle
        "Pirate Quest Giver"           -- Pirate Village
    }
    
    -- Verifica NPCs prioritários primeiro
    for _, npcName in ipairs(priorityNPCs) do
        local npc = workspace.NPCs:FindFirstChild(npcName)
        if npc and npc:FindFirstChild("Quest") then
            local npcLevel = npc.Quest.RequiredLevel.Value
            if PlayerLevel >= npcLevel - 10 and PlayerLevel <= npcLevel + 20 then
                local dist = (npc.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    closestNPC = npc
                    minDist = dist
                end
            end
        end
    end
    
    -- Se não encontrou, verifica todos os NPCs
    if not closestNPC then
        for _, npc in pairs(workspace.NPCs:GetChildren()) do
            if npc:FindFirstChild("Quest") then
                local npcLevel = npc.Quest.RequiredLevel.Value
                if PlayerLevel >= npcLevel - 15 and PlayerLevel <= npcLevel + 25 then
                    local dist = (npc.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                    if dist < minDist then
                        closestNPC = npc
                        minDist = dist
                    end
                end
            end
        end
    end
    
    return closestNPC
end

local function AcceptQuest(npc)
    for i = 1, 3 do  -- 3 tentativas
        local success = pcall(function()
            return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", npc.Name, 1)
        end)
        if success then return true end
        task.wait(0.5)
    end
    return false
end

-- ========== FARM AUTOMÁTICO INFALÍVEL ==========
local Farming = false
local CurrentQuest = ""

local function ToggleFarm()
    Farming = not Farming
    
    if Farming then
        spawn(function()
            while Farming do
                -- Etapa 1: Encontrar e aceitar missão
                local npc = FindQuestNPC()
                
                if not npc then
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "ALERTA",
                        Text = "Nenhum NPC encontrado! Mudando de área...",
                        Duration = 5
                    })
                    -- Teleporte para área central para encontrar NPCs
                    Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
                    task.wait(3)
                    continue
                end
                
                game.StarterGui:SetCore("SendNotification", {
                    Title = "MISSÃO",
                    Text = "NPC encontrado: "..npc.Name,
                    Duration = 3
                })
                
                -- Vai até o NPC
                local startTime = os.time()
                while (npc.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude > 15 and os.time() - startTime < 20 do
                    Character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                    task.wait(0.5)
                end
                
                -- Aceita a missão
                if AcceptQuest(npc) then
                    CurrentQuest = npc.Name
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "SUCESSO",
                        Text = "Missão aceita: "..CurrentQuest,
                        Duration = 3
                    })
                    
                    -- Etapa 2: Farmar os mobs
                    local lastMobCheck = os.time()
                    while Farming and task.wait(0.3) do
                        pcall(function()
                            -- Atualiza lista de mobs a cada 5 segundos
                            if os.time() - lastMobCheck > 5 then
                                lastMobCheck = os.time()
                                
                                local validMobs = {}
                                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                                        if string.find(enemy.Name, CurrentQuest) then
                                            table.insert(validMobs, enemy)
                                        end
                                    end
                                end
                                
                                if #validMobs == 0 then
                                    break  -- Volta para buscar novo NPC
                                end
                                
                                -- Ordena por distância
                                table.sort(validMobs, function(a,b)
                                    return (a.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude <
                                           (b.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                                end)
                                
                                -- Movimento e ataque
                                local target = validMobs[1]
                                local distance = (target.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                                
                                if distance > 50 then
                                    Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 10, 10)
                                else
                                    Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3)
                                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", target)
                                end
                            end
                        end)
                    end
                else
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "ERRO",
                        Text = "Falha ao aceitar missão",
                        Duration = 5
                    })
                end
            end
        end)
    else
        CurrentQuest = ""
    end
end

-- ========== TELEPORTE PERFEITO ==========
local Teleporting = false
local function EliteTeleport(cframe)
    if Teleporting then return end
    Teleporting = true
    
    -- 1. Prepara anti-return
    AntiReturn.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    AntiReturn.Velocity = Vector3.new(0, 0, 0)
    
    -- 2. Teleporte para posição alta
    Character.HumanoidRootPart.CFrame = cframe + Vector3.new(0, 50, 0)
    task.wait(0.2)
    
    -- 3. Teleporte para posição correta
    Character.HumanoidRootPart.CFrame = cframe
    task.wait(0.5)
    
    -- 4. Verificação final
    if (Character.HumanoidRootPart.Position - cframe.Position).Magnitude > 10 then
        -- Se falhou, tenta método alternativo
        Character.HumanoidRootPart.CFrame = cframe + Vector3.new(0, 100, 0)
        task.wait(0.3)
        Character.HumanoidRootPart.CFrame = cframe
    end
    
    -- 5. Desativa gradualmente
    for i = 1, 0, -0.1 do
        AntiReturn.MaxForce = Vector3.new(math.huge * i, math.huge * i, math.huge * i)
        task.wait(0.05)
    end
    
    Teleporting = false
end

-- Locais testados e aprovados
local Locations = {
    ["Starter Island"] = CFrame.new(-100, 15, 200),
    ["Desert"] = CFrame.new(1094.15, 16.84, 1792.70),
    ["Pirate Village"] = CFrame.new(-1163.40, 44.79, 3846.38),
    ["Jungle"] = CFrame.new(-1500, 70, -500),
    ["Snow Village"] = CFrame.new(1300, 120, -1400)
}

-- ========== BOTÕES DA INTERFACE ==========
local ButtonLayout = {
    {"🔘 INICIAR AUTO FARM", 0.15, 0.1, ToggleFarm},
    {"🏝️ STARTER ISLAND", 0.15, 0.55, function() EliteTeleport(Locations["Starter Island"]) end},
    {"🏜️ DESERT", 0.3, 0.1, function() EliteTeleport(Locations["Desert"]) end},
    {"🏴‍☠️ PIRATE VILLAGE", 0.3, 0.55, function() EliteTeleport(Locations["Pirate Village"]) end},
    {"🌴 JUNGLE", 0.45, 0.1, function() EliteTeleport(Locations["Jungle"]) end},
    {"❄️ SNOW VILLAGE", 0.45, 0.55, function() EliteTeleport(Locations["Snow Village"]) end},
    {"❌ FECHAR HUB", 0.6, 0.325, function() SonicHub:Destroy() end}
}

for _, btnData in ipairs(ButtonLayout) do
    local btn = Instance.new("TextButton")
    btn.Text = btnData[1]
    btn.Size = UDim2.new(0.4, 0, 0, 40)
    btn.Position = UDim2.new(btnData[3], 0, btnData[2], 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(btnData[4])
    btn.Parent = MainFrame
end

-- Status do Player
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "PRONTO - "..Player.Data.Level.Value.." LVL"
StatusLabel.Size = UDim2.new(0.9, 0, 0, 30)
StatusLabel.Position = UDim2.new(0.05, 0, 0.8, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- Atualização de status
spawn(function()
    while task.wait(1) do
        if Farming then
            if CurrentQuest ~= "" then
                StatusLabel.Text = "FARMANDO: "..CurrentQuest
            else
                StatusLabel.Text = "BUSCANDO NPC..."
            end
        else
            StatusLabel.Text = "PRONTO - "..Player.Data.Level.Value.." LVL"
        end
    end
end)

-- Anti-AFK
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
    Title = "SONIC HUB ELITE",
    Text = "Script carregado com sucesso!",
    Duration = 5
})

print("✅ SonicHub Elite carregado com sucesso!")
