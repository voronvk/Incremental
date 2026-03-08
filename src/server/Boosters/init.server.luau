local ReplicatedStorage = game:GetService("ReplicatedStorage")
local upgradeEvent = ReplicatedStorage:WaitForChild("BoosterBuy")

upgradeEvent.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not upgrades then return end

	local boosters = upgrades:FindFirstChild("Boosters")
	local ascensions = currencies:FindFirstChild("Ascensions")
	local kernel3 = upgrades:WaitForChild("Kernel3")
	if not boosters or not ascensions then return end

	local currentcost = math.floor((5 ^ boosters.Value) / (1 + (kernel3.Value * 0.25)))
	if currentcost == 0 then
		currentcost = 1
	end

	if ascensions.Value >= currentcost then
		ascensions.Value -= currentcost
		boosters.Value += 1
	end
end)
