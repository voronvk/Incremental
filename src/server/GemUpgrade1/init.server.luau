local ReplicatedStorage = game:GetService("ReplicatedStorage")
local upgradeEvent = ReplicatedStorage:WaitForChild("UpgradeCornValueUpg3Request")
local upgradeEventMax = ReplicatedStorage:WaitForChild("UpgradeCornValueUpg3RequestMax")

local BASE_COST = 10
local MULTIPLIER = 1.5
local MAX_LEVEL = 50

upgradeEvent.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then return end

	local gems = currencies:FindFirstChild("Gemeralds")
	local upg = upgrades:FindFirstChild("CornValueUpg3")
	if not gems or not upg then return end

	local currentLevel = upg.Value
	if currentLevel >= MAX_LEVEL then return end

	local cost = math.floor(BASE_COST * (MULTIPLIER ^ currentLevel))

	if gems.Value >= cost then
		gems.Value -= cost
		upg.Value += 1
	end
end)

upgradeEventMax.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then return end

	local gems = currencies:FindFirstChild("Gemeralds")
	local upg = upgrades:FindFirstChild("CornValueUpg3")
	if not gems or not upg then return end

	while upg.Value < MAX_LEVEL do
		local currentLevel = upg.Value
		local cost = math.floor(BASE_COST * (MULTIPLIER ^ currentLevel))

		if gems.Value >= cost then
			gems.Value -= cost
			upg.Value += 1
		else
			break
		end
	end
end)
