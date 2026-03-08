local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local Event = ReplicatedStorage:WaitForChild("GenerationEvent")

while true do
	local generators = upgrades:WaitForChild("Generators")
	if generators.Value > 0 then
		Event:FireServer()
		wait(1)
	else
		wait(1) -- wait a bit before checking again
	end
end
