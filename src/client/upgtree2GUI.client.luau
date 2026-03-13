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
local ascensions = currencies:WaitForChild("Ascensions")

local upgradeData = {}
local upgradeTree = Workspace:WaitForChild("Island2"):WaitForChild("UpgradeTree")

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))
local UpgradeConfig = require(ReplicatedStorage:WaitForChild("Upgrade2Config"))

local SoundService = game:GetService("SoundService")
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://140206660137491"
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
	Ascensions = ascensions,
}

for i = 1, 29 do
	local upgName = "UpgTree2_" .. i
	local upgValue = upgrades:WaitForChild(upgName)
	local upgEvent = ReplicatedStorage:WaitForChild(upgName)

	local baseName = "Upg" .. i

	local upgMainName = "Main"
	local upgMain = upgradeTree:WaitForChild(baseName):WaitForChild(upgMainName)
	local upgGui = upgMain:WaitForChild("UpgradeGUI")
	local upgCost = upgGui:WaitForChild("CostLabel")
	local upgButton = upgMain:WaitForChild("ClickDetector")

	local upgWires = {}
	local upgWireBorders = {}

	if i ~= 1 then
		if i == 2 or i == 4 or i == 5 or i == 6 or i == 7 or i == 17 or i == 18 or i == 19 or i == 20 or i == 27 then
			for j = 1, 2 do
				table.insert(upgWires, upgradeTree:WaitForChild(baseName):WaitForChild("Wire" .. j))
				table.insert(upgWireBorders, upgradeTree:WaitForChild(baseName):WaitForChild("WireBorder" .. j))
			end
		else
			table.insert(upgWires, upgradeTree:WaitForChild(baseName):WaitForChild("Wire"))
			table.insert(upgWireBorders, upgradeTree:WaitForChild(baseName):WaitForChild("WireBorder"))
		end
	end


	upgradeData[i] = {
		Value = upgValue,
		Event = upgEvent,
		Cost = upgCost,
		Button = upgButton,
		Part = upgMain,
		Wires = upgWires,
		WireBorders = upgWireBorders,
	}


	local config = UpgradeConfig[i] or {}
	local cost = config.Cost or 1000000
	local currencyName = config.Currency or "Corn"
	local colorUnbought = (i == 13) and Color3.fromRGB(255, 58, 58) or (config.ColorUnbought or Color3.fromRGB(255, 255, 127))
	local colorBought = config.ColorBought or Color3.fromRGB(153, 153, 76)
	local currency = currencyMap[currencyName]
	local cosmeticCurrency = currencyName
	if currencyName == "Corn" then
		cosmeticCurrency = "Melons"
	end

	local function updateLabel()
		if i == 1 then return end -- Skip Upgrade 1

		if upgradeData[i].Value.Value == 0 then
			upgradeData[i].Cost.Text = "Cost: " .. Abbreviate(cost) .. " " .. cosmeticCurrency
			upgradeData[i].Part.Color = colorUnbought
			for _, wire in ipairs(upgradeData[i].Wires or {}) do
				wire.Color = colorUnbought
			end
		else
			upgradeData[i].Cost.Text = "Bought!"
			upgradeData[i].Part.Color = colorBought
			for _, wire in ipairs(upgradeData[i].Wires or {}) do
				wire.Color = colorBought
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
			local currencyName = config.Currency or "Corn"
			local currency = currencyMap[currencyName]

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
				local currencyName = config.Currency or "Corn"
				local currency = currencyMap[currencyName]

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
