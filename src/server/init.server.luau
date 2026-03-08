local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local buyAllRemote = ReplicatedStorage:WaitForChild("BuyAllGamePasses")

buyAllRemote.OnServerEvent:Connect(function(player, ids)
	if type(ids) ~= "table" then
		return
	end
	local current = player:GetAttribute("SimulatedGamePasses")
	if type(current) ~= "table" then
		current = {}
	end
	for _, id in ipairs(ids) do
		table.insert(current, tonumber(id) or id)
	end
	player:SetAttribute("SimulatedGamePasses", current)
end)
