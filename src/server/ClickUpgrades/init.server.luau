--[[
	ClickUpgrades - Maneja UpgradeCornValueUpg4, UpgradeRebirthValueUpg2, UpgradeAutoclickers.
	Reemplaza ClickUpgrade1, ClickUpgrade2, ClickUpgrade3.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CLICK_UPGRADES = {
	{ event = "UpgradeCornValueUpg4Request", eventMax = "UpgradeCornValueUpg4RequestMax", upg = "CornValueUpg4", base = 100, mult = 5, maxLevel = 10 },
	{ event = "UpgradeRebirthValueUpg2Request", eventMax = "UpgradeRebirthValueUpg2RequestMax", upg = "RebirthValueUpg2", base = 100, mult = 5, maxLevel = 10 },
	{ event = "UpgradeAutoclickersRequest", eventMax = "UpgradeAutoclickersRequestMax", upg = "Autoclickers", base = 10, mult = 10, maxLevel = 10 },
}

for _, cfg in ipairs(CLICK_UPGRADES) do
	local ev = ReplicatedStorage:WaitForChild(cfg.event)
	local evMax = ReplicatedStorage:WaitForChild(cfg.eventMax)

	local function tryUpgrade(player)
		local currencies = player:FindFirstChild("Currencies")
		local upgrades = player:FindFirstChild("Upgrades")
		if not currencies or not upgrades then return end
		local clicks = currencies:FindFirstChild("Clicks")
		local upg = upgrades:FindFirstChild(cfg.upg)
		if not clicks or not upg or upg.Value >= cfg.maxLevel then return end

		local tier = upgrades:FindFirstChild("Tier")
		local surcharge = (tier and tier.Value >= 1) and 25 or 1
		local cost = math.floor(cfg.base * (cfg.mult ^ upg.Value) * surcharge)

		if clicks.Value >= cost then
			clicks.Value -= cost
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

-- Autobuy loop (UpgTree2_4)
task.spawn(function()
	while true do
		for _, player in pairs(Players:GetPlayers()) do
			local upgrades = player:FindFirstChild("Upgrades")
			if not upgrades then continue end
			local upgtree2_4 = upgrades:FindFirstChild("UpgTree2_4")
			if not upgtree2_4 or upgtree2_4.Value < 1 then continue end

			for _, cfg in ipairs(CLICK_UPGRADES) do
				local upg = upgrades:FindFirstChild(cfg.upg)
				if upg and upg.Value < cfg.maxLevel then
					local currencies = player:FindFirstChild("Currencies")
					if not currencies then break end
					local clicks = currencies:FindFirstChild("Clicks")
					if not clicks then break end

					local tier = upgrades:FindFirstChild("Tier")
					local surcharge = (tier and tier.Value >= 1) and 25 or 1
					local cost = math.floor(cfg.base * (cfg.mult ^ upg.Value) * surcharge)

					-- Autobuy matches GeneratorPurchase: require affordable cost but do not spend clicks
					if clicks.Value >= cost then
						upg.Value += 1
					end
				end
			end
		end
		task.wait(1)
	end
end)
