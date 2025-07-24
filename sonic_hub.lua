--[[
  🚀 SonicHub RELOADED - Blox Fruits Script 🚀
  Versão 10.0 | Loader Infalível | Interface Garantida
]]

-- Verificação de Segurança Inicial
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Função para criar a interface
local function CreateInterface()
    -- Remove interface antiga se existir
    if game:GetService("CoreGui"):FindFirstChild("SonicHubReloaded") then
        game:GetService("CoreGui").SonicHubReloaded:Destroy()
    end

    -- Criação da Interface
    local SonicHub = Instance.new("ScreenGui")
    SonicHub.Name = "SonicHubReloaded"
    SonicHub.ResetOnSpawn = false
    SonicHub.Parent = game:GetService("CoreGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.05, 0, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = SonicHub

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = "SONIC HUB RELOADED"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.Parent = MainFrame

    -- Botão de Farm Automático
    local FarmBtn = Instance.new("TextButton")
    FarmBtn.Text = "▶ INICIAR AUTO FARM"
    FarmBtn.Size = UDim2.new(0.9, 0, 0, 45)
    FarmBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
    FarmBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FarmBtn.Font = Enum.Font.GothamBold
    FarmBtn.Parent = MainFrame

    local Corner = Instance.new("UICorner")
    Corner.Parent = FarmBtn

    -- Botão de Teleporte
    local TeleportBtn = Instance.new("TextButton")
    TeleportBtn.Text = "🌍 MENU DE TELEPORTES"
    TeleportBtn.Size = UDim2.new(0.9, 0, 0, 45)
    TeleportBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
    TeleportBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
    TeleportBtn.Parent = MainFrame

    local Corner2 = Instance.new("UICorner")
    Corner2.Parent = TeleportBtn

    -- Botão Fechar
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "❌ FECHAR INTERFACE"
    CloseBtn.Size = UDim2.new(0.9, 0, 0, 45)
    CloseBtn.Position = UDim2.new(0.05, 0, 0.85, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    CloseBtn.Parent = MainFrame

    local Corner3 = Instance.new("UICorner")
    Corner3.Parent = CloseBtn

    -- Ações dos Botões
    FarmBtn.MouseButton1Click:Connect(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USER/SEU_REPO/main/autofarm.lua", true))()
    end)

    TeleportBtn.MouseButton1Click:Connect(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USER/SEU_REPO/main/teleport.lua", true))()
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        SonicHub:Destroy()
    end)

    -- Notificação de Sucesso
    game.StarterGui:SetCore("SendNotification", {
        Title = "SONIC HUB CARREGADO",
        Text = "Interface criada com sucesso!",
        Duration = 5,
        Icon = "rbxassetid://6726579484"
    })

    print("✅ Interface carregada com sucesso!")
end

-- Carregamento Seguro
local success, err = pcall(function()
    CreateInterface()
end)

if not success then
    warn("❌ Erro ao criar interface: "..err)
    game.StarterGui:SetCore("SendNotification", {
        Title = "ERRO CRÍTICO",
        Text = "Falha ao carregar o SonicHub",
        Duration = 10,
        Icon = "rbxassetid://7733960981"
    })
end
