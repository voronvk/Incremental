local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local spawnRateUpg1 = upgrades:WaitForChild("SpawnRateUpg1")
local corn = currencies:WaitForChild("Corn")

local upgradefolder = workspace:WaitForChild("Upgrades")
local upgradePart = upgradefolder:WaitForChild("UpgradeBoard1")
local levelPart = upgradePart:WaitForChild("LevelBoard")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
local levelGui = levelPart:WaitForChild("LevelGUI")
local button = surfaceGui:WaitForChild("UpgradeButton")
local buttonmax = surfaceGui:WaitForChild("UpgradeMaxButton")
local costlabel = surfaceGui:WaitForChild("CostLabel")
local effectlabel = surfaceGui:WaitForChild("EffectLabel")
local levellabel = levelGui:WaitForChild("LevelLabel")

local upgradeEvent = ReplicatedStorage:WaitForChild("UpgradeSpawnRateUpg1Request")
local upgradeEventMax = ReplicatedStorage:WaitForChild("UpgradeSpawnRateUpg1RequestMax")

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

local MAX_LEVEL = 7

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

-- Calculate cost based on current level
local function getCost(level)
	return math.floor(5 * (2 ^ level))
end

-- Update label when value changes
local function updateLabel()
	local cost = getCost(spawnRateUpg1.Value)
	levellabel.Text = "Level: " .. spawnRateUpg1.Value .. "/" .. MAX_LEVEL
	if corn.Value >= cost and spawnRateUpg1.Value < MAX_LEVEL then
		button.BackgroundColor3 = Color3.new(0,1,0)
		buttonmax.BackgroundColor3 = Color3.new(0,1,0)
	else
		button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
		buttonmax.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
	end

	if spawnRateUpg1.Value < MAX_LEVEL then
		effectlabel.Text = ((30 - (spawnRateUpg1.Value * 4)) / 10) .. "s ➡ " .. ((30 - ((spawnRateUpg1.Value + 1) * 4)) / 10) .. "s"
		costlabel.Text = "Cost: " .. Abbreviate(cost) .. " <font color=\"#7FFF7F\">Melons</font>"
	else
		effectlabel.Text = ((30 - (spawnRateUpg1.Value * 4)) / 10) .. "s"
		costlabel.Text = "Cost: Max Level!"
	end
end

updateLabel()
spawnRateUpg1:GetPropertyChangedSignal("Value"):Connect(updateLabel)
corn:GetPropertyChangedSignal("Value"):Connect(updateLabel)

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
