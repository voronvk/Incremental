local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local upg = upgrades:WaitForChild("CornEnergy")
local energy = currencies:WaitForChild("Energy")

local upgradefolder = workspace:WaitForChild("Upgrades")
local clickfolder = upgradefolder:WaitForChild("GeneratorUpgrades")
local upgradePart = clickfolder:WaitForChild("EnergyBoard1")
local levelPart = upgradePart:WaitForChild("LevelBoard")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
local levelGui = levelPart:WaitForChild("LevelGUI")
local button = surfaceGui:WaitForChild("UpgradeButton")
local effectlabel = surfaceGui:WaitForChild("EffectLabel")
local levellabel = levelGui:WaitForChild("LevelLabel")

local upgradeEvent = ReplicatedStorage:WaitForChild("AddEnergy1")

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

local MAX_LEVEL = 999999999999999

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))


local function updateLabel()
	local cost = 1
	levellabel.Text = "Energy: " .. Abbreviate(upg.Value)
	if energy.Value >= cost and upg.Value < MAX_LEVEL then
		button.BackgroundColor3 = Color3.new(0,1,0)
	else
		button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
	end

	if upg.Value < MAX_LEVEL then
		effectlabel.Text = string.format("%.2fx", (upg.Value + 1) ^ (1/5))
	else
		effectlabel.Text = string.format("%.2fx", (upg.Value + 1) ^ (1/5))
	end
end

updateLabel()
upg:GetPropertyChangedSignal("Value"):Connect(updateLabel)
energy:GetPropertyChangedSignal("Value"):Connect(updateLabel)

button.MouseButton1Click:Connect(function()
	upgradeEvent:FireServer()
	sound:Play()
end)

player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkmuted)
checkmuted()
