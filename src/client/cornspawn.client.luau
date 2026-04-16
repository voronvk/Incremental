--[[
	CornSpawn - Spawn de maíz local. Clona desde ReplicatedStorage.
	Solo spawnea en FarmPlot (nunca en CloneFolder/Island3).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local player = game.Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local events = player:WaitForChild("Events")
local collectradius = upgrades:WaitForChild("CollectRadiusUpg1")
local spawnRateUpg1 = upgrades:WaitForChild("SpawnRateUpg1")
local spawnRateUpg2 = upgrades:WaitForChild("SpawnRateUpg2")
local cornAmountUpg1 = upgrades:WaitForChild("CornAmountUpg1")
local upgtree8 = upgrades:WaitForChild("UpgTree8")
local upgtree10 = upgrades:WaitForChild("UpgTree10")
local upgtree2_6 = upgrades:WaitForChild("UpgTree2_6")
local upgtree2_13 = upgrades:WaitForChild("UpgTree2_13")
local kernel4 = upgrades:WaitForChild("Kernel4")
local kernel5 = upgrades:WaitForChild("Kernel5")
local tier = upgrades:WaitForChild("Tier")

-- Solo FarmPlot, NUNCA el que está en Island3 (CloneFolder).
local function getSpawnPlot()
	local island3 = workspace:FindFirstChild("Island3")
	-- Hijo directo de workspace primero
	local direct = workspace:FindFirstChild("FarmPlot")
	if direct and (direct:IsA("BasePart") or direct:IsA("Model")) then
		return direct
	end
	for _, desc in ipairs(workspace:GetDescendants()) do
		if desc.Name == "FarmPlot" and (desc:IsA("BasePart") or desc:IsA("Model")) then
			if not island3 or not desc:IsDescendantOf(island3) then
				return desc
			end
		end
	end
	return nil
end
local plot = getSpawnPlot() or workspace:WaitForChild("FarmPlot")
local SpawnHelper = require(ReplicatedStorage.Shared:WaitForChild("SpawnHelper"))
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
local GamePassConfig = require(ReplicatedStorage.Shared:WaitForChild("GamePassConfig"))

-- Templates: clonar desde ReplicatedStorage (añadir nuevos aquí o en la carpeta CornTemplates)
local CORN_TEMPLATES = {
	ReplicatedStorage:WaitForChild("Corn"),
	ReplicatedStorage:WaitForChild("SilverCorn"),
	ReplicatedStorage:WaitForChild("GoldenCorn"),
	ReplicatedStorage:WaitForChild("DiamondCorn"),
	ReplicatedStorage:WaitForChild("RubyCorn"),
}

local collectEvent = ReplicatedStorage:WaitForChild("CollectCornEvent")
local collectEventAuto = ReplicatedStorage:WaitForChild("CollectCornEventAuto")
local clearCornEvent = ReplicatedStorage:WaitForChild("ClearLocalCornEvent")

local myCorn = {}
local spawnInterval = 3
local pickupRange = 2.5

local COLLECT_SOUND_ID = "rbxassetid://140206660137491"
local COLLECT_SOUND_VOLUME = 0.4

-- Salida al recoger (Melons / maíz): sube 1 stud y funde a invisible antes de destruir.
local COLLECT_FLOAT_STUDS = 1
local COLLECT_FLOAT_DURATION = 0.55
local COLLECT_FLOAT_EASING = TweenInfo.new(
	COLLECT_FLOAT_DURATION,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

local function prepPartsCollectVfx(root: Instance): { BasePart }
	local parts: { BasePart } = {}
	for _, d in root:GetDescendants() do
		if d:IsA("BasePart") then
			d.CanCollide = false
			d.CanTouch = false
			d.CanQuery = false
			d.Anchored = true
			table.insert(parts, d)
		end
	end
	return parts
end

local function tweenCollectExitThenDestroy(root: Instance)
	if not root.Parent then
		return
	end

	if root:IsA("BasePart") then
		local p = root
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.Anchored = true
		local startCf = p.CFrame
		local goalCf = startCf + Vector3.new(0, COLLECT_FLOAT_STUDS, 0)
		local tw = TweenService:Create(p, COLLECT_FLOAT_EASING, { CFrame = goalCf, Transparency = 1 })
		tw.Completed:Connect(function()
			if root.Parent then
				root:Destroy()
			end
		end)
		tw:Play()
		return
	end

	if not root:IsA("Model") then
		root:Destroy()
		return
	end

	local model = root :: Model
	local parts = prepPartsCollectVfx(model)
	if #parts == 0 then
		model:Destroy()
		return
	end

	local okPivot, startPivot = pcall(function()
		return model:GetPivot()
	end)
	if not okPivot or typeof(startPivot) ~= "CFrame" then
		model:Destroy()
		return
	end

	local goalPivot = startPivot + Vector3.new(0, COLLECT_FLOAT_STUDS, 0)
	local baseTransparency: { [BasePart]: number } = {}
	for _, p in parts do
		baseTransparency[p] = p.Transparency
	end

	local alpha = Instance.new("NumberValue")
	alpha.Name = "CollectExitAlpha"
	alpha.Value = 0
	alpha.Parent = model

	local conn: RBXScriptConnection? = nil
	conn = alpha.Changed:Connect(function()
		local t = alpha.Value
		pcall(function()
			model:PivotTo(startPivot:Lerp(goalPivot, t))
		end)
		for p, bt in baseTransparency do
			if p.Parent then
				p.Transparency = math.clamp(bt + (1 - bt) * t, 0, 1)
			end
		end
	end)

	local tw = TweenService:Create(alpha, COLLECT_FLOAT_EASING, { Value = 1 })
	tw.Completed:Connect(function()
		if conn then
			conn:Disconnect()
			conn = nil
		end
		if model.Parent then
			model:Destroy()
		end
	end)
	tw:Play()
end

local function isSfxMuted(): boolean
	local settings = player:FindFirstChild("Settings")
	local sfxMuted = settings and settings:FindFirstChild("SfxMuted")
	return sfxMuted ~= nil and sfxMuted.Value >= 1
end

-- Una instancia por recogida: cada clip va al final y se pueden superponer.
local function playCollectSound()
	if isSfxMuted() then
		return
	end
	local sound = Instance.new("Sound")
	sound.SoundId = COLLECT_SOUND_ID
	sound.Volume = COLLECT_SOUND_VOLUME
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

clearCornEvent.OnClientEvent:Connect(function()
	for i = #myCorn, 1, -1 do
		local c = myCorn[i]
		if c then c:Destroy() end
		table.remove(myCorn, i)
	end
end)

local SPAWN_Y_OFFSET = -0.5 -- studs más abajo

-- Posición de spawn (solo FarmPlot)
local function getSpawnPosition()
	if not plot then return nil end
	local pos = SpawnHelper.getRandomSpawnPosition(plot)
	if pos then
		return Vector3.new(pos.X, pos.Y + SPAWN_Y_OFFSET, pos.Z)
	end
	-- Fallback
	local part = plot
	if plot:IsA("Model") and plot.PrimaryPart then
		part = plot.PrimaryPart
	elseif plot:IsA("Model") then
		part = plot:FindFirstChildWhichIsA("BasePart", true)
	end
	if not part or not part:IsA("BasePart") then return nil end
	local size, p = part.Size, part.Position
	local edge = 1
	local x = math.random() * (size.X - 2*edge) - (size.X/2 - edge)
	local z = math.random() * (size.Z - 2*edge) - (size.Z/2 - edge)
	local y = math.random() * 0.5 + 0.75 + SPAWN_Y_OFFSET
	return Vector3.new(p.X + x, p.Y + y, p.Z + z)
end

local function selectCornTemplate()
	local currencies = player:WaitForChild("Currencies")
	local rubySeeds = currencies:WaitForChild("RubySeeds").Value
	local diamondSeeds = currencies:WaitForChild("DiamondSeeds").Value
	local goldenSeeds = currencies:WaitForChild("GoldenSeeds").Value
	local silverSeeds = currencies:WaitForChild("SilverSeeds").Value

	local luckMult = (upgtree2_6.Value == 1) and 2 or 1
	local luckMult2 = 1
	if GamePassCheck.playerOwnsGamePass(player, GamePassConfig.GOLD_CORN_GAMEPASS_ID) then
		luckMult2 = 2
	end
	if GamePassCheck.playerOwnsGamePass(player, GamePassConfig.MELON_X2_GAMEPASS_ID) then
		luckMult2 = luckMult2 * 2
	end
	luckMult2 = luckMult2 * (player:GetAttribute("LuckBoostMultiplier") or 1)

	local rubychance = 1 + rubySeeds * luckMult * luckMult2
	local diamondchance = 10 + diamondSeeds + rubychance * luckMult * luckMult2
	local goldenchance = 150 + goldenSeeds + diamondchance * luckMult * luckMult2
	local silverchance = 750 + silverSeeds + goldenchance * luckMult * luckMult2

	local level = events:WaitForChild("Level")
	if level.Value <= 20 then rubychance = 0; diamondchance = 0 end

	local rand = math.random(1, 10000)
	if rand <= rubychance then return CORN_TEMPLATES[5] -- RubyCorn
	elseif rand <= diamondchance then return CORN_TEMPLATES[4] -- DiamondCorn
	elseif rand <= goldenchance then return CORN_TEMPLATES[3] -- GoldenCorn
	elseif rand <= silverchance then return CORN_TEMPLATES[2] -- SilverCorn
	else return CORN_TEMPLATES[1] end -- Corn
end

-- Spawn loop
task.spawn(function()
	while true do
		local mult = (upgtree8.Value == 1) and 2 or 1
		local mult2 = (tier.Value >= 2) and tier.Value or 1
		local mult3 = kernel5.Value * 0.02 + 1
		local mult4 = kernel4.Value * 0.05 + 1
		local maxCorn = (2 + cornAmountUpg1.Value * 2) * mult * mult3

		if #myCorn < maxCorn then
			local pos = getSpawnPosition()
			if pos then
				local corn = selectCornTemplate():Clone()
				if corn.SetPrimaryPartCFrame then
					corn:SetPrimaryPartCFrame(CFrame.new(pos))
				elseif corn.PrimaryPart then
					corn.PrimaryPart.CFrame = CFrame.new(pos)
				end
				corn.Parent = workspace
				table.insert(myCorn, corn)
			end
		end

		task.wait((spawnInterval - spawnRateUpg1.Value * 0.4) / (1 + spawnRateUpg2.Value * 0.5) / mult2 / mult4)
	end
end)

-- Collect por proximidad
RunService.Heartbeat:Connect(function()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local range = pickupRange + collectradius.Value * 0.5 + 0.1 + upgtree10.Value

	for i = #myCorn, 1, -1 do
		local corn = myCorn[i]
		if corn and corn.PrimaryPart then
			local pXZ = Vector2.new(root.Position.X, root.Position.Z)
			local cXZ = Vector2.new(corn.PrimaryPart.Position.X, corn.PrimaryPart.Position.Z)
			if (pXZ - cXZ).Magnitude <= range then
				collectEvent:FireServer(corn.Name)
				table.remove(myCorn, i)
				playCollectSound()
				tweenCollectExitThenDestroy(corn)
			end
		end
	end
end)

-- Auto collect (UpgTree2_13)
task.spawn(function()
	while true do
		task.wait(1)
		if upgtree2_13.Value >= 1 and #myCorn > 0 then
			local idx = math.random(1, #myCorn)
			local corn = myCorn[idx]
			if corn and corn.PrimaryPart then
				collectEventAuto:FireServer(corn.Name)
				table.remove(myCorn, idx)
				tweenCollectExitThenDestroy(corn)
			end
		end
	end
end)
