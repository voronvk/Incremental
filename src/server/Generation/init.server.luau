local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Event = ReplicatedStorage:WaitForChild("GenerationEvent")

Event.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	local events = player:FindFirstChild("Events")
	local generators = upgrades:FindFirstChild("Generators")
	local energy = currencies:FindFirstChild("Energy")
	local upgtree13 = upgrades:FindFirstChild("UpgTree13")
	local upgtree15 = upgrades:FindFirstChild("UpgTree15")
	local upgtree17 = upgrades:FindFirstChild("UpgTree17")
	local autoclickers = upgrades:FindFirstChild("Autoclickers")
	local level = events:FindFirstChild("Level")
	local energyenergy = upgrades:FindFirstChild("EnergyEnergy")
	local tier = upgrades:FindFirstChild("Tier")
	local upgtree2_3 = upgrades:FindFirstChild("UpgTree2_3")
	local upgtree2_16 = upgrades:FindFirstChild("UpgTree2_16")

	if not (generators and energy) then return end

	local mult = (upgtree13 and upgtree13.Value == 1) and 5 or 1
	local mult2 = (upgtree15 and upgtree15.Value == 1) and ((autoclickers and autoclickers.Value == 0) and 1 or autoclickers.Value) or 1
	local mult3 = (upgtree17 and upgtree17.Value == 1) and ((level and level.Value == 0) and 1 or level.Value) or 1
	local mult4 = (energyenergy and ((energyenergy.Value + 1) ^ (1/5))) or 1
	local mult5 = (tier and tier.Value >= 1) and 2 or 1
	local mult6 = (tier and tier.Value >= 2) and tier.Value or 1
	local mult7 = (upgtree2_3 and upgtree2_3.Value >= 1) and 5 or 1
	local mult8 = (upgtree2_16 and upgtree2_16.Value >= 1) and 10 or 1

	energy.Value = energy.Value + (generators.Value * mult * mult2 * mult3 * mult4 * mult5 * mult6 * mult7 * mult8)
end)
