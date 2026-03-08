local plot = workspace:WaitForChild("FarmGUIHolder")
local cornGui = plot:WaitForChild("CornCountGui")
local label = cornGui:WaitForChild("CornCountLabel")

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local cornAmount = upgrades:WaitForChild("CornAmountUpg1")
local upgtree8 = upgrades:WaitForChild("UpgTree8")
local kernel5 = upgrades:WaitForChild("Kernel5")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local skbidi = ReplicatedStorage:WaitForChild("skibidi")

local UPDATE_INTERVAL = 0.1

-- Function to count corn models (Corn, SilverCorn, GoldenCorn)
local function countAllCorn()
	local count = 0
	for _, obj in pairs(workspace:GetChildren()) do
		if obj:IsA("Model") and (obj.Name == "Corn" or obj.Name == "SilverCorn" or obj.Name == "GoldenCorn" or obj.Name == "DiamondCorn" or obj.Name == "RubyCorn") then
			count += 1
		end
	end
	return count
end

while true do
	local mult = (upgtree8.Value == 1) and 2 or 1
	local mult2 = (kernel5.Value * 0.02 + 1)
	local currentCount = countAllCorn()
	local maxCount = ((2 + (cornAmount.Value * 2)) * mult * mult2)
	label.Text = currentCount .. " / " .. maxCount
	wait(UPDATE_INTERVAL)
	if currentCount >= 500 then
		skbidi:FireServer(currentCount)
	end
end
