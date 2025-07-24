--[[
  🚀 SonicHub Ultimate - Blox Fruits Script 🚀
  Versão 7.0 | Farm e Teleporte 100% Funcionais
]]

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Configuração Anti-Return melhorada
local AntiReturn = Instance.new("BodyVelocity")
AntiReturn.Velocity = Vector3.new(0, 0, 0)
AntiReturn.MaxForce = Vector3.new(0, 0, 0) -- Inicialmente desativado
AntiReturn.Parent = Character:WaitForChild("HumanoidRootPart")

-- Interface Premium
local SonicHub = Instance.new("ScreenGui")
SonicHub.Name = "SonicHubUltimate"
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
Title.Text = "SONIC HUB ULTIMATE"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

MainFrame.Parent = SonicHub

-- Sistema de Missões Aprimorado
local function GetBestQuest()
    local PlayerLevel = Player.Data.Level.Value
    local closestNPC, minDist = nil, math.huge
    
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if npc:FindFirstChild("Quest") and npc.Quest.Visible then
            local npcLevel = npc.Quest.RequiredLevel.Value
            if PlayerLevel >= npcLevel and PlayerLevel <= npcLevel + 20 then
                local dist = (npc.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    closestNPC = npc
                    minDist = dist
                end
            end
        end
    end
    return closestNPC and closestNPC.Name
end

-- Farm Automático Corrigido
local Farming = false
local function ToggleFarm()
    Farming = not Farming
    
    if Farming then
        local QuestName = GetBestQuest()
        if not QuestName then
            game.StarterGui:SetCore("SendNotification", {
                Title = "ERRO",
                Text = "Aproxime-se de um NPC de missão!",
                Duration = 5
            })
            Farming = false
            return
        end
        
        -- Aceita a missão corretamente
        local success = pcall(function()
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", QuestName, 1)
        end)
        
        if not success then
            game.StarterGui:SetCore("SendNotification", {
                Title = "ERRO",
                Text = "Falha ao aceitar missão",
                Duration = 5
            })
            Farming = false
            return
        end

        spawn(function()
            while Farming and task.wait(0.3) do
                pcall(function()
                    -- Encontra todos os mobs da missão
                    local ValidEnemies = {}
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if string.find(enemy.Name, QuestName) and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            table.insert(ValidEnemies, enemy)
                        end
                    end
                    
                    if #ValidEnemies > 0 then
                        -- Ordena por distância
                        table.sort(ValidEnemies, function(a,b)
                            return (a.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude <
                                   (b.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                        end)
                        
                        local Target = ValidEnemies[1]
                        local Distance = (Target.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                        
                        -- Movimento seguro
                        if Distance > 50 then
                            Character.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 10, 10)
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

-- Teleporte Aprimorado (Sem bug visual)
local Teleporting = false
local function SafeTeleport(cframe)
    if Teleporting then return end
    Teleporting = true
    
    pcall(function()
        -- Prepara para teleporte
        AntiReturn.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        AntiReturn.Velocity = Vector3.new(0, 0, 0)
        
        -- Teleporte suave
        Character.HumanoidRootPart.CFrame = cframe
        wait(0.5)
        
        -- Reset seguro
        AntiReturn.MaxForce = Vector3.new(0, 0, 0)
    end)
    
    Teleporting = false
end

-- Locais Atualizados (Testados)
local Locations = {
    ["Desert"] = CFrame.new(1094.14587, 16.8427763, 1792.69617),
    ["Pirate Village"] = CFrame.new(-1163.39746, 44.7868423, 3846.37939),
    ["Castle on Sea"] = CFrame.new(-5478.39209, 315.634277, -3136.25635),
    ["Middle Town"] = CFrame.new(-655.825317, 15.88708115, 1435.90234)
}

-- Criação de Botões
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
    Title = "SonicHub Ultimate",
    Text = "Script carregado com sucesso!",
    Duration = 5
})

-- Atualização automática de status
spawn(function()
    while wait(5) do
        pcall(function()
            if Farming then
                local QuestName = GetBestQuest()
                if QuestName then
                    Title.Text = "FARMANDO: "..QuestName
                end
            else
                Title.Text = "SONIC HUB ULTIMATE"
            end
        end)
    end
end)
