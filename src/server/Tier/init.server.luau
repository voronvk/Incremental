local ReplicatedStorage = game:GetService("ReplicatedStorage")
local upgradeEvent = ReplicatedStorage:WaitForChild("TierUp")
local clearCornEvent = ReplicatedStorage:WaitForChild("ClearLocalCornEvent")

local BadgeService = game:GetService("BadgeService")
local TIERUP_BADGE_ID = 3562049986397498

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
	local tier = upgrades and upgrades:FindFirstChild("Tier")
	if not currencies or not upgrades or not tier then return end

	local currentLevel = tier.Value
	local MAX_LEVEL = 6
	if currentLevel >= MAX_LEVEL then return end

	local corn = currencies:FindFirstChild("Corn")
	if corn and corn.Value >= 100000000000000 then
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

		tier.Value += 1

		local success, hasBadge = pcall(function()
			return BadgeService:UserHasBadgeAsync(player.UserId, TIERUP_BADGE_ID)
		end)

		if success and not hasBadge then
			pcall(function()
				BadgeService:AwardBadge(player.UserId, TIERUP_BADGE_ID)
			end)
		end
	end
end)
