-- Script de Imunidade e Controle
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Configurações
local IMMUNITY_ENABLED = true  -- Se você quer estar imune
local USE_KEYBIND = true       -- Se você quer usar keybind para ativar
local KEYBIND = Enum.KeyCode.X -- Tecla para ativar (mude se quiser)

-- Variáveis do sistema
local Remote = ReplicatedStorage.RE:FindFirstChild("1Gu1n")
local isProtected = true
local isActive = false
local targetIndex = 1

-- Função para detectar se o vetor é suspeito (valores muito altos)
local function isSuspiciousVector(vector)
    if not vector then return false end
    local threshold = 1e10 -- Limite para considerar suspeito
    return math.abs(vector.X) > threshold or 
           math.abs(vector.Y) > threshold or 
           math.abs(vector.Z) > threshold
end

-- Função para proteger contra o exploit
local function protectPlayer()
    if not IMMUNITY_ENABLED then return end
    
    -- Hook no RemoteEvent para interceptar chamadas maliciosas
    local originalFireServer = Remote.FireServer
    Remote.FireServer = function(self, ...)
        local args = {...}
        
        -- Verifica se os argumentos contêm vetores suspeitos
        if args[3] and isSuspiciousVector(args[3]) then
            -- Se o alvo for você, bloqueia
            if args[1] and args[1].Parent == LocalPlayer.Character then
                warn("Exploit bloqueado! Tentativa de teleporte malicioso detectada.")
                return -- Bloqueia a execução
            end
        end
        
        -- Se não for suspeito ou não for direcionado a você, permite
        return originalFireServer(self, ...)
    end
end

-- Função para executar o exploit em outros players
local function executeOnTarget()
    if not isActive then return end
    
    local allPlayers = Players:GetPlayers()
    if #allPlayers < 2 then return end
    
    targetIndex = targetIndex + 1
    if targetIndex > #allPlayers then targetIndex = 1 end
    
    local target = allPlayers[targetIndex]
    
    -- Pula se o alvo for você mesmo
    if target == LocalPlayer then
        targetIndex = targetIndex + 1
        if targetIndex > #allPlayers then targetIndex = 1 end
        target = allPlayers[targetIndex]
    end
    
    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local crazyVector = Vector3.new(
            math.random(1e14, 1e15),
            math.random(1e14, 1e15),
            math.random(1e14, 1e15)
        )
        
        local args = {
            [1] = target.Character.HumanoidRootPart,
            [2] = target.Character.HumanoidRootPart,
            [3] = crazyVector,
            [4] = target.Character.HumanoidRootPart.Position,
            [5] = LocalPlayer.Backpack:FindFirstChild("Assault") and LocalPlayer.Backpack.Assault.GunScript_Local:FindFirstChild("MuzzleEffect"),
            [6] = LocalPlayer.Backpack:FindFirstChild("Assault") and LocalPlayer.Backpack.Assault.GunScript_Local:FindFirstChild("HitEffect"),
            [7] = 0,
            [8] = 0,
            [9] = { [1] = false },
            [10] = {
                [1] = 25,
                [2] = Vector3.new(100, 100, 100),
                [3] = BrickColor.new(29),
                [4] = 0.25,
                [5] = Enum.Material.SmoothPlastic,
                [6] = 0.25
            },
            [11] = true,
            [12] = false
        }
        
        -- Usa a função original para bypassing da proteção
        Remote.FireServer(Remote, unpack(args))
    end
end

-- Sistema de controle por tecla
if USE_KEYBIND then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == KEYBIND then
            isActive = not isActive
            
            if isActive then
                print("Sistema ativado! Pressione " .. KEYBIND.Name .. " novamente para desativar.")
                -- Conecta o loop de execução
                RunService.Stepped:Connect(executeOnTarget)
            else
                print("Sistema desativado!")
            end
        end
    end)
end

-- Função para ativar/desativar manualmente (para usar em outros scripts)
local function toggleSystem(state)
    if state == nil then
        isActive = not isActive
    else
        isActive = state
    end
    
    if isActive then
        print("Sistema ativado programaticamente!")
        RunService.Stepped:Connect(executeOnTarget)
    else
        print("Sistema desativado programaticamente!")
    end
end

-- Função para ativar em player específico
local function targetSpecificPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("Player não encontrado ou sem character válido: " .. playerName)
        return
    end
    
    local crazyVector = Vector3.new(
        math.random(1e14, 1e15),
        math.random(1e14, 1e15),
        math.random(1e14, 1e15)
    )
    
    local args = {
        [1] = targetPlayer.Character.HumanoidRootPart,
        [2] = targetPlayer.Character.HumanoidRootPart,
        [3] = crazyVector,
        [4] = targetPlayer.Character.HumanoidRootPart.Position,
        [5] = LocalPlayer.Backpack:FindFirstChild("Assault") and LocalPlayer.Backpack.Assault.GunScript_Local:FindFirstChild("MuzzleEffect"),
        [6] = LocalPlayer.Backpack:FindFirstChild("Assault") and LocalPlayer.Backpack.Assault.GunScript_Local:FindFirstChild("HitEffect"),
        [7] = 0,
        [8] = 0,
        [9] = { [1] = false },
        [10] = {
            [1] = 25,
            [2] = Vector3.new(100, 100, 100),
            [3] = BrickColor.new(29),
            [4] = 0.25,
            [5] = Enum.Material.SmoothPlastic,
            [6] = 0.25
        },
        [11] = true,
        [12] = false
    }
    
    Remote.FireServer(Remote, unpack(args))
    print("Exploit executado em: " .. playerName)
end

-- Ativa a proteção
protectPlayer()

-- Interface para controle manual
print("=== SISTEMA DE CONTROLE ===")
print("Imunidade: " .. (IMMUNITY_ENABLED and "ATIVADA" or "DESATIVADA"))
if USE_KEYBIND then
    print("Pressione " .. KEYBIND.Name .. " para ativar/desativar o sistema")
end
print("Use toggleSystem(true/false) para controle manual")
print("Use targetSpecificPlayer('NomeDoPlayer') para alvo específico")
print("============================")

-- Retorna as funções para uso externo
return {
    toggleSystem = toggleSystem,
    targetSpecificPlayer = targetSpecificPlayer,
    isActive = function() return isActive end,
    setImmunity = function(state) IMMUNITY_ENABLED = state; protectPlayer() end
}