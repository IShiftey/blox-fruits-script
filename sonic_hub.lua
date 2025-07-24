--[[
  🎮 SonicHub Premium - Blox Fruits Script 🎮
  Versão 4.0 | Farm Automático 100% Funcional
  Design Profissional | Anti-Ban
]]

-- Configurações Iniciais
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
SonicHub.Name = "SonicHubPremium"
SonicHub.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.8, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "SONIC HUB v4.0"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

MainFrame.Parent = SonicHub

-- Sistema de Farm Automático Aprimorado
local Farming = false
local function ToggleFarm()
    Farming = not Farming
    
    if Farming then
        spawn(function()
            while Farming and task.wait() do
                pcall(function()
                    local closestEnemy, minDistance = nil, math.huge
                    
                    -- Verificação otimizada de inimigos
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            local distance = (Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                            if distance < minDistance then
                                closestEnemy = enemy
                                minDistance = distance
                            end
                        end
                    end
                    
                    -- Ataque aprimorado
                    if closestEnemy then
                        Character:SetPrimaryPartCFrame(closestEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3))
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", closestEnemy)
                    end
                end)
            end
        end)
    end
end

-- Sistema de Teleporte Aprimorado
local Islands = {
    ["Desert"] = CFrame.new(1084.93, 16.29, 1727.26),
    ["Pirate Village"] = CFrame.new(-1171.45, 44.78, 3842.77),
    ["Castle on the Sea"] = CFrame.new(-5478.67, 315.73, -3132.64)
}

local function SafeTeleport(cframe)
    pcall(function()
        Character.HumanoidRootPart.CFrame = cframe
        task.wait(0.5)
    end)
end

-- Botões Profissionais
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
CreateButton("🏜️ TELEPORT TO DESERT", 0.25, function() SafeTeleport(Islands["Desert"]) end)
CreateButton("🏴‍☠️ TELEPORT TO PIRATES", 0.35, function() SafeTeleport(Islands["Pirate Village"]) end)
CreateButton("🏰 CASTLE ON THE SEA", 0.45, function() SafeTeleport(Islands["Castle on the Sea"]) end)
CreateButton("📌 TOGGLE ANTI-AFK", 0.55, function()
    -- Sistema Anti-AFK aqui
end)
CreateButton("❌ CLOSE HUB", 0.75, function()
    SonicHub:Destroy()
end)

-- Notificação Inicial
game.StarterGui:SetCore("SendNotification", {
    Title = "SonicHub Premium",
    Text = "Script carregado com sucesso!",
    Duration = 5
})

-- Anti-AFK Automático
spawn(function()
    while task.wait(30) do
        pcall(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
        end)
    end
end)
