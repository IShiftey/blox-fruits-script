--[[
  🚀 SonicHub PERFECT FARM - Blox Fruits Script 🚀
  Versão 12.0 | Corrigido problema de NPC não encontrado
]]

-- Configuração inicial aprimorada
repeat task.wait() until game:IsLoaded()
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Sistema Anti-Return melhorado
local AntiReturn = Instance.new("BodyVelocity")
AntiReturn.Velocity = Vector3.new(0, 0, 0)
AntiReturn.MaxForce = Vector3.new(0, 0, 0)
AntiReturn.Parent = Character:WaitForChild("HumanoidRootPart")

-- Atualização de personagem com tratamento de erro
Player.CharacterAdded:Connect(function(newChar)
    repeat task.wait() until newChar:FindFirstChild("HumanoidRootPart")
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    if AntiReturn then AntiReturn:Destroy() end
    
    AntiReturn = Instance.new("BodyVelocity")
    AntiReturn.Velocity = Vector3.new(0, 0, 0)
    AntiReturn.MaxForce = Vector3.new(0, 0, 0)
    AntiReturn.Parent = newChar:WaitForChild("HumanoidRootPart")
end)

-- Remove GUI antiga com verificação adicional
if game:GetService("CoreGui"):FindFirstChild("SonicHubPerfectFarm") then
    game:GetService("CoreGui").SonicHubPerfectFarm:Destroy()
end

