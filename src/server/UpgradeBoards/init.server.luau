--[[
	UpgradeBoards - Maneja SpawnRateUpg1, CornValueUpg1, CornAmountUpg1.
	Reemplaza Upgrade1, Upgrade2, Upgrade3.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local UPGRADE_BOARDS = {
	{ event = "UpgradeSpawnRateUpg1Request", eventMax = "UpgradeSpawnRateUpg1RequestMax", upg = "SpawnRateUpg1", base = 5, mult = 2, maxLevel = 7 },
	{ event = "UpgradeCornValueUpg1Request", eventMax = "UpgradeCornValueUpg1RequestMax", upg = "CornValueUpg1", base = 2, mult = 1.4, maxLevel = 99 },
	{ event = "UpgradeCornAmountUpg1Request", eventMax = "UpgradeCornAmountUpg1RequestMax", upg = "CornAmountUpg1", base = 3, mult = 1.4, maxLevel = 49 },
}

for _, cfg in ipairs(UPGRADE_BOARDS) do
	local ev = ReplicatedStorage:WaitForChild(cfg.event)
	local evMax = ReplicatedStorage:WaitForChild(cfg.eventMax)

	local function tryUpgrade(player)
		local currencies = player:FindFirstChild("Currencies")
		local upgrades = player:FindFirstChild("Upgrades")
		if not currencies or not upgrades then return end
		local corn = currencies:FindFirstChild("Corn")
		local upg = upgrades:FindFirstChild(cfg.upg)
		if not corn or not upg or upg.Value >= cfg.maxLevel then return end

		local cost = math.floor(cfg.base * (cfg.mult ^ upg.Value))

		if corn.Value >= cost then
			corn.Value -= cost
			upg.Value += 1
		end
	end

	ev.OnServerEvent:Connect(function(player)
		tryUpgrade(player)
	end)

	evMax.OnServerEvent:Connect(function(player)
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

-- Autobuy loop (tier >= 5)
task.spawn(function()
	while true do
		for _, player in pairs(Players:GetPlayers()) do
			local currencies = player:FindFirstChild("Currencies")
			local upgrades = player:FindFirstChild("Upgrades")
			if not currencies or not upgrades then continue end
			local tier = upgrades:FindFirstChild("Tier")
			if not tier or tier.Value < 5 then continue end
			local corn = currencies:FindFirstChild("Corn")
			if not corn then continue end

			for _, cfg in ipairs(UPGRADE_BOARDS) do
				local upg = upgrades:FindFirstChild(cfg.upg)
				if upg and upg.Value < cfg.maxLevel then
					local cost = math.floor(cfg.base * (cfg.mult ^ upg.Value))
					if corn.Value >= cost then
						corn.Value -= cost
						upg.Value += 1
					end
				end
			end
		end
		task.wait(1)
	end
end)
