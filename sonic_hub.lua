--[[
  🚀 AUTO FARM POR NÍVEL - Blox Fruits 🚀
  Versão 3.0 | Foco na missão correta para seu nível
  Corrigido problema de teleporte errado
]]

repeat task.wait() until game:IsLoaded()

-- Configurações básicas
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Sistema Anti-Return
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

-- Remove GUI antiga
if game:GetService("CoreGui"):FindFirstChild("LevelFarmHub") then
    game:GetService("CoreGui").LevelFarmHub:Destroy()
end

-- ========== SISTEMA INTELIGENTE POR NÍVEL ==========
local function GetCorrectLocation()
    local PlayerLevel = Player.Data.Level.Value
    
    -- Mapeamento de ilhas por nível
    if PlayerLevel >= 60 and PlayerLevel < 90 then
        return {
            npcName = "Desert Bandit Quest Giver",
            cf = CFrame.new(1094.15, 16.84, 1792.70),
            islandName = "Desert",
            enemies = {"Desert Bandit", "Desert Officer"}
        }
    elseif PlayerLevel >= 90 and PlayerLevel < 120 then
        return {
            npcName = "Snow Bandit Quest Giver",
            cf = CFrame.new(1289.32, 120.34, -1372.47),
            islandName = "Snow Village",
            enemies = {"Snow Bandit", "Snowman"}
        }
    else
        return {
            npcName = "Bandit Quest Giver",
            cf = CFrame.new(-1145.15, 4.75, 3824.41),
            islandName = "Starter Island",
            enemies = {"Bandit"}
        }
    end
end

local function FindCorrectNPC(npcName)
    -- Procura com tolerância para variações de nome
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if string.find(npc.Name:lower(), npcName:lower()) then
            if npc:FindFirstChild("Quest") then
                return npc
            end
        end
    end
    return nil
end

local function FlyToLocation(cframe)
    local startPos = Character.HumanoidRootPart.Position
    local endPos = cframe.Position
    local distance = (startPos - endPos).Magnitude
    
    -- Voando progressivamente
    for i = 1, 100 do
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then break end
        
        local ratio = i/100
        local newPos = startPos:Lerp(endPos, ratio)
        Character.HumanoidRootPart.CFrame = CFrame.new(newPos.X, newPos.Y + 10, newPos.Z)
        task.wait(0.03)
    end
    
    -- Ajuste final
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = cframe * CFrame.new(0, 3, 0)
    end
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
            while Farming do
                -- 1. Obtém localização correta
                local location = GetCorrectLocation()
                
                game.StarterGui:SetCore("SendNotification", {
                    Title = "MISSÃO",
                    Text = "Indo para: "..location.islandName,
                    Duration = 3
                })
                
                -- 2. Voa até a ilha
                FlyToLocation(location.cf)
                task.wait(1)
                
                -- 3. Encontra o NPC
                local npc = FindCorrectNPC(location.npcName)
                if not npc then
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "ERRO",
                        Text = "NPC não encontrado! Tentando novamente...",
                        Duration = 3
                    })
                    
                    -- Tenta método alternativo
                    Character.HumanoidRootPart.CFrame = location.cf * CFrame.new(0, 10, 0)
                    task.wait(2)
                    npc = FindCorrectNPC(location.npcName)
                    
                    if not npc then
                        task.wait(3)
                        continue
                    end
                end
                
                -- 4. Aceita a missão
                if AcceptQuest(npc) then
                    CurrentQuest = npc.Name
                    
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "SUCESSO",
                        Text = "Missão aceita: "..CurrentQuest,
                        Duration = 3
                    })
                    
                    -- 5. Farm loop
                    local lastMobCheck = os.time()
                    while Farming and task.wait(0.3) do
                        -- Atualiza lista de inimigos periodicamente
                        if os.time() - lastMobCheck > 5 then
                            lastMobCheck = os.time()
                            
                            local target = nil
                            local closestDist = math.huge
                            
                            for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                                if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                                    for _, enemyName in pairs(location.enemies) do
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
                                break -- Volta a procurar missão
                            end
                        end
                    end
                end
            end
        end)
    else
        CurrentQuest = ""
    end
end

-- ========== INTERFACE SIMPLES ==========
local LevelFarmHub = Instance.new("ScreenGui")
LevelFarmHub.Name = "LevelFarmHub"
LevelFarmHub.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 150)
MainFrame.Position = UDim2.new(0.05, 0, 0.7, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "AUTO FARM (LVL "..Player.Data.Level.Value..")"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

local FarmButton = Instance.new("TextButton")
FarmButton.Text = "🔘 INICIAR AUTO FARM"
FarmButton.Size = UDim2.new(0.9, 0, 0, 40)
FarmButton.Position = UDim2.new(0.05, 0, 0.3, 0)
FarmButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
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

MainFrame.Parent = LevelFarmHub

-- Atualiza status
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

print("✅ Auto Farm Inteligente carregado!")
