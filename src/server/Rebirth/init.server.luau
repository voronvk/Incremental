local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local rebirthEvent = ReplicatedStorage:WaitForChild("RebirthEvent")
local plotRebirthEvent = ReplicatedStorage:WaitForChild("PlotRebirthEvent")
local clearCornEvent = ReplicatedStorage:WaitForChild("ClearLocalCornEvent")
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
local RebirthRules = require(ReplicatedStorage.Shared:WaitForChild("RebirthRules"))

local BASE_COST = RebirthRules.UpgradesRebirthBoard.CornChunkSize
-- Bucle pasivo: mismo criterio de melón que la parcela (no el tablero Upgrades sin melón).
local AUTO_GAIN_MIN_MELON = RebirthRules.PlotRebirthBoard.MinMelonLevel

local REBIRTHS_GAMEPASS_ID = 1740115835

local function rebirthDebug(player, msg)
	if RunService:IsStudio() or player:GetAttribute("DebugRebirthGUI") == true then
		print("[Rebirth srv]", player.Name, msg)
	end
end

local function processManualRebirth(player, rules)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	local events = player:FindFirstChild("Events")

	if not currencies or not upgrades or not events then
		rebirthDebug(player, "reject: faltan Currencies/Upgrades/Events")
		return
	end

	local corn = currencies:FindFirstChild("Corn")
	local rebirths = currencies:FindFirstChild("Rebirths")
	local playtime = events:FindFirstChild("Playtime")
	local timesRebirthed = events:FindFirstChild("TimesRebirthed")
	local spawnRate = upgrades:FindFirstChild("SpawnRateUpg1")
	local cornValue = upgrades:FindFirstChild("CornValueUpg1")
	local cornAmount = upgrades:FindFirstChild("CornAmountUpg1")
	local melonLevel = events:FindFirstChild("MelonLevel")

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
	local okGroup, inGroup = pcall(function()
		return player:IsInGroupAsync(117519888)
	end)
	if okGroup and inGroup then
		groupMulti = 1.2
	end

	if not corn or not rebirths or not playtime or not timesRebirthed then
		rebirthDebug(player, "reject: faltan Corn/Rebirths/Playtime/TimesRebirthed")
		return
	end
	if not spawnRate or not cornValue or not cornAmount then
		rebirthDebug(player, "reject: faltan SpawnRateUpg1/CornValueUpg1/CornAmountUpg1")
		return
	end
	if rules.MinMelonLevel > 0 then
		if not melonLevel or melonLevel.Value < rules.MinMelonLevel then
			rebirthDebug(
				player,
				"reject: melon "
					.. (melonLevel and melonLevel.Value or "nil")
					.. " < "
					.. rules.MinMelonLevel
			)
			return
		end
	end
	if not rebirthValue or not upgtree1 or not upgtree3 or not upgtree5 or not upgtree6 then
		rebirthDebug(player, "reject: falta algun UpgTree/RebirthValue para formula")
		return
	end
	if not clickbooster or not rebirthenergy or not tier or not upgtree2_3 then
		rebirthDebug(player, "reject: falta RebirthValueUpg2/RebirthEnergy/Tier/UpgTree2_3")
		return
	end

	local chunkSize = rules.CornChunkSize
	if chunkSize < 1 then
		rebirthDebug(player, "reject: CornChunkSize invalido")
		return
	end
	local chunks = math.floor(corn.Value / chunkSize)
	if chunks < 1 or corn.Value < rules.MinCorn then
		rebirthDebug(
			player,
			"reject: maiz servidor "
				.. corn.Value
				.. " (min "
				.. rules.MinCorn
				.. ", chunks "
				.. chunks
				.. ")"
		)
		return
	end

	local mult1 = 2 ^ rebirthValue.Value
	local mult2 = (upgtree1.Value == 1) and 2 or 1
	local mult3 = (upgtree3.Value == 1) and 1.5 or 1
	local mult4 = (upgtree5.Value == 1) and math.max(math.log(math.max(playtime.Value + 100, 1), 100), 1) or 1
	local mult5 = (upgtree6.Value == 1) and 2 or 1
	local mult6 = 2 ^ clickbooster.Value
	local mult7 = ((rebirthenergy.Value + 1) ^ (1 / 5))
	local mult8 = (tier.Value >= 1) and 2 or 1

	local mult9 = 1
	if GamePassCheck.playerOwnsGamePass(player, REBIRTHS_GAMEPASS_ID) then
		mult9 = 2
	end

	local mult10 = (upgtree2_3.Value == 1) and 0.1 or 1
	local mult11 = (upgtree2_10 and upgtree2_10.Value == 1) and 0.25 or 1
	local rebirthBoostMult = 1
	local rebirthEnd = events:FindFirstChild("RebirthBoostEndTime")
	local rebirthBoostMultiplier = events:FindFirstChild("RebirthBoostMultiplier")
	if rebirthEnd and rebirthBoostMultiplier and rebirthEnd.Value > os.time() then
		rebirthBoostMult = math.max(1, rebirthBoostMultiplier.Value)
		local allEnd = events:FindFirstChild("LuckAllBoostEndTime")
		local allAdd = events:FindFirstChild("LuckAllBoostAdd")
		if allEnd and allAdd and allEnd:IsA("NumberValue") and allAdd:IsA("NumberValue") and allEnd.Value > os.time() then
			rebirthBoostMult += math.max(0, allAdd.Value)
		end
	end

	local gain = chunks * mult1 * mult2 * mult3 * mult4 * mult5 * mult6 * mult7 * mult8 * mult9 * mult10 * mult11 * groupMulti * rebirthBoostMult

	local goldTreeP3 = upgrades:FindFirstChild("GoldTreeP3")
	if goldTreeP3 and goldTreeP3.Value >= 1 then
		gain *= 2
	end

	rebirths.Value += math.floor(gain + 0.5)
	timesRebirthed.Value = timesRebirthed.Value + 1
	corn.Value = 0
	spawnRate.Value = 0
	cornValue.Value = 0
	cornAmount.Value = 0

	clearCornEvent:FireClient(player)
	rebirthDebug(player, "OK rebirth manual: +" .. math.floor(gain + 0.5) .. " rebirths, maiz a 0")
