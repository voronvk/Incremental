local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")

local upgradeFolder = workspace:WaitForChild("Upgrades")
local tierfolder = upgradeFolder:WaitForChild("TierBoards")
local upgradePart = tierfolder:WaitForChild("TierBoard1")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")

local tierButtons = {
	surfaceGui:WaitForChild("T1"),
	surfaceGui:WaitForChild("T2"),
	surfaceGui:WaitForChild("T3"),
	surfaceGui:WaitForChild("T4"),
	surfaceGui:WaitForChild("T5"),
	surfaceGui:WaitForChild("T6"),
}

local tier = upgrades:WaitForChild("Tier")

local COLOR_ON = Color3.fromRGB(255, 170, 255)
local COLOR_OFF = Color3.fromRGB(85, 0, 127)

local function updateLabel()
	local t = tier.Value
	for i = 1, 6 do
		tierButtons[i].BackgroundColor3 = (t >= i) and COLOR_ON or COLOR_OFF
	end
end

updateLabel()
tier:GetPropertyChangedSignal("Value"):Connect(updateLabel)
