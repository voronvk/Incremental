local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local events = player:WaitForChild("Events")

local Corn = currencies:WaitForChild("Corn")
local rebirths = currencies:WaitForChild("Rebirths")
local energy = currencies:WaitForChild("Energy")
local clicks = currencies:WaitForChild("Clicks")
local playtime = events:WaitForChild("Playtime")
local generators = upgrades:WaitForChild("Generators")
local autoclickers = upgrades:WaitForChild("Autoclickers")
local level = events:WaitForChild("Level")

local upgradeData = {}
local upgradeTree = Workspace:WaitForChild("Island1"):WaitForChild("UpgradeTree")

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))
local UpgradeConfig = require(ReplicatedStorage:WaitForChild("UpgradeConfig"))

local SoundService = game:GetService("SoundService")
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://100841669467007"
local function checkmuted()
	if player:WaitForChild("Settings"):WaitForChild("SfxMuted").Value >= 1 then
		sound.Volume = 0
	else
		sound.Volume = 1
	end
end
sound.Parent = SoundService

local currencyMap = {
	Corn = Corn,
	Rebirths = rebirths,
	Energy = energy,
	Clicks = clicks,
}

for i = 1, 20 do
	local upgName = "UpgTree" .. i
	local upgValue = upgrades:WaitForChild(upgName)
	local upgEvent = ReplicatedStorage:WaitForChild(upgName)

	local baseName = "Upg" .. i

	local upgMainName = "Main"
	local upgMain = upgradeTree:WaitForChild(baseName):WaitForChild(upgMainName)
	local upgGui = upgMain:WaitForChild("UpgradeGUI")
	local upgCost = upgGui:WaitForChild("CostLabel")
	local upgButton = upgMain:WaitForChild("ClickDetector")

	-- For Upg1, skip Wire and WireBorder
	local upgWire = nil
	local upgWireBorder = nil
	if i ~= 1 then
		local upgWireName = "Wire"
		local upgWireBorderName = "WireBorder"
		upgWire = upgradeTree:WaitForChild(baseName):WaitForChild(upgWireName)
		upgWireBorder = upgradeTree:WaitForChild(baseName):WaitForChild(upgWireBorderName)
	end

	upgradeData[i] = {
		Value = upgValue,
		Event = upgEvent,
		Cost = upgCost,
		Button = upgButton,
		Part = upgMain,
		Wire = upgWire,
		WireBorder = upgWireBorder,
	}

	local config = UpgradeConfig[i] or {}
	local cost = config.Cost or 1000000
	local currencyKey = config.Currency or "Corn"
	local currencyName = (currencyKey == "Corn") and "Melon" or currencyKey
	local colorUnbought = config.ColorUnbought or Color3.fromRGB(255, 255, 127)
	local colorBought = config.ColorBought or Color3.fromRGB(153, 153, 76)
	local currency = currencyMap[currencyKey]

	local function updateLabel()
		if upgradeData[i].Value.Value == 0 then
			upgradeData[i].Cost.Text = "Cost: " .. Abbreviate(cost) .. " " .. currencyName
			upgradeData[i].Part.Color = colorUnbought
			if upgradeData[i].Wire then
				upgradeData[i].Wire.Color = colorUnbought
			end
		else
			if i == 2 then
				local currentMult = math.max(math.log(math.max(rebirths.Value + 100, 1), 100), 1)
				upgradeData[i].Cost.Text = "Currently: " .. string.format("%.2f", currentMult) .. "x"
			elseif i == 5 then
				local playtimeMult = math.max(math.log(math.max(playtime.Value + 100, 1), 100), 1)
				upgradeData[i].Cost.Text = "Currently: " .. string.format("%.2f", playtimeMult) .. "x"
			elseif i == 7 then
				local clicksMult = math.max(math.log(math.max(clicks.Value + 100, 1), 100), 1)
				upgradeData[i].Cost.Text = "Currently: " .. string.format("%.2f", clicksMult) .. "x"
			elseif i == 15 then
				local energyMult = autoclickers.Value
				upgradeData[i].Cost.Text = "Currently: " .. string.format("%.0f", energyMult) .. "x"
			elseif i == 16 then
				local clicksMult = generators.Value
				upgradeData[i].Cost.Text = "Currently: " .. string.format("%.0f", clicksMult) .. "x"
			elseif i == 17 then
				local energyMult = level.Value
				upgradeData[i].Cost.Text = "Currently: " .. string.format("%.0f", energyMult) .. "x"
			else
				upgradeData[i].Cost.Text = "Bought!"
			end
			upgradeData[i].Part.Color = colorBought
			if upgradeData[i].Wire then
				upgradeData[i].Wire.Color = colorBought
			end
		end
	end

	updateLabel()
	upgradeData[i].Value:GetPropertyChangedSignal("Value"):Connect(updateLabel)

	if currency then
		currency:GetPropertyChangedSignal("Value"):Connect(updateLabel)
	end

	playtime:GetPropertyChangedSignal("Value"):Connect(updateLabel)

	upgradeData[i].Button.MouseClick:Connect(function()
		if upgradeData[i].Value.Value == 0 then
			local config = UpgradeConfig[i] or {}
			local cost = config.Cost or 1000000
			local currencyKey = config.Currency or "Corn"
			local currency = currencyMap[currencyKey]

			if currency and currency.Value >= cost then
				upgradeData[i].Event:FireServer()
				sound:Play()
			end
		end
	end)

	upgradeData[i].Part.Touched:Connect(function(hit)
		local character = player.Character
		if character and hit:IsDescendantOf(character) then
			if upgradeData[i].Value.Value == 0 then
				local config = UpgradeConfig[i] or {}
				local cost = config.Cost or 1000000
				local currencyKey = config.Currency or "Corn"
				local currency = currencyMap[currencyKey]

				if currency and currency.Value >= cost then
					upgradeData[i].Event:FireServer()
					sound:Play()
				end
			end
		end
	end)

end

player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkmuted)
checkmuted()
