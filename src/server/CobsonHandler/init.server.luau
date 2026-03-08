local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

-- Gemerald product IDs
local GEM_PRODUCT_ID_1 = 3461625487
local GEM_PRODUCT_ID_2 = 3461625810
local GEM_PRODUCT_ID_3 = 3461626222
local GEM_PRODUCT_ID_4 = 3461626520
local GEM_PRODUCT_ID_5 = 3461627003

-- RobuxDonated product IDs
local ROBUX_PRODUCT_ID_1 = 3461636278
local ROBUX_PRODUCT_ID_2 = 3461636401
local ROBUX_PRODUCT_ID_3 = 3461636491
local ROBUX_PRODUCT_ID_4 = 3461636595
local ROBUX_PRODUCT_ID_5 = 3461636718
local ROBUX_PRODUCT_ID_6 = 3461636839
local ROBUX_PRODUCT_ID_7 = 3461636909
local ROBUX_PRODUCT_ID_8 = 3461637009

local CORN_PRODUCT_ID_1 = 3461631999
local CORN_PRODUCT_ID_2 = 3461632217
local CORN_PRODUCT_ID_3 = 3461632548
local CORN_PRODUCT_ID_4 = 3461632783

local gemProductValues = {
	[GEM_PRODUCT_ID_1] = { amount = 10 },
	[GEM_PRODUCT_ID_2] = { amount = 25 },
	[GEM_PRODUCT_ID_3] = { amount = 100 },
	[GEM_PRODUCT_ID_4] = { amount = 250 },
	[GEM_PRODUCT_ID_5] = { amount = 1000 },
}

local robuxProductValues = {
	[ROBUX_PRODUCT_ID_1] = { robux = 10 },
	[ROBUX_PRODUCT_ID_2] = { robux = 20 },
	[ROBUX_PRODUCT_ID_3] = { robux = 50 },
	[ROBUX_PRODUCT_ID_4] = { robux = 100 },
	[ROBUX_PRODUCT_ID_5] = { robux = 500 },
	[ROBUX_PRODUCT_ID_6] = { robux = 1000 },
	[ROBUX_PRODUCT_ID_7] = { robux = 5000 },
	[ROBUX_PRODUCT_ID_8] = { robux = 10000 },
}

local cornProductValues = {
	[CORN_PRODUCT_ID_1] = { amount = 1e3 },
	[CORN_PRODUCT_ID_2] = { amount = 1e6 },
	[CORN_PRODUCT_ID_3] = { amount = 1e9 },
	[CORN_PRODUCT_ID_4] = { amount = 1e12 },
}

local receiptDataStore = DataStoreService:GetDataStore("ProcessedReceipts")

local function safelyGetGemeralds(player)
	for i = 1, 10 do
		local currencies = player:FindFirstChild("Currencies")
		if currencies then
			local gemeralds = currencies:FindFirstChild("Gemeralds")
			if gemeralds then
				return gemeralds
			end
		end
		task.wait(0.5)
	end
	return nil
end

local function safelyGetRobuxDonated(player)
	for i = 1, 10 do
		local events = player:FindFirstChild("Events")
		if not events then
			events = Instance.new("Folder")
			events.Name = "Events"
			events.Parent = player
		end

		local robuxDonated = events:FindFirstChild("RobuxDonated")
		if not robuxDonated then
			robuxDonated = Instance.new("NumberValue")
			robuxDonated.Name = "RobuxDonated"
			robuxDonated.Value = 0
			robuxDonated.Parent = events
		end

		if robuxDonated then
			return robuxDonated
		end

		task.wait(0.5)
	end
	return nil
end

local function safelyGetCorn(player)
	for i = 1, 10 do
		local currencies = player:FindFirstChild("Currencies")
		if currencies then
			local corn = currencies:FindFirstChild("Corn")
			if corn then
				return corn
			end
		end
		task.wait(0.5)
	end
	return nil
end

local function processReceipt(receiptInfo)
	local userId = receiptInfo.PlayerId
	local purchaseId = receiptInfo.PurchaseId
	local productId = receiptInfo.ProductId

	local success, alreadyProcessed = pcall(function()
		return receiptDataStore:GetAsync(purchaseId)
	end)

	if not success then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if alreadyProcessed then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local player = Players:GetPlayerByUserId(userId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if gemProductValues[productId] then
		local gemeralds = safelyGetGemeralds(player)
		if not gemeralds then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		gemeralds.Value += gemProductValues[productId].amount

	elseif robuxProductValues[productId] then
		local robuxDonated = safelyGetRobuxDonated(player)
		if not robuxDonated then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		robuxDonated.Value += robuxProductValues[productId].robux

	elseif cornProductValues[productId] then
		local corn = safelyGetCorn(player)
		if not corn then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		corn.Value += cornProductValues[productId].amount

	else
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	pcall(function()
		receiptDataStore:SetAsync(purchaseId, true)
	end)

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.ProcessReceipt = processReceipt
