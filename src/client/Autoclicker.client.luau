local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local autoclickers = player:WaitForChild("Upgrades"):WaitForChild("Autoclickers")
local clickEvent = ReplicatedStorage:WaitForChild("AutoClickEvent")

while true do
	local rate = autoclickers.Value
	if rate > 0 then
		clickEvent:FireServer()
		wait(1 / rate)
	else
		wait(1) -- wait a bit before checking again
	end
end
