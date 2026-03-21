local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local displayGui = script.Parent

local ButtonScaleEffect = require(ReplicatedStorage.Shared:WaitForChild("ButtonScaleEffect"))
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

-- Currencies
local currencies = player:WaitForChild("Currencies")
local corn = currencies:WaitForChild("Corn")
local rebirths = currencies:WaitForChild("Rebirths")

-- Labels en Frame
local frame = displayGui:FindFirstChild("Frame")
if frame then
	local melonsFrame = frame:FindFirstChild("MelonsFrame")
	local rebirthFrame = frame:FindFirstChild("RebirthFrame")

	local function updateMelonsLabel()
		if melonsFrame then
			local label = melonsFrame:FindFirstChild("TextLabel")
			if label then
				label.Text = Abbreviate(corn.Value)
			end
		end
	end

	local function updateRebirthsLabel()
		if rebirthFrame then
			local label = rebirthFrame:FindFirstChild("TextLabel")
			if label then
				label.Text = Abbreviate(rebirths.Value)
			end
		end
	end

	updateMelonsLabel()
	updateRebirthsLabel()
	corn.Changed:Connect(updateMelonsLabel)
	rebirths.Changed:Connect(updateRebirthsLabel)
end

-- Botones que abren frames con animación Scale in (solo uno abierto a la vez)
local SCALE_TWEEN_TIME = 0.15
local TARGET_SCALE = 1
local tweenInfo = TweenInfo.new(SCALE_TWEEN_TIME, Enum.EasingStyle.Quad)

local buttonToFrame = {
	BoostsButton = "BoostShop",
	QuestsButton = "QuestFrame",
	ShopButton = "Shop",
}

-- Datos de cada frame para poder cerrarlos
local frameData = {}

local function closeFrame(data)
	if not data.isOpen then return end
	data.isOpen = false
	local tween = TweenService:Create(data.uiScale, tweenInfo, { Scale = 0 })
	tween.Completed:Connect(function()
		data.frame.Visible = false
	end)
	tween:Play()
end

local function openFrame(data)
	data.frame.Visible = true
	data.isOpen = true
	TweenService:Create(data.uiScale, tweenInfo, { Scale = TARGET_SCALE }):Play()
end

-- Primero preparar todos los frames
for buttonName, frameName in pairs(buttonToFrame) do
	local targetFrame = displayGui:FindFirstChild(frameName)
	if targetFrame then
		local uiScale = targetFrame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		uiScale.Scale = 0
		uiScale.Parent = targetFrame
		targetFrame.Visible = false
		frameData[frameName] = { frame = targetFrame, uiScale = uiScale, isOpen = false }
	end
end

-- Conectar botones
for buttonName, frameName in pairs(buttonToFrame) do
	local button = displayGui:FindFirstChild(buttonName)
	local data = frameData[frameName]

	if button and data then
		local img = button:FindFirstChild("ImageLabel")
		ButtonScaleEffect.applyScaleEffect(button, img or button)

		local function toggleFrame()
			if data.isOpen then
				closeFrame(data)
			else
				-- Cerrar cualquier otro frame abierto
				for name, other in pairs(frameData) do
					if name ~= frameName then
						closeFrame(other)
					end
				end
				openFrame(data)
			end
		end

		if button:IsA("GuiButton") then
			button.Activated:Connect(toggleFrame)
		else
			button.MouseButton1Click:Connect(toggleFrame)
		end
	end
end

-- Shop: CloseButton y botones de gamepass
local shop = displayGui:FindFirstChild("Shop")
local shopData = frameData["Shop"]

