--[[
	RebirthUpgrades - RebirthBoard1/2/3 (currency: Rebirths).
	Reemplaza RebirthUpgrade1, RebirthUpgrade2, RebirthUpgrade3.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local REBIRTH_UPGRADES = {
	{ event = "UpgradeCornValueUpg2Request", eventMax = "UpgradeCornValueUpg2RequestMax", upg = "CornValueUpg2", base = 1, mult = 4, maxLevel = 6 },
	{ event = "UpgradeCollectRadiusUpg1Request", eventMax = "UpgradeCollectRadiusUpg1RequestMax", upg = "CollectRadiusUpg1", base = 2, mult = 2, maxLevel = 5 },
	{ event = "UpgradeSpawnRateUpg2Request", eventMax = "UpgradeSpawnRateUpg2RequestMax", upg = "SpawnRateUpg2", base = 3, mult = 2, maxLevel = 8 },
}

for _, cfg in ipairs(REBIRTH_UPGRADES) do
	local upgradeEvent = ReplicatedStorage:WaitForChild(cfg.event)
	local upgradeEventMax = ReplicatedStorage:WaitForChild(cfg.eventMax)

	local function tryUpgrade(player)
		local currencies = player:FindFirstChild("Currencies")
		local upgrades = player:FindFirstChild("Upgrades")
		if not currencies or not upgrades then return end

		local rebirths = currencies:FindFirstChild("Rebirths")
		local upg = upgrades:FindFirstChild(cfg.upg)
		if not rebirths or not upg or upg.Value >= cfg.maxLevel then return end

		local cost = math.floor(cfg.base * (cfg.mult ^ upg.Value))

		if rebirths.Value >= cost then
			rebirths.Value -= cost
			upg.Value += 1
		end
	end

	upgradeEvent.OnServerEvent:Connect(tryUpgrade)

	upgradeEventMax.OnServerEvent:Connect(function(player)
		local upgrades = player:FindFirstChild("Upgrades")
		if not upgrades then return end
		local upg = upgrades:FindFirstChild(cfg.upg)
		if not upg then return end

		while upg.Value < cfg.maxLevel do
			local before = upg.Value
			tryUpgrade(player)
			if upg.Value == before then break end
		end
	end)
end

-- Autobuy (tier >= 5)
task.spawn(function()
	while true do
		for _, player in pairs(Players:GetPlayers()) do
			local currencies = player:FindFirstChild("Currencies")
			local upgrades = player:FindFirstChild("Upgrades")
			if not currencies or not upgrades then continue end
			local tier = upgrades:FindFirstChild("Tier")
			if not tier or tier.Value < 5 then continue end

			local rebirths = currencies:FindFirstChild("Rebirths")
			if not rebirths then continue end

			for _, cfg in ipairs(REBIRTH_UPGRADES) do
				local upg = upgrades:FindFirstChild(cfg.upg)
				if upg and upg.Value < cfg.maxLevel then
					local cost = math.floor(cfg.base * (cfg.mult ^ upg.Value))
					if rebirths.Value >= cost then
						rebirths.Value -= cost
						upg.Value += 1
					end
				end
			end
		end
		task.wait(1)
	end
end)
