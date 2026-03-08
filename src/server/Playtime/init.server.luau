local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	local events = player:WaitForChild("Events")
	local playtime = events:WaitForChild("Playtime")

	while player.Parent do
		playtime.Value += 1
		task.wait(1)
	end
end)
