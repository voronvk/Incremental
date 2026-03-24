--[[
	KernelUpgrades - Maneja Kernel1 hasta Kernel5 en un solo script.
	Reemplaza KernelUpgrade1, KernelUpgrade2, KernelUpgrade3, KernelUpgrade4, KernelUpgrade5.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MAX_LEVEL = 50
local COST = 1

local function getUnspentKernels(upgrades, level)
	local k1 = upgrades:FindFirstChild("Kernel1")
	local k2 = upgrades:FindFirstChild("Kernel2")
	local k3 = upgrades:FindFirstChild("Kernel3")
	local k4 = upgrades:FindFirstChild("Kernel4")
	local k5 = upgrades:FindFirstChild("Kernel5")
	if not (k1 and k2 and k3 and k4 and k5) then return 0 end
	local u17 = upgrades:FindFirstChild("UpgTree2_17")
	local u18 = upgrades:FindFirstChild("UpgTree2_18")
	local mult = (u17 and u17.Value >= 1) and 1.25 or 1
	local mult2 = (u18 and u18.Value >= 1) and 1.25 or 1
	return math.floor(level.Value * mult * mult2 - k1.Value - k2.Value - k3.Value - k4.Value - k5.Value)
end

for i = 1, 5 do
	local upgName = "Kernel" .. i
	local event = ReplicatedStorage:WaitForChild(upgName)
	local eventMax = ReplicatedStorage:WaitForChild(upgName .. "Max")

	event.OnServerEvent:Connect(function(player)
		local upgrades = player:FindFirstChild("Upgrades")
		local events = player:FindFirstChild("Events")
		if not upgrades or not events then return end
		local level = events:FindFirstChild("Level")
		local upg = upgrades:FindFirstChild(upgName)
		if not level or not upg then return end

		local unspent = getUnspentKernels(upgrades, level)
		if unspent >= COST and upg.Value < MAX_LEVEL then
			upg.Value += COST
		end
	end)

	eventMax.OnServerEvent:Connect(function(player)
		local upgrades = player:FindFirstChild("Upgrades")
		local events = player:FindFirstChild("Events")
		if not upgrades or not events then return end
		local level = events:FindFirstChild("Level")
		local upg = upgrades:FindFirstChild(upgName)
		if not level or not upg then return end

		while upg.Value < MAX_LEVEL do
			local unspent = getUnspentKernels(upgrades, level)
			if unspent >= COST then
				upg.Value += COST
			else
				break
			end
		end
	end)
end
