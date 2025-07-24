--[[
  🚀 SonicHub Pro - Farm Inteligente 🚀
  Versão 5.0 | Missões Automáticas | Design Premium
]]

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Verificação de Jogo
if not game:GetService("Workspace"):FindFirstChild("Enemies") then
    Player:Kick("❌ Execute apenas em Blox Fruits!")
    return
end

-- Interface Premium
local SonicHub = Instance.new("ScreenGui")
SonicHub.Name = "SonicHubPro"
SonicHub.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.8, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "SONIC HUB v5.0"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

MainFrame.Parent = SonicHub

-- Sistema de Missões Automáticas
local function GetCurrentMission()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local PlayerData = ReplicatedStorage.Remotes["CommF_"]:InvokeServer("getInventory")
    local PlayerLevel = PlayerData.Level.Value
    
    for _, npc in pairs(game:GetService("Workspace").NPCs:GetChildren()) do
        if npc:FindFirstChild("Quest") then
            local requiredLevel = npc.Quest.RequiredLevel.Value
            if PlayerLevel >= requiredLevel and PlayerLevel <= requiredLevel + 10 then
                return npc.Name
            end
        end
    end
    return nil
end

local function AcceptMission(npcName)
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", npcName, 1)
end

-- Sistema de Farm Inteligente
local Farming = false
local CurrentMission = ""

local function ToggleFarm()
    Farming = not Farming
    
    if Farming then
        -- Pegar missão automática
        CurrentMission = GetCurrentMission()
        if CurrentMission then
            AcceptMission(CurrentMission)
            game.StarterGui:SetCore("SendNotification", {
                Title = "Missão Aceita",
                Text = "Farmando: "..CurrentMission,
                Duration = 5
            })
        else
            game.StarterGui:SetCore("SendNotification", {
                Title = "Erro",
                Text = "Nenhuma missão disponível para seu nível",
                Duration = 5
            })
            Farming = false
            return
        end
        
        -- Farm automático
        spawn(function()
            while Farming and task.wait(0.3) do
                pcall(function()
                    local closestEnemy, minDistance = nil, math.huge
                    local missionMobs = {}
                    
                    -- Filtra apenas mobs da missão atual
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if string.find(enemy.Name, CurrentMission) then
                            table.insert(missionMobs, enemy)
                        end
                    end
                    
                    -- Encontra o mob mais próximo
                    for _, enemy in pairs(missionMobs) do
                        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            local distance = (Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                            if distance < minDistance then
                                closestEnemy = enemy
                                minDistance = distance
                            end
                        end
                    end
                    
                    -- Ataca o mob
                    if closestEnemy then
                        -- Posicionamento inteligente (não teleporta diretamente)
                        local targetCFrame = closestEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3)
                        Character.HumanoidRootPart.CFrame = targetCFrame
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", closestEnemy)
                    end
                end)
            end
        end)
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Farm",
            Text = "Farm automático desligado",
            Duration = 3
        })
    end
end

-- Botões Premium
local function CreateButton(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, yPos, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    btn.Parent = MainFrame
    return btn
end

-- Criação dos Botões
CreateButton("🔘 TOGGLE AUTO FARM", 0.15, ToggleFarm)
CreateButton("🏜️ DESERT", 0.25, function() 
    Character.HumanoidRootPart.CFrame = CFrame.new(1084.93, 16.29, 1727.26)
end)
CreateButton("🏴‍☠️ PIRATE VILLAGE", 0.35, function() 
    Character.HumanoidRootPart.CFrame = CFrame.new(-1171.45, 44.78, 3842.77)
end)
CreateButton("🏰 CASTLE ON SEA", 0.45, function() 
    Character.HumanoidRootPart.CFrame = CFrame.new(-5478.67, 315.73, -3132.64)
end)
CreateButton("📌 ANTI-AFK", 0.55, function()
    -- Sistema Anti-AFK aqui
end)
CreateButton("❌ CLOSE HUB", 0.65, function()
    SonicHub:Destroy()
end)

-- Status do Player
local LevelLabel = Instance.new("TextLabel")
LevelLabel.Text = "Level: "..game:GetService("Players").LocalPlayer.Data.Level.Value
LevelLabel.Size = UDim2.new(0.9, 0, 0, 30)
LevelLabel.Position = UDim2.new(0.05, 0, 0.85, 0)
LevelLabel.BackgroundTransparency = 1
LevelLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
LevelLabel.Font = Enum.Font.GothamBold
LevelLabel.Parent = MainFrame

-- Atualizar level automaticamente
game:GetService("Players").LocalPlayer.Data.Level.Changed:Connect(function()
    LevelLabel.Text = "Level: "..game:GetService("Players").LocalPlayer.Data.Level.Value
end)

-- Notificação Inicial
game.StarterGui:SetCore("SendNotification", {
    Title = "SonicHub Pro",
    Text = "Farm inteligente carregado!",
    Duration = 5
})
