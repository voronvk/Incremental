local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local upgTree4 = upgrades:WaitForChild("UpgTree4")
local upgtree2_28 = upgrades:WaitForChild("UpgTree2_28")
local upgtree2_29 = upgrades:WaitForChild("UpgTree2_29")
local defaultspeed = 16

local ownsGamepass = false

local function checkGamepass()
	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, 1594634081)
	end)
	if success then
		ownsGamepass = result
	end
end

checkGamepass()

local function applyWalkspeedBonus()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local speed = defaultspeed
	checkGamepass()

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
