--[[
	RebirthBoardUpgradesGUI - RebirthBoard1, 2, 3 en un solo script.
	RebirthBoard0 (acción Rebirth) sigue en rebirthboard0GUI.client.luau
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = game.Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local rebirths = currencies:WaitForChild("Rebirths")

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

local REBIRTH_BOARDS = {
	{ board = "RebirthBoard1", upg = "CornValueUpg2", event = "UpgradeCornValueUpg2Request", eventMax = "UpgradeCornValueUpg2RequestMax",
		maxLevel = 6, getCost = function(L) return math.floor(4^L) end,
		getEffect = function(L,nxt) return (2^L).."x" .. (nxt and (" ➡ "..(2^(L+1)).."x") or "") end },
	{ board = "RebirthBoard2", upg = "CollectRadiusUpg1", event = "UpgradeCollectRadiusUpg1Request", eventMax = "UpgradeCollectRadiusUpg1RequestMax",
		maxLevel = 5, getCost = function(L) return math.floor(2^(L+1)) end,
		getEffect = function(L,nxt) local c=2.5+L*0.5; return nxt and (c.." ➡ "..(3+L*0.5)) or tostring(c) end },
	{ board = "RebirthBoard3", upg = "SpawnRateUpg2", event = "UpgradeSpawnRateUpg2Request", eventMax = "UpgradeSpawnRateUpg2RequestMax",
		maxLevel = 8, getCost = function(L) return math.floor(3*(2^L)) end,
		getEffect = function(L,nxt) local c=1+L*0.5; return nxt and (c.."x ➡ "..(1.5+L*0.5).."x") or (c.."x") end },
}

for _, cfg in ipairs(REBIRTH_BOARDS) do
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
		if rebirths.Value >= cost and upg.Value < cfg.maxLevel then
			button.BackgroundColor3 = Color3.new(0,1,0)
			buttonmax.BackgroundColor3 = Color3.new(0,1,0)
		else
			button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
			buttonmax.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
		end
		if upg.Value < cfg.maxLevel then
			effectlabel.Text = cfg.getEffect(upg.Value, true)
			costlabel.Text = "Cost: " .. Abbreviate(cost) .. " <font color=\"#AAAAFF\">Rebirths</font>"
		else
			effectlabel.Text = cfg.getEffect(upg.Value, false)
			costlabel.Text = "Cost: Max Level!"
		end
	end
	updateLabel()
	upg:GetPropertyChangedSignal("Value"):Connect(updateLabel)
	rebirths:GetPropertyChangedSignal("Value"):Connect(updateLabel)

	button.MouseButton1Click:Connect(function() upgradeEvent:FireServer(); sound:Play() end)
	buttonmax.MouseButton1Click:Connect(function() upgradeEventMax:FireServer(); sound:Play() end)
end