-- Interface Premium Atualizada
local SonicHub = Instance.new("ScreenGui")
SonicHub.Name = "SonicHubPerfectFarm"
SonicHub.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 550) -- Tamanho aumentado
MainFrame.Position = UDim2.new(0.05, 0, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

-- Barra de título com gradiente
local Title = Instance.new("TextLabel")
Title.Text = "SONICHUB PERFECT FARM v12"
Title.Size = UDim2.new(1, 0, 0, 55)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 24
Title.Parent = MainFrame

MainFrame.Parent = SonicHub

-- ========== SISTEMA DE MISSÕES ATUALIZADO ==========
local function GetProperQuest()
    local PlayerLevel = Player.Data.Level.Value
    local closestNPC, minDist = nil, math.huge
    
    -- Debug: Imprime todos os NPCs disponíveis
    print("[DEBUG] Procurando NPCs...")
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        print("NPC encontrado:", npc.Name)
    end
    
    -- Método aprimorado de busca
    if workspace:FindFirstChild("NPCs") then
        for _, npc in pairs(workspace.NPCs:GetChildren()) do
            if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Quest") then
                -- Verificação mais flexível para NPCs de missão
                if npc.Quest:FindFirstChild("RequiredLevel") then
                    local npcLevel = npc.Quest.RequiredLevel.Value
                    
                    -- Faixa de nível mais ampla
                    if PlayerLevel >= npcLevel - 25 and PlayerLevel <= npcLevel + 30 then
                        local dist = (npc.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                        if dist < minDist then
                            closestNPC = npc
                            minDist = dist
                        end
                    end
                else
                    -- Verifica NPCs sem RequiredLevel (para casos especiais)
                    local dist = (npc.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                    if dist < minDist then
                        closestNPC = npc
                        minDist = dist
                    end
                end
            end
        end
    end
    
    -- Backup para NPCs específicos com busca mais abrangente
    if not closestNPC then
        print("[DEBUG] Usando busca de backup...")
        local backupNPCs = {
            "Bandit", -- Muitos NPCs começam com "Bandit"
            "Pirate", 
            "Marine",
            "Desert",
            "Snow"
        }
        
        for _, npcPrefix in ipairs(backupNPCs) do
            for _, npc in pairs(workspace.NPCs:GetChildren()) do
                if string.find(npc.Name:lower(), npcPrefix:lower()) and npc:FindFirstChild("HumanoidRootPart") then
                    closestNPC = npc
                    break
                end
            end
            if closestNPC then break end
        end
    end
    
    -- Final debug output
    if closestNPC then
        print("[DEBUG] NPC selecionado:", closestNPC.Name)
    else
        print("[DEBUG] Nenhum NPC adequado encontrado!")
    end
    
    return closestNPC
end

local function AcceptQuest(npc)
    if not npc then return false end
    
    local success = pcall(function()
        local args = {
            [1] = npc.Name,
            [2] = 1
        }
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", unpack(args))
        return true
    end)
    
    if not success then
        -- Tentativa alternativa para alguns casos especiais
        success = pcall(function()
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", npc.Name)
            return true
        end)
    end
    
    return success
end

-- ========== FARM AUTOMÁTICO OTIMIZADO ==========
local Farming = false
local CurrentQuest = ""
local LastNPCCheck = 0

local function ToggleFarm()
    Farming = not Farming
    
    if Farming then
        -- Fase 1: Encontrar e aceitar missão
        local npc = GetProperQuest()
        
        if not npc then
            game.StarterGui:SetCore("SendNotification", {
                Title = "ERRO",
                Text = "Nenhum NPC adequado encontrado",
                Duration = 5,
                Icon = "rbxassetid://0"
            })
            Farming = false
            return
        end
        
        -- Vai até o NPC com verificação de tempo
        game.StarterGui:SetCore("SendNotification", {
            Title = "MISSÃO",
            Text = "Indo até: "..npc.Name,
            Duration = 3,
            Icon = "rbxassetid://0"
        })
        
        local startTime = os.time()
        while Farming and npc and npc.Parent and (npc.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude > 15 and os.time() - startTime < 25 do
            pcall(function()
                Character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
            end)
            task.wait(0.7)
        end
        
        -- Aceita a missão com verificação
        if npc and npc.Parent then
            if AcceptQuest(npc) then
                CurrentQuest = npc.Name
                game.StarterGui:SetCore("SendNotification", {
                    Title = "SUCESSO",
                    Text = "Missão aceita: "..CurrentQuest,
                    Duration = 3,
                    Icon = "rbxassetid://0"
                })
            else
                game.StarterGui:SetCore("SendNotification", {
                    Title = "ERRO",
                    Text = "Falha ao aceitar missão",
                    Duration = 5,
                    Icon = "rbxassetid://0"
                })
                Farming = false
                return
            end
        else
            Farming = false
            return
        end
        
        -- Fase 2: Farmar os mobs
        spawn(function()
            while Farming and task.wait(0.2) do
                pcall(function()
                    -- Verificação periódica de NPC
                    if os.time() - LastNPCCheck > 30 then
                        local newNPC = GetProperQuest()
                        if newNPC and newNPC.Name ~= CurrentQuest then
                            if AcceptQuest(newNPC) then
                                CurrentQuest = newNPC.Name
                            end
                        end
                        LastNPCCheck = os.time()
                    end
                    
                    -- Encontra todos os mobs válidos (mais flexível)
                    local ValidEnemies = {}
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                            -- Aceita vários padrões de nome
                            if string.find(enemy.Name:lower(), CurrentQuest:lower()) or 
                               string.find(CurrentQuest:lower(), enemy.Name:lower()) or
                               string.find(enemy.Name:lower(), "quest") then
                                table.insert(ValidEnemies, enemy)
                            end
                        end
                    end
                    
                    -- Verifica mobs alternativos se nenhum corresponder exatamente
                    if #ValidEnemies == 0 then
                        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                                table.insert(ValidEnemies, enemy)
                            end
                        end
                    end
                    
                    -- Sistema de combate melhorado
                    if #ValidEnemies > 0 then
                        -- Ordena por distância
                        table.sort(ValidEnemies, function(a,b)
                            return (a.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude <
                                   (b.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                        end)
                        
                        local Target = ValidEnemies[1]
                        local Distance = (Target.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                        
                        -- Movimento inteligente com proteção anti-queda
                        if Distance > 50 then
                            Character.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 15, 15)
                        elseif Distance > 10 then
                            Character.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 5, 5)
                        else
                            Character.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 2, -2)
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", Target)
                        end
                    else
                        -- Verifica se precisa de nova missão
                        if os.time() % 15 < 0.3 then
                            npc = GetProperQuest()
                            if npc and (npc.Name ~= CurrentQuest) then
                                if AcceptQuest(npc) then
                                    CurrentQuest = npc.Name
                                end
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

-- ========== TELEPORTE APRIMORADO ==========
local Teleporting = false
local function PerfectTeleport(cframe)
    if Teleporting or not cframe then return end
    Teleporting = true
    
    -- Salva posição original
    local originalPosition = Character.HumanoidRootPart.CFrame
    
    -- Configura anti-return de forma segura
    pcall(function()
        AntiReturn.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        AntiReturn.Velocity = Vector3.new(0, 0, 0)
        AntiReturn.Parent = Character.HumanoidRootPart
    end)
    
    -- Teleporte em etapas com verificação
    local success = pcall(function()
        Character.HumanoidRootPart.CFrame = cframe * CFrame.new(0, 30, 0) -- Etapa 1: Alto
        task.wait(0.25)
        Character.HumanoidRootPart.CFrame = cframe * CFrame.new(0, 10, 0) -- Etapa 2: Médio
        task.wait(0.25)
        Character.HumanoidRootPart.CFrame = cframe -- Etapa 3: Posição final
        task.wait(0.5)
    end)
    
    -- Verificação de sucesso
    if not success or (Character.HumanoidRootPart.Position - cframe.Position).Magnitude > 100 then
        pcall(function()
            Character.HumanoidRootPart.CFrame = originalPosition
        end)
    end
    
    -- Desativa gradualmente
    for i = 1, 0, -0.1 do
        pcall(function()
            AntiReturn.MaxForce = Vector3.new(math.huge * i, math.huge * i, math.huge * i)
        end)
        task.wait(0.05)
    end
    
    Teleporting = false
    return success
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
    {"🏴‍☠️ PIRATE VILLAGE", 0.45, 0.1, function() PerfectTeleport(Locations["Pirate Village"]) end},
    {"🏰 CASTLE ON SEA", 0.45, 0.55, function() PerfectTeleport(Locations["Castle on Sea"]) end},
    {"🏘️ MIDDLE TOWN", 0.3, 0.1, function() PerfectTeleport(Locations["Middle Town"]) end},
    {"🌴 GREEN ZONE", 0.3, 0.55, function() PerfectTeleport(Locations["Green Zone"]) end},
    {"❌ CLOSE HUB", 0.75, 0.325, function() SonicHub:Destroy() end}
}

for _, btnData in ipairs(ButtonLayout) do
    local btn = Instance.new("TextButton")
    btn.Text = btnData[1]
    btn.Size = UDim2.new(0.4, 0, 0, 45)
    btn.Position = UDim2.new(btnData[3], 0, btnData[2], 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.TextColor3 = Color3.fromRGB(0, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 16
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn
    
    -- Efeito hover
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    end)
    
    btn.MouseButton1Click:Connect(btnData[4])
    btn.Parent = MainFrame
end

-- Status do Player aprimorado
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "AGUARDANDO COMANDOS..."
StatusLabel.Size = UDim2.new(0.9, 0, 0, 40)
StatusLabel.Position = UDim2.new(0.05, 0, 0.8, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 16
StatusLabel.Parent = MainFrame

-- Atualização de status melhorada
spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Farming then
                if CurrentQuest ~= "" then
                    StatusLabel.Text = "FARMANDO: "..CurrentQuest.." | "..Player.Data.Level.Value.." LVL"
                else
                    StatusLabel.Text = "BUSCANDO NPC ADEQUADO..."
                end
            else
                StatusLabel.Text = "PRONTO | "..Player.Data.Level.Value.." LVL | "..Player.Name
            end
        end)
    end
end)

-- Anti-AFK melhorado
spawn(function()
    while task.wait(30) do
        pcall(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
        end)
    end
end)

-- Notificação inicial com verificação
delay(2, function()
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "SonicHub PERFECT FARM v12",
            Text = "Script carregado com sucesso!\nNPC Detection System Ativo",
            Duration = 8,
            Icon = "rbxassetid://0"
        })
    end)
end)

-- Adiciona mensagem de debug no output
print("====================================")
print("SonicHub PERFECT FARM v12 Carregado")
print("Sistema de Detecção de NPC aprimorado")
print("====================================")
