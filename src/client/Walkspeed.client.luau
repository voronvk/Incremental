local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
local WALKSPEED_GAMEPASS_ID = 1740406688

local upgrades = player:WaitForChild("Upgrades")
local upgTree4 = upgrades:WaitForChild("UpgTree4")
local upgtree2_28 = upgrades:WaitForChild("UpgTree2_28")
local upgtree2_29 = upgrades:WaitForChild("UpgTree2_29")
local events = player:WaitForChild("Events")
local speedBoostEndTime = events:WaitForChild("SpeedBoostEndTime")
local defaultspeed = 16

local function checkGamepass()
	return GamePassCheck.playerOwnsGamePass(player, WALKSPEED_GAMEPASS_ID)
end

local function applyWalkspeedBonus()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local speed = defaultspeed
	local ownsGamepass = checkGamepass()

	if upgTree4.Value == 1 then
		speed = speed * 1.5
	end

	if upgtree2_28.Value >= 1 then
		speed = speed * 1.25
	end

	if upgtree2_29.Value >= 1 then
		speed = speed * 1.25
	end

	if ownsGamepass then
		speed = speed * 1.75
	end

	local speedBoostMult = (speedBoostEndTime.Value > os.time()) and 2 or 1
	speed = speed * speedBoostMult

	humanoid.WalkSpeed = speed
end

-- Run when script starts
applyWalkspeedBonus()

-- Re-apply bonus every 5 seconds
task.spawn(function()
	while true do
		task.wait(5)
		applyWalkspeedBonus()
	end
end)

-- Re-apply bonus every time character respawns
player.CharacterAdded:Connect(function()
	applyWalkspeedBonus()
end)

upgTree4:GetPropertyChangedSignal("Value"):Connect(applyWalkspeedBonus)
upgtree2_28:GetPropertyChangedSignal("Value"):Connect(applyWalkspeedBonus)
upgtree2_29:GetPropertyChangedSignal("Value"):Connect(applyWalkspeedBonus)
speedBoostEndTime:GetPropertyChangedSignal("Value"):Connect(applyWalkspeedBonus)
