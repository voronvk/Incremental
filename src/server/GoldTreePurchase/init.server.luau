local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local FloodCheck = require(ServerScriptService.Server:WaitForChild("RemoteFloodCheck") :: ModuleScript)
local GoldTreeConfig = require(ReplicatedStorage.Shared:WaitForChild("GoldTreeConfig"))

local request = ReplicatedStorage:WaitForChild("GoldTreePurchaseRequest")
local result = ReplicatedStorage:WaitForChild("GoldTreePurchaseResult")
local announce = ReplicatedStorage:WaitForChild("GamePassPurchaseAnnounce")

local function hasNode(upgrades, index)
	local name = GoldTreeConfig.upgradeName(index)
	local v = upgrades:FindFirstChild(name)
	return v and v.Value >= 1
end

local function prereqsSatisfied(upgrades, index)
	local reqs = GoldTreeConfig.PREREQS[index]
	if not reqs then
		return false
	end
	for _, reqIndex in reqs do
		if not hasNode(upgrades, reqIndex) then
			return false
		end
	end
	return true
end

request.OnServerEvent:Connect(function(player, rawIndex)
	if not FloodCheck:Check(player, request, 8) then
		return
	end

	local index = tonumber(rawIndex)
	if not index or index ~= math.floor(index) or index < 1 or index > 7 then
		return
	end

	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then
		return
	end

	local gold = currencies:FindFirstChild("Gold")
	local nodeDef = GoldTreeConfig.NODES[index]
	local upg = upgrades:FindFirstChild(GoldTreeConfig.upgradeName(index))
	if not gold or not nodeDef or not upg then
		return
	end

	if upg.Value >= 1 then
		return
	end

	if index > 1 and not hasNode(upgrades, 1) then
		return
	end

	if not prereqsSatisfied(upgrades, index) then
		return
	end

	local cost = nodeDef.cost
	if gold.Value < cost then
		result:FireClient(player, index, false, "nogold")
		return
	end

	gold.Value -= cost
	upg.Value = 1

	local displayName = GoldTreeConfig.displayNameForAnnounce(index)
	local msg = string.format("%s just unlocked %s!", player.Name, displayName)
	announce:FireAllClients(msg)

	result:FireClient(player, index, true)
end)
