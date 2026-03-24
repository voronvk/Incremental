local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

local menuGui = script.Parent

local QUICKSHOP_PRODUCT_ID = 3553201276
local ButtonScaleEffect = require(ReplicatedStorage.Shared:WaitForChild("ButtonScaleEffect"))
local UIBlur = require(ReplicatedStorage.Shared:WaitForChild("UIBlur"))

local effectImages = {}
for _, desc in ipairs(menuGui:GetDescendants()) do
	if desc.Name == "EffectImage" and desc:IsA("GuiObject") then
		table.insert(effectImages, desc)
	end
end
if #effectImages > 0 then
	local ROTATION_SPEED = 20 -- grados por segundo
	RunService.RenderStepped:Connect(function(dt)
		for _, effectImage in ipairs(effectImages) do
			if effectImage.Parent then
				effectImage.Rotation = effectImage.Rotation + ROTATION_SPEED * dt
			end
		end
	end)
end

local menuButton = menuGui:FindFirstChild("MenuButton")
local shop = menuGui:FindFirstChild("Shop")
if shop then
	local shopScale = shop:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	shopScale.Scale = 0
	shopScale.Parent = shop
	shop.Visible = false

	local targetScale = 1.2
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad)
	local isOpen = false

	local function closeShop()
		if isOpen then
			UIBlur.endModal()
		end
		isOpen = false
		shopScale.Scale = 0
		shop.Visible = false
	end

	if menuButton then
		menuButton.Activated:Connect(function()
			local wasOpen = isOpen
			isOpen = not isOpen
			if isOpen and not wasOpen then
				UIBlur.beginModal()
			elseif not isOpen and wasOpen then
				UIBlur.endModal()
			end
			shop.Visible = true
			local tween = TweenService:Create(shopScale, tweenInfo, {
				Scale = isOpen and targetScale or 0
			})
			tween.Completed:Connect(function()
				if not isOpen then
					shop.Visible = false
				end
			end)
			tween:Play()
		end)
	end

	-- Esperar a que la GUI esté lista (ExitButton puede cargar después)
	task.defer(function()
		local exitButton = shop:FindFirstChild("ExitButton", true) or shop:WaitForChild("ExitButton", 3)
		if not exitButton then return end

		-- Poner ExitButton por encima del ScrollingFrame para que reciba clicks
		if exitButton:IsA("GuiObject") then
			exitButton.ZIndex = math.max(exitButton.ZIndex, 100)
		end

		local function connectClose(obj)
			if obj:IsA("GuiButton") then
				obj.Activated:Connect(closeShop)
			else
				obj.MouseButton1Click:Connect(closeShop)
			end
		end
		connectClose(exitButton)
		for _, child in ipairs(exitButton:GetDescendants()) do
			if child:IsA("GuiButton") then
				connectClose(child)
			end
		end
		ButtonScaleEffect.applyScaleEffect(exitButton, exitButton)
	end)
end

if menuButton then
	local buttonImage = menuButton:FindFirstChild("ImageLabel")
	if buttonImage then
		ButtonScaleEffect.applyScaleEffect(menuButton, buttonImage)
	end
end

-- QuickShop: comprar developer product directamente
local quickShop = menuGui:FindFirstChild("QuickShop")
if quickShop and quickShop:IsA("GuiButton") then
	ButtonScaleEffect.applyScaleEffect(quickShop, quickShop:FindFirstChild("ImageLabel") or quickShop)
	quickShop.Activated:Connect(function()
		MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, QUICKSHOP_PRODUCT_ID)
	end)
end
