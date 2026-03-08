local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local cornValueUpg2 = upgrades:WaitForChild("CornValueUpg2")
local rebirths = currencies:WaitForChild("Rebirths")

local upgradefolder = workspace:WaitForChild("Upgrades")
local upgradePart = upgradefolder:WaitForChild("RebirthBoard1")
local levelPart = upgradePart:WaitForChild("LevelBoard")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
local levelGui = levelPart:WaitForChild("LevelGUI")
local button = surfaceGui:WaitForChild("UpgradeButton")
local buttonmax = surfaceGui:WaitForChild("UpgradeMaxButton")
local costlabel = surfaceGui:WaitForChild("CostLabel")
local effectlabel = surfaceGui:WaitForChild("EffectLabel")
local levellabel = levelGui:WaitForChild("LevelLabel")

local upgradeEvent = ReplicatedStorage:WaitForChild("UpgradeCornValueUpg2Request")
local upgradeEventMax = ReplicatedStorage:WaitForChild("UpgradeCornValueUpg2RequestMax")

local SoundService = game:GetService("SoundService")
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://100841669467007"
local function checkmuted()
	if player:WaitForChild("Settings"):WaitForChild("SfxMuted").Value >= 1 then
		sound.Volume = 0
	else
		sound.Volume = 1
	end
end
sound.Parent = SoundService

local RunService = game:GetService("RunService")

local MAX_LEVEL = 6

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

-- Calculate cost based on current level
local function getCost(level)
	return math.floor(4 ^ level)
end

-- Update label when value changes
local function updateLabel()
	local cost = getCost(cornValueUpg2.Value)
	levellabel.Text = "Level: " .. cornValueUpg2.Value .. "/" .. MAX_LEVEL
	if rebirths.Value >= cost and cornValueUpg2.Value < MAX_LEVEL then
		button.BackgroundColor3 = Color3.new(0,1,0)
		buttonmax.BackgroundColor3 = Color3.new(0,1,0)
	else
		button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
		buttonmax.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
	end

	if cornValueUpg2.Value < MAX_LEVEL then
		effectlabel.Text = (2 ^ cornValueUpg2.Value) .. "x ➡ " .. (2 ^ (cornValueUpg2.Value + 1)) .. "x"
		costlabel.Text = "Cost: " .. Abbreviate(cost) .. " <font color=\"#AAAAFF\">Rebirths</font>"
	else
		effectlabel.Text = (2 ^ cornValueUpg2.Value)
		costlabel.Text = "Cost: Max Level!"
	end
end

updateLabel()
cornValueUpg2:GetPropertyChangedSignal("Value"):Connect(updateLabel)
rebirths:GetPropertyChangedSignal("Value"):Connect(updateLabel)

button.MouseButton1Click:Connect(function()
	upgradeEvent:FireServer()
	sound:Play()
end)

buttonmax.MouseButton1Click:Connect(function()
	upgradeEventMax:FireServer()
	sound:Play()
end)

player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkmuted)
checkmuted()
