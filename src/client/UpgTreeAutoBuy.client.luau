local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local AutobuyRows = require(ReplicatedStorage.Shared:WaitForChild("UpgTreeAutobuyConfig")).rows

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local upg13 = upgrades:WaitForChild("UpgTree13")

local treeRemotes = {}
for i = 1, 20 do
	treeRemotes[i] = ReplicatedStorage:WaitForChild("UpgTree" .. i)
end

local upgradeGates: { [string]: IntValue } = {}
for _, row in ipairs(AutobuyRows) do
	upgradeGates[row.source] = upgrades:WaitForChild(row.source)
end

task.spawn(function()
	while true do
		for _, row in ipairs(AutobuyRows) do
			local gate = upgradeGates[row.source]
			if gate and gate.Value >= 1 then
				if not row.needsUpgTree13 or upg13.Value >= 1 then
					for _, treeIndex in ipairs(row.trees) do
						treeRemotes[treeIndex]:FireServer("autobuy", row.source)
					end
				end
			end
		end
		task.wait(0.5)
	end
end)
