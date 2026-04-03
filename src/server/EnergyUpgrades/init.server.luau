--[[
	EnergyUpgrades - AddEnergy1/2/3 (CornEnergy, RebirthEnergy, EnergyEnergy).
	Reemplaza EnergyUpgrade1, EnergyUpgrade2, EnergyUpgrade3.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ENERGY_CONFIG = {
	{ event = "AddEnergy1", upg = "CornEnergy" },
	{ event = "AddEnergy2", upg = "RebirthEnergy" },
	{ event = "AddEnergy3", upg = "EnergyEnergy" },
}

for _, cfg in ipairs(ENERGY_CONFIG) do
	local upgradeEvent = ReplicatedStorage:WaitForChild(cfg.event)

	upgradeEvent.OnServerEvent:Connect(function(player)
		local currencies = player:FindFirstChild("Currencies")
		local upgrades = player:FindFirstChild("Upgrades")
		if not currencies or not upgrades then return end

		local upgtree2_2 = upgrades:FindFirstChild("UpgTree2_2")
		if upgtree2_2 and upgtree2_2.Value >= 1 then
			return
		end

		local energy = currencies:FindFirstChild("Energy")
		local upg = upgrades:FindFirstChild(cfg.upg)
		if not energy or not upg then return end

		local cost = math.floor(energy.Value * 0.5)

		if energy.Value >= cost then
			energy.Value -= cost
			upg.Value += cost
		end
	end)
end

-- Sync loop (UpgTree2_2)
task.spawn(function()
	while true do
		for _, player in pairs(Players:GetPlayers()) do
			local currencies = player:FindFirstChild("Currencies")
			local upgrades = player:FindFirstChild("Upgrades")
			if not currencies or not upgrades then continue end
			local upgtree2_2 = upgrades:FindFirstChild("UpgTree2_2")
			if not upgtree2_2 or upgtree2_2.Value < 1 then continue end

			local energy = currencies:FindFirstChild("Energy")
			if not energy then continue end

			for _, cfg in ipairs(ENERGY_CONFIG) do
				local upg = upgrades:FindFirstChild(cfg.upg)
				if upg and energy.Value >= upg.Value then
					upg.Value = energy.Value
				end
			end
		end
		task.wait(1)
	end
end)
