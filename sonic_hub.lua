--[[
  🚀 SonicHub PRO MAX - Blox Fruits Script 🚀
  Versão 8.0 | Auto-NPC | Interface Ampliada
]]

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Configuração Anti-Return
local AntiReturn = Instance.new("BodyVelocity")
AntiReturn.Velocity = Vector3.new(0, 0, 0)
AntiReturn.MaxForce = Vector3.new(0, 0, 0)
AntiReturn.Parent = Character:WaitForChild("HumanoidRootPart")

-- Interface Ampliada
local SonicHub = Instance.new("ScreenGui")
SonicHub.Name = "SonicHubPROMAX"
SonicHub.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 500)  -- Largura aumentada
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)  -- Centralizado
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "SONIC HUB PRO MAX"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

MainFrame.Parent = SonicHub

-- Sistema de Busca de NPC Automática
local function FindAndGoToNPC()
    local PlayerLevel = Player.Data.Level.Value
    local closestNPC, minDist = nil, math.huge
    
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if npc:FindFirstChild("Quest") and npc.Quest.Visible then
            local npcLevel = npc.Quest.RequiredLevel.Value
            if PlayerLevel >= npcLevel and PlayerLevel <= npcLevel + 25 then
                local dist = (npc.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    closestNPC = npc
                    minDist = dist
                end
            end
        end
    end
    
    if closestNPC then
        game.StarterGui:SetCore("SendNotification", {
            Title = "NPC ENCONTRADO",
            Text = "Indo até: "..closestNPC.Name,
            Duration = 3
        })
        
        -- Vai até o NPC
        local startTime = os.time()
        while (closestNPC.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude > 10 and os.time() - startTime < 15 do
            Character.HumanoidRootPart.CFrame = closestNPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
            task.wait(0.3)
        end
        
        -- Aceita a missão
        if (closestNPC.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude <= 15 then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", closestNPC.Name, 1)
            return closestNPC.Name
        end
    end
    return nil
end

-- Farm Automático Completo
local Farming = false
local CurrentQuest = ""

local function ToggleFarm()
    Farming = not Farming
    
    if Farming then
        -- Busca e aceita missão automaticamente
        CurrentQuest = FindAndGoToNPC()
        
        if not CurrentQuest then
            game.StarterGui:SetCore("SendNotification", {
                Title = "ERRO",
                Text = "Nenhum NPC de missão encontrado!",
                Duration = 5
            })
            Farming = false
            return
        end

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
                        -- Se não achar mobs, procura novamente
                        if os.time() % 10 < 0.3 then  -- A cada ~10 segundos
                            CurrentQuest = FindAndGoToNPC()
                        end
                    end
                end)
            end
        end)
    else
        CurrentQuest = ""
    end
end

-- Teleporte Aprimorado
local Teleporting = false
local function SafeTeleport(cframe)
    if Teleporting then return end
    Teleporting = true
    
    pcall(function()
        -- Prepara para teleporte
        AntiReturn.MaxForce = Vector3.new(math.huge, 0, math.huge)  -- Só trava no eixo Y
        AntiReturn.Velocity = Vector3.new(0, 25, 0)  -- Impede queda
        
        -- Teleporte suave
        Character.HumanoidRootPart.CFrame = cframe
        task.wait(0.5)
        
        -- Reset seguro
        AntiReturn.MaxForce = Vector3.new(0, 0, 0)
    end)
    
    Teleporting = false
end

-- Locais Atualizados
local Locations = {
    ["Desert"] = CFrame.new(1094.15, 16.84, 1792.70),
    ["Pirate Village"] = CFrame.new(-1163.40, 44.79, 3846.38),
    ["Castle on Sea"] = CFrame.new(-5478.39, 315.63, -3136.26),
    ["Middle Town"] = CFrame.new(-655.83, 15.89, 1435.90),
    ["Green Zone"] = CFrame.new(-2258.69, 73.02, -2696.33)
}

-- Criação de Botões em Grade (2 colunas)
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
    Title = "SonicHub PRO MAX",
    Text = "Script carregado com sucesso!",
    Duration = 5
})
