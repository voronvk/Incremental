local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local events = player:WaitForChild("Events")
local donoed = events:WaitForChild("RobuxDonated")

local upgradePart = workspace:WaitForChild("Donations")
local surfaceGui = upgradePart:WaitForChild("SurfaceGui")

local dono1 = surfaceGui:WaitForChild("Dono1")
local dono2 = surfaceGui:WaitForChild("Dono2")
local dono3 = surfaceGui:WaitForChild("Dono3")
local dono4 = surfaceGui:WaitForChild("Dono4")
local dono5 = surfaceGui:WaitForChild("Dono5")
local dono6 = surfaceGui:WaitForChild("Dono6")
local dono7 = surfaceGui:WaitForChild("Dono7")
local dono8 = surfaceGui:WaitForChild("Dono8")

local donoevent1 = ReplicatedStorage:WaitForChild("donoevent1")
local donoevent2 = ReplicatedStorage:WaitForChild("donoevent2")
local donoevent3 = ReplicatedStorage:WaitForChild("donoevent3")
local donoevent4 = ReplicatedStorage:WaitForChild("donoevent4")
local donoevent5 = ReplicatedStorage:WaitForChild("donoevent5")
local donoevent6 = ReplicatedStorage:WaitForChild("donoevent6")
local donoevent7 = ReplicatedStorage:WaitForChild("donoevent7")
local donoevent8 = ReplicatedStorage:WaitForChild("donoevent8")

local RunService = game:GetService("RunService")

local MAX_LEVEL = 50

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

local PRODUCT_ID_1 = 3461636278
local PRODUCT_ID_2 = 3461636401
local PRODUCT_ID_3 = 3461636491
local PRODUCT_ID_4 = 3461636595
local PRODUCT_ID_5 = 3461636718
local PRODUCT_ID_6 = 3461636839
local PRODUCT_ID_7 = 3461636909
local PRODUCT_ID_8 = 3461637009

local MarketplaceService = game:GetService("MarketplaceService")

dono1.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, PRODUCT_ID_1)
end)

dono2.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, PRODUCT_ID_2)
end)

dono3.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, PRODUCT_ID_3)
end)

dono4.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, PRODUCT_ID_4)
end)

dono5.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, PRODUCT_ID_5)
end)

dono6.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, PRODUCT_ID_6)
end)

dono7.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, PRODUCT_ID_7)
end)

dono8.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, PRODUCT_ID_8)
end)
