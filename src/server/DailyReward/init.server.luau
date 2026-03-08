local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Event = ReplicatedStorage:WaitForChild("DailyClaim")

Event.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local events = player:FindFirstChild("Events")
	if not currencies or not events then return end

	local streak = events:WaitForChild("Streak")
	local lastclaim = events:WaitForChild("LastClaim")
	local timenow = os.time()
	local gems = currencies:WaitForChild("Gemeralds")

	if (timenow - lastclaim.Value) >= (24 * 60 * 60) then
		if streak.Value >= 7 then
			gems.Value = gems.Value + 3
		else
			gems.Value = gems.Value + 2
		end

		streak.Value = streak.Value + 1
		lastclaim.Value = os.time()
	end
end)
