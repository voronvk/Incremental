local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- true = Taps + mejoras del melon/tapping no cargan ni se guardan (solo para testear en sesión)
local SKIP_TAPPING_PERSIST = true

local cornDataStore = DataStoreService:GetDataStore("JoggersCoalyThoCobsonGotTheGemmyTho")
local SAVE_INTERVAL = 300
local SCALE = 1e6
local MAX_LOG = 308

local currencyStats = {
	"Corn", "Rebirths", "Gemeralds", "Gold", "Clicks", "Energy",
	"CornLogged", "RebirthsLogged", "Ascensions", "BasicSeeds",
	"SilverSeeds", "GoldenSeeds", "DiamondSeeds", "RubySeeds",
}
local upgradeStats = {
	"SpawnRateUpg1", "CornValueUpg1", "CornAmountUpg1", "CornValueUpg2",
	"CollectRadiusUpg1", "SpawnRateUpg2", "CornValueUpg3", "RebirthValueUpg1",
	"UpgTree1", "UpgTree2", "UpgTree3", "UpgTree4",
	"UpgTree5", "UpgTree6", "UpgTree7", "UpgTree8",
	"UpgTree9", "UpgTree10", "UpgTree11", "UpgTree12",
	"UpgTree13", "CornValueUpg4", "RebirthValueUpg2", "Autoclickers",
	"Generators", "CornEnergy", "RebirthEnergy", "UpgTree14",
	"UpgTree15", "UpgTree16", "UpgTree17", "UpgTree18",
	"UpgTree19", "UpgTree20", "EnergyEnergy", "Tier",
	"UpgTree2_1", "UpgTree2_2", "UpgTree2_3", "UpgTree2_4",
	"UpgTree2_5", "UpgTree2_6", "UpgTree2_7", "UpgTree2_8",
	"UpgTree2_9", "UpgTree2_10", "UpgTree2_11", "UpgTree2_12",
	"UpgTree2_13", "UpgTree2_14", "UpgTree2_15", "UpgTree2_16",
	"UpgTree2_17", "UpgTree2_18", "Boosters", "Kernel1",
	"Kernel2", "Kernel3", "Kernel4", "Kernel5",
	"UpgTree2_19", "UpgTree2_20", "UpgTree2_21", "UpgTree2_22",
	"UpgTree2_23", "UpgTree2_24", "UpgTree2_25", "UpgTree2_26",
	"UpgTree2_27", "UpgTree2_28", "UpgTree2_29",
	"GoldTreeP1", "GoldTreeP2", "GoldTreeP3", "GoldTreeP4", "GoldTreeP5", "GoldTreeP6", "GoldTreeP7",
}
local eventStats = {
	"TimesRebirthed", "Island1Bought", "Playtime", "Collects",
	"LevelRaw", "Level", "LastClaim", "Streak", "RobuxDonated",
	-- Boosts temporales (Developer Products)
	"MelonBoostEndTime", "RebirthBoostEndTime", "AscensionBoostEndTime", "SpeedBoostEndTime",
	"MelonBoostMultiplier", "RebirthBoostMultiplier", "AscensionBoostMultiplier", "SpeedBoostMultiplier",
	"TimesAscended", "SeedCollects", "SeedCollectsActual",
	-- Quest system (resetea cada 24h)
	"Quest1Type", "Quest1Target", "Quest1Progress",
	"Quest2Type", "Quest2Target", "Quest2Progress",
	"Quest3Type", "Quest3Target", "Quest3Progress",
	"QuestLastResetTime", "QuestPlaytimeAtReset", "QuestRebirthsAtReset", "QuestMelonsCollected",
	"QuestRewardClaimed",
	"ExclusiveOfferPurchased",
	"TappingXpBonus",
	"TappingDamageLevel",
	"TappingCritLevel",
	"DailyRewardNextDay",
	"DailyRewardLastClaimUnix",
	"MelonLevel",
	"AutoTapBasicUnlocked",
}

local settingsStats = {
	"MusicMuted", "SfxMuted", "PopUpsMuted", "PlayersHidden"
}

local leaderstatsStats = {
	"Level",
	"Taps",
}

local function createValues(parent, class, names)
	for _, name in ipairs(names) do
		local val = Instance.new(class)
		val.Name = name
		val.Value = 0
		val.Parent = parent
	end
end

local function loadData(player, data)
	for _, name in ipairs(currencyStats) do
		local c = player.Currencies:FindFirstChild(name)
		if c then c.Value = data[name] or 0 end
	end
	for _, name in ipairs(upgradeStats) do
		local u = player.Upgrades:FindFirstChild(name)
		if u then u.Value = data[name] or 0 end
	end
	for _, name in ipairs(eventStats) do
		local e = player.Events:FindFirstChild(name)
		if e then
			if
				SKIP_TAPPING_PERSIST
				and (
					name == "TappingXpBonus"
					or name == "TappingDamageLevel"
					or name == "TappingCritLevel"
				)
			then
				e.Value = 0
			else
				local v = data[name] or 0
				if name == "DailyRewardNextDay" then
					if v < 1 then
						v = 1
					elseif v > 8 then
						v = 8
					end
				end
				e.Value = v
			end
		end
	end
	for _, name in ipairs(settingsStats) do
		local s = player.Settings:FindFirstChild(name)
		if s then s.Value = data[name] or 0 end
	end
	for _, name in ipairs(leaderstatsStats) do
		local l = player.leaderstats:FindFirstChild(name)
		if l then
			if SKIP_TAPPING_PERSIST and name == "Taps" then
				l.Value = 0
			else
				l.Value = data[name] or 0
			end
		end
	end
