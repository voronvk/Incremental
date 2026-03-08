local ReplicatedStorage = game:GetService("ReplicatedStorage")
local upgradeEvent = ReplicatedStorage:WaitForChild("Kernel4")
local upgradeEventMax = ReplicatedStorage:WaitForChild("Kernel4Max")
local Players = game:GetService("Players")

local MAX_LEVEL = 50
local cost = 1

upgradeEvent.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then return end

	local events = player:WaitForChild("Events")
	local level = events:WaitForChild("Level")
	local kernelupg1 = upgrades:WaitForChild("Kernel1")
	local kernelupg2 = upgrades:WaitForChild("Kernel2")
	local kernelupg3 = upgrades:WaitForChild("Kernel3")
	local kernelupg4 = upgrades:WaitForChild("Kernel4")
	local kernelupg5 = upgrades:WaitForChild("Kernel5")
	local upgtree2_17 = upgrades:WaitForChild("UpgTree2_17")
	local upgtree2_18 = upgrades:WaitForChild("UpgTree2_18")
	local mult = (upgtree2_17.Value >= 1) and 1.25 or 1
	local mult2 = (upgtree2_18.Value >= 1) and 1.25 or 1
	local unspentkernels = math.floor(level.Value * mult * mult2 - kernelupg1.Value - kernelupg2.Value - kernelupg3.Value - kernelupg4.Value - kernelupg5.Value)

	if unspentkernels >= cost and kernelupg4.Value < MAX_LEVEL then
		kernelupg4.Value += cost
	end
end)

upgradeEventMax.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then return end

	local events = player:WaitForChild("Events")
	local level = events:WaitForChild("Level")
	local kernelupg1 = upgrades:WaitForChild("Kernel1")
	local kernelupg2 = upgrades:WaitForChild("Kernel2")
	local kernelupg3 = upgrades:WaitForChild("Kernel3")
	local kernelupg4 = upgrades:WaitForChild("Kernel4")
	local kernelupg5 = upgrades:WaitForChild("Kernel5")
	local upgtree2_17 = upgrades:WaitForChild("UpgTree2_17")
	local upgtree2_18 = upgrades:WaitForChild("UpgTree2_18")
	local mult = (upgtree2_17.Value >= 1) and 1.25 or 1
	local mult2 = (upgtree2_18.Value >= 1) and 1.25 or 1
	local unspentkernels = math.floor(level.Value * mult * mult2 - kernelupg1.Value - kernelupg2.Value - kernelupg3.Value - kernelupg4.Value - kernelupg5.Value)

	while kernelupg4.Value < MAX_LEVEL do
		local upgtree2_17 = upgrades:WaitForChild("UpgTree2_17")
		local upgtree2_18 = upgrades:WaitForChild("UpgTree2_18")
		local mult = (upgtree2_17.Value >= 1) and 1.25 or 1
		local mult2 = (upgtree2_18.Value >= 1) and 1.25 or 1
		local unspentkernels = math.floor(level.Value * mult * mult2 - kernelupg1.Value - kernelupg2.Value - kernelupg3.Value - kernelupg4.Value - kernelupg5.Value)

		if unspentkernels >= cost then
			kernelupg4.Value += cost
		else
			break
		end
	end
end)