end

rebirthEvent.OnServerEvent:Connect(function(player)
	rebirthDebug(player, "OnServerEvent UpgradesRebirthBoard")
	processManualRebirth(player, RebirthRules.UpgradesRebirthBoard)
end)

plotRebirthEvent.OnServerEvent:Connect(function(player)
	processManualRebirth(player, RebirthRules.PlotRebirthBoard)
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
				local melonLevel = events:FindFirstChild("MelonLevel")

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

				if corn and rebirths and playtime and spawnRate and cornValue and cornAmount and timesRebirthed and tier and melonLevel and rebirthValue then
					if tier.Value >= 4 and melonLevel.Value >= AUTO_GAIN_MIN_MELON then

						local cost = BASE_COST
						local rebirthBoostMult = 1
						local rebirthEnd = events:FindFirstChild("RebirthBoostEndTime")
						local rebirthBoostMultiplier = events:FindFirstChild("RebirthBoostMultiplier")
						if rebirthEnd and rebirthBoostMultiplier and rebirthEnd.Value > os.time() then
							rebirthBoostMult = math.max(1, rebirthBoostMultiplier.Value)
							local allEnd = events:FindFirstChild("LuckAllBoostEndTime")
							local allAdd = events:FindFirstChild("LuckAllBoostAdd")
							if allEnd and allAdd and allEnd:IsA("NumberValue") and allAdd:IsA("NumberValue") and allEnd.Value > os.time() then
								rebirthBoostMult += math.max(0, allAdd.Value)
							end
						end

						local mult1 = 2 ^ rebirthValue.Value
						local mult2 = (upgtree1.Value == 1) and 2 or 1
						local mult3 = (upgtree3.Value == 1) and 1.5 or 1
						local mult4 = (upgtree5.Value == 1) and math.max(math.log(math.max(playtime.Value + 100, 1), 100), 1) or 1
						local mult5 = (upgtree6.Value == 1) and 2 or 1
						local mult6 = 2 ^ clickbooster.Value
						local mult7 = ((rebirthenergy.Value + 1) ^ (1 / 5))
						local mult8 = (tier.Value >= 1) and 2 or 1

						local mult9 = 1

						if GamePassCheck.playerOwnsGamePass(player, REBIRTHS_GAMEPASS_ID) then
							mult9 = 2
						end

						local autogain = (upgtree2_9 and upgtree2_9.Value == 1) and 1 or 10

						local mult10 = (upgtree2_3 and upgtree2_3.Value == 1) and 0.1 or 1
						local mult11 = (upgtree2_10 and upgtree2_10.Value == 1) and 0.25 or 1

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

							local goldTreeP3 = upgrades:FindFirstChild("GoldTreeP3")
							if goldTreeP3 and goldTreeP3.Value >= 1 then
								gain *= 2
							end

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