end

local function getDataToSave(player)
	local data = {}
	for _, name in ipairs(currencyStats) do
		data[name] = player.Currencies:FindFirstChild(name) and player.Currencies[name].Value or 0
	end
	for _, name in ipairs(upgradeStats) do
		data[name] = player.Upgrades:FindFirstChild(name) and player.Upgrades[name].Value or 0
	end
	for _, name in ipairs(eventStats) do
		if
			SKIP_TAPPING_PERSIST
			and (
				name == "TappingXpBonus"
				or name == "TappingDamageLevel"
				or name == "TappingCritLevel"
			)
		then
			data[name] = 0
		else
			data[name] = player.Events:FindFirstChild(name) and player.Events[name].Value or 0
		end
	end
	for _, name in ipairs(settingsStats) do
		data[name] = player.Settings:FindFirstChild(name) and player.Settings[name].Value or 0
	end
	for _, name in ipairs(leaderstatsStats) do
		if SKIP_TAPPING_PERSIST and name == "Taps" then
			data[name] = 0
		else
			data[name] = player.leaderstats:FindFirstChild(name) and player.leaderstats[name].Value or 0
		end
	end
	return data
end

Players.PlayerAdded:Connect(function(player)
	local currencies = Instance.new("Folder")
	currencies.Name = "Currencies"
	currencies.Parent = player

	local upgrades = Instance.new("Folder")
	upgrades.Name = "Upgrades"
	upgrades.Parent = player

	local events = Instance.new("Folder")
	events.Name = "Events"
	events.Parent = player

	local settingsFolder = Instance.new("Folder")
	settingsFolder.Name = "Settings"
	settingsFolder.Parent = player

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	createValues(currencies, "NumberValue", currencyStats)
	createValues(upgrades, "NumberValue", upgradeStats)
	createValues(events, "NumberValue", eventStats)
	createValues(settingsFolder, "NumberValue", settingsStats)
	createValues(leaderstats, "NumberValue", leaderstatsStats)

	local success, data = pcall(function()
		return cornDataStore:GetAsync(player.UserId)
	end)

	if success and data then
		loadData(player, data)
	else
		warn("Could not load data for", player.Name)
	end

	local drNext = player.Events:FindFirstChild("DailyRewardNextDay")
	if drNext and drNext:IsA("NumberValue") then
		if drNext.Value < 1 then
			drNext.Value = 1
		elseif drNext.Value > 8 then
			drNext.Value = 8
		end
	end

	local excl = player.Events:FindFirstChild("ExclusiveOfferPurchased")
	if excl and excl:IsA("NumberValue") then
		player:SetAttribute("ExclusiveOfferPurchased", excl.Value >= 1)
	end

	task.spawn(function()
		while player.Parent do
			local cornVal = player.Currencies:FindFirstChild("Corn") and player.Currencies.Corn.Value or 0
			local rebirthVal = player.Currencies:FindFirstChild("Rebirths") and player.Currencies.Rebirths.Value or 0

			local cornLogged = (cornVal > 0) and math.log10(cornVal) or 0
			local rebirthLogged = (rebirthVal > 0) and math.log10(rebirthVal) or 0

			cornLogged = math.clamp(cornLogged, 0, MAX_LOG)
			rebirthLogged = math.clamp(rebirthLogged, 0, MAX_LOG)

			local scaledCornLogged = math.floor(cornLogged * SCALE)
			local scaledRebirthLogged = math.floor(rebirthLogged * SCALE)

			if player.Currencies:FindFirstChild("CornLogged") then
				player.Currencies.CornLogged.Value = scaledCornLogged
			end
			if player.Currencies:FindFirstChild("RebirthsLogged") then
				player.Currencies.RebirthsLogged.Value = scaledRebirthLogged
			end

			task.wait(SAVE_INTERVAL)

			if not player.Parent then return end

			local saveSuccess, err = pcall(function()
				cornDataStore:UpdateAsync(player.UserId, function(oldData)
					return getDataToSave(player)
				end)
			end)
			if not saveSuccess then
				warn("Autosave failed for", player.Name, err)
			end
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local success, err = pcall(function()
		cornDataStore:UpdateAsync(player.UserId, function(oldData)
			return getDataToSave(player)
		end)
	end)
	if not success then
		warn("Failed to save data for", player.Name, err)
	end
end)
