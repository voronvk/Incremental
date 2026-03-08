local ReplicatedStorage = game:GetService("ReplicatedStorage")
local respecEvent = ReplicatedStorage:WaitForChild("RespecEvent")
local Players = game:GetService("Players")

respecEvent.OnServerEvent:Connect(function(player)
	local upgrades = player:FindFirstChild("Upgrades")
	if not upgrades then return end

	local kernelupg1 = upgrades:FindFirstChild("Kernel1")
	local kernelupg2 = upgrades:FindFirstChild("Kernel2")
	local kernelupg3 = upgrades:FindFirstChild("Kernel3")
	local kernelupg4 = upgrades:FindFirstChild("Kernel4")
	local kernelupg5 = upgrades:FindFirstChild("Kernel5")

	if kernelupg1 then kernelupg1.Value = 0 end
	if kernelupg2 then kernelupg2.Value = 0 end
	if kernelupg3 then kernelupg3.Value = 0 end
	if kernelupg4 then kernelupg4.Value = 0 end
	if kernelupg5 then kernelupg5.Value = 0 end
end)
