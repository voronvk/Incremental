local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local events = player:WaitForChild("Events")
local level = events:WaitForChild("Level")
local island1Bought = events:WaitForChild("Island1Bought")

local unlockEvent = ReplicatedStorage:WaitForChild("UnlockIsland1Event")

local upgradefolder = workspace:WaitForChild("Upgrades")
local islandfolder = upgradefolder:WaitForChild("IslandExpand")
local upgradePart = islandfolder:WaitForChild("IslandBoard1")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
local button = surfaceGui:WaitForChild("UpgradeButton")

local MIN_LEVEL = 16

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://140206660137491"
sound.Parent = SoundService

local function checkmuted()
	local settings = player:FindFirstChild("Settings")
	local sfx = settings and settings:FindFirstChild("SfxMuted")
	if sfx and sfx:IsA("ValueBase") and sfx.Value >= 1 then
		sound.Volume = 0
	else
		sound.Volume = 1
	end
end

local function canUnlockIsland(): boolean
	if island1Bought.Value >= 1 then
		return false
	end
	return level.Value >= MIN_LEVEL
end

local function updateButtonVisual()
	local ok = canUnlockIsland()
	if ok then
		button.BackgroundColor3 = Color3.new(0, 1, 0)
	else
		button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
	end
	if button:IsA("GuiButton") then
		button.Active = ok
		button.AutoButtonColor = ok
	end
end

updateButtonVisual()
level:GetPropertyChangedSignal("Value"):Connect(updateButtonVisual)
island1Bought:GetPropertyChangedSignal("Value"):Connect(updateButtonVisual)

-- Al llegar a nivel 16 (o si ya lo superaste), dispara el remoto para que el servidor marque Island1Bought.
local function requestUnlockViaRemote()
	if island1Bought.Value >= 1 or level.Value < MIN_LEVEL then
		return
	end
	unlockEvent:FireServer()
end

task.defer(requestUnlockViaRemote)
level:GetPropertyChangedSignal("Value"):Connect(requestUnlockViaRemote)

local function onUnlockIslandClick()
	if not canUnlockIsland() then
		return
	end
	unlockEvent:FireServer()
	sound:Play()
end

if button:IsA("GuiButton") then
	button.Activated:Connect(onUnlockIslandClick)
end
button.MouseButton1Click:Connect(onUnlockIslandClick)

player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkmuted)
checkmuted()
