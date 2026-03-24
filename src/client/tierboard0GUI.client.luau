local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local corn = player:WaitForChild("Currencies"):WaitForChild("Corn")

local upgradeFolder = workspace:WaitForChild("Upgrades")
local tierfolder = upgradeFolder:WaitForChild("TierBoards")
local upgradePart = tierfolder:WaitForChild("TierBoard0")
local levelPart = upgradePart:WaitForChild("LevelBoard")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
local levelGui = levelPart:WaitForChild("LevelGUI")
local button = surfaceGui:WaitForChild("UpgradeButton")
local costLabel = surfaceGui:WaitForChild("CostLabel")
local levelLabel = levelGui:WaitForChild("LevelLabel")
local tier = upgrades:WaitForChild("Tier")

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

local upg20 = upgrades:WaitForChild("UpgTree20")

local upgradeEvent = ReplicatedStorage:WaitForChild("TierUp")

local TierCost = 100_000_000_000_000

local function updateLabel()
	local tier = upgrades:WaitForChild("Tier")
	levelLabel.Text = "Tier: " .. tier.Value
	if tier.Value >= 6 then
		costLabel.Text = "Maxed!"
	end

	if corn.Value >= TierCost and upg20.Value >= 1 and tier.Value <= 5 then
		button.BackgroundColor3 = Color3.new(0, 1, 0)
	else
		button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
	end
end

updateLabel()

tier:GetPropertyChangedSignal("Value"):Connect(updateLabel)
corn:GetPropertyChangedSignal("Value"):Connect(updateLabel)
upg20:GetPropertyChangedSignal("Value"):Connect(updateLabel)

button.MouseButton1Click:Connect(function()
	if corn.Value >= TierCost then
		upgradeEvent:FireServer()
		sound:Play()
	else
		print("blud2")
	end
end)

player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkmuted)
checkmuted()
