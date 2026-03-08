local ReplicatedStorage = game:GetService("ReplicatedStorage")
local upgradeEvent = ReplicatedStorage:WaitForChild("GeneratorPurchaseEvent")
local upgradeEventMax = ReplicatedStorage:WaitForChild("GeneratorPurchaseEventMax")
local Players = game:GetService("Players")

local BASE_COST = 100000
local MULTIPLIER = 1.1
local MAX_LEVEL = 100000

upgradeEvent.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then return end

	local clicks = currencies:FindFirstChild("Clicks")
	local upg = upgrades:FindFirstChild("Generators")
	local upgtree14 = upgrades:FindFirstChild("UpgTree14")
	local tier = upgrades:WaitForChild("Tier")

	local discount = (upgtree14 and upgtree14.Value == 1) and 0.1 or 1
	local discount2 = (tier.Value >= 3) and 0.001 or 1

	local currentLevel = upg.Value
	if currentLevel >= MAX_LEVEL then return end

	local cost = math.floor(BASE_COST * (MULTIPLIER ^ currentLevel) * discount * discount2)

	if clicks and clicks.Value >= cost then
		clicks.Value -= cost
		upg.Value += 1
	end
end)

upgradeEventMax.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then return end

	local clicks = currencies:FindFirstChild("Clicks")
	local upg = upgrades:FindFirstChild("Generators")
	local upgtree14 = upgrades:FindFirstChild("UpgTree14")
	local tier = upgrades:WaitForChild("Tier")

	local discount = (upgtree14 and upgtree14.Value == 1) and 0.1 or 1
	local discount2 = (tier.Value >= 3) and 0.001 or 1

	while upg.Value < MAX_LEVEL do
		local currentLevel = upg.Value
		local cost = math.floor(BASE_COST * (MULTIPLIER ^ currentLevel) * discount * discount2)

		if clicks and clicks.Value >= cost then
			clicks.Value -= cost
			upg.Value += 1
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
			if not currencies or not upgrades then continue end

			local clicks = currencies:FindFirstChild("Clicks")
			local upg = upgrades:FindFirstChild("Generators")
			local upgtree14 = upgrades:FindFirstChild("UpgTree14")
			local tier = upgrades:FindFirstChild("Tier")
			local upgtree2_15 = upgrades:FindFirstChild("UpgTree2_15")

			if clicks and upg and upgtree14 and tier and upgtree2_15 and upg.Value < MAX_LEVEL and upgtree2_15.Value >= 1 then
				local discount = (upgtree14.Value == 1) and 0.1 or 1
				local discount2 = (tier.Value >= 3) and 0.001 or 1
				local cost = math.floor(BASE_COST * (MULTIPLIER ^ upg.Value) * discount * discount2)

				if clicks.Value >= cost then
					upg.Value += 1
				end
			end
		end
		task.wait(1)
	end
end)
