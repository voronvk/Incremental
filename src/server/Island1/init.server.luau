local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local event = ReplicatedStorage:WaitForChild("UnlockIsland1Event")

local MIN_LEVEL = 16

local function tryGrantIsland1(player: Player)
	local events = player:FindFirstChild("Events")
	if not events then
		return
	end
	local upg = events:FindFirstChild("Island1Bought")
	local level = events:FindFirstChild("Level")
	if not upg or not level or not upg:IsA("NumberValue") or not level:IsA("NumberValue") then
		return
	end
	if upg.Value >= 1 then
		return
	end
	if level.Value < MIN_LEVEL then
		return
	end
	upg.Value = 1
end

event.OnServerEvent:Connect(function(player: Player)
	tryGrantIsland1(player)
end)

local function hookPlayer(player: Player)
	task.spawn(function()
		local events = player:WaitForChild("Events", 60)
		if not events or not player.Parent then
			return
		end
		local level = events:WaitForChild("Level", 30)
		local upg = events:WaitForChild("Island1Bought", 30)
		if not level or not upg then
			return
		end
		tryGrantIsland1(player)
		level:GetPropertyChangedSignal("Value"):Connect(function()
			if not player.Parent then
				return
			end
			tryGrantIsland1(player)
		end)
	end)
end

Players.PlayerAdded:Connect(hookPlayer)
for _, p in Players:GetPlayers() do
	hookPlayer(p)
end
