local ReplicatedStorage = game:GetService("ReplicatedStorage")
local upgradeEvent = ReplicatedStorage:WaitForChild("UpgradeCornValueUpg4Request")
local upgradeEventMax = ReplicatedStorage:WaitForChild("UpgradeCornValueUpg4RequestMax")
local Players = game:GetService("Players")

local BASE_COST = 100
local MULTIPLIER = 5
local MAX_LEVEL = 10

upgradeEvent.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then return end

	local clicks = currencies:FindFirstChild("Clicks")
	local upg = upgrades:FindFirstChild("CornValueUpg4")
	if not clicks or not upg then return end

	local currentLevel = upg.Value
	if currentLevel >= MAX_LEVEL then return end

	local tier = upgrades:WaitForChild("Tier")
	local surcharge = (tier.Value >= 1) and 25 or 1

	local cost = math.floor(BASE_COST * (MULTIPLIER ^ currentLevel) * surcharge)

	if clicks.Value >= cost then
		clicks.Value -= cost
		upg.Value += 1
	end
end)

upgradeEventMax.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then return end

	local clicks = currencies:FindFirstChild("Clicks")
	local upg = upgrades:FindFirstChild("CornValueUpg4")
	if not clicks or not upg then return end

	while upg.Value < MAX_LEVEL do
		local currentLevel = upg.Value
		local tier = upgrades:WaitForChild("Tier")
		local surcharge = (tier.Value >= 1) and 25 or 1

		local cost = math.floor(BASE_COST * (MULTIPLIER ^ currentLevel) * surcharge)

		if clicks.Value >= cost then
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

			local upgtree2_4 = upgrades:FindFirstChild("UpgTree2_4")
			local upg = upgrades:FindFirstChild("CornValueUpg4")
			local clicks = currencies:FindFirstChild("Clicks")
			if upg and clicks and upgtree2_4 and upg.Value < MAX_LEVEL and upgtree2_4.Value >= 1 then
				local currentLevel = upg.Value
				local tier = upgrades:WaitForChild("Tier")
				local surcharge = (tier.Value >= 1) and 25 or 1
				local cost = math.floor(BASE_COST * (MULTIPLIER ^ currentLevel) * surcharge)
				if clicks.Value >= cost then
					upg.Value += 1
				end
			end
		end
		task.wait(1)
	end
end)