if shop and shopData then
	-- CloseButton cierra la tienda
	local closeButton = shop:FindFirstChild("CloseButton", true)
	if closeButton then
		local img = closeButton:FindFirstChild("ImageLabel")
		ButtonScaleEffect.applyScaleEffect(closeButton, img or closeButton)
		local function connectClose(obj)
			if obj:IsA("GuiButton") then
				obj.Activated:Connect(function() closeFrame(shopData) end)
			else
				obj.MouseButton1Click:Connect(function() closeFrame(shopData) end)
			end
		end
		connectClose(closeButton)
	end

	-- Gamepasses: frame -> gamepass ID
	local gamepassFrames = {
		RebirthMultiplier = 1740115835,
		MelonMultiplier = 1740686732,
		EverythingFrame = 1740820575, -- Pack completo
		WalkSpeedMultiplier = 1740406688,
		AscensionMultiplier = 1740630375,
	}

	local function getBuyLabel(buyButton)
		return buyButton:FindFirstChildOfClass("TextLabel")
			or buyButton:FindFirstChildWhichIsA("TextLabel", true)
	end

	local function updateOwnedLabel(buyButton, gamePassId)
		local label = getBuyLabel(buyButton)
		if not label then
			return
		end
		if GamePassCheck.playerOwnsGamePass(player, gamePassId) then
			label.Text = "Owned"
		end
	end

	local function refreshAllShopOwnedLabels()
		for frameName, gamePassId in pairs(gamepassFrames) do
			local f = shop:FindFirstChild(frameName)
			if f then
				local buyButton = f:FindFirstChildWhichIsA("GuiButton", true)
				if buyButton then
					updateOwnedLabel(buyButton, gamePassId)
				end
			end
		end
	end

	for frameName, gamePassId in pairs(gamepassFrames) do
		local frame = shop:FindFirstChild(frameName)
		if frame then
			local buyButton = frame:FindFirstChildWhichIsA("GuiButton", true)
			if buyButton then
				local img = buyButton:FindFirstChild("ImageLabel")
				ButtonScaleEffect.applyScaleEffect(buyButton, img or buyButton)
				updateOwnedLabel(buyButton, gamePassId)
				buyButton.Activated:Connect(function()
					MarketplaceService:PromptGamePassPurchase(player, gamePassId)
				end)
			end
		end
	end

	-- Tras comprar o al cerrar el prompt (actualiza si ya posee)
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(_, _, wasPurchased)
		if wasPurchased then
			task.defer(refreshAllShopOwnedLabels)
		end
	end)

	-- BuyAll / pack simulado
	player:GetAttributeChangedSignal("SimulatedGamePasses"):Connect(function()
		task.defer(refreshAllShopOwnedLabels)
	end)

	task.defer(refreshAllShopOwnedLabels)
end

-- BoostShop: CloseButton y botones de boost (Developer Products)
local boostShop = displayGui:FindFirstChild("BoostShop")
local boostShopData = frameData["BoostShop"]

-- IDs de productos de boost
local MELON_BOOST_15MIN_PRODUCT_ID = 3560570963
local MELON_BOOST_1HOUR_PRODUCT_ID = 3560571041
local EVERYTHING_BOOST_15MIN_PRODUCT_ID = 3560571168
local EVERYTHING_BOOST_1HOUR_PRODUCT_ID = 3560571293

local function connectButtonWithProduct(button, productId)
	if not button or productId == 0 then
		return
	end
	local img = button:FindFirstChild("ImageLabel")
	ButtonScaleEffect.applyScaleEffect(button, img or button)
	local function prompt()
		MarketplaceService:PromptProductPurchase(player, productId)
	end
	if button:IsA("GuiButton") then
		button.Activated:Connect(prompt)
	else
		button.MouseButton1Click:Connect(prompt)
	end
end

if boostShop and boostShopData then
	-- CloseButton
	local closeButton = boostShop:FindFirstChild("CloseButton", true)
	if closeButton then
		local img = closeButton:FindFirstChild("ImageLabel")
		ButtonScaleEffect.applyScaleEffect(closeButton, img or closeButton)
		if closeButton:IsA("GuiButton") then
			closeButton.Activated:Connect(function() closeFrame(boostShopData) end)
		else
			closeButton.MouseButton1Click:Connect(function() closeFrame(boostShopData) end)
		end
	end

	-- MelonFrame: x2 melones durante 15 min o 1 hora
	local melonFrame = boostShop:FindFirstChild("MelonFrame")
	if melonFrame then
		local btn15 = melonFrame:FindFirstChild("15MinutesButton")
		local btn1h = melonFrame:FindFirstChild("1HourButton")
		connectButtonWithProduct(btn15, MELON_BOOST_15MIN_PRODUCT_ID)
		connectButtonWithProduct(btn1h, MELON_BOOST_1HOUR_PRODUCT_ID)
	end

	-- EverythingFrame (BoostShop): x2 todo excepto melones (Rebirths, Ascension, Speed) durante 15 min o 1 hora
	local everythingFrameBoost = boostShop:FindFirstChild("EverythingFrame")
	if everythingFrameBoost then
		local btn15 = everythingFrameBoost:FindFirstChild("15MinutesButton")
		local btn1h = everythingFrameBoost:FindFirstChild("1HourButton")
		connectButtonWithProduct(btn15, EVERYTHING_BOOST_15MIN_PRODUCT_ID)
		connectButtonWithProduct(btn1h, EVERYTHING_BOOST_1HOUR_PRODUCT_ID)
	end
