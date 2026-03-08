local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local events = player:FindFirstChild("Events")
local rebirths = currencies:WaitForChild("Rebirths")
local corn = currencies:WaitForChild("Corn")

local upgradeFolder = workspace:WaitForChild("Upgrades")
local tierfolder = upgradeFolder:WaitForChild("BoosterBoards")
local upgradePart = tierfolder:WaitForChild("BoosterBoard0")
local levelPart = upgradePart:WaitForChild("LevelBoard")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
local levelGui = levelPart:WaitForChild("LevelGUI")
local button = surfaceGui:WaitForChild("UpgradeButton")
local costLabel = surfaceGui:WaitForChild("CostLabel")
local levelLabel = levelGui:WaitForChild("LevelLabel")
local effectlabel = surfaceGui:WaitForChild("effectLabel")
local boosters = upgrades:WaitForChild("Boosters")
local ascensions = currencies:WaitForChild("Ascensions")

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

local upg5 = upgrades:WaitForChild("UpgTree2_5")

local upgradeEvent = ReplicatedStorage:WaitForChild("BoosterBuy")

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

local upgTree1 = upgrades:WaitForChild("UpgTree1")
local rebirthValue = upgrades:WaitForChild("RebirthValueUpg1")

local kernel3 = upgrades:WaitForChild("Kernel3")

local cost = math.floor((5 ^ boosters.Value) / (1 + (kernel3.Value * 0.25)))

if cost == 0 then
	cost = 1
end

local function updateLabel()
	local cost = math.floor((5 ^ boosters.Value) / (1 + (kernel3.Value * 0.25)))
	if cost == 0 then
		cost = 1
	end
	levelLabel.Text = "Boosters: " .. boosters.Value
	costLabel.Text = "Cost: " .. cost .. " Ascensions"
	effectlabel.Text = "Currently: " .. boosters.Value + 1 .. "x"

	if ascensions.Value >= cost then
		button.BackgroundColor3 = Color3.new(0, 1, 0)
	else
		print(kernel3.Value)
		button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
	end
end

updateLabel()

boosters:GetPropertyChangedSignal("Value"):Connect(updateLabel)
upg5:GetPropertyChangedSignal("Value"):Connect(updateLabel)
ascensions:GetPropertyChangedSignal("Value"):Connect(updateLabel)
kernel3:GetPropertyChangedSignal("Value"):Connect(updateLabel)

button.MouseButton1Click:Connect(function()
	if ascensions.Value >= cost then
		upgradeEvent:FireServer()
		sound:Play()
	else
		print("blud2")
	end
end)

player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkmuted)
checkmuted()
