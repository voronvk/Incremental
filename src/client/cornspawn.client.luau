local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local upgrades = player:WaitForChild("Upgrades")
local collectradius = upgrades:WaitForChild("CollectRadiusUpg1")

local events = player:WaitForChild("Events")

local cornTemplate = ReplicatedStorage:WaitForChild("Corn")
local silverCornTemplate = ReplicatedStorage:WaitForChild("SilverCorn")
local goldenCornTemplate = ReplicatedStorage:WaitForChild("GoldenCorn")
local diamondCornTemplate = ReplicatedStorage:WaitForChild("DiamondCorn")
local rubyCornTemplate = ReplicatedStorage:WaitForChild("RubyCorn")

local plot = workspace:WaitForChild("FarmPlot")
local collectEvent = ReplicatedStorage:WaitForChild("CollectCornEvent")
local collectEventAuto = ReplicatedStorage:WaitForChild("CollectCornEventAuto")

local lastCollectSoundTime = 0
local SOUND_COOLDOWN = 1

local spawnInterval = 3
--local maxCorn = 10
local pickupRange = 2.5
local cornYOffset = 1
local myCorn = {}
local clearCornEvent = ReplicatedStorage:WaitForChild("ClearLocalCornEvent")

local SoundService = game:GetService("SoundService")

local collectsound = Instance.new("Sound")
collectsound.SoundId = "rbxassetid://101429032102613"
-- collectsound.SoundId = "rbxassetid://71250259471548" -- dig
-- collectsound.SoundId = "rbxassetid://105910802751420" -- puff
local function checkmuted()
	if player:WaitForChild("Settings"):WaitForChild("SfxMuted").Value >= 1 then
		collectsound.Volume = 0
	else
		collectsound.Volume = 1
	end
end
collectsound.Parent = SoundService

clearCornEvent.OnClientEvent:Connect(function()
	for i = #myCorn, 1, -1 do
		local corn = myCorn[i]
		if corn then
			corn:Destroy()
		end
		table.remove(myCorn, i)
	end
end)


local function getRandomPositionOnPlot()
	local size = plot.Size
	local pos = plot.Position
	local edgeBuffer = 1

	local x = math.random() * (size.X - 2 * edgeBuffer) - (size.X / 2 - edgeBuffer)
	local z = math.random() * (size.Z - 2 * edgeBuffer) - (size.Z / 2 - edgeBuffer)
	local y = math.random() * (1.25 - 0.75) + 0.75

	return Vector3.new(pos.X + x, pos.Y + y, pos.Z + z)
end


local player = game.Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local spawnRateUpg1 = upgrades:WaitForChild("SpawnRateUpg1")
local cornAmountUpg1 = upgrades:WaitForChild("CornAmountUpg1")
local spawnRateUpg2 = upgrades:WaitForChild("SpawnRateUpg2")
local upgtree8 = upgrades:WaitForChild("UpgTree8")
local upgtree10 = upgrades:WaitForChild("UpgTree10")
local upgtree2_6 = upgrades:WaitForChild("UpgTree2_6")
local kernel4 = upgrades:WaitForChild("Kernel4")
local kernel5 = upgrades:WaitForChild("Kernel5")

task.spawn(function()
	while true do
		local mult = (upgtree8.Value == 1) and 2 or 1
		local tier = upgrades:WaitForChild("Tier")
		local mult2 = (tier.Value >= 2) and tier.Value or 1
		local luckmult = (upgtree2_6.Value == 1) and 2 or 1

		local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
		local luckmult2 = 1
		if GamePassCheck.playerOwnsGamePass(player, 1740516591) then
			luckmult2 = 2
		end
		if GamePassCheck.playerOwnsGamePass(player, 1740686732) then
			luckmult2 = luckmult2 * 2
		end
		local luckBoost = player:GetAttribute("LuckBoostMultiplier") or 1
		luckmult2 = luckmult2 * luckBoost

		local mult3 = (kernel5.Value * 0.02 + 1)
		local mult4 = (kernel4.Value * 0.05 + 1)
		local level = events:WaitForChild("Level")
		if #myCorn < ((2 + (cornAmountUpg1.Value * 2)) * mult * mult3) then

			local currencies = player:WaitForChild("Currencies")
			local rubyseeds = currencies:WaitForChild("RubySeeds").Value
			local diamondseeds = currencies:WaitForChild("DiamondSeeds").Value
			local goldenseeds = currencies:WaitForChild("GoldenSeeds").Value
			local silverseeds = currencies:WaitForChild("SilverSeeds").Value
			local rubychance = 1 + rubyseeds * luckmult * luckmult2
			local diamondchance = 10 + diamondseeds + rubychance * luckmult * luckmult2
			local goldenchance = 150 + goldenseeds + diamondchance * luckmult * luckmult2
			local silverchance = 750 + silverseeds + goldenchance * luckmult * luckmult2

			if level.Value <= 20 then
				rubychance = 0
				diamondchance = 0
			end

			local rand = math.random(1, 10000)
			local corn
			if rand <= rubychance then
				corn = rubyCornTemplate:Clone()
			elseif rand <= diamondchance then
				corn = diamondCornTemplate:Clone()
			elseif rand <= goldenchance then
				corn = goldenCornTemplate:Clone()
			elseif rand <= silverchance then
				corn = silverCornTemplate:Clone()
			else
				corn = cornTemplate:Clone()
			end
			local pos = getRandomPositionOnPlot()
			corn:SetPrimaryPartCFrame(CFrame.new(pos))
			corn.Parent = workspace
			table.insert(myCorn, corn)
		end
		task.wait((spawnInterval - (spawnRateUpg1.Value * 0.4) ) / (1 + (spawnRateUpg2.Value * 0.5)) / mult2 / mult4)
	end
end)


RunService.Heartbeat:Connect(function()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local soundPlayedThisFrame = false

	for i = #myCorn, 1, -1 do
		local corn = myCorn[i]
		if corn and corn.PrimaryPart then
			local playerXZ = Vector2.new(root.Position.X, root.Position.Z)
			local cornXZ = Vector2.new(corn.PrimaryPart.Position.X, corn.PrimaryPart.Position.Z)
			local horizontalDist = (playerXZ - cornXZ).Magnitude
			if horizontalDist <= (pickupRange + (collectradius.Value * 0.5) + 0.1 + upgtree10.Value) then
				collectEvent:FireServer(corn.Name)
				corn:Destroy()
				table.remove(myCorn, i)

				if not soundPlayedThisFrame then
					collectsound:Play()
					soundPlayedThisFrame = true
				end
			end
		end
	end
end)

local upgtree2_13 = upgrades:WaitForChild("UpgTree2_13")

task.spawn(function()
	while true do
		wait(1)
		if upgtree2_13.Value >= 1 then
			if #myCorn > 0 then
				local randomIndex = math.random(1, #myCorn)
				local corn = myCorn[randomIndex]
				if corn and corn.PrimaryPart then
					collectEventAuto:FireServer(corn.Name)
					corn:Destroy()
					table.remove(myCorn, randomIndex)
				end
			end
		end
	end
end)


player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkmuted)
checkmuted()
