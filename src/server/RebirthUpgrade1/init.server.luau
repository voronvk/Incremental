local ReplicatedStorage = game:GetService("ReplicatedStorage")
local upgradeEvent = ReplicatedStorage:WaitForChild("UpgradeCornValueUpg2Request")
local upgradeEventMax = ReplicatedStorage:WaitForChild("UpgradeCornValueUpg2RequestMax")
local Players = game:GetService("Players")

local BASE_COST = 1
local MULTIPLIER = 4
local MAX_LEVEL = 6

upgradeEvent.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then return end

	local rebirths = currencies:FindFirstChild("Rebirths")
	local cornValue = upgrades:FindFirstChild("CornValueUpg2")
	if not rebirths or not cornValue then return end

	local currentLevel = cornValue.Value
	if currentLevel >= MAX_LEVEL then return end

	local cost = math.floor(BASE_COST * (MULTIPLIER ^ currentLevel))

	if rebirths.Value >= cost then
		rebirths.Value -= cost
		cornValue.Value += 1
	end
end)

upgradeEventMax.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then return end

	local rebirths = currencies:FindFirstChild("Rebirths")
	local cornValue = upgrades:FindFirstChild("CornValueUpg2")
	if not rebirths or not cornValue then return end

	while cornValue.Value < MAX_LEVEL do
		local currentLevel = cornValue.Value
		local cost = math.floor(BASE_COST * (MULTIPLIER ^ currentLevel))

		if rebirths.Value >= cost then
			rebirths.Value -= cost
			cornValue.Value += 1
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
				local spawnRate = upgrades:FindFirstChild("CornValueUpg2")
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
