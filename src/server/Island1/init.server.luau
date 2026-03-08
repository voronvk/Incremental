local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage:WaitForChild("UnlockIsland1Event")

local BASE_COST = 100

event.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:WaitForChild("Upgrades")
	local events = player:FindFirstChild("Events")

	local rebirths = currencies:FindFirstChild("Rebirths")
	local upg = events:FindFirstChild("Island1Bought")

	if rebirths and upg and rebirths.Value >= BASE_COST then
		rebirths.Value = rebirths.Value - BASE_COST
		upg.Value = upg.Value + 1
	end
end)
