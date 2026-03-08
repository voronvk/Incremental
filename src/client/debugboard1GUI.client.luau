local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local rebirths = currencies:WaitForChild("Rebirths")
local corn = currencies:WaitForChild("Corn")

local upgradefolder = workspace:WaitForChild("Upgrades")
local upgradePart = upgradefolder:WaitForChild("DebugBoard1")
local levelPart = upgradePart:WaitForChild("LevelBoard")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
local levelGui = levelPart:WaitForChild("LevelGUI")
local button = surfaceGui:WaitForChild("UpgradeButton")
local costlabel = surfaceGui:WaitForChild("CostLabel")
local effectlabel = surfaceGui:WaitForChild("EffectLabel")
local levellabel = levelGui:WaitForChild("LevelLabel")

local upgradeEvent = ReplicatedStorage:WaitForChild("Debug1")

local RunService = game:GetService("RunService")

button.MouseButton1Click:Connect(function()
	upgradeEvent:FireServer()
end)
