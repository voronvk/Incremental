local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local upg = upgrades:WaitForChild("Kernel1")
local events = player:FindFirstChild("Events")

local upgradefolder = workspace:WaitForChild("Upgrades")
local clickfolder = upgradefolder:WaitForChild("KernelUpgrades")
local upgradePart = clickfolder:WaitForChild("KernelBoard1")
local levelPart = upgradePart:WaitForChild("LevelBoard")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
local levelGui = levelPart:WaitForChild("LevelGUI")
local button = surfaceGui:WaitForChild("UpgradeButton")
local buttonmax = surfaceGui:WaitForChild("UpgradeMaxButton")
local costlabel = surfaceGui:WaitForChild("CostLabel")
local effectlabel = surfaceGui:WaitForChild("EffectLabel")
local levellabel = levelGui:WaitForChild("LevelLabel")
local level = events:WaitForChild("Level")
local kernelupg1 = upgrades:WaitForChild("Kernel1")
local kernelupg2 = upgrades:WaitForChild("Kernel2")
local kernelupg3 = upgrades:WaitForChild("Kernel3")
local kernelupg4 = upgrades:WaitForChild("Kernel4")
local kernelupg5 = upgrades:WaitForChild("Kernel5")

local upgradeEvent = ReplicatedStorage:WaitForChild("Kernel1")
local upgradeEventMax = ReplicatedStorage:WaitForChild("Kernel1Max")

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

local MAX_LEVEL = 50

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

local upgtree2_17 = upgrades:WaitForChild("UpgTree2_17")
local upgtree2_18 = upgrades:WaitForChild("UpgTree2_18")

local function updateLabel()
	local mult = (upgtree2_17.Value >= 1) and 1.25 or 1
	local mult2 = (upgtree2_18.Value >= 1) and 1.25 or 1
	local unspentkernels =  math.floor(level.Value * mult * mult2 - kernelupg1.Value - kernelupg2.Value - kernelupg3.Value - kernelupg4.Value - kernelupg5.Value)
	local cost = 1
	levellabel.Text = "Level: " .. upg.Value .. "/" .. MAX_LEVEL
	if unspentkernels >= cost and upg.Value < MAX_LEVEL then
		button.BackgroundColor3 = Color3.new(0,1,0)
		buttonmax.BackgroundColor3 = Color3.new(0,1,0)
	else
		button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
		buttonmax.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
	end

	if upg.Value < MAX_LEVEL then
		local currentEffect = 1.15 ^ upg.Value
		local nextEffect = 1.15 ^ (upg.Value + 1)
		effectlabel.Text = string.format("%.2f", currentEffect) .. "x ➡ " .. string.format("%.2f", nextEffect) .. "x"
		costlabel.Text = "Cost: " .. Abbreviate(cost) .. " Pumpkin"
	else
		local currentEffect = 1.15 ^ upg.Value
		effectlabel.Text = string.format("%.2f", currentEffect) .. "x"
		costlabel.Text = "Cost: Max Level!"
	end
end

updateLabel()
level:GetPropertyChangedSignal("Value"):Connect(updateLabel)
kernelupg1:GetPropertyChangedSignal("Value"):Connect(updateLabel)
kernelupg2:GetPropertyChangedSignal("Value"):Connect(updateLabel)
kernelupg3:GetPropertyChangedSignal("Value"):Connect(updateLabel)
kernelupg4:GetPropertyChangedSignal("Value"):Connect(updateLabel)
kernelupg5:GetPropertyChangedSignal("Value"):Connect(updateLabel)
upgtree2_17:GetPropertyChangedSignal("Value"):Connect(updateLabel)
upgtree2_18:GetPropertyChangedSignal("Value"):Connect(updateLabel)

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
