local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local upg = upgrades:WaitForChild("RebirthValueUpg1")
local corn = currencies:WaitForChild("Corn")
local gems = currencies:WaitForChild("Gemeralds")

local upgradefolder = workspace:WaitForChild("Upgrades")
local gemfolder = upgradefolder:WaitForChild("GemUpgrades")
local upgradePart = gemfolder:WaitForChild("GemBoard2")
local levelPart = upgradePart:WaitForChild("LevelBoard")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
local levelGui = levelPart:WaitForChild("LevelGUI")
local button = surfaceGui:WaitForChild("UpgradeButton")
local buttonmax = surfaceGui:WaitForChild("UpgradeMaxButton")
local costlabel = surfaceGui:WaitForChild("CostLabel")
local effectlabel = surfaceGui:WaitForChild("EffectLabel")
local levellabel = levelGui:WaitForChild("LevelLabel")

local upgradeEvent = ReplicatedStorage:WaitForChild("UpgradeRebirthValueUpg1Request")
local upgradeEventMax = ReplicatedStorage:WaitForChild("UpgradeRebirthValueUpg1RequestMax")

local RunService = game:GetService("RunService")

local SoundService = game:GetService("SoundService")
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://140206660137491"
local function checkmuted()
	if player:WaitForChild("Settings"):WaitForChild("SfxMuted").Value >= 1 then
		sound.Volume = 0
	else
		sound.Volume = 1
	end
end
sound.Parent = SoundService

local MAX_LEVEL = 50

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

-- Calculate cost based on current level
local function getCost(level)
	return math.floor(10 * (1.5 ^ level))
end

-- Update label when value changes
local function updateLabel()
	local cost = getCost(upg.Value)
	levellabel.Text = "Level: " .. upg.Value .. "/" .. MAX_LEVEL
	if gems.Value >= cost and upg.Value < MAX_LEVEL then
		button.BackgroundColor3 = Color3.new(0,1,0)
		buttonmax.BackgroundColor3 = Color3.new(0,1,0)
	else
		button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
		buttonmax.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
	end

	if upg.Value < MAX_LEVEL then
		effectlabel.Text = (2 ^ upg.Value) .. "x ➡ " .. (2 ^ (upg.Value + 1)) .. "x"
		costlabel.Text = "Cost: " .. Abbreviate(cost) .. " <font color=\"#A656E3\">Crystals</font>"
	else
		effectlabel.Text = (2 ^ upg.Value) .. "x"
		costlabel.Text = "Cost: Max Level!"
	end
end

updateLabel()
upg:GetPropertyChangedSignal("Value"):Connect(updateLabel)
gems:GetPropertyChangedSignal("Value"):Connect(updateLabel)

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
