--[[
	UpgradeBoardsGUI - UpgradeBoard1, 2, 3 en un solo script.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = game.Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local corn = currencies:WaitForChild("Corn")

local folder = workspace:WaitForChild("Upgrades")
local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://140206660137491"
sound.Parent = SoundService

local function checkMuted()
	sound.Volume = (player:WaitForChild("Settings"):WaitForChild("SfxMuted").Value >= 1) and 0 or 1
end
player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkMuted)
checkMuted()

local UPGRADE_BOARDS = {
	{ board = "UpgradeBoard1", upg = "SpawnRateUpg1", event = "UpgradeSpawnRateUpg1Request", eventMax = "UpgradeSpawnRateUpg1RequestMax",
		maxLevel = 7, getCost = function(L) return math.floor(5 * (2^L)) end,
		getEffect = function(L,nxt) local c=(30-L*4)/10; return nxt and (string.format("%.1fs ➡ %.1fs", c, (30-(L+1)*4)/10)) or string.format("%.1fs", c) end },
	{ board = "UpgradeBoard2", upg = "CornValueUpg1", event = "UpgradeCornValueUpg1Request", eventMax = "UpgradeCornValueUpg1RequestMax",
		maxLevel = 99, getCost = function(L) return math.floor(2 * (1.4^L)) end,
		getEffect = function(L,nxt) return nxt and ((1+L).." ➡ "..(2+L)) or tostring(1+L) end },
	{ board = "UpgradeBoard3", upg = "CornAmountUpg1", event = "UpgradeCornAmountUpg1Request", eventMax = "UpgradeCornAmountUpg1RequestMax",
		maxLevel = 49, getCost = function(L) return math.floor(3 * (1.4^L)) end,
		getEffect = function(L,nxt) return nxt and ((2+L*2).." ➡ "..(4+L*2)) or tostring(2+L*2) end },
}

for _, cfg in ipairs(UPGRADE_BOARDS) do
	local upgradePart = folder:WaitForChild(cfg.board)
	local levelPart = upgradePart:WaitForChild("LevelBoard")
	local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
	local levelGui = levelPart:WaitForChild("LevelGUI")
	local button = surfaceGui:WaitForChild("UpgradeButton")
	local buttonmax = surfaceGui:WaitForChild("UpgradeMaxButton")
	local costlabel = surfaceGui:WaitForChild("CostLabel")
	local effectlabel = surfaceGui:WaitForChild("EffectLabel")
	local levellabel = levelGui:WaitForChild("LevelLabel")

	local upg = upgrades:WaitForChild(cfg.upg)
	local upgradeEvent = ReplicatedStorage:WaitForChild(cfg.event)
	local upgradeEventMax = ReplicatedStorage:WaitForChild(cfg.eventMax)

	local function updateLabel()
		local cost = cfg.getCost(upg.Value)
		levellabel.Text = "Level: " .. upg.Value .. "/" .. cfg.maxLevel
		if corn.Value >= cost and upg.Value < cfg.maxLevel then
			button.BackgroundColor3 = Color3.new(0,1,0)
			buttonmax.BackgroundColor3 = Color3.new(0,1,0)
		else
			button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
			buttonmax.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
		end
		if upg.Value < cfg.maxLevel then
			effectlabel.Text = cfg.getEffect(upg.Value, true)
			costlabel.Text = "Cost: " .. Abbreviate(cost) .. " <font color=\"#7FFF7F\">Melons</font>"
		else
			effectlabel.Text = cfg.getEffect(upg.Value, false)
			costlabel.Text = "Cost: Max Level!"
		end
	end

	updateLabel()
	upg:GetPropertyChangedSignal("Value"):Connect(updateLabel)
	corn:GetPropertyChangedSignal("Value"):Connect(updateLabel)

	button.MouseButton1Click:Connect(function() upgradeEvent:FireServer(); sound:Play() end)
	buttonmax.MouseButton1Click:Connect(function() upgradeEventMax:FireServer(); sound:Play() end)
end
