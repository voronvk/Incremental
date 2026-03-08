local ReplicatedStorage = game:GetService("ReplicatedStorage")
local upgradeEvent = ReplicatedStorage:WaitForChild("AscensionEvent")
local clearCornEvent = ReplicatedStorage:WaitForChild("ClearLocalCornEvent")
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))

local ASCENSION_GAMEPASS_ID = 1740630375

local currenciesToReset = { "Corn", "Rebirths", "Clicks", "Energy" }
local upgradesToReset = {
	"SpawnRateUpg1", "CornValueUpg1", "CornAmountUpg1", "CornValueUpg2",
	"CollectRadiusUpg1", "SpawnRateUpg2",
	"UpgTree1", "UpgTree2", "UpgTree3", "UpgTree4",
	"UpgTree5", "UpgTree6", "UpgTree7", "UpgTree8",
	"UpgTree9", "UpgTree10", "UpgTree11", "UpgTree12",
	"UpgTree13", "CornValueUpg4", "RebirthValueUpg2", "Autoclickers",
	"Generators", "CornEnergy", "RebirthEnergy", "UpgTree14",
	"UpgTree15", "UpgTree16", "UpgTree17", "UpgTree18",
	"UpgTree19", "UpgTree20", "EnergyEnergy",
}

upgradeEvent.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	local events = player:FindFirstChild("Events")
	local ascensions = currencies and currencies:FindFirstChild("Ascensions")
	local timesascended = events and events:FindFirstChild("TimesAscended")
	if not currencies or not upgrades or not ascensions then return end

	local upgtree2_7 = upgrades:WaitForChild("UpgTree2_7")

	local currentLevel = ascensions.Value
	local MAX_LEVEL = 999999999
	if currentLevel >= MAX_LEVEL then return end

	local rebirths = currencies:FindFirstChild("Rebirths")
	if rebirths and rebirths.Value >= 1_000_000_000_000_000_000 then
		clearCornEvent:FireClient(player)

		for _, name in ipairs(currenciesToReset) do
			local currency = currencies:FindFirstChild(name)
			if currency then
				currency.Value = 0
			end
		end

		for _, name in ipairs(upgradesToReset) do
			local upgrade = upgrades:FindFirstChild(name)
			if upgrade then
				upgrade.Value = 0
			end
		end

		if upgtree2_7.Value >= 1 then
			local autoclickers = upgrades:WaitForChild("Autoclickers")
			local generators = upgrades:WaitForChild("Generators")
			autoclickers.Value = 1
			generators.Value = 1
		end

		local boosters = upgrades:WaitForChild("Boosters")
		local kernel2 = upgrades:WaitForChild("Kernel2")
		local mult = (boosters.Value >= 1) and boosters.Value + 1 or 1
		local mult2 = 1 + (0.05 * kernel2.Value)

		local mult3 = GamePassCheck.playerOwnsGamePass(player, ASCENSION_GAMEPASS_ID) and 2 or 1

		ascensions.Value += math.floor(1 * mult * mult2 * mult3)
		if timesascended then
			timesascended.Value += 1
		end
	end
end)
