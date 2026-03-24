local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage:WaitForChild("CollectSeedEvent")

local Workspace = game:GetService("Workspace")
local remoteMisuseTracker = {}
local MAX_ATTEMPTS = 20
local Zone = Workspace:FindFirstChild("Part14")

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

local FloodCheck = require(game.ServerScriptService.Server:WaitForChild("RemoteFloodCheck") :: ModuleScript)
event.OnServerEvent:Connect(function(player, seedType)
	if FloodCheck:Check(player, event, 5) then
		local currencies = player:FindFirstChild("Currencies")
		local events = player:FindFirstChild("Events")
		local leaderstats = player:FindFirstChild("leaderstats")

		if not (currencies and events and leaderstats) then return end

		local collects = events:FindFirstChild("Collects")
		local level = events:FindFirstChild("Level")
		local levelraw = events:FindFirstChild("LevelRaw")
		local levelleader = leaderstats:FindFirstChild("Level")

		local currencyNameMap = {
			BasicSeed = "BasicSeeds",
			SilverSeed = "SilverSeeds",
			GoldenSeed = "GoldenSeeds",
			DiamondSeed = "DiamondSeeds",
			RubySeed = "RubySeeds",
		}

		local currencyName = currencyNameMap[seedType]
		if not currencyName then return end

		local seedStat = currencies:FindFirstChild(currencyName)
		if not seedStat then return end

		local character = player.Character
		if character then
			local root = character:FindFirstChild("HumanoidRootPart")
			if root and Zone then
				if not isInsideZone(root, Zone) then
					local count = remoteMisuseTracker[player] or 0
					count += 1
					remoteMisuseTracker[player] = count
				end
			end
		end

		seedStat.Value += 1
		local seedcollects = events:WaitForChild("SeedCollects")
		local seedcollectsactual = events:WaitForChild("SeedCollectsActual")
		seedcollects.Value += 1
		seedcollectsactual.Value += 1

		levelraw.Value = math.log(((collects.Value + seedcollectsactual.Value) / 50) + 1) / math.log(1.2)
		level.Value = math.floor(levelraw.Value)
		levelleader.Value = level.Value
	end
end)
