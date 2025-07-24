--[[
  🚀 SonicHub Premium - Blox Fruits Ultimate 🚀
  Versão 3.0.1 | Auto-Update | Design Premium
]]

-- Configurações globais
local VERSION = "3.0.1"
local GITHUB_URL = "https://raw.githubusercontent.com/IShiftey/blox-fruits-script/main/sonic_hub.lua"
local PLAYER = game:GetService("Players").LocalPlayer

local validGames = {
    [2753915549] = "Blox Fruits",
    [4442272183] = "Blox Fruits (Second Sea)",
    [7449423635] = "Blox Fruits (Third Sea)"
}

if not validGames[game.PlaceId] then
    PLAYER:Kick("❌ Execute apenas em Blox Fruits!")
    return
end

-- Sistema de Auto-Update
local function CheckUpdates()
    local success, latestVersion = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/IShiftey/blox-fruits-script/main/version.txt")
    end)
    
    if success and latestVersion ~= VERSION then
        game.StarterGui:SetCore("SendNotification", {
            Title = "SonicHub Update",
            Text = "Nova versão "..latestVersion.." disponível!",
            Duration = 10,
            Button1 = "Atualizar"
        })
        
        return loadstring(game:HttpGet(GITHUB_URL.."?update="..tostring(os.time()), true))()
    end
end

spawn(CheckUpdates)

-- Interface Premium
local SonicUI = Instance.new("ScreenGui")
SonicUI.Name = "SonicHubPremium"
SonicUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SonicUI.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.05, 0, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 150, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

MainFrame.Parent = SonicUI

-- Cabeçalho Premium
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "SONIC HUB PREMIUM"
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Text = "v"..VERSION
VersionLabel.Size = UDim2.new(0, 60, 1, 0)
VersionLabel.Position = UDim2.new(1, -70, 0, 0)
VersionLabel.BackgroundTransparency = 1
VersionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextSize = 14
VersionLabel.Parent = Header

-- Funções Premium
local function CreateSonicButton(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Position = UDim2.new(0.05, 0, yPos, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(0, 150, 255)
    btnStroke.Thickness = 1
    btnStroke.Parent = btn
    
    btn.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(40, 50, 80)
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(30, 40, 60)
        }):Play()
    end)
    
    btn.MouseButton1Click:Connect(callback)
    btn.Parent = MainFrame
    return btn
end

-- Sistema de Farm Inteligente
local farming = false
local function ToggleFarm()
    farming = not farming
    
    if farming then
        spawn(function()
            while farming and task.wait(0.3) do
                pcall(function()
                    local closest, dist = nil, math.huge
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            local enemyDist = (PLAYER.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                            if enemyDist < dist then
                                closest = enemy
                                dist = enemyDist
                            end
                        end
                    end
                    
                    if closest then
                        PLAYER.Character:SetPrimaryPartCFrame(closest.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", closest)
                    end
                end)
            end
        end)
    end
end

-- Sistema de Teleporte Seguro
local Islands = {
    ["Desert"] = CFrame.new(1000, 20, 2000),
    ["Pirate Village"] = CFrame.new(-1100, 20, 3900),
    ["Castle on the Sea"] = CFrame.new(-5000, 350, 300)
}

local teleporting = false
local function SafeTeleport(cframe)
    if teleporting then return end
    teleporting = true
    
    pcall(function()
        PLAYER.Character:SetPrimaryPartCFrame(cframe)
        task.wait(1.5) -- Delay de segurança
    end)
    
    teleporting = false
end

-- Botões Premium
CreateSonicButton("🔄 TOGGLE AUTO FARM", 0.15, ToggleFarm)
CreateSonicButton("🏜️ TELEPORT TO DESERT", 0.25, function() SafeTeleport(Islands["Desert"]) end)
CreateSonicButton("🏴‍☠️ TELEPORT TO PIRATES", 0.35, function() SafeTeleport(Islands["Pirate Village"]) end)
CreateSonicButton("🏰 CASTLE ON THE SEA", 0.45, function() SafeTeleport(Islands["Castle on the Sea"]) end)
CreateSonicButton("📌 TOGGLE ANTI-AFK", 0.55, function()
    -- Implementar anti-afk aqui
end)
CreateSonicButton("❌ FECHAR HUB", 0.75, function()
    SonicUI:Destroy()
end)

-- Notificação Inicial
game.StarterGui:SetCore("SendNotification", {
    Title = "SonicHub Premium",
    Text = "Versão "..VERSION.." carregada!",
    Duration = 5,
    Icon = "rbxassetid://6726579484"
})

-- Anti-AFK Automático
local VirtualInput = game:GetService("VirtualInputManager")
spawn(function()
    while task.wait(30) do
        pcall(function()
            VirtualInput:SendKeyEvent(true, "F", false, game)
            task.wait(0.1)
            VirtualInput:SendKeyEvent(false, "F", false, game)
        end)
    end
end)
