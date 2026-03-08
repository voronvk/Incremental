local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local upg = upgrades:WaitForChild("Generators")
local clicks = currencies:WaitForChild("Clicks")
local generators = upgrades:WaitForChild("Generators")
local energy = currencies:WaitForChild("Energy")

local upgradefolder = workspace:WaitForChild("Upgrades")
local generatorfolder = upgradefolder:WaitForChild("GeneratorUpgrades")
local upgradePart = generatorfolder:WaitForChild("GeneratorBoard0")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
local button = surfaceGui:WaitForChild("UpgradeButton")
local buttonMax = surfaceGui:WaitForChild("UpgradeMaxButton")
local costlabel = surfaceGui:WaitForChild("CostLabel")
local energylabel = surfaceGui:WaitForChild("EnergyLabel")
local generatorslabel = surfaceGui:WaitForChild("GeneratorsLabel")

local upgtree14 = upgrades:WaitForChild("UpgTree14")

local upgradeEvent = ReplicatedStorage:WaitForChild("GeneratorPurchaseEvent")
local upgradeEventMax = ReplicatedStorage:WaitForChild("GeneratorPurchaseEventMax")

local MAX_LEVEL = 100000

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

-- Calculate cost based on current level
local function getCost(level)
	local tier = upgrades:WaitForChild("Tier")
	local discount = (upgtree14.Value == 1) and 0.1 or 1
	local discount2 = (tier.Value >= 3) and 0.001 or 1
	return math.floor(100000 * (1.1 ^ level) * discount * discount2)
end

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

-- Update label when value changes
local function updateLabel()
	local cost = getCost(upg.Value)
	if clicks.Value >= cost and upg.Value < MAX_LEVEL then
		button.BackgroundColor3 = Color3.new(0,1,0)
		buttonMax.BackgroundColor3 = Color3.new(0,1,0)
	else
		button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
		buttonMax.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
	end

	if upg.Value < MAX_LEVEL then
		generatorslabel.Text = "Generators: " .. generators.Value
		energylabel.Text = "Energy: " .. Abbreviate(energy.Value)
		costlabel.Text = "Cost: " .. Abbreviate(cost) .. " Clicks"
	else
		costlabel.Text = "Cost: Max Level!"
	end
end

updateLabel()
upg:GetPropertyChangedSignal("Value"):Connect(updateLabel)
clicks:GetPropertyChangedSignal("Value"):Connect(updateLabel)
energy:GetPropertyChangedSignal("Value"):Connect(updateLabel)

button.MouseButton1Click:Connect(function()
	upgradeEvent:FireServer()
	sound:Play()
end)

buttonMax.MouseButton1Click:Connect(function()
	upgradeEventMax:FireServer()
	sound:Play()
end)

player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkmuted)
checkmuted()
