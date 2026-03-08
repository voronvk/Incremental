local ReplicatedStorage = game:GetService("ReplicatedStorage")
local upgradeEvent = ReplicatedStorage:WaitForChild("UpgradeSpawnRateUpg1Request")
local upgradeEventMax = ReplicatedStorage:WaitForChild("UpgradeSpawnRateUpg1RequestMax")
local Players = game:GetService("Players")

local BASE_COST = 5
local MULTIPLIER = 2
local MAX_LEVEL = 7

upgradeEvent.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then return end

	local corn = currencies:FindFirstChild("Corn")
	local spawnRate = upgrades:FindFirstChild("SpawnRateUpg1")
	if not corn or not spawnRate then return end

	local currentLevel = spawnRate.Value
	if currentLevel >= MAX_LEVEL then return end

	local cost = math.floor(BASE_COST * (MULTIPLIER ^ currentLevel))

	if corn.Value >= cost then
		corn.Value -= cost
		spawnRate.Value += 1
	end
end)

upgradeEventMax.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then return end

	local corn = currencies:FindFirstChild("Corn")
	local spawnRate = upgrades:FindFirstChild("SpawnRateUpg1")
	if not corn or not spawnRate then return end

	while spawnRate.Value < MAX_LEVEL do
		local currentLevel = spawnRate.Value
		local cost = math.floor(BASE_COST * (MULTIPLIER ^ currentLevel))

		if corn.Value >= cost then
			corn.Value -= cost
			spawnRate.Value += 1
		else
			break
		end
	end
end)

task.spawn(function()
	while true do
		for _, player in pairs(Players:GetPlayers()) do
			local currencies = player:FindFirstChild("Currencies")
			local upgrades = player:FindFirstChild("Upgrades")
			local tier = upgrades:WaitForChild("Tier")
			if currencies and upgrades then
				local corn = currencies:FindFirstChild("Corn")
				local spawnRate = upgrades:FindFirstChild("SpawnRateUpg1")
				if corn and spawnRate and spawnRate.Value < MAX_LEVEL and tier.Value >= 5 then
					local currentLevel = spawnRate.Value
					local cost = math.floor(BASE_COST * (MULTIPLIER ^ currentLevel))
					if corn.Value >= cost then
						spawnRate.Value += 1
					end
				end
			end
		end
		task.wait(1)
	end
end)
