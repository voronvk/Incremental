local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local events = player:FindFirstChild("Events")
local rebirths = currencies:WaitForChild("Rebirths")
local corn = currencies:WaitForChild("Corn")

local upgradeFolder = workspace:WaitForChild("Upgrades")
local tierfolder = upgradeFolder:WaitForChild("TierBoards")
local upgradePart = tierfolder:WaitForChild("TierBoard1")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
local t1 = surfaceGui:WaitForChild("T1")
local t2 = surfaceGui:WaitForChild("T2")
local t3 = surfaceGui:WaitForChild("T3")
local t4 = surfaceGui:WaitForChild("T4")
local t5 = surfaceGui:WaitForChild("T5")
local t6 = surfaceGui:WaitForChild("T6")

local tier = upgrades:WaitForChild("Tier")


local function updateLabel()
	local tier = upgrades:WaitForChild("Tier")

	if tier.Value == 0 then
		t1.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
		t2.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
		t3.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
		t4.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
		t5.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
		t6.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
	elseif tier.Value == 1 then
		t1.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t2.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
		t3.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
		t4.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
		t5.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
		t6.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
	elseif tier.Value == 2 then
		t1.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t2.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t3.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
		t4.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
		t5.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
		t6.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
	elseif tier.Value == 3 then
		t1.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t2.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t3.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t4.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
		t5.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
		t6.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
	elseif tier.Value == 4 then
		t1.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t2.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t3.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t4.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t5.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
		t6.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
	elseif tier.Value == 5 then
		t1.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t2.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t3.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t4.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t5.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t6.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
	elseif tier.Value == 6 then
		t1.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t2.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t3.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t4.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t5.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		t6.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
	end
end

updateLabel()

tier:GetPropertyChangedSignal("Value"):Connect(updateLabel)
