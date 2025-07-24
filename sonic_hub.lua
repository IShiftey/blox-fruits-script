--[[
  🚀 AUTO FARM INTELIGENTE - Blox Fruits 🚀
  Versão 2.0 | Farm Automático | Teleporte Perfeito
  Atualizado para funcionar em qualquer nível
]]

-- Espera o jogo carregar
repeat task.wait() until game:IsLoaded()

-- Configuração básica
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Sistema Anti-Return Aprimorado
local AntiReturn = Instance.new("BodyVelocity")
AntiReturn.Velocity = Vector3.new(0, 0, 0)
AntiReturn.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
AntiReturn.Parent = Character:WaitForChild("HumanoidRootPart")

-- Atualiza personagem se morrer
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    AntiReturn = Instance.new("BodyVelocity")
    AntiReturn.Velocity = Vector3.new(0, 0, 0)
    AntiReturn.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    AntiReturn.Parent = Character:WaitForChild("HumanoidRootPart")
end)

-- Remove GUI antiga se existir
if game:GetService("CoreGui"):FindFirstChild("AutoFarmHub") then
    game:GetService("CoreGui").AutoFarmHub:Destroy()
end

-- Cria a interface
local AutoFarmHub = Instance.new("ScreenGui")
AutoFarmHub.Name = "AutoFarmHub"
AutoFarmHub.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Position = UDim2.new(0.05, 0, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "AUTO FARM INTELIGENTE"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

MainFrame.Parent = AutoFarmHub

-- ========== SISTEMA DE MISSÕES INTELIGENTE ==========
local function GetBestQuestForLevel()
    local PlayerLevel = Player.Data.Level.Value
    local questData = {
        ["Bandit Quest Giver"] = {15, CFrame.new(-1145.15, 4.75, 3824.41), "Starter Island"},
        ["Marine Quest Giver"] = {30, CFrame.new(-2916.96, 43.76, 2976.98), "Starter Island"},
        ["Desert Bandit Quest Giver"] = {60, CFrame.new(1094.15, 16.84, 1792.70), "Desert"},
        ["Snow Bandit Quest Giver"] = {90, CFrame.new(1289.32, 120.34, -1372.47), "Snow Village"},
        ["Forest Pirate Quest Giver"] = {120, CFrame.new(-1598.12, 36.85, -1536.91), "Jungle"},
        ["Pirate Quest Giver"] = {150, CFrame.new(-1163.40, 44.79, 3846.38), "Pirate Village"}
    }
    
    -- Encontra a melhor missão
    local bestNPC, bestData, closestLevelDiff = nil, nil, math.huge
    
    for npcName, data in pairs(questData) do
        local levelDiff = math.abs(PlayerLevel - data[1])
        if (PlayerLevel >= data[1] or levelDiff <= 20) and levelDiff < closestLevelDiff then
            closestLevelDiff = levelDiff
            bestNPC = npcName
            bestData = data
        end
    end
    
    return bestNPC, bestData
end

-- ========== TELEPORTE AUTOMÁTICO ==========
local function TeleportToCFrame(cframe)
    Character.HumanoidRootPart.CFrame = cframe
    task.wait(0.5)
    if (Character.HumanoidRootPart.Position - cframe.Position).Magnitude > 10 then
        -- Método alternativo se o teleporte falhar
        Character.HumanoidRootPart.CFrame = cframe + Vector3.new(0, 50, 0)
        task.wait(0.3)
        Character.HumanoidRootPart.CFrame = cframe
    end
end

-- ========== ACEITAR MISSÃO ==========
local function AcceptQuest(npc)
    for i = 1, 3 do
        local success = pcall(function()
            return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", npc.Name, 1)
        end)
        if success then return true end
        task.wait(0.5)
    end
    return false
end

-- ========== FARM AUTOMÁTICO ==========
local Farming = false
local CurrentQuest = ""

local function ToggleFarm()
    Farming = not Farming
    
    if Farming then
        spawn(function()
            while Farming do
                -- Passo 1: Encontrar a melhor missão
                local npcName, questData = GetBestQuestForLevel()
                
                if not npcName then
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "ERRO",
                        Text = "Nenhuma missão encontrada para seu nível!",
                        Duration = 5
                    })
                    task.wait(5)
                    continue
                end
                
                -- Passo 2: Teleportar para a ilha
                game.StarterGui:SetCore("SendNotification", {
                    Title = "TELEPORTANDO",
                    Text = "Indo para: "..questData[3],
                    Duration = 3
                })
                
                TeleportToCFrame(questData[2])
                task.wait(2)
                
                -- Passo 3: Encontrar o NPC
                local npc = workspace.NPCs:FindFirstChild(npcName)
                if not npc then
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "ERRO",
                        Text = "NPC não encontrado!",
                        Duration = 3
                    })
                    task.wait(3)
                    continue
                end
                
                -- Passo 4: Ir até o NPC
                local startTime = os.time()
                while (npc.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude > 15 and os.time() - startTime < 10 do
                    Character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                    task.wait(0.3)
                end
                
                -- Passo 5: Aceitar a missão
                if AcceptQuest(npc) then
                    CurrentQuest = npcName
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "MISSÃO ACEITA",
                        Text = "Farmando: "..CurrentQuest,
                        Duration = 3
                    })
                    
                    -- Passo 6: Farmar os inimigos
                    while Farming and task.wait(0.3) do
                        local enemies = workspace.Enemies:GetChildren()
                        local target = nil
                        
                        for _, enemy in pairs(enemies) do
                            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                                if string.find(enemy.Name, CurrentQuest) then
                                    target = enemy
                                    break
                                end
                            end
                        end
                        
                        if target then
                            -- Atacar o inimigo
                            local distance = (target.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                            
                            if distance > 50 then
                                Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 10, 10)
                            else
                                Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3)
                                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", target)
                            end
                        else
                            break -- Volta a procurar missão se não houver inimigos
                        end
                    end
                end
            end
        end)
    else
        CurrentQuest = ""
    end
end

-- ========== BOTÃO DE INICIAR ==========
local FarmButton = Instance.new("TextButton")
FarmButton.Text = "🔘 INICIAR AUTO FARM"
FarmButton.Size = UDim2.new(0.8, 0, 0, 40)
FarmButton.Position = UDim2.new(0.1, 0, 0.3, 0)
FarmButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
FarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmButton.Font = Enum.Font.GothamSemibold
FarmButton.TextSize = 14

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = FarmButton

FarmButton.MouseButton1Click:Connect(ToggleFarm)
FarmButton.Parent = MainFrame

-- ========== STATUS DO PLAYER ==========
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "PRONTO - "..Player.Data.Level.Value.." LVL"
StatusLabel.Size = UDim2.new(0.8, 0, 0, 30)
StatusLabel.Position = UDim2.new(0.1, 0, 0.6, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- Atualiza o status
spawn(function()
    while task.wait(1) do
        if Farming then
            if CurrentQuest ~= "" then
                StatusLabel.Text = "FARMANDO: "..CurrentQuest
            else
                StatusLabel.Text = "BUSCANDO MISSÃO..."
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
    Title = "AUTO FARM INTELIGENTE",
    Text = "Script carregado com sucesso!",
    Duration = 5
})

print("✅ Auto Farm Inteligente carregado!")
