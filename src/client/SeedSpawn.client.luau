--[[
	SeedSpawn - Spawn de semillas local. Clona desde ReplicatedStorage.
	Usa la misma lógica de spawn flexible que CornSpawn (SpawnPoints o Part del plot).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local player = game.Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local collectradius = upgrades:WaitForChild("CollectRadiusUpg1")
local upgtree10 = upgrades:WaitForChild("UpgTree10")
local upgtree2_27 = upgrades:WaitForChild("UpgTree2_27")

local island3 = workspace:WaitForChild("Island3")
local plot = island3:FindFirstChild("FarmPlot", true) or island3:WaitForChild("FarmPlot")
local SpawnHelper = require(ReplicatedStorage.Shared:WaitForChild("SpawnHelper"))
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
local GamePassConfig = require(ReplicatedStorage.Shared:WaitForChild("GamePassConfig"))

local SEED_TEMPLATES = {
	ReplicatedStorage:WaitForChild("BasicSeed"),
	ReplicatedStorage:WaitForChild("SilverSeed"),
	ReplicatedStorage:WaitForChild("GoldenSeed"),
	ReplicatedStorage:WaitForChild("DiamondSeed"),
	ReplicatedStorage:WaitForChild("RubySeed"),
}

local collectEvent = ReplicatedStorage:WaitForChild("CollectSeedEvent")
local clearSeedEvent = ReplicatedStorage:WaitForChild("ClearLocalSeedEvent")

local mySeed = {}
local pickupRange = 2.5

local collectsound = Instance.new("Sound")
collectsound.SoundId = "rbxassetid://101429032102613"
collectsound.Parent = SoundService

local function checkMuted()
	collectsound.Volume = (player:WaitForChild("Settings"):WaitForChild("SfxMuted").Value >= 1) and 0 or 1
end

player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkMuted)
checkMuted()

clearSeedEvent.OnClientEvent:Connect(function()
	for i = #mySeed, 1, -1 do
		local s = mySeed[i]
		if s then s:Destroy() end
		table.remove(mySeed, i)
	end
end)

local function getSpawnPosition()
	local pos = SpawnHelper.getRandomSpawnPosition(plot)
	if pos then return pos end
	local part = plot
	if plot:IsA("Model") and plot.PrimaryPart then part = plot.PrimaryPart
	elseif plot:IsA("Model") then part = plot:FindFirstChildWhichIsA("BasePart", true) end
	if not part or not part:IsA("BasePart") then return nil end
	local size, p = part.Size, part.Position
	local edge = 1
	local x = math.random() * (size.X - 2*edge) - (size.X/2 - edge)
	local z = math.random() * (size.Z - 2*edge) - (size.Z/2 - edge)
	local y = math.random() * 0.1 + 1
	return Vector3.new(p.X + x, p.Y + y, p.Z + z)
end

local function selectSeedTemplate()
	local luckMult = GamePassCheck.playerOwnsGamePass(player, GamePassConfig.LUCK_GAMEPASS_ID) and 2 or 1
	luckMult = luckMult * (player:GetAttribute("LuckBoostMultiplier") or 1)

	local rubychance = 1 * luckMult
	local diamondchance = 4 * luckMult
	local goldenchance = 16 * luckMult
	local silverchance = 64 * luckMult

	local rand = math.random(1, 100)
	if rand <= rubychance then return SEED_TEMPLATES[5]
	elseif rand <= diamondchance then return SEED_TEMPLATES[4]
	elseif rand <= goldenchance then return SEED_TEMPLATES[3]
	elseif rand <= silverchance then return SEED_TEMPLATES[2]
	else return SEED_TEMPLATES[1] end
end

task.spawn(function()
	while true do
		if #mySeed < 3 and upgtree2_27.Value >= 1 then
			local pos = getSpawnPosition()
			if pos then
				local seed = selectSeedTemplate():Clone()
				seed.Position = pos
				seed.Parent = workspace
				table.insert(mySeed, seed)
			end
		end
		task.wait(3)
	end
end)

RunService.Heartbeat:Connect(function()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local range = pickupRange + collectradius.Value * 0.5 + 0.1 + upgtree10.Value
	local soundPlayed = false

	for i = #mySeed, 1, -1 do
		local seed = mySeed[i]
		if seed and seed:IsA("BasePart") then
			local pXZ = Vector2.new(root.Position.X, root.Position.Z)
			local sXZ = Vector2.new(seed.Position.X, seed.Position.Z)
			if (pXZ - sXZ).Magnitude <= range then
				collectEvent:FireServer(seed.Name)
				seed:Destroy()
				table.remove(mySeed, i)
				if not soundPlayed then collectsound:Play(); soundPlayed = true end
			end
		end
	end
end)
