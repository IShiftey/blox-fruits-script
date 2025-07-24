--[[
  🚀 AUTO FARM DESERTO - Blox Fruits 🚀
  Versão 2.1 | Foco no Desert Bandit (Level 60-90)
  Corrigido para evitar teleportes errados
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
if game:GetService("CoreGui"):FindFirstChild("DesertFarmHub") then
    game:GetService("CoreGui").DesertFarmHub:Destroy()
end

-- ========== CONFIGURAÇÃO ESPECÍFICA PARA DESERTO ==========
local DESERT_NPC_NAME = "Desert Bandit Quest Giver"
local DESERT_CFRAME = CFrame.new(1094.15, 16.84, 1792.70)
local DESERT_ENEMIES = {"Desert Bandit", "Desert Officer"}

-- ========== FUNÇÕES PRINCIPAIS ==========
local function TeleportToDesert()
    -- Teleporte seguro para o Deserto
    local attempts = 0
    while attempts < 3 do
        Character.HumanoidRootPart.CFrame = DESERT_CFRAME + Vector3.new(0, 10, 0)
        task.wait(1)
        
        -- Verifica se chegou no deserto
        if (Character.HumanoidRootPart.Position - DESERT_CFRAME.Position).Magnitude < 100 then
            return true
        end
        attempts += 1
    end
    return false
end

local function FindDesertNPC()
    -- Procura o NPC com tolerância para variações de nome
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if string.find(npc.Name:lower(), "desert") and string.find(npc.Name:lower(), "bandit") then
            if npc:FindFirstChild("Quest") then
                return npc
            end
        end
    end
    return nil
end

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

-- ========== SISTEMA DE FARM ==========
local Farming = false
local CurrentQuest = ""

local function ToggleFarm()
    Farming = not Farming
    
    if Farming then
        spawn(function()
            -- Notificação inicial
            game.StarterGui:SetCore("SendNotification", {
                Title = "DESERT FARM",
                Text = "Iniciando farm no Deserto...",
                Duration = 3
            })
            
            while Farming do
                -- 1. Teleporta para o Deserto
                if not TeleportToDesert() then
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "ERRO",
                        Text = "Falha ao teleportar para o Deserto!",
                        Duration = 5
                    })
                    task.wait(5)
                    continue
                end
                
                -- 2. Encontra o NPC
                local npc = FindDesertNPC()
                if not npc then
                    -- Tenta método alternativo de busca
                    Character.HumanoidRootPart.CFrame = DESERT_CFRAME
                    task.wait(2)
                    npc = FindDesertNPC()
                    
                    if not npc then
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "ERRO",
                            Text = "NPC do Deserto não encontrado!",
                            Duration = 5
                        })
                        task.wait(5)
                        continue
                    end
                end
                
                -- 3. Aceita a missão
                if AcceptQuest(npc) then
                    CurrentQuest = npc.Name
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "MISSÃO ACEITA",
                        Text = "Farmando Desert Bandits!",
                        Duration = 3
                    })
                    
                    -- 4. Farm loop
                    while Farming and task.wait(0.3) do
                        local target = nil
                        local closestDist = math.huge
                        
                        -- Encontra o inimigo mais próximo
                        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                                for _, enemyName in pairs(DESERT_ENEMIES) do
                                    if string.find(enemy.Name, enemyName) then
                                        local dist = (enemy.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                                        if dist < closestDist then
                                            closestDist = dist
                                            target = enemy
                                        end
                                    end
                                end
                            end
                        end
                        
                        -- Ataca ou se move
                        if target then
                            if closestDist > 50 then
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

-- ========== INTERFACE SIMPLIFICADA ==========
local DesertFarmHub = Instance.new("ScreenGui")
DesertFarmHub.Name = "DesertFarmHub"
DesertFarmHub.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 150)
MainFrame.Position = UDim2.new(0.05, 0, 0.7, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "DESERT FARM (LVL 60-90)"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(200, 150, 0) -- Cor de deserto
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

local FarmButton = Instance.new("TextButton")
FarmButton.Text = "🔘 INICIAR DESERT FARM"
FarmButton.Size = UDim2.new(0.9, 0, 0, 40)
FarmButton.Position = UDim2.new(0.05, 0, 0.3, 0)
FarmButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
FarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmButton.Font = Enum.Font.GothamSemibold
FarmButton.TextSize = 14

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 6)
Corner.Parent = FarmButton

FarmButton.MouseButton1Click:Connect(ToggleFarm)
FarmButton.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "PRONTO - "..Player.Data.Level.Value.." LVL"
StatusLabel.Size = UDim2.new(0.9, 0, 0, 30)
StatusLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

MainFrame.Parent = DesertFarmHub

-- Atualiza status
spawn(function()
    while task.wait(1) do
        if Farming then
            StatusLabel.Text = "FARMANDO BANDITS - "..Player.Data.Level.Value.." LVL"
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

print("✅ Desert Farm carregado com sucesso!")
