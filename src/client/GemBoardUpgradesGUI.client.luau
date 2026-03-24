--[[
	GemBoardUpgradesGUI - GemBoard1, 2 en un solo script.
	GemBoard0 (productos Robux) sigue en gemboard0GUI.client.luau
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = game.Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local gems = currencies:WaitForChild("Gemeralds")

local folder = workspace:WaitForChild("Upgrades"):WaitForChild("GemUpgrades")
local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://140206660137491"
sound.Parent = SoundService

local function checkMuted()
	sound.Volume = (player:WaitForChild("Settings"):WaitForChild("SfxMuted").Value >= 1) and 0 or 1
end
player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkMuted)
checkMuted()

local GEM_BOARDS = {
	{ board = "GemBoard1", upg = "CornValueUpg3", event = "UpgradeCornValueUpg3Request", eventMax = "UpgradeCornValueUpg3RequestMax" },
	{ board = "GemBoard2", upg = "RebirthValueUpg1", event = "UpgradeRebirthValueUpg1Request", eventMax = "UpgradeRebirthValueUpg1RequestMax" },
}

local MAX_LEVEL = 50

for _, cfg in ipairs(GEM_BOARDS) do
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

	local function getCost(L) return math.floor(10 * (1.5^L)) end

	local function updateLabel()
		local cost = getCost(upg.Value)
		levellabel.Text = "Level: " .. upg.Value .. "/" .. MAX_LEVEL
		if gems.Value >= cost and upg.Value < MAX_LEVEL then
			button.BackgroundColor3 = Color3.new(0,1,0)
			buttonmax.BackgroundColor3 = Color3.new(0,1,0)
		else
			button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
			buttonmax.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
		end
		if upg.Value < MAX_LEVEL then
			effectlabel.Text = (2^upg.Value).."x ➡ "..(2^(upg.Value+1)).."x"
			costlabel.Text = "Cost: " .. Abbreviate(cost) .. " <font color=\"#A656E3\">Crystals</font>"
		else
			effectlabel.Text = (2^upg.Value).."x"
			costlabel.Text = "Cost: Max Level!"
		end
	end
	updateLabel()
	upg:GetPropertyChangedSignal("Value"):Connect(updateLabel)
	gems:GetPropertyChangedSignal("Value"):Connect(updateLabel)

	button.MouseButton1Click:Connect(function() upgradeEvent:FireServer(); sound:Play() end)
	buttonmax.MouseButton1Click:Connect(function() upgradeEventMax:FireServer(); sound:Play() end)
end
