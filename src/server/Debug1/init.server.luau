local ReplicatedStorage = game:GetService("ReplicatedStorage")
local debugEvent = ReplicatedStorage:WaitForChild("Debug1")
local clearCornEvent = ReplicatedStorage:WaitForChild("ClearLocalCornEvent")

debugEvent.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	local events = player:FindFirstChild("Events")
	if not currencies or not upgrades or not events then return end

	for _, stat in ipairs(currencies:GetChildren()) do
		if stat:IsA("ValueBase") then
			stat.Value = 0
		end
	end

	for _, stat in ipairs(upgrades:GetChildren()) do
		if stat:IsA("ValueBase") then
			stat.Value = 0
		end
	end

	for _, stat in ipairs(events:GetChildren()) do
		if stat:IsA("ValueBase") then
			stat.Value = 0
		end
	end

	clearCornEvent:FireClient(player)
end)
