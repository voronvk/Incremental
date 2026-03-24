--[[
	ClickBoardUpgradesGUI - ClickBoard1, 2, 3 en un solo script.
	ClickBoard0 (click principal) sigue en Clickboard0GUI.client.luau
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = game.Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local clicks = currencies:WaitForChild("Clicks")
local tier = upgrades:WaitForChild("Tier")

local folder = workspace:WaitForChild("Upgrades"):WaitForChild("ClickUpgrades")
local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://140206660137491"
sound.Parent = SoundService

local function checkMuted()
	sound.Volume = (player:WaitForChild("Settings"):WaitForChild("SfxMuted").Value >= 1) and 0 or 1
end
player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkMuted)
checkMuted()

local CLICK_BOARDS = {
	{ board = "ClickBoard1", upg = "CornValueUpg4", event = "UpgradeCornValueUpg4Request", eventMax = "UpgradeCornValueUpg4RequestMax",
		getCost = function(L) local s = (tier.Value >= 1) and 25 or 1; return math.floor(100 * (5^L) * s) end,
		getEffect = function(L) return 2^L end },
	{ board = "ClickBoard2", upg = "RebirthValueUpg2", event = "UpgradeRebirthValueUpg2Request", eventMax = "UpgradeRebirthValueUpg2RequestMax",
		getCost = function(L) local s = (tier.Value >= 1) and 25 or 1; return math.floor(100 * (5^L) * s) end,
		getEffect = function(L) return 2^L end },
	{ board = "ClickBoard3", upg = "Autoclickers", event = "UpgradeAutoclickersRequest", eventMax = "UpgradeAutoclickersRequestMax",
		getCost = function(L) local s = (tier.Value >= 1) and 25 or 1; return math.floor(10 * (10^L) * s) end,
		getEffect = function(L) return L .. "/s" end },
}

local MAX_LEVEL = 10

for _, cfg in ipairs(CLICK_BOARDS) do
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
		levellabel.Text = "Level: " .. upg.Value .. "/" .. MAX_LEVEL
		if clicks.Value >= cost and upg.Value < MAX_LEVEL then
			button.BackgroundColor3 = Color3.new(0,1,0)
			buttonmax.BackgroundColor3 = Color3.new(0,1,0)
		else
			button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
			buttonmax.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
		end
		if upg.Value < MAX_LEVEL then
			effectlabel.Text = cfg.getEffect(upg.Value) .. " ➡ " .. cfg.getEffect(upg.Value + 1)
			costlabel.Text = "Cost: " .. Abbreviate(cost) .. " Clicks"
		else
			effectlabel.Text = cfg.getEffect(upg.Value)
			costlabel.Text = "Cost: Max Level!"
		end
	end
	updateLabel()
	upg:GetPropertyChangedSignal("Value"):Connect(updateLabel)
	clicks:GetPropertyChangedSignal("Value"):Connect(updateLabel)
	tier:GetPropertyChangedSignal("Value"):Connect(updateLabel)

	button.MouseButton1Click:Connect(function() upgradeEvent:FireServer(); sound:Play() end)
	buttonmax.MouseButton1Click:Connect(function() upgradeEventMax:FireServer(); sound:Play() end)
end
