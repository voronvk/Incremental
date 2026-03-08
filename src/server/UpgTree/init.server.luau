local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UpgradeConfig = require(ReplicatedStorage:WaitForChild("UpgradeConfig"))

for i = 1, 20 do
	local eventName = "UpgTree" .. i
	local event = ReplicatedStorage:WaitForChild(eventName)

	event.OnServerEvent:Connect(function(player)
		local upgrades = player:FindFirstChild("Upgrades")
		local currencies = player:FindFirstChild("Currencies")
		if not upgrades or not currencies then return end

		local upgValue = upgrades:FindFirstChild(eventName)
		if not upgValue then return end

		local config = UpgradeConfig[i]
		if not config then return end

		local currencyValue = currencies:FindFirstChild(config.Currency)
		if not currencyValue then return end

		if upgValue.Value == 0 and currencyValue.Value >= config.Cost then
			currencyValue.Value -= config.Cost
			upgValue.Value += 1
		end
	end)
end
