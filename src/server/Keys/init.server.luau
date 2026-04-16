local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Keys: nueva moneda (player.Currencies.Keys)
-- Objetivo: 5 Keys por 60s, entregadas al TERMINAR el ciclo (cuando se llena la barra).
local CYCLE_SECONDS = 60
local KEYS_PER_CYCLE = 5

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
			keysVal.Value += KEYS_PER_CYCLE
			elapsed = 0
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	task.spawn(function()
		startKeyLoop(player)
	end)
end)

