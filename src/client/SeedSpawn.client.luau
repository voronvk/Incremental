local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local upgrades = player:WaitForChild("Upgrades")
local collectradius = upgrades:WaitForChild("CollectRadiusUpg1")

local seedTemplate = ReplicatedStorage:WaitForChild("BasicSeed")
local silverSeedTemplate = ReplicatedStorage:WaitForChild("SilverSeed")
local goldenSeedTemplate = ReplicatedStorage:WaitForChild("GoldenSeed")
local diamondSeedTemplate = ReplicatedStorage:WaitForChild("DiamondSeed")
local rubySeedTemplate = ReplicatedStorage:WaitForChild("RubySeed")

local island3 = workspace:WaitForChild("Island3")

local plot = island3:WaitForChild("FarmPlot")
local collectEvent = ReplicatedStorage:WaitForChild("CollectSeedEvent")

local lastCollectSoundTime = 0
local SOUND_COOLDOWN = 1

local spawnInterval = 3
--local maxSeed = 10
local pickupRange = 2.5
local seedYOffset = 1
local mySeed = {}
local clearSeedEvent = ReplicatedStorage:WaitForChild("ClearLocalSeedEvent")

local SoundService = game:GetService("SoundService")

local upgtree10 = upgrades:WaitForChild("UpgTree10")
local upgtree2_27 = upgrades:WaitForChild("UpgTree2_27")

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

clearSeedEvent.OnClientEvent:Connect(function()
	for i = #mySeed, 1, -1 do
		local seed = mySeed[i]
		if seed then
			seed:Destroy()
		end
		table.remove(mySeed, i)
	end
end)


local function getRandomPositionOnPlot()
	local size = plot.Size
	local pos = plot.Position
	local edgeBuffer = 1

	local x = math.random() * (size.X - 2 * edgeBuffer) - (size.X / 2 - edgeBuffer)
	local z = math.random() * (size.Z - 2 * edgeBuffer) - (size.Z / 2 - edgeBuffer)
	local y = math.random() * (0.1) + 1

	return Vector3.new(pos.X + x, pos.Y + y, pos.Z + z)
end


local player = game.Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")

task.spawn(function()
	while true do
		if #mySeed < (3) and upgtree2_27.Value >= 1 then

			local currencies = player:WaitForChild("Currencies")
			local rubyseeds = currencies:WaitForChild("RubySeeds")
			local diamondseeds = currencies:WaitForChild("DiamondSeeds")
			local goldenseeds = currencies:WaitForChild("GoldenSeeds")
			local silverseeds = currencies:WaitForChild("SilverSeeds")

			local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
			local luckmult = GamePassCheck.playerOwnsGamePass(player, 1740219830) and 2 or 1

			local rubychance = 1 * luckmult
			local diamondchance = 4 * luckmult
			local goldenchance = 16 * luckmult
			local silverchance = 64 * luckmult

			local rand = math.random(1, 100)
			local seed
			if rand <= rubychance then
				seed = rubySeedTemplate:Clone()
			elseif rand <= diamondchance then
				seed = diamondSeedTemplate:Clone()
			elseif rand <= goldenchance then
				seed = goldenSeedTemplate:Clone()
			elseif rand <= silverchance then
				seed = silverSeedTemplate:Clone()
			else
				seed = seedTemplate:Clone()
			end
			local pos = getRandomPositionOnPlot()
			seed.Position = pos
			seed.Parent = workspace
			table.insert(mySeed, seed)
		end
		task.wait(3)
	end
end)


RunService.Heartbeat:Connect(function()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local soundPlayedThisFrame = false

	for i = #mySeed, 1, -1 do
		local seed = mySeed[i]
		if seed and seed:IsA("BasePart") then
			local playerXZ = Vector2.new(root.Position.X, root.Position.Z)
			local seedXZ = Vector2.new(seed.Position.X, seed.Position.Z)
			local horizontalDist = (playerXZ - seedXZ).Magnitude

			local range = pickupRange + (collectradius.Value * 0.5) + 0.1 + upgtree10.Value
			if horizontalDist <= range then
				collectEvent:FireServer(seed.Name)
				seed:Destroy()
				table.remove(mySeed, i)

				if not soundPlayedThisFrame then
					collectsound:Play()
					soundPlayedThisFrame = true
				end
			end
		end
	end
end)


player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkmuted)
checkmuted()
