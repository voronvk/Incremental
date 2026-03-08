local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local events = player:FindFirstChild("Events")
local rebirths = currencies:WaitForChild("Rebirths")
local corn = currencies:WaitForChild("Corn")

local upgradeFolder = workspace:WaitForChild("Upgrades")
local gemFolder = upgradeFolder:WaitForChild("GemUpgrades")
local dailyBoard = gemFolder:WaitForChild("DailyReward")
local dailyGui = dailyBoard:WaitForChild("UpgradeGUI")
local button = dailyGui:WaitForChild("UpgradeButton")
local streaklabel = dailyGui:WaitForChild("StreakLabel")

local Event = ReplicatedStorage:WaitForChild("DailyClaim")

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

local function updateLabel()
	local streak = events:WaitForChild("Streak")
	local lastClaim = events:WaitForChild("LastClaim")
	local timeNow = os.time()

	local secondsSinceClaim = timeNow - lastClaim.Value
	local secondsRemaining = math.clamp((24 * 60 * 60) - secondsSinceClaim, 0, 24 * 60 * 60)

	local hours = math.floor(secondsRemaining / 3600)
	local minutes = math.floor((secondsRemaining % 3600) / 60)
	local seconds = secondsRemaining % 60

	local minutesDisplay = string.format("%02d", minutes)
	local secondsDisplay = string.format("%02d", seconds)

	streaklabel.Text = "Streak: " .. streak.Value

	local gemreward
	if streak.Value >= 7 then
		gemreward = 3
	else
		gemreward = 2
	end

	if secondsSinceClaim >= 24 * 60 * 60 then
		button.BackgroundColor3 = Color3.new(0, 1, 0)
		button.Text = "Claim! (+" .. gemreward .. ")"
	else
		button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
		button.Text = string.format("%02d:%s:%s", hours, minutesDisplay, secondsDisplay)
	end
end



updateLabel()

task.spawn(function()
	while true do
		updateLabel()
		task.wait(1)
	end
end)

button.MouseButton1Click:Connect(function()
	local timenow = os.time()
	local lastclaim = events:WaitForChild("LastClaim")
	if (timenow - lastclaim.Value) >= (24*60*60) then
		Event:FireServer()
		sound:Play()
	else
		print("blud")
	end
end)

player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkmuted)
checkmuted()
