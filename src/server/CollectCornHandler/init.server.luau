local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BadgeService = game:GetService("BadgeService")
local event = ReplicatedStorage:WaitForChild("CollectCornEvent")
local autoevent = ReplicatedStorage:WaitForChild("CollectCornEventAuto")

local QuestSystem = require(script.Parent:WaitForChild("QuestSystem"))

local Workspace = game:GetService("Workspace")
local remoteMisuseTracker = {}
local MAX_ATTEMPTS = 10
local Zone = Workspace:FindFirstChild("Part88")

local function isInsideZone(part, zone)
	if not part or not zone then return false end

	local zoneCF = zone.CFrame
	local zoneSize = zone.Size
	local relative = zoneCF:PointToObjectSpace(part.Position)

	return
		math.abs(relative.X) <= zoneSize.X / 2 and
		math.abs(relative.Y) <= zoneSize.Y / 2 and
		math.abs(relative.Z) <= zoneSize.Z / 2
end

local GamePassConfig = require(game.ReplicatedStorage.Shared:WaitForChild("GamePassConfig"))
local CORN_GAMEPASS_ID = GamePassConfig.GOLD_CORN_GAMEPASS_ID
local GamePassCheck = require(game.ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
local FloodCheck = require(game.ServerScriptService.Server:WaitForChild("RemoteFloodCheck") :: ModuleScript)

event.OnServerEvent:Connect(function(player, cornType)
	if FloodCheck:Check(player, event, 200) then
		local currencies = player:FindFirstChild("Currencies")
		local upgrades = player:FindFirstChild("Upgrades")
		local events = player:FindFirstChild("Events")
		local leaderstats = player:FindFirstChild("leaderstats")

		if not (currencies and upgrades) then return end

		local cornStat = currencies:FindFirstChild("Corn")
		local rebirths = currencies:FindFirstChild("Rebirths")
		local clicks = currencies:FindFirstChild("Clicks")
		local playtime = events and events:FindFirstChild("Playtime")
		local collects = events:FindFirstChild("Collects")
		local level = events:FindFirstChild("Level")
		local levelraw = events:FindFirstChild("LevelRaw")
		local cornValueUpg1 = upgrades:FindFirstChild("CornValueUpg1")
		local cornValueUpg2 = upgrades:FindFirstChild("CornValueUpg2")
		local cornValueUpg3 = upgrades:FindFirstChild("CornValueUpg3")
		local upgtree1 = upgrades:FindFirstChild("UpgTree1")
		local upgtree2 = upgrades:FindFirstChild("UpgTree2")
		local upgtree3 = upgrades:FindFirstChild("UpgTree3")
		local upgtree5 = upgrades:FindFirstChild("UpgTree5")
		local clickbooster = upgrades:FindFirstChild("CornValueUpg4")
		local upgtree7 = upgrades:FindFirstChild("UpgTree7")
		local cornenergy = upgrades:FindFirstChild("CornEnergy")
		local tier = upgrades:FindFirstChild("Tier")
		local levelleader = leaderstats and leaderstats:FindFirstChild("Level")
		local upgtree2_3 = upgrades:WaitForChild("UpgTree2_3")
		local kernel1 = upgrades:WaitForChild("Kernel1")
		local upgtree2_10 = upgrades:FindFirstChild("UpgTree2_10")
		local upgtree2_14 = upgrades:WaitForChild("UpgTree2_14")
		local silvermult = (upgtree2_14.Value == 1) and 2 or 1
		local goldenmult = (upgtree2_14.Value == 1) and 5 or 1

		local groupMulti = 1
		local successGroup, inGroup = pcall(function()
			return player:IsInGroup(117519888)
		end)
		if successGroup and inGroup then
			groupMulti = 1.2
		end

		if not (cornStat and rebirths and cornValueUpg1 and cornValueUpg2 and cornValueUpg3 and upgtree1 and upgtree2) then return end

		local baseValue = 1
		if cornType == "SilverCorn" then
			baseValue = 10 * silvermult
		elseif cornType == "GoldenCorn" then
			baseValue = 50 * goldenmult
		elseif cornType == "DiamondCorn" then
			baseValue = 500
		elseif cornType == "RubyCorn" then
			baseValue = 2500
		end

		local mult1 = 1 + cornValueUpg1.Value
		local mult2 = 2 ^ cornValueUpg2.Value
		local mult3 = 2 ^ cornValueUpg3.Value
		local mult4 = (upgtree1.Value == 1) and 3 or 1
		local mult5 = (upgtree2.Value == 1) and math.max(math.log(math.max(rebirths.Value + 100, 1), 100), 1) or 1
		local mult6 = (upgtree3.Value == 1) and 1.5 or 1
		local mult7 = (upgtree5.Value == 1) and playtime and math.max(math.log(math.max(playtime.Value + 100, 1), 100), 1) or 1
		local mult8 = 2 ^ clickbooster.Value
		local mult9 = (upgtree7.Value == 1) and clicks and math.max(math.log(math.max(clicks.Value + 100, 1), 100), 1) or 1
		local mult10 = ((cornenergy.Value + 1) ^ (1/5))
		local mult11 = (tier.Value >= 1) and 2 or 1

		local mult12 = GamePassCheck.playerOwnsGamePass(player, CORN_GAMEPASS_ID) and 2 or 1

		local mult13 = (upgtree2_3.Value >= 1) and 5 or 1
		local mult14 = 1.15 ^ kernel1.Value
		local mult15 = (upgtree2_10 and upgtree2_10.Value == 1) and 5 or 1

		local totalValue = math.floor(baseValue * mult1 * mult2 * mult3 * mult4 * mult5 * mult6 * mult7 * mult8 * mult9 * mult10 * mult11 * mult12 * mult13 * mult14 * mult15 * groupMulti)

		local character = player.Character
		if character then
			local root = character:FindFirstChild("HumanoidRootPart")
			if root and Zone then
				local count = remoteMisuseTracker[player] or 0
				if not isInsideZone(root, Zone) then
					count += 1
					remoteMisuseTracker[player] = count
					if count >= MAX_ATTEMPTS then
						player:Kick("skibidi tolet...")
						return
					end
				else
					if count >= 1 then
						remoteMisuseTracker[player] = 0
					end
				end
			end
		end

		cornStat.Value += totalValue
		collects.Value += 1
		QuestSystem.onCollectCorn(player, totalValue)

		local seedcollects = events:WaitForChild("SeedCollects")
		local seedcollectsactual = events:WaitForChild("SeedCollectsActual")

		levelraw.Value = math.log(((collects.Value + seedcollectsactual.Value) / 50) + 1) / math.log(1.2)
		level.Value = math.floor(levelraw.Value)
		if levelleader then levelleader.Value = level.Value end
	end
end)

autoevent.OnServerEvent:Connect(function(player, cornType)
	if FloodCheck:Check(player, autoevent, 5) then
		local currencies = player:FindFirstChild("Currencies")
		local upgrades = player:FindFirstChild("Upgrades")
		local events = player:FindFirstChild("Events")
		local leaderstats = player:FindFirstChild("leaderstats")

		if not (currencies and upgrades) then return end

		local cornStat = currencies:FindFirstChild("Corn")
		local rebirths = currencies:FindFirstChild("Rebirths")
		local clicks = currencies:FindFirstChild("Clicks")
		local playtime = events and events:FindFirstChild("Playtime")
		local collects = events:FindFirstChild("Collects")
		local level = events:FindFirstChild("Level")
		local levelraw = events:FindFirstChild("LevelRaw")
		local cornValueUpg1 = upgrades:FindFirstChild("CornValueUpg1")
		local cornValueUpg2 = upgrades:FindFirstChild("CornValueUpg2")
		local cornValueUpg3 = upgrades:FindFirstChild("CornValueUpg3")
		local upgtree1 = upgrades:FindFirstChild("UpgTree1")
		local upgtree2 = upgrades:FindFirstChild("UpgTree2")
		local upgtree3 = upgrades:FindFirstChild("UpgTree3")
		local upgtree5 = upgrades:FindFirstChild("UpgTree5")
		local clickbooster = upgrades:FindFirstChild("CornValueUpg4")
		local upgtree7 = upgrades:FindFirstChild("UpgTree7")
		local cornenergy = upgrades:FindFirstChild("CornEnergy")
		local tier = upgrades:FindFirstChild("Tier")
		local levelleader = leaderstats and leaderstats:FindFirstChild("Level")
		local upgtree2_3 = upgrades:WaitForChild("UpgTree2_3")
		local kernel1 = upgrades:WaitForChild("Kernel1")
		local upgtree2_10 = upgrades:FindFirstChild("UpgTree2_10")
		local upgtree2_14 = upgrades:WaitForChild("UpgTree2_14")
		local silvermult = (upgtree2_14.Value == 1) and 2 or 1
		local goldenmult = (upgtree2_14.Value == 1) and 5 or 1

		if not (cornStat and rebirths and cornValueUpg1 and cornValueUpg2 and cornValueUpg3 and upgtree1 and upgtree2) then return end

		local baseValue = 1
		if cornType == "SilverCorn" then
			baseValue = 10 * silvermult
		elseif cornType == "GoldenCorn" then
			baseValue = 50 * goldenmult
		elseif cornType == "DiamondCorn" then
			baseValue = 500
		elseif cornType == "RubyCorn" then
			baseValue = 2500
		end

		local mult1 = 1 + cornValueUpg1.Value
		local mult2 = 2 ^ cornValueUpg2.Value
		local mult3 = 2 ^ cornValueUpg3.Value
		local mult4 = (upgtree1.Value == 1) and 3 or 1
		local mult5 = (upgtree2.Value == 1) and math.max(math.log(math.max(rebirths.Value + 100, 1), 100), 1) or 1
		local mult6 = (upgtree3.Value == 1) and 1.5 or 1
		local mult7 = (upgtree5.Value == 1) and playtime and math.max(math.log(math.max(playtime.Value + 100, 1), 100), 1) or 1
		local mult8 = 2 ^ clickbooster.Value
		local mult9 = (upgtree7.Value == 1) and clicks and math.max(math.log(math.max(clicks.Value + 100, 1), 100), 1) or 1
		local mult10 = ((cornenergy.Value + 1) ^ (1/5))
		local mult11 = (tier.Value >= 1) and 2 or 1

		local mult12 = GamePassCheck.playerOwnsGamePass(player, CORN_GAMEPASS_ID) and 2 or 1

		local mult13 = (upgtree2_3.Value >= 1) and 5 or 1
		local mult14 = 1.15 ^ kernel1.Value
		local mult15 = (upgtree2_10 and upgtree2_10.Value == 1) and 5 or 1

		local totalValue = math.floor(baseValue * mult1 * mult2 * mult3 * mult4 * mult5 * mult6 * mult7 * mult8 * mult9 * mult10 * mult11 * mult12 * mult13 * mult14 * mult15)

		cornStat.Value += totalValue
		collects.Value += 1
		QuestSystem.onCollectCorn(player, totalValue)

		local seedcollects = events:WaitForChild("SeedCollects")
		local seedcollectsactual = events:WaitForChild("SeedCollectsActual")

		levelraw.Value = math.log(((collects.Value + seedcollectsactual.Value) / 50) + 1) / math.log(1.2)
		level.Value = math.floor(levelraw.Value)
		if levelleader then levelleader.Value = level.Value end
	end
end)