end

-- QuestFrame: CloseButton y sistema de misiones (Quest1, Quest2, Quest3)
local questFrame = displayGui:FindFirstChild("QuestFrame")
local questFrameData = frameData["QuestFrame"]
local FILL_TWEEN_TIME = 0.25

if questFrame and questFrameData then
	local events = player:WaitForChild("Events")

	local function getQuestName(qType, target)
		if qType == 1 then
			return "Play for " .. target .. " Minutes"
		elseif qType == 2 then
			return "Collect " .. target .. " Melons"
		else
			return "Rebirth " .. target .. " times"
		end
	end

	local function setupQuestUI(questSlot, questFrameChild)
		local questLabel = questFrameChild:FindFirstChild("QuestLabel")
		local questButton = questFrameChild:FindFirstChild("QuestButton")
		local frameFill = questFrameChild:FindFirstChild("FrameFill")
		local fill = frameFill and frameFill:FindFirstChild("Fill")

		local qTypeVal = events:FindFirstChild("Quest" .. questSlot .. "Type")
		local qTargetVal = events:FindFirstChild("Quest" .. questSlot .. "Target")
		local qProgressVal = events:FindFirstChild("Quest" .. questSlot .. "Progress")
		if not (qTypeVal and qTargetVal and qProgressVal) then return end

		local function updateUI()
			local qType = qTypeVal.Value
			local target = qTargetVal.Value
			local progress = qProgressVal.Value
			local isDone = progress >= target

			if questLabel then
				questLabel.Text = getQuestName(qType, target)
			end

			local progressLabel = questButton and (questButton:FindFirstChildOfClass("TextLabel") or questButton:FindFirstChildWhichIsA("TextLabel", true))
			if progressLabel then
				progressLabel.Text = isDone and "Done!" or (progress .. "/" .. target)
			end

			if fill then
				local targetScaleX = (target > 0) and (math.min(progress, target) / target) or 0
				TweenService:Create(fill, TweenInfo.new(FILL_TWEEN_TIME, Enum.EasingStyle.Quad), {
					Size = UDim2.new(targetScaleX, 0, fill.Size.Y.Scale, fill.Size.Y.Offset)
				}):Play()
			end
		end

		updateUI()
		qTypeVal.Changed:Connect(updateUI)
		qTargetVal.Changed:Connect(updateUI)
		qProgressVal.Changed:Connect(updateUI)

		if questButton then
			local img = questButton:FindFirstChild("ImageLabel")
			ButtonScaleEffect.applyScaleEffect(questButton, img or questButton)
		end
	end

	-- CloseButton
	local closeButton = questFrame:FindFirstChild("CloseButton", true)
	if closeButton then
		local img = closeButton:FindFirstChild("ImageLabel")
		ButtonScaleEffect.applyScaleEffect(closeButton, img or closeButton)
		if closeButton:IsA("GuiButton") then
			closeButton.Activated:Connect(function() closeFrame(questFrameData) end)
		else
			closeButton.MouseButton1Click:Connect(function() closeFrame(questFrameData) end)
		end
	end

	-- Quest1, Quest2, Quest3
	for i = 1, 3 do
		local q = questFrame:FindFirstChild("Quest" .. i)
		if q then
			setupQuestUI(i, q)
		end
	end
end
