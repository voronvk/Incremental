local ReplicatedStorage = game:GetService("ReplicatedStorage")
local upgradeEvent = ReplicatedStorage:WaitForChild("AddEnergy2")
local Players = game:GetService("Players")

upgradeEvent.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then return end

	local energy = currencies:FindFirstChild("Energy")
	local upg = upgrades:FindFirstChild("RebirthEnergy")
	if not energy or not upg then return end

	local cost = math.floor(energy.Value * 0.5)

	if energy.Value >= cost then
		energy.Value -= cost
		upg.Value += cost
	end
end)

task.spawn(function()
	while true do
		for _, player in pairs(Players:GetPlayers()) do
			local currencies = player:FindFirstChild("Currencies")
			local upgrades = player:FindFirstChild("Upgrades")
			local tier = upgrades:WaitForChild("Tier")
			local upgtree2_2 = upgrades:WaitForChild("UpgTree2_2")
			if currencies and upgrades then
				local energy = currencies:WaitForChild("Energy")
				if upgtree2_2.Value >= 1 then
					local upg = upgrades:FindFirstChild("RebirthEnergy")
					if upg and energy.Value >= upg.Value then
						upg.Value = energy.Value
					end
				end
			end
		end
		task.wait(1)
	end
end)
