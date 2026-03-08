local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerName = player.Name

local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local rebirths = currencies:WaitForChild("Rebirths")
local events = player:WaitForChild("Events")

local unlockEvent = ReplicatedStorage:WaitForChild("UnlockIsland1Event")
local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

local event = events:WaitForChild("Island1Bought")

-- Wait for player's personal clone of IslandBoard1
local islandBoardName = "IslandBoard1"
local upgradefolder = workspace:WaitForChild("Upgrades")
local islandfolder = upgradefolder:WaitForChild("IslandExpand")
local upgradePart = islandfolder:WaitForChild(islandBoardName)
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
local button = surfaceGui:WaitForChild("UpgradeButton")

-- Cost to unlock Island1
local UnlockCost = 100

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

local function getCost(level)
	return math.floor(UnlockCost) -- placeholder if dynamic later
end

local function updateLabel()
	local cost = getCost(rebirths.Value)
	if rebirths.Value >= cost then
		button.BackgroundColor3 = Color3.new(0, 1, 0)
	else
		button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
	end
end

updateLabel()
rebirths:GetPropertyChangedSignal("Value"):Connect(updateLabel)

button.MouseButton1Click:Connect(function()
	unlockEvent:FireServer()
	sound:Play()
end)

player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkmuted)
checkmuted()
