local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local upg = upgrades:WaitForChild("RebirthValueUpg1")
local corn = currencies:WaitForChild("Corn")
local gems = currencies:WaitForChild("Gemeralds")

local upgradefolder = workspace:WaitForChild("Upgrades")
local gemfolder = upgradefolder:WaitForChild("GemUpgrades")
local upgradePart = gemfolder:WaitForChild("GemBoard0")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")

local levelPart = upgradePart:WaitForChild("LevelBoard")
local levelGui = levelPart:WaitForChild("LevelGUI")
local levellabel = levelGui:WaitForChild("LevelLabel")

local gem1 = surfaceGui:WaitForChild("Gem1")
local gem2 = surfaceGui:WaitForChild("Gem2")
local gem3 = surfaceGui:WaitForChild("Gem3")
local gem4 = surfaceGui:WaitForChild("Gem4")
local gem5 = surfaceGui:WaitForChild("Gem5")

local upgradeEvent = ReplicatedStorage:WaitForChild("UpgradeRebirthValueUpg1Request")
local upgradeEventMax = ReplicatedStorage:WaitForChild("UpgradeRebirthValueUpg1RequestMax")

local RunService = game:GetService("RunService")

local MAX_LEVEL = 50

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

local PRODUCT_ID_1 = 3461625487
local PRODUCT_ID_2 = 3461625810
local PRODUCT_ID_3 = 3461626222
local PRODUCT_ID_4 = 3461626520
local PRODUCT_ID_5 = 3461627003

local MarketplaceService = game:GetService("MarketplaceService")

gem1.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, PRODUCT_ID_1)
end)

gem2.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, PRODUCT_ID_2)
end)

gem3.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, PRODUCT_ID_3)
end)

gem4.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, PRODUCT_ID_4)
end)

gem5.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, PRODUCT_ID_5)
end)

local function updateLabel()
	levellabel.Text = "<font color=\"#A656E3\">Crystals:</font> " .. gems.Value
end

updateLabel()
gems:GetPropertyChangedSignal("Value"):Connect(updateLabel)
