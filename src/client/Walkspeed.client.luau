local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
local WALKSPEED_GAMEPASS_ID = 1740406688

local upgrades = player:WaitForChild("Upgrades")
local upgTree4 = upgrades:WaitForChild("UpgTree4")
local upgtree2_28 = upgrades:WaitForChild("UpgTree2_28")
local upgtree2_29 = upgrades:WaitForChild("UpgTree2_29")
local goldTreeP1 = upgrades:WaitForChild("GoldTreeP1")
local events = player:WaitForChild("Events")
local speedBoostEndTime = events:WaitForChild("SpeedBoostEndTime")
local speedBoostMultiplier = events:WaitForChild("SpeedBoostMultiplier")
local luckAllBoostEndTime = events:FindFirstChild("LuckAllBoostEndTime")
local luckAllBoostAdd = events:FindFirstChild("LuckAllBoostAdd")
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

	local speedBoostMult = (speedBoostEndTime.Value > os.time()) and math.max(1, speedBoostMultiplier.Value) or 1
	-- LuckShop option B: +1 a todos los boosts mientras esté activo
	if luckAllBoostEndTime and luckAllBoostAdd and luckAllBoostEndTime:IsA("NumberValue") and luckAllBoostAdd:IsA("NumberValue") then
		if luckAllBoostEndTime.Value > os.time() then
			speedBoostMult += math.max(0, luckAllBoostAdd.Value)
		end
	end
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
speedBoostMultiplier:GetPropertyChangedSignal("Value"):Connect(applyWalkspeedBonus)
if luckAllBoostEndTime and luckAllBoostEndTime:IsA("NumberValue") then
	luckAllBoostEndTime:GetPropertyChangedSignal("Value"):Connect(applyWalkspeedBonus)
end
if luckAllBoostAdd and luckAllBoostAdd:IsA("NumberValue") then
	luckAllBoostAdd:GetPropertyChangedSignal("Value"):Connect(applyWalkspeedBonus)
end
goldTreeP1:GetPropertyChangedSignal("Value"):Connect(applyWalkspeedBonus)
