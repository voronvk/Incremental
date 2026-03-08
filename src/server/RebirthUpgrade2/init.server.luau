local ReplicatedStorage = game:GetService("ReplicatedStorage")
local upgradeEvent = ReplicatedStorage:WaitForChild("UpgradeCollectRadiusUpg1Request")
local upgradeEventMax = ReplicatedStorage:WaitForChild("UpgradeCollectRadiusUpg1RequestMax")
local Players = game:GetService("Players")

local BASE_COST = 2
local MULTIPLIER = 2
local MAX_LEVEL = 5

upgradeEvent.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then return end

	local rebirths = currencies:FindFirstChild("Rebirths")
	local collectRadius = upgrades:FindFirstChild("CollectRadiusUpg1")
	if not rebirths or not collectRadius then return end

	local currentLevel = collectRadius.Value
	if currentLevel >= MAX_LEVEL then return end

	local cost = math.floor(BASE_COST * (MULTIPLIER ^ currentLevel))

	if rebirths.Value >= cost then
		rebirths.Value -= cost
		collectRadius.Value += 1
	end
end)

upgradeEventMax.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then return end

	local rebirths = currencies:FindFirstChild("Rebirths")
	local collectRadius = upgrades:FindFirstChild("CollectRadiusUpg1")
	if not rebirths or not collectRadius then return end

	while collectRadius.Value < MAX_LEVEL do
		local currentLevel = collectRadius.Value
		local cost = math.floor(BASE_COST * (MULTIPLIER ^ currentLevel))

		if rebirths.Value >= cost then
			rebirths.Value -= cost
			collectRadius.Value += 1
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
				local rebirths = currencies:FindFirstChild("Rebirths")
				local spawnRate = upgrades:FindFirstChild("CollectRadiusUpg1")
				if rebirths and spawnRate and spawnRate.Value < MAX_LEVEL and tier.Value >= 5 then
					local currentLevel = spawnRate.Value
					local cost = math.floor(BASE_COST * (MULTIPLIER ^ currentLevel))
					if rebirths.Value >= cost then
						spawnRate.Value += 1
					end
				end
			end
		end
		task.wait(1)
	end
end)
