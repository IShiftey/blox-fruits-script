--[[
  🚀 Blox Fruits Ultimate Script 🚀
  Recursos: Auto Farm, Teleporte, Interface Amigável
  Atualizado para a versão mais recente do jogo
]]

-- Configurações iniciais
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Verificação do jogo
local validPlaceIds = {2753915549, 4442272183, 7449423635}
if not table.find(validPlaceIds, game.PlaceId) then
    Player:Kick("⚠️ Script compatível apenas com Blox Fruits!")
    return
end

-- Função para criar botões
local function CreateButton(parent, text, position, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0, 200, 0, 50)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Criação da interface
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxFruitsGUI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.05, 0, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "BLOX FRUITS SCRIPT"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Funções principais
local farming = false
local function ToggleFarm()
    farming = not farming
    while farming do
        task.wait()
        local Enemies = workspace.Enemies:GetChildren()
        for _, enemy in pairs(Enemies) do
            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                Character:SetPrimaryPartCFrame(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", enemy)
            end
        end
    end
end

local Islands = {
    ["Shells Town"] = CFrame.new(-260, 20, 340),
    ["Desert"] = CFrame.new(1000, 20, 2000),
    ["Pirate Village"] = CFrame.new(-1100, 20, 3900)
}

-- Botões
CreateButton(MainFrame, "TOGGLE AUTO FARM", UDim2.new(0.1, 0, 0.2, 0), ToggleFarm)

CreateButton(MainFrame, "TELEPORT TO DESERT", UDim2.new(0.1, 0, 0.4, 0), function()
    Character:SetPrimaryPartCFrame(Islands["Desert"])
end)

CreateButton(MainFrame, "TELEPORT TO PIRATES", UDim2.new(0.1, 0, 0.6, 0), function()
    Character:SetPrimaryPartCFrame(Islands["Pirate Village"])
end)

CreateButton(MainFrame, "FECHAR INTERFACE", UDim2.new(0.1, 0, 0.8, 0), function()
    ScreenGui:Destroy()
end)

-- Notificação inicial
game.StarterGui:SetCore("SendNotification", {
    Title = "Blox Fruits Script",
    Text = "Script carregado com sucesso!",
    Duration = 5
})
