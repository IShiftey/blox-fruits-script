--[[
  🚀 SonicHub Ultra - Blox Fruits Script 🚀
  Versão 6.0 | Farm Completo | Teleporte Fixo
  Baseado nos melhores scripts disponíveis
]]

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Anti-Return
local AntiReturn = Instance.new("BodyVelocity")
AntiReturn.Velocity = Vector3.new(0,0,0)
AntiReturn.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
AntiReturn.Parent = Character:WaitForChild("HumanoidRootPart")

-- Interface Premium
local SonicHub = Instance.new("ScreenGui")
SonicHub.Name = "SonicHubUltra"
SonicHub.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.05, 0, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "SONIC HUB ULTRA"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

MainFrame.Parent = SonicHub

-- Sistema de Missões Automático (Versão Melhorada)
local function GetBestQuest()
    local QuestRemote = game:GetService("ReplicatedStorage").Remotes.CommF_
    local PlayerLevel = Player.Data.Level.Value
    
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if npc:FindFirstChild("Quest") then
            local QuestLevel = npc.Quest.RequiredLevel.Value
            if PlayerLevel >= QuestLevel and PlayerLevel <= QuestLevel + 15 then
                return npc.Name
            end
        end
    end
    return nil
end

-- Farm Automático Aprimorado
local Farming = false
local function ToggleFarm()
    Farming = not Farming
    
    if Farming then
        local QuestName = GetBestQuest()
        if not QuestName then
            game.StarterGui:SetCore("SendNotification", {
                Title = "ERRO",
                Text = "Nenhuma missão encontrada!",
                Duration = 5
            })
            Farming = false
            return
        end
        
        -- Aceita a missão
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", QuestName, 1)
        
        spawn(function()
            while Farming and task.wait() do
                pcall(function()
                    -- Encontra todos os mobs da missão
                    local ValidEnemies = {}
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if string.find(enemy.Name, QuestName) and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            table.insert(ValidEnemies, enemy)
                        end
                    end
                    
                    -- Ataca o mais próximo
                    if #ValidEnemies > 0 then
                        table.sort(ValidEnemies, function(a,b)
                            return (a.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude <
                                   (b.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                        end)
                        
                        local Target = ValidEnemies[1]
                        local Distance = (Target.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                        
                        -- Movimento inteligente
                        if Distance > 50 then
                            Character.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0)
                        else
                            Character.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3)
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", Target)
                        end
                    end
                end)
            end
        end)
    end
end

-- Teleporte Aprimorado (Com Anti-Return)
local Teleporting = false
local function SafeTeleport(cframe)
    if Teleporting then return end
    Teleporting = true
    
    pcall(function()
        -- Ativa anti-return
        AntiReturn.Velocity = Vector3.new(0,10000,0)
        Character.HumanoidRootPart.CFrame = cframe
        wait(1)
        AntiReturn.Velocity = Vector3.new(0,0,0)
    end)
    
    Teleporting = false
end

-- Locais Atualizados (Coordenadas precisas)
local Locations = {
    ["Desert"] = CFrame.new(1094.14587, 6.8427763, 1792.69617),
    ["Pirate Village"] = CFrame.new(-1163.39746, 44.7868423, 3846.37939),
    ["Castle on Sea"] = CFrame.new(-5478.39209, 315.634277, -3136.25635),
    ["Middle Town"] = CFrame.new(-655.825317, 7.88708115, 1435.90234)
}

-- Criação de Botões Automática
local ButtonLayout = {
    {"🔘 TOGGLE AUTO FARM", 0.15, ToggleFarm},
    {"🏜️ DESERT", 0.25, function() SafeTeleport(Locations["Desert"]) end},
    {"🏴‍☠️ PIRATE VILLAGE", 0.35, function() SafeTeleport(Locations["Pirate Village"]) end},
    {"🏰 CASTLE ON SEA", 0.45, function() SafeTeleport(Locations["Castle on Sea"]) end},
    {"🏘️ MIDDLE TOWN", 0.55, function() SafeTeleport(Locations["Middle Town"]) end},
    {"❌ CLOSE HUB", 0.75, function() SonicHub:Destroy() end}
}

for _, btnData in ipairs(ButtonLayout) do
    local btn = Instance.new("TextButton")
    btn.Text = btnData[1]
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, btnData[2], 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(btnData[3])
    btn.Parent = MainFrame
end

-- Sistema Anti-AFK
spawn(function()
    while wait(30) do
        pcall(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
            wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
        end)
    end
end)

-- Notificação Inicial
game.StarterGui:SetCore("SendNotification", {
    Title = "SonicHub Ultra",
    Text = "Script carregado com sucesso!",
    Duration = 5
})
