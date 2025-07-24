--[[
  🚀 SonicHub ULTIMATE FIX - Blox Fruits Script 🚀
  Versão 10.1 | Correções Completas
]]

-- Configuração inicial segura
repeat task.wait() until game:IsLoaded()
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Sistema Anti-Return Aprimorado
local AntiReturn = Instance.new("BodyVelocity")
AntiReturn.Velocity = Vector3.new(0, 25, 0)
AntiReturn.MaxForce = Vector3.new(0, 0, 0) -- Inicia desativado
AntiReturn.Parent = Character:WaitForChild("HumanoidRootPart")

-- Atualiza referências ao respawn
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    AntiReturn = Instance.new("BodyVelocity")
    AntiReturn.Velocity = Vector3.new(0, 25, 0)
    AntiReturn.MaxForce = Vector3.new(0, 0, 0)
    AntiReturn.Parent = Character:WaitForChild("HumanoidRootPart")
end)

-- Remove GUI antiga
if game:GetService("CoreGui"):FindFirstChild("SonicHubUltimateFix") then
    game:GetService("CoreGui").SonicHubUltimateFix:Destroy()
end

-- Interface Ampliada
local SonicHub = Instance.new("ScreenGui")
SonicHub.Name = "SonicHubUltimateFix"
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
Title.Text = "SONIC HUB ULTIMATE FIX"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

MainFrame.Parent = SonicHub

-- Sistema de Missões Automático Aprimorado
local function GetBestQuest()
    local PlayerLevel = Player.Data.Level.Value
    local closestNPC, minDist = nil, math.huge
    
    -- Verifica todos os NPCs com quests
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if npc:FindFirstChild("Quest") and npc.Quest:FindFirstChild("RequiredLevel") then
            local npcLevel = npc.Quest.RequiredLevel.Value
            local levelDiff = math.abs(PlayerLevel - npcLevel)
            
            -- Aceita NPCs até 25 níveis acima/abaixo
            if levelDiff <= 25 then
                local dist = (npc.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    closestNPC = npc
                    minDist = dist
                end
            end
        end
    end
    
    return closestNPC
end

-- Função para ir até o NPC
local function GoToNPC(npc)
    local startTime = os.time()
    local maxAttempts = 3
    
    for attempt = 1, maxAttempts do
        -- Ativa anti-return durante movimento
        AntiReturn.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        while (npc.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude > 15 and os.time() - startTime < 20 do
            pcall(function()
                Character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
            end)
            task.wait(0.5)
        end
        
        -- Tenta aceitar a missão
        local success = pcall(function()
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", npc.Name, 1)
        end)
        
        if success then
            AntiReturn.MaxForce = Vector3.new(0, 0, 0)
            return npc.Name
        end
    end
    
    AntiReturn.MaxForce = Vector3.new(0, 0, 0)
    return nil
end

-- Farm Automático Completo
local Farming = false
local CurrentQuest = ""

local function ToggleFarm()
    Farming = not Farming
    
    if Farming then
        -- Busca e vai até o NPC
        local npc = GetBestQuest()
        if not npc then
            game.StarterGui:SetCore("SendNotification", {
                Title = "ERRO",
                Text = "Nenhum NPC de missão encontrado!",
                Duration = 5
            })
            Farming = false
            return
        end
        
        CurrentQuest = GoToNPC(npc)
        if not CurrentQuest then
            game.StarterGui:SetCore("SendNotification", {
                Title = "ERRO",
                Text = "Falha ao aceitar missão",
                Duration = 5
            })
            Farming = false
            return
        end

        -- Inicia o farm
        spawn(function()
            while Farming and task.wait(0.3) do
                pcall(function()
                    -- Encontra mobs da missão atual
                    local ValidEnemies = {}
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if string.find(enemy.Name, CurrentQuest) and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
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
                        
                        -- Movimento inteligente
                        if Distance > 50 then
                            Character.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 10, 10)
                        else
                            Character.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3)
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", Target)
                        end
                    else
                        -- Se não achar mobs, verifica se precisa de nova missão
                        if os.time() % 15 < 0.3 then
                            CurrentQuest = GoToNPC(GetBestQuest()) or CurrentQuest
                        end
                    end
                end)
            end
        end)
    else
        CurrentQuest = ""
        AntiReturn.MaxForce = Vector3.new(0, 0, 0)
    end
end

-- Teleporte Aprimorado (Anti-Return)
local Teleporting = false
local function SafeTeleport(cframe)
    if Teleporting then return end
    Teleporting = true
    
    pcall(function()
        -- Prepara anti-return
        AntiReturn.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        AntiReturn.Velocity = Vector3.new(0, 25, 0)
        
        -- Teleporte em duas etapas
        Character.HumanoidRootPart.CFrame = cframe + Vector3.new(0, 25, 0) -- Posição alta
        task.wait(0.3)
        Character.HumanoidRootPart.CFrame = cframe -- Posição final
        task.wait(0.5)
        
        -- Desativa anti-return gradualmente
        for i = 1, 0, -0.1 do
            AntiReturn.MaxForce = Vector3.new(math.huge * i, math.huge * i, math.huge * i)
            task.wait(0.05)
        end
    end)
    
    Teleporting = false
end

-- Locais Atualizados (Testados)
local Locations = {
    ["Desert"] = CFrame.new(1094.15, 16.84, 1792.70),
    ["Pirate Village"] = CFrame.new(-1163.40, 44.79, 3846.38),
    ["Castle on Sea"] = CFrame.new(-5478.39, 315.63, -3136.26),
    ["Middle Town"] = CFrame.new(-655.83, 15.89, 1435.90),
    ["Green Zone"] = CFrame.new(-2258.69, 73.02, -2696.33)
}

-- Criação de Botões em Grade
local ButtonLayout = {
    {"🔘 TOGGLE AUTO FARM", 0.15, 0.1, ToggleFarm},
    {"🏜️ DESERT", 0.15, 0.55, function() SafeTeleport(Locations["Desert"]) end},
    {"🏴‍☠️ PIRATE VILLAGE", 0.3, 0.1, function() SafeTeleport(Locations["Pirate Village"]) end},
    {"🏰 CASTLE ON SEA", 0.3, 0.55, function() SafeTeleport(Locations["Castle on Sea"]) end},
    {"🏘️ MIDDLE TOWN", 0.45, 0.1, function() SafeTeleport(Locations["Middle Town"]) end},
    {"🌴 GREEN ZONE", 0.45, 0.55, function() SafeTeleport(Locations["Green Zone"]) end},
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

-- Sistema Anti-AFK
spawn(function()
    while task.wait(30) do
        pcall(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
        end)
    end
end)

-- Notificação Inicial
game.StarterGui:SetCore("SendNotification", {
    Title = "SonicHub ULTIMATE FIX",
    Text = "Script carregado com sucesso!",
    Duration = 5
})
