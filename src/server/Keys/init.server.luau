local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
local GamePassConfig = require(ReplicatedStorage.Shared:WaitForChild("GamePassConfig"))

-- Keys: nueva moneda (player.Currencies.Keys)
-- Objetivo: 5 Keys por 60s, entregadas al TERMINAR el ciclo (cuando se llena la barra).
local CYCLE_SECONDS = 60
local KEYS_PER_CYCLE = 5
local X2_KEYS_GAMEPASS_ID = GamePassConfig.RUNE_X2_KEYS_GAMEPASS_ID or 1795970950

local function getKeysValue(player: Player): NumberValue?
	local currencies = player:FindFirstChild("Currencies")
	if not currencies then return nil end
	local keys = currencies:FindFirstChild("Keys")
	if keys and keys:IsA("NumberValue") then
		return keys
	end
	return nil
end

local function startKeyLoop(player: Player)
	-- Espera a que el DataStore haya creado los folders/values
	for _ = 1, 120 do
		if not player.Parent then return end
		if player:GetAttribute("PlayerDataLoaded") == true then
			break
		end
		task.wait(0.25)
	end
	if not player.Parent then return end

	local keysVal = getKeysValue(player)
	if not keysVal then
		warn("[Keys] Missing player.Currencies.Keys for", player.Name)
		return
	end

	local elapsed = 0

	while player.Parent do
		-- Pausa en Studio si el juego no está corriendo (evita bucles raros al recargar)
		if RunService:IsStudio() and not RunService:IsRunning() then
			task.wait(1)
			continue
		end

		task.wait(1)
		elapsed += 1

		if elapsed >= CYCLE_SECONDS then
			local gain = KEYS_PER_CYCLE
			if GamePassCheck.playerOwnsGamePass(player, X2_KEYS_GAMEPASS_ID) then
				gain *= 2
			end
			keysVal.Value += gain
			elapsed = 0
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	task.spawn(function()
		startKeyLoop(player)
	end)
end)

