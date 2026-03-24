--[[
	EnergyBoardsGUI - EnergyBoard1, 2, 3 en un solo script.
	Añade entradas a ENERGY_BOARDS para nuevos.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = game.Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local energy = currencies:WaitForChild("Energy")

local folder = workspace:WaitForChild("Upgrades"):WaitForChild("GeneratorUpgrades")
local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://140206660137491"
sound.Parent = SoundService

local function checkMuted()
	sound.Volume = (player:WaitForChild("Settings"):WaitForChild("SfxMuted").Value >= 1) and 0 or 1
end
player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkMuted)
checkMuted()

local ENERGY_BOARDS = {
	{ board = "EnergyBoard1", upg = "CornEnergy", event = "AddEnergy1" },
	{ board = "EnergyBoard2", upg = "RebirthEnergy", event = "AddEnergy2" },
	{ board = "EnergyBoard3", upg = "EnergyEnergy", event = "AddEnergy3" },
}

for _, cfg in ipairs(ENERGY_BOARDS) do
	local upgradePart = folder:WaitForChild(cfg.board)
	local levelPart = upgradePart:WaitForChild("LevelBoard")
	local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
	local levelGui = levelPart:WaitForChild("LevelGUI")
	local button = surfaceGui:WaitForChild("UpgradeButton")
	local effectlabel = surfaceGui:WaitForChild("EffectLabel")
	local levellabel = levelGui:WaitForChild("LevelLabel")

	local upg = upgrades:WaitForChild(cfg.upg)
	local upgradeEvent = ReplicatedStorage:WaitForChild(cfg.event)

	local function updateLabel()
		levellabel.Text = "Energy: " .. Abbreviate(upg.Value)
		button.BackgroundColor3 = (energy.Value >= 1 and upg.Value < 999999999999999) and Color3.new(0,1,0) or Color3.new(0.35, 0.35, 0.35)
		effectlabel.Text = string.format("%.2fx", (upg.Value + 1) ^ (1/5))
	end
	updateLabel()
	upg:GetPropertyChangedSignal("Value"):Connect(updateLabel)
	energy:GetPropertyChangedSignal("Value"):Connect(updateLabel)

	button.MouseButton1Click:Connect(function()
		upgradeEvent:FireServer()
		sound:Play()
	end)
end
