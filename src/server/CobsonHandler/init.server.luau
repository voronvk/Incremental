local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- QuickShop: +300% luck por 2 min, stackable
local QUICKSHOP_LUCK_PRODUCT_ID = 3553201276
local LUCK_BOOST_DURATION = 120 -- segundos
local LUCK_BOOST_PER_STACK = 3 -- +300% = 4x por stack (1 + 3)

-- BoostShop (Developer Products)
local MELON_BOOST_15MIN_PRODUCT_ID = 3560570963
local MELON_BOOST_1HOUR_PRODUCT_ID = 3560571041
local EVERYTHING_BOOST_15MIN_PRODUCT_ID = 3560571168
local EVERYTHING_BOOST_1HOUR_PRODUCT_ID = 3560571293

local MELON_BOOST_DURATION_15MIN = 15 * 60
local MELON_BOOST_DURATION_1HOUR = 60 * 60

local function extendBoostEndTime(numberValue, durationSeconds)
	if not numberValue then return end
	local now = os.time()
	local current = numberValue.Value
	if type(current) ~= "number" then
		current = 0
	end
	if current < now then
		numberValue.Value = now + durationSeconds
	else
		-- Extend if already active (sumar duración)
		numberValue.Value = current + durationSeconds
	end
end

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

local function safelyGetBoostEndTime(player, valueName)
	local events = player:FindFirstChild("Events")
	if not events then
		events = Instance.new("Folder")
		events.Name = "Events"
		events.Parent = player
	end

	local v = events:FindFirstChild(valueName)
	if v and v:IsA("NumberValue") then
		return v
	end

	-- Espera corta por si DataStore ya lo creó pero justo después
	for _ = 1, 10 do
		local candidate = events:FindFirstChild(valueName)
		if candidate and candidate:IsA("NumberValue") then
			return candidate
		end
		task.wait(0.1)
	end

	-- Fallback: crear para no perder la compra
	v = Instance.new("NumberValue")
	v.Name = valueName
	v.Value = 0
	v.Parent = events
	return v
end

local function processReceipt(receiptInfo)
	local userId = tonumber(receiptInfo.PlayerId) or receiptInfo.PlayerId
	local purchaseId = receiptInfo.PurchaseId
	local productId = tonumber(receiptInfo.ProductId)

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

	elseif productId == MELON_BOOST_15MIN_PRODUCT_ID then
		local melonEnd = safelyGetBoostEndTime(player, "MelonBoostEndTime")
		if not melonEnd then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		extendBoostEndTime(melonEnd, MELON_BOOST_DURATION_15MIN)
		player:SetAttribute("LastBoostProduct", tostring(productId))
		player:SetAttribute("LastMelonBoostEnd", melonEnd.Value)

	elseif productId == MELON_BOOST_1HOUR_PRODUCT_ID then
		local melonEnd = safelyGetBoostEndTime(player, "MelonBoostEndTime")
		if not melonEnd then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		extendBoostEndTime(melonEnd, MELON_BOOST_DURATION_1HOUR)
		player:SetAttribute("LastBoostProduct", tostring(productId))
		player:SetAttribute("LastMelonBoostEnd", melonEnd.Value)

	elseif productId == EVERYTHING_BOOST_15MIN_PRODUCT_ID then
		local speedEnd = safelyGetBoostEndTime(player, "SpeedBoostEndTime")
		local rebirthEnd = safelyGetBoostEndTime(player, "RebirthBoostEndTime")
		local ascEnd = safelyGetBoostEndTime(player, "AscensionBoostEndTime")
		if not (speedEnd and rebirthEnd and ascEnd) then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		extendBoostEndTime(speedEnd, MELON_BOOST_DURATION_15MIN)
		extendBoostEndTime(rebirthEnd, MELON_BOOST_DURATION_15MIN)
		extendBoostEndTime(ascEnd, MELON_BOOST_DURATION_15MIN)
		player:SetAttribute("LastBoostProduct", tostring(productId))
		player:SetAttribute("LastSpeedBoostEnd", speedEnd.Value)
		player:SetAttribute("LastRebirthBoostEnd", rebirthEnd.Value)
		player:SetAttribute("LastAscensionBoostEnd", ascEnd.Value)

	elseif productId == EVERYTHING_BOOST_1HOUR_PRODUCT_ID then
		local speedEnd = safelyGetBoostEndTime(player, "SpeedBoostEndTime")
		local rebirthEnd = safelyGetBoostEndTime(player, "RebirthBoostEndTime")
		local ascEnd = safelyGetBoostEndTime(player, "AscensionBoostEndTime")
		if not (speedEnd and rebirthEnd and ascEnd) then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		extendBoostEndTime(speedEnd, MELON_BOOST_DURATION_1HOUR)
		extendBoostEndTime(rebirthEnd, MELON_BOOST_DURATION_1HOUR)
		extendBoostEndTime(ascEnd, MELON_BOOST_DURATION_1HOUR)
		player:SetAttribute("LastBoostProduct", tostring(productId))
		player:SetAttribute("LastSpeedBoostEnd", speedEnd.Value)
		player:SetAttribute("LastRebirthBoostEnd", rebirthEnd.Value)
		player:SetAttribute("LastAscensionBoostEnd", ascEnd.Value)

	elseif productId == QUICKSHOP_LUCK_PRODUCT_ID then
		local endTimes = player:GetAttribute("LuckBoostEndTimes")
		if type(endTimes) ~= "table" then
			endTimes = {}
		end
		table.insert(endTimes, os.time() + LUCK_BOOST_DURATION)
		player:SetAttribute("LuckBoostEndTimes", endTimes)

	else
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	pcall(function()
		receiptDataStore:SetAsync(purchaseId, true)
	end)

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.ProcessReceipt = processReceipt

-- Actualizar LuckBoostMultiplier cada frame (limpiar expirados, calcular multiplicador)
RunService.Heartbeat:Connect(function()
	local now = os.time()
	for _, player in ipairs(Players:GetPlayers()) do
		local endTimes = player:GetAttribute("LuckBoostEndTimes")
		if type(endTimes) == "table" and #endTimes > 0 then
			local valid = {}
			for _, et in ipairs(endTimes) do
				if et > now then
					table.insert(valid, et)
				end
			end
			player:SetAttribute("LuckBoostEndTimes", valid)
			local stacks = #valid
			player:SetAttribute("LuckBoostMultiplier", 1 + (stacks * LUCK_BOOST_PER_STACK))
		else
			player:SetAttribute("LuckBoostMultiplier", 1)
		end
	end
end)
