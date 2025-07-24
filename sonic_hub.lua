--[[
  🚀 SonicHub ULTIMATE V2 - Blox Fruits Script 🚀
  Versão 9.0 | Sistema de Missões Inteligente
]]

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Configuração Anti-Return Otimizada
local AntiReturn = Instance.new("BodyVelocity")
AntiReturn.Velocity = Vector3.new(0, 25, 0)
AntiReturn.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
AntiReturn.Parent = Character:WaitForChild("HumanoidRootPart")

-- Interface Ampliada
local SonicHub = Instance.new("ScreenGui")
SonicHub.Name = "SonicHubULTIMATE"
SonicHub.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 500)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "SONIC HUB ULTIMATE V2"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

MainFrame.Parent = SonicHub

-- Sistema Inteligente de Busca de NPCs (Métodos Combinados)
local function FindBestNPC()
    local PlayerLevel = Player.Data.Level.Value
    local bestNPC, bestScore = nil, -math.huge
    
    -- Método 1: Busca por proximidade e nível
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if npc:FindFirstChild("Quest") then
            local npcLevel = npc.Quest.RequiredLevel.Value
            local levelDiff = math.abs(PlayerLevel - npcLevel)
            
            -- Calcula score baseado em nível e distância
            if PlayerLevel >= npcLevel - 10 and PlayerLevel <= npcLevel + 25 then
                local distance = (npc.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                local score = (100 - levelDiff) * 0.6 + (100 - distance/10) * 0.4
                
                if score > bestScore then
                    bestNPC = npc
                    bestScore = score
                end
            end
        end
    end
    
    -- Método 2: Busca alternativa para ilhas específicas
    if not bestNPC then
        local zoneNPCs = {
            ["Desert"] = {"Desert Quest Giver"},
            ["Pirate Village"] = {"Pirate Quest Giver"},
            ["Green Zone"] = {"Forest Pirate Quest Giver"}
        }
        
        for zoneName, npcNames in pairs(zoneNPCs) do
            for _, npcName in ipairs(npcNames) do
                local npc = workspace.NPCs:FindFirstChild(npcName)
                if npc and npc:FindFirstChild("Quest") then
                    bestNPC = npc
                    break
                end
            end
            if bestNPC then break end
        end
    end
    
    return bestNPC
end

-- Sistema de Navegação até NPC
local function GoToNPC(npc)
    local maxAttempts = 3
    for attempt = 1, maxAttempts do
        local startTime = os.time()
        local success = false
        
        -- Ativa anti-return durante o movimento
        AntiReturn.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        while os.time() - startTime < 15 and not success do
            pcall(function()
                local npcPos = npc.HumanoidRootPart.Position
                local charPos = Character.HumanoidRootPart.Position
                local distance = (npcPos - charPos).Magnitude
                
                if distance > 50 then
                    -- Teleporte para perto do NPC
                    Character.HumanoidRootPart.CFrame = CFrame.new(npcPos + Vector3.new(0, 10, 10))
                elseif distance > 10 then
                    -- Aproximação suave
                    Character.HumanoidRootPart.CFrame = CFrame.new(npcPos + Vector3.new(0, 0, 5))
                else
                    success = true
                end
            end)
            task.wait(0.5)
        end
        
        if success then
            -- Tenta aceitar a missão
            local questAccepted = pcall(function()
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", npc.Name, 1)
            end)
            
            if questAccepted then
                return npc.Name
            end
        end
    end
    return nil
end

-- Sistema de Farm Automático Completo
local Farming = false
local CurrentQuest = ""

local function ToggleFarm()
    Farming = not Farming
    
    if Farming then
        spawn(function()
            while Farming do
                -- Etapa 1: Encontrar e ir até o NPC
                local npc = FindBestNPC()
                
                if not npc then
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "ALERTA",
                        Text = "NPC não encontrado! Mudando de servidor...",
                        Duration = 5
                    })
                    -- Auto-server hop pode ser implementado aqui
                    Farming = false
                    break
                end
                
                game.StarterGui:SetCore("SendNotification", {
                    Title = "MISSÃO",
                    Text = "Indo até: "..npc.Name,
                    Duration = 5
                })
                
                CurrentQuest = GoToNPC(npc)
                
                if not CurrentQuest then
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "ERRO",
                        Text = "Falha ao aceitar missão",
                        Duration = 5
                    })
                    task.wait(3)
                    continue
                end
                
                -- Etapa 2: Farmar os mobs
                local lastMobCheck = 0
                while Farming and task.wait(0.3) do
                    pcall(function()
                        -- Verifica mobs a cada 5 segundos
                        if os.time() - lastMobCheck > 5 then
                            lastMobCheck = os.time()
                            
                            -- Atualiza lista de mobs válidos
                            local validMobs = {}
                            for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                                if string.find(enemy.Name, CurrentQuest) and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                                    table.insert(validMobs, enemy)
                                end
                            end
                            
                            if #validMobs == 0 then
                                break -- Volta para buscar novo NPC
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
            end
        end)
    else
        CurrentQuest = ""
        AntiReturn.MaxForce = Vector3.new(0, 0, 0)
    end
end

-- (O resto do código permanece igual ao anterior...)
