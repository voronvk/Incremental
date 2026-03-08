local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local events = player:FindFirstChild("Events")
local rebirths = currencies:WaitForChild("Rebirths")
local corn = currencies:WaitForChild("Corn")

local upgradeFolder = workspace:WaitForChild("Upgrades")
local tierfolder = upgradeFolder:WaitForChild("KernelUpgrades")
local upgradePart = tierfolder:WaitForChild("KernelBoard0")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
local levelPart = tierfolder:WaitForChild("KernelBoard0Top")
local levelGui = levelPart:WaitForChild("SurfaceGui")
local levelLabel = levelGui:WaitForChild("TextLabel")
local level = events:WaitForChild("Level")
local kernelupg1 = upgrades:WaitForChild("Kernel1")
local kernelupg2 = upgrades:WaitForChild("Kernel2")
local kernelupg3 = upgrades:WaitForChild("Kernel3")
local kernelupg4 = upgrades:WaitForChild("Kernel4")
local kernelupg5 = upgrades:WaitForChild("Kernel5")

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

local respecevent = ReplicatedStorage:WaitForChild("RespecEvent")

local button = surfaceGui:WaitForChild("RespecButton")

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

local upgTree1 = upgrades:WaitForChild("UpgTree1")
local rebirthValue = upgrades:WaitForChild("RebirthValueUpg1")

local upgtree2_17 = upgrades:WaitForChild("UpgTree2_17")
local upgtree2_18 = upgrades:WaitForChild("UpgTree2_18")

local function updateLabel()
	local mult = (upgtree2_17.Value >= 1) and 1.25 or 1
	local mult2 = (upgtree2_18.Value >= 1) and 1.25 or 1
	local unspentkernels = math.floor(level.Value * mult * mult2 - kernelupg1.Value - kernelupg2.Value - kernelupg3.Value - kernelupg4.Value - kernelupg5.Value)
	levelLabel.Text = "Pumpkins: " .. unspentkernels
end

local lastRespecTime = 0
local COOLDOWN = 300 -- 5 minutes in seconds
local cooldownActive = false

button.MouseButton1Click:Connect(function()
	local currentTime = os.time()
	if currentTime - lastRespecTime >= COOLDOWN then
		lastRespecTime = currentTime
		respecevent:FireServer()
		sound:Play()

		cooldownActive = true
		button.AutoButtonColor = false
		button.Text = "Cooldown: 5:00"

		task.spawn(function()
			while cooldownActive do
				local timeLeft = COOLDOWN - (os.time() - lastRespecTime)
				if timeLeft <= 0 then
					button.Text = "Respec"
					button.AutoButtonColor = true
					cooldownActive = false
					break
				end

				local minutes = math.floor(timeLeft / 60)
				local seconds = timeLeft % 60
				button.Text = string.format("Cooldown: %d:%02d", minutes, seconds)

				task.wait(1)
			end
		end)
	else
	end
end)

updateLabel()

level:GetPropertyChangedSignal("Value"):Connect(updateLabel)
kernelupg1:GetPropertyChangedSignal("Value"):Connect(updateLabel)
kernelupg2:GetPropertyChangedSignal("Value"):Connect(updateLabel)
kernelupg3:GetPropertyChangedSignal("Value"):Connect(updateLabel)
kernelupg4:GetPropertyChangedSignal("Value"):Connect(updateLabel)
kernelupg5:GetPropertyChangedSignal("Value"):Connect(updateLabel)
upgtree2_17:GetPropertyChangedSignal("Value"):Connect(updateLabel)
upgtree2_18:GetPropertyChangedSignal("Value"):Connect(updateLabel)
