--[[
	GemUpgrades - CornValueUpg3 y RebirthValueUpg1 (gemas).
	Reemplaza GemUpgrade1 y GemUpgrade2.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BASE_COST = 10
local MULTIPLIER = 1.5
local MAX_LEVEL = 50

local GEM_UPGRADES = {
	{ event = "UpgradeCornValueUpg3Request", eventMax = "UpgradeCornValueUpg3RequestMax", upg = "CornValueUpg3" },
	{ event = "UpgradeRebirthValueUpg1Request", eventMax = "UpgradeRebirthValueUpg1RequestMax", upg = "RebirthValueUpg1" },
}

for _, cfg in ipairs(GEM_UPGRADES) do
	local upgradeEvent = ReplicatedStorage:WaitForChild(cfg.event)
	local upgradeEventMax = ReplicatedStorage:WaitForChild(cfg.eventMax)

	local function tryUpgrade(player)
		local currencies = player:FindFirstChild("Currencies")
		local upgrades = player:FindFirstChild("Upgrades")
		if not currencies or not upgrades then return end

		local gems = currencies:FindFirstChild("Gemeralds")
		local upg = upgrades:FindFirstChild(cfg.upg)
		if not gems or not upg or upg.Value >= MAX_LEVEL then return end

		local cost = math.floor(BASE_COST * (MULTIPLIER ^ upg.Value))

		if gems.Value >= cost then
			gems.Value -= cost
			upg.Value += 1
		end
	end

	upgradeEvent.OnServerEvent:Connect(tryUpgrade)

	upgradeEventMax.OnServerEvent:Connect(function(player)
		local upgrades = player:FindFirstChild("Upgrades")
		if not upgrades then return end
		local upg = upgrades:FindFirstChild(cfg.upg)
		if not upg then return end

		while upg.Value < MAX_LEVEL do
			local before = upg.Value
			tryUpgrade(player)
			if upg.Value == before then break end
		end
	end)
end
