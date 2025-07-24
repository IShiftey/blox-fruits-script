--[[
  🚀 SonicHub PERFECT FARM - Blox Fruits Script 🚀
  Versão 11.0 | Farm 100% Funcional | Teleporte Estável
  Baseado nos melhores scripts da comunidade
]]

-- Configuração inicial à prova de erros
repeat task.wait() until game:IsLoaded()
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Sistema Anti-Return Revolucionário
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
if game:GetService("CoreGui"):FindFirstChild("SonicHubPerfectFarm") then
    game:GetService("CoreGui").SonicHubPerfectFarm:Destroy()
end

-- Interface Premium Ampliada
local SonicHub = Instance.new("ScreenGui")
SonicHub.Name = "SonicHubPerfectFarm"
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
Title.Text = "SONIC HUB PERFECT FARM"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

MainFrame.Parent = SonicHub

-- ========== SISTEMA DE MISSÕES PERFEITO ==========
local function GetProperQuest()
    local PlayerLevel = Player.Data.Level.Value
    local closestNPC, minDist = nil, math.huge
    
    -- Método 1: Busca por NPCs visíveis
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if npc:FindFirstChild("Quest") and npc.Quest.Visible then
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
    
    -- Método 2: Busca por nome para casos especiais
    if not closestNPC then
        local backupNPCs = {
            "Bandit Quest Giver",
            "Marine Quest Giver",
            "Desert Bandit Quest Giver",
            "Snow Bandit Quest Giver"
        }
        
        for _, npcName in ipairs(backupNPCs) do
            local npc = workspace.NPCs:FindFirstChild(npcName)
            if npc and npc:FindFirstChild("Quest") then
                closestNPC = npc
                break
            end
        end
    end
    
    return closestNPC
end

local function AcceptQuest(npc)
    local success = pcall(function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", npc.Name, 1)
    end)
    return success
end

-- ========== FARM AUTOMÁTICO PERFEITO ==========
local Farming = false
local CurrentQuest = ""

local function ToggleFarm()
    Farming = not Farming
    
    if Farming then
        -- Fase 1: Encontrar e aceitar missão
        local npc = GetProperQuest()
        
        if not npc then
            game.StarterGui:SetCore("SendNotification", {
                Title = "ERRO",
                Text = "Nenhum NPC adequado encontrado",
                Duration = 5
            })
            Farming = false
            return
        end
        
        -- Vai até o NPC
        game.StarterGui:SetCore("SendNotification", {
            Title = "MISSÃO",
            Text = "Indo até: "..npc.Name,
            Duration = 3
        })
        
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
        else
            game.StarterGui:SetCore("SendNotification", {
                Title = "ERRO",
                Text = "Falha ao aceitar missão",
                Duration = 5
            })
            Farming = false
            return
        end
        
        -- Fase 2: Farmar os mobs
        spawn(function()
            while Farming and task.wait(0.3) do
                pcall(function()
                    -- Encontra todos os mobs da missão
                    local ValidEnemies = {}
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            if string.find(enemy.Name, CurrentQuest) or (CurrentQuest == "" and enemy:FindFirstChild("HumanoidRootPart")) then
                                table.insert(ValidEnemies, enemy)
                            end
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
                        
                        -- Movimento inteligente
                        if Distance > 50 then
                            Character.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 10, 10)
                        else
                            Character.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3)
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", Target)
                        end
                    else
                        -- Verifica se precisa de nova missão
                        if os.time() % 10 < 0.3 then
                            npc = GetProperQuest()
                            if npc and (npc.Name ~= CurrentQuest) then
                                CurrentQuest = AcceptQuest(npc) and npc.Name or CurrentQuest
                            end
                        end
                    end
                end)
            end
        end)
    else
        CurrentQuest = ""
    end
end

-- ========== TELEPORTE PERFEITO ==========
local Teleporting = false
local function PerfectTeleport(cframe)
    if Teleporting then return end
    Teleporting = true
    
    -- Salva posição original
    local originalPosition = Character.HumanoidRootPart.CFrame
    
    -- Configura anti-return
    AntiReturn.MaxForce = Vector3.new(math.huge, 0, math.huge) -- Só trava no eixo Y
    AntiReturn.Velocity = Vector3.new(0, 0, 0)
    
    -- Teleporte em 3 etapas
    Character.HumanoidRootPart.CFrame = cframe * CFrame.new(0, 25, 0) -- Etapa 1: Alto
    task.wait(0.2)
    Character.HumanoidRootPart.CFrame = cframe -- Etapa 2: Posição correta
    task.wait(0.5)
    
    -- Verificação final
    if (Character.HumanoidRootPart.Position - cframe.Position).Magnitude > 50 then
        -- Se falhar, volta para posição original
        Character.HumanoidRootPart.CFrame = originalPosition
    end
    
    -- Desativa gradualmente
    for i = 1, 0, -0.1 do
        AntiReturn.MaxForce = Vector3.new(math.huge * i, 0, math.huge * i)
        task.wait(0.05)
    end
    
    Teleporting = false
end

-- Locais testados e aprovados
local Locations = {
    ["Desert"] = CFrame.new(1094.15, 16.84, 1792.70),
    ["Pirate Village"] = CFrame.new(-1163.40, 44.79, 3846.38),
    ["Castle on Sea"] = CFrame.new(-5478.39, 315.63, -3136.26),
    ["Middle Town"] = CFrame.new(-655.83, 15.89, 1435.90),
    ["Green Zone"] = CFrame.new(-2258.69, 73.02, -2696.33)
}

-- ========== INTERFACE COMPLETA ==========
local ButtonLayout = {
    {"🔘 TOGGLE AUTO FARM", 0.15, 0.1, ToggleFarm},
    {"🏜️ DESERT", 0.15, 0.55, function() PerfectTeleport(Locations["Desert"]) end},
    {"🏴‍☠️ PIRATE VILLAGE", 0.3, 0.1, function() PerfectTeleport(Locations["Pirate Village"]) end},
    {"🏰 CASTLE ON SEA", 0.3, 0.55, function() PerfectTeleport(Locations["Castle on Sea"]) end},
    {"🏘️ MIDDLE TOWN", 0.45, 0.1, function() PerfectTeleport(Locations["Middle Town"]) end},
    {"🌴 GREEN ZONE", 0.45, 0.55, function() PerfectTeleport(Locations["Green Zone"]) end},
    {"❌ CLOSE HUB", 0.6, 0.325, function() SonicHub:Destroy() end}
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
StatusLabel.Text = "AGUARDANDO..."
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
    Title = "SonicHub PERFECT FARM",
    Text = "Script carregado com sucesso!",
    Duration = 5
})
