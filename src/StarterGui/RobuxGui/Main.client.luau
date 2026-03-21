local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local robuxGui = script.Parent

local ButtonScaleEffect = require(ReplicatedStorage.Shared:WaitForChild("ButtonScaleEffect"))

local QUICKSHOP_PRODUCT_ID = 3553201276

local quickShop = robuxGui:FindFirstChild("QuickShop", true)
if quickShop then
	local img = quickShop:FindFirstChild("ImageLabel")
	ButtonScaleEffect.applyScaleEffect(quickShop, img or quickShop)
	local function prompt()
		MarketplaceService:PromptProductPurchase(player, QUICKSHOP_PRODUCT_ID)
	end
	if quickShop:IsA("GuiButton") then
		quickShop.Activated:Connect(prompt)
	else
		quickShop.MouseButton1Click:Connect(prompt)
	end
end
