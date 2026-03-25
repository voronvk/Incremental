local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rebirthEvent = ReplicatedStorage:WaitForChild("RebirthEvent")
local clearCornEvent = ReplicatedStorage:WaitForChild("ClearLocalCornEvent")
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))

local BASE_COST = 1000

local REBIRTHS_GAMEPASS_ID = 1740115835

rebirthEvent.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	local events = player:FindFirstChild("Events")

	if not currencies or not upgrades then return end

	local corn = currencies:FindFirstChild("Corn")
	local rebirths = currencies:FindFirstChild("Rebirths")
	local playtime = events:FindFirstChild("Playtime")
	local spawnRate = upgrades:FindFirstChild("SpawnRateUpg1")
	local cornValue = upgrades:FindFirstChild("CornValueUpg1")
	local cornAmount = upgrades:FindFirstChild("CornAmountUpg1")
	local timesRebirthed = events:FindFirstChild("TimesRebirthed")

	local rebirthValue = upgrades:FindFirstChild("RebirthValueUpg1")
	local upgtree1 = upgrades:FindFirstChild("UpgTree1")
	local upgtree3 = upgrades:FindFirstChild("UpgTree3")
	local upgtree5 = upgrades:FindFirstChild("UpgTree5")
	local upgtree6 = upgrades:FindFirstChild("UpgTree6")
	local clickbooster = upgrades:FindFirstChild("RebirthValueUpg2")
	local rebirthenergy = upgrades:FindFirstChild("RebirthEnergy")
	local tier = upgrades:FindFirstChild("Tier")
	local upgtree2_3 = upgrades:FindFirstChild("UpgTree2_3")
	local upgtree2_10 = upgrades:FindFirstChild("UpgTree2_10")

	local groupMulti = 1

	if player:IsInGroupAsync(117519888) then
		groupMulti = 1.2
	end

	if not corn or not spawnRate or not cornValue or not cornAmount then return end

	local cost = math.floor((corn.Value) / BASE_COST)
	local mult1 = 2 ^ rebirthValue.Value
	local mult2 = (upgtree1.Value == 1) and 2 or 1
	local mult3 = (upgtree3.Value == 1) and 1.5 or 1
	local mult4 = (upgtree5.Value == 1) and math.max(math.log(math.max(playtime.Value + 100, 1), 100), 1) or 1
	local mult5 = (upgtree6.Value == 1) and 2 or 1
	local mult6 = 2 ^ clickbooster.Value
	local mult7 = ((rebirthenergy.Value + 1) ^ (1/5))
	local mult8 = (tier.Value >= 1) and 2 or 1

	local mult9 = 1

	if GamePassCheck.playerOwnsGamePass(player, REBIRTHS_GAMEPASS_ID) then
		mult9 = 2
	end

	local mult10 = (upgtree2_3.Value == 1) and 0.1 or 1
	local mult11 = (upgtree2_10.Value == 1) and 0.25 or 1
	local rebirthBoostMult = 1
	local rebirthEnd = events and events:FindFirstChild("RebirthBoostEndTime")
	if rebirthEnd and rebirthEnd.Value > os.time() then
		rebirthBoostMult = 2
	end

	if corn.Value >= cost then
		local gain = (math.floor(corn.Value / BASE_COST) * mult1 * mult2 * mult3 * mult4 * mult5 * mult6 * mult7 * mult8 * mult9 * mult10 * mult11 * groupMulti * rebirthBoostMult)

		rebirths.Value += math.floor(gain + 0.5)
		timesRebirthed.Value = timesRebirthed.Value + 1
		corn.Value = 0
		spawnRate.Value = 0
		cornValue.Value = 0
		cornAmount.Value = 0

		clearCornEvent:FireClient(player)
	end
end)

task.spawn(function()
	while true do
		for _, player in pairs(game.Players:GetPlayers()) do
			local currencies = player:FindFirstChild("Currencies")
			local upgrades = player:FindFirstChild("Upgrades")
			local events = player:FindFirstChild("Events")

			if currencies and upgrades and events then
				local corn = currencies:FindFirstChild("Corn")
				local rebirths = currencies:FindFirstChild("Rebirths")
				local playtime = events:FindFirstChild("Playtime")
				local spawnRate = upgrades:FindFirstChild("SpawnRateUpg1")
				local cornValue = upgrades:FindFirstChild("CornValueUpg1")
				local cornAmount = upgrades:FindFirstChild("CornAmountUpg1")
				local timesRebirthed = events:FindFirstChild("TimesRebirthed")

				local rebirthValue = upgrades:FindFirstChild("RebirthValueUpg1")
				local upgtree1 = upgrades:FindFirstChild("UpgTree1")
				local upgtree3 = upgrades:FindFirstChild("UpgTree3")
				local upgtree5 = upgrades:FindFirstChild("UpgTree5")
				local upgtree6 = upgrades:FindFirstChild("UpgTree6")
				local clickbooster = upgrades:FindFirstChild("RebirthValueUpg2")
				local rebirthenergy = upgrades:FindFirstChild("RebirthEnergy")
				local tier = upgrades:FindFirstChild("Tier")
				local upgtree2_3 = upgrades:FindFirstChild("UpgTree2_3")
				local upgtree2_9 = upgrades:FindFirstChild("UpgTree2_9")
				local upgtree2_10 = upgrades:FindFirstChild("UpgTree2_10")

				if corn and rebirths and playtime and spawnRate and cornValue and cornAmount and timesRebirthed and tier then
					if tier.Value >= 4 then

						local cost = BASE_COST
						local rebirthBoostMult = 1
						local rebirthEnd = events and events:FindFirstChild("RebirthBoostEndTime")
						if rebirthEnd and rebirthEnd.Value > os.time() then
							rebirthBoostMult = 2
						end

						local mult1 = 2 ^ rebirthValue.Value
						local mult2 = (upgtree1.Value == 1) and 2 or 1
						local mult3 = (upgtree3.Value == 1) and 1.5 or 1
						local mult4 = (upgtree5.Value == 1) and math.max(math.log(math.max(playtime.Value + 100, 1), 100), 1) or 1
						local mult5 = (upgtree6.Value == 1) and 2 or 1
						local mult6 = 2 ^ clickbooster.Value
						local mult7 = ((rebirthenergy.Value + 1) ^ (1/5))
						local mult8 = (tier.Value >= 1) and 2 or 1

						local mult9 = 1

						if GamePassCheck.playerOwnsGamePass(player, REBIRTHS_GAMEPASS_ID) then
							mult9 = 2
						end

						local autogain = (upgtree2_9 and upgtree2_9.Value == 1) and 1 or 10

						local mult10 = (upgtree2_3.Value == 1) and 0.1 or 1
						local mult11 = (upgtree2_10.Value == 1) and 0.25 or 1

						if corn.Value >= cost then

							local gain = (corn.Value / BASE_COST)

							gain *= mult1
							gain *= mult2
							gain *= mult3
							gain *= mult4
							gain *= mult5
							gain *= mult6
							gain *= mult7
							gain *= mult8
							gain *= mult9
							gain *= mult10
							gain *= mult11
							gain *= rebirthBoostMult

							gain /= autogain

							gain = math.floor(gain + 0.5)

							rebirths.Value += gain

						end

					end
				end
			end
		end
		task.wait(1)
	end
end)
