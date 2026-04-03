local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpgradeConfig = require(ReplicatedStorage:WaitForChild("UpgradeConfig"))
local AutobuyBySource = require(ReplicatedStorage.Shared:WaitForChild("UpgTreeAutobuyConfig")).bySource

local function canAutobuyThisTree(upgrades: Instance, treeIndex: number, sourceUpgradeName: string): boolean
	local row = AutobuyBySource[sourceUpgradeName]
	if not row or not table.find(row.trees, treeIndex) then
		return false
	end
	local gate = upgrades:FindFirstChild(sourceUpgradeName)
	if not gate or gate.Value < 1 then
		return false
	end
	if row.needsUpgTree13 then
		local u13 = upgrades:FindFirstChild("UpgTree13")
		if not u13 or u13.Value < 1 then
			return false
		end
	end
	return true
end

for i = 1, 20 do
	local eventName = "UpgTree" .. i
	local event = ReplicatedStorage:WaitForChild(eventName)

	event.OnServerEvent:Connect(function(player, mode, sourceUpgradeName)
		local upgrades = player:FindFirstChild("Upgrades")
		local currencies = player:FindFirstChild("Currencies")
		if not upgrades or not currencies then return end

		local upgValue = upgrades:FindFirstChild(eventName)
		if not upgValue then return end

		local config = UpgradeConfig[i]
		if not config then return end

		local currencyValue = currencies:FindFirstChild(config.Currency)
		if not currencyValue then return end

		if mode == "autobuy" and type(sourceUpgradeName) == "string" then
			if not canAutobuyThisTree(upgrades, i, sourceUpgradeName) then
				return
			end
			if upgValue.Value == 0 and currencyValue.Value >= config.Cost then
				upgValue.Value += 1
			end
			return
		end

		if mode ~= nil then
			return
		end

		if upgValue.Value == 0 and currencyValue.Value >= config.Cost then
			currencyValue.Value -= config.Cost
			upgValue.Value += 1
		end
	end)
end
