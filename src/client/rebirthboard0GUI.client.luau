local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local events = player:WaitForChild("Events")
local rebirths = currencies:WaitForChild("Rebirths")
local corn = currencies:WaitForChild("Corn")

local upgradeFolder = workspace:WaitForChild("Upgrades")
local upgradePart = upgradeFolder:WaitForChild("RebirthBoard0")
local levelPart = upgradePart:WaitForChild("LevelBoard")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
local levelGui = levelPart:WaitForChild("LevelGUI")

local button = surfaceGui:WaitForChild("UpgradeButton")
local costLabel = surfaceGui:WaitForChild("CostLabel")
local effectLabel = surfaceGui:WaitForChild("EffectLabel")
local levelLabel = levelGui:WaitForChild("LevelLabel")

local upgradeEvent = ReplicatedStorage:WaitForChild("RebirthEvent")

-- SOUND
local SoundService = game:GetService("SoundService")
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://140206660137491"
sound.Parent = SoundService

local function checkmuted()
	if player:WaitForChild("Settings"):WaitForChild("SfxMuted").Value >= 1 then
		sound.Volume = 0
	else
		sound.Volume = 1
	end
end

-- CONFIG
local RebirthCost = 1000

-- MODULE
local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

-- UPGRADES
local upgTree1 = upgrades:WaitForChild("UpgTree1")
local rebirthValue = upgrades:WaitForChild("RebirthValueUpg1")

-- GAMEPASS
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
local REBIRTHS_GAMEPASS_ID = 1740115835

-- COST FUNCTION
local function getCost(level)
	return math.floor(RebirthCost)
end

-- MAIN UPDATE FUNCTION
local function updateLabel()

	local cost = getCost(rebirths.Value)
	local playtime = events:WaitForChild("Playtime")

	local upgTree1 = upgrades:WaitForChild("UpgTree1")
	local rebirthValue = upgrades:WaitForChild("RebirthValueUpg1")
	local upgTree3 = upgrades:WaitForChild("UpgTree3")
	local upgtree5 = upgrades:WaitForChild("UpgTree5")
	local upgtree6 = upgrades:WaitForChild("UpgTree6")
	local clickbooster = upgrades:WaitForChild("RebirthValueUpg2")
	local rebirthenergy = upgrades:WaitForChild("RebirthEnergy")
	local tier = upgrades:WaitForChild("Tier")
	local upgtree2_3 = upgrades:WaitForChild("UpgTree2_3")

	-- MULTIPLIERS
	local mult1 = 2 ^ rebirthValue.Value
	local mult2 = (upgTree1.Value == 1) and 2 or 1
	local mult3 = (upgTree3.Value == 1) and 1.5 or 1

	local mult4 =
		(upgtree5.Value == 1)
		and math.max(math.log(math.max(playtime.Value + 100, 1), 100), 1)
		or 1

	local mult5 = (upgtree6.Value == 1) and 2 or 1
	local mult6 = 2 ^ clickbooster.Value
	local mult7 = ((rebirthenergy.Value + 1) ^ (1/5))
	local mult8 = (tier.Value >= 1) and 2 or 1

	local mult9 = GamePassCheck.playerOwnsGamePass(player, REBIRTHS_GAMEPASS_ID) and 2 or 1

	local mult10 =
		(upgtree2_3.Value == 1)
		and 0.1
		or 1

	-- BONUS CALCULATION
	local bonus =
		math.floor(
			(corn.Value / RebirthCost)
			* mult1
			* mult2
			* mult3
			* mult4
			* mult5
			* mult6
			* mult7
			* mult8
			* mult9
			* mult10
		)

	-- REDONDEO SOLO PARA EFFECTLABEL
	local rebirthsDisplay = math.floor(rebirths.Value)
	local bonusDisplay = math.floor(bonus)

	effectLabel.Text =
		Abbreviate(rebirthsDisplay)
		.. " (+"
		.. Abbreviate(bonusDisplay)
		.. ")"

	-- LEVEL LABEL SIN CAMBIOS
	levelLabel.Text =
		"Level: "
		.. rebirths.Value

	-- BUTTON COLOR
	if corn.Value >= cost then
		button.BackgroundColor3 =
			Color3.new(0, 1, 0)
	else
		button.BackgroundColor3 =
			Color3.new(0.35, 0.35, 0.35)
	end

end

-- INITIAL UPDATE
updateLabel()

-- CONNECTIONS
rebirths:GetPropertyChangedSignal("Value"):Connect(updateLabel)
corn:GetPropertyChangedSignal("Value"):Connect(updateLabel)
rebirthValue:GetPropertyChangedSignal("Value"):Connect(updateLabel)
upgTree1:GetPropertyChangedSignal("Value"):Connect(updateLabel)

-- CLICK HANDLER
local lastClickTime = 0
local DEBOUNCE_TIME = 5

button.MouseButton1Click:Connect(function()

	local currentTime = tick()

	if currentTime - lastClickTime < DEBOUNCE_TIME then
		return
	end

	lastClickTime = currentTime

	if corn.Value >= RebirthCost then
		upgradeEvent:FireServer()
		sound:Play()
	else
		print("Not enough corn")
	end

end)

-- SOUND SETTINGS
player:WaitForChild("Settings")
	:WaitForChild("SfxMuted")
	:GetPropertyChangedSignal("Value")
	:Connect(checkmuted)

checkmuted()
