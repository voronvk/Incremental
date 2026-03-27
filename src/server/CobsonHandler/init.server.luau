local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- LuckShop: +x1 luck multiplier por 15 min, stackable por tiempo
local LUCKSHOP_15MIN_PRODUCT_ID = 3553201276
local LUCK_BOOST_DURATION = 15 * 60

-- LuckShop option B: +1 a TODOS los boosts (Melon/Speed/Rebirth/Ascension) mientras esté activo
local LUCK_ALLBOOST_ADD = 1
local DEBUG_RECEIPTS = true
local function dbgReceipt(...)
	if DEBUG_RECEIPTS then
		warn("[ProcessReceipt]", ...)
	end
end

-- BoostShop (Developer Products)
local MELON_BOOST_15MIN_PRODUCT_ID = 3560570963
local MELON_BOOST_1HOUR_PRODUCT_ID = 3560571041
local EVERYTHING_BOOST_15MIN_PRODUCT_ID = 3560571168
local EVERYTHING_BOOST_1HOUR_PRODUCT_ID = 3560571293
local DOUBLE_QUEST_REWARD_PRODUCT_ID = 3563363605

-- Rotating RobuxGui products
local MELONSHOP_30MIN_PRODUCT_ID = 3564513610 -- x2 melones 30 min (stackea tiempo)
local SPEEDSHOP_30MIN_PRODUCT_ID = 3564513530 -- x1.5 velocidad 30 min (stackea tiempo)

local MELON_BOOST_DURATION_15MIN = 15 * 60
local MELON_BOOST_DURATION_1HOUR = 60 * 60
local BOOST_DURATION_30MIN = 30 * 60
local LUCK_DURATION_15MIN = 15 * 60

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

local function safelyGetBoostMultiplier(player, valueName)
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

	for _ = 1, 10 do
		local candidate = events:FindFirstChild(valueName)
		if candidate and candidate:IsA("NumberValue") then
			return candidate
		end
		task.wait(0.1)
	end

	v = Instance.new("NumberValue")
	v.Name = valueName
	v.Value = 2
	v.Parent = events
	return v
end

local function setBoostMultiplierIfInactive(endTimeValue: NumberValue?, multiplierValue: NumberValue?, newMultiplier: number)
	if not (endTimeValue and multiplierValue) then return end
	local now = os.time()
	if endTimeValue.Value <= now then
		multiplierValue.Value = newMultiplier
	end
end

local function grantQuestRewardBoost(player, timeMultiplier: number)
	local events = player:FindFirstChild("Events")
	if not events then return false end

	local function isQuestDone(i: number)
		local t = events:FindFirstChild("Quest" .. i .. "Target")
		local p = events:FindFirstChild("Quest" .. i .. "Progress")
		return t and p and p.Value >= t.Value
	end

	local claimed = events:FindFirstChild("QuestRewardClaimed")
	if not claimed or claimed.Value ~= 0 then
		return false
	end

	if not (isQuestDone(1) and isQuestDone(2) and isQuestDone(3)) then
		return false
	end

	local boostKeys = { "Melon", "Speed", "Rebirth", "Ascension" }
	local chosen = boostKeys[math.random(1, #boostKeys)]

	local durationMinutes = math.random(15, 30) * math.max(1, (tonumber(timeMultiplier) or 1))
	local durationSeconds = durationMinutes * 60
	local mult = 1.5 + (math.random() * (3 - 1.5))
	-- Redondear a 2 decimales para que el texto se vea estable
	mult = math.floor(mult * 100 + 0.5) / 100

	local endTime = safelyGetBoostEndTime(player, chosen .. "BoostEndTime")
	local multiplier = safelyGetBoostMultiplier(player, chosen .. "BoostMultiplier")
	setBoostMultiplierIfInactive(endTime, multiplier, mult)
	extendBoostEndTime(endTime, durationSeconds)

	claimed.Value = 1
	return true
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
	dbgReceipt("User", userId, "ProductId", productId, "PurchaseId", purchaseId, "Player", player.Name)

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
		local melonMult = safelyGetBoostMultiplier(player, "MelonBoostMultiplier")
		if not melonEnd then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		setBoostMultiplierIfInactive(melonEnd, melonMult, 2)
		extendBoostEndTime(melonEnd, MELON_BOOST_DURATION_15MIN)
		player:SetAttribute("LastBoostProduct", tostring(productId))
		player:SetAttribute("LastMelonBoostEnd", melonEnd.Value)

	elseif productId == MELON_BOOST_1HOUR_PRODUCT_ID then
		local melonEnd = safelyGetBoostEndTime(player, "MelonBoostEndTime")
		local melonMult = safelyGetBoostMultiplier(player, "MelonBoostMultiplier")
		if not melonEnd then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		setBoostMultiplierIfInactive(melonEnd, melonMult, 2)
		extendBoostEndTime(melonEnd, MELON_BOOST_DURATION_1HOUR)
		player:SetAttribute("LastBoostProduct", tostring(productId))
		player:SetAttribute("LastMelonBoostEnd", melonEnd.Value)

	elseif productId == EVERYTHING_BOOST_15MIN_PRODUCT_ID then
		local speedEnd = safelyGetBoostEndTime(player, "SpeedBoostEndTime")
		local rebirthEnd = safelyGetBoostEndTime(player, "RebirthBoostEndTime")
		local ascEnd = safelyGetBoostEndTime(player, "AscensionBoostEndTime")
		local speedMult = safelyGetBoostMultiplier(player, "SpeedBoostMultiplier")
		local rebirthMult = safelyGetBoostMultiplier(player, "RebirthBoostMultiplier")
		local ascMult = safelyGetBoostMultiplier(player, "AscensionBoostMultiplier")
		if not (speedEnd and rebirthEnd and ascEnd) then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		setBoostMultiplierIfInactive(speedEnd, speedMult, 2)
		setBoostMultiplierIfInactive(rebirthEnd, rebirthMult, 2)
		setBoostMultiplierIfInactive(ascEnd, ascMult, 2)
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
		local speedMult = safelyGetBoostMultiplier(player, "SpeedBoostMultiplier")
		local rebirthMult = safelyGetBoostMultiplier(player, "RebirthBoostMultiplier")
		local ascMult = safelyGetBoostMultiplier(player, "AscensionBoostMultiplier")
		if not (speedEnd and rebirthEnd and ascEnd) then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		setBoostMultiplierIfInactive(speedEnd, speedMult, 2)
		setBoostMultiplierIfInactive(rebirthEnd, rebirthMult, 2)
		setBoostMultiplierIfInactive(ascEnd, ascMult, 2)
		extendBoostEndTime(speedEnd, MELON_BOOST_DURATION_1HOUR)
		extendBoostEndTime(rebirthEnd, MELON_BOOST_DURATION_1HOUR)
		extendBoostEndTime(ascEnd, MELON_BOOST_DURATION_1HOUR)
		player:SetAttribute("LastBoostProduct", tostring(productId))
		player:SetAttribute("LastSpeedBoostEnd", speedEnd.Value)
		player:SetAttribute("LastRebirthBoostEnd", rebirthEnd.Value)
		player:SetAttribute("LastAscensionBoostEnd", ascEnd.Value)

	elseif productId == DOUBLE_QUEST_REWARD_PRODUCT_ID then
		local ok = grantQuestRewardBoost(player, 2)
		if not ok then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

	elseif productId == LUCKSHOP_15MIN_PRODUCT_ID then
		dbgReceipt("Grant LuckShop", "player", player.Name)
		-- 1) Luck multiplier usado por spawns (atributo LuckBoostMultiplier vía Heartbeat abajo)
		local luckEnd = safelyGetBoostEndTime(player, "LuckBoostEndTime")
		local luckMult = safelyGetBoostMultiplier(player, "LuckBoostMultiplier")
		-- 2) Boost global que suma +1 a todos los boosts en cálculos (no cambia timers base)
		local allEnd = safelyGetBoostEndTime(player, "LuckAllBoostEndTime")
		local allAdd = safelyGetBoostMultiplier(player, "LuckAllBoostAdd")
		if not (luckEnd and allEnd and allAdd) then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		-- LuckShop: fijo a 2x mientras esté activo; si recompras suma tiempo (no multiplica más)
		setBoostMultiplierIfInactive(luckEnd, luckMult, 2)
		extendBoostEndTime(luckEnd, LUCK_BOOST_DURATION)
		-- Option B: fijo a +1 mientras esté activo; si recompras suma tiempo
		setBoostMultiplierIfInactive(allEnd, allAdd, LUCK_ALLBOOST_ADD)
		extendBoostEndTime(allEnd, LUCK_BOOST_DURATION)

	elseif productId == MELONSHOP_30MIN_PRODUCT_ID then
		local melonEnd = safelyGetBoostEndTime(player, "MelonBoostEndTime")
		local melonMult = safelyGetBoostMultiplier(player, "MelonBoostMultiplier")
		if not melonEnd then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		setBoostMultiplierIfInactive(melonEnd, melonMult, 2)
		extendBoostEndTime(melonEnd, BOOST_DURATION_30MIN)
		player:SetAttribute("LastBoostProduct", tostring(productId))
		player:SetAttribute("LastMelonBoostEnd", melonEnd.Value)

	elseif productId == SPEEDSHOP_30MIN_PRODUCT_ID then
		local speedEnd = safelyGetBoostEndTime(player, "SpeedBoostEndTime")
		local speedMult = safelyGetBoostMultiplier(player, "SpeedBoostMultiplier")
		if not speedEnd then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		setBoostMultiplierIfInactive(speedEnd, speedMult, 1.5)
		extendBoostEndTime(speedEnd, BOOST_DURATION_30MIN)
		player:SetAttribute("LastBoostProduct", tostring(productId))
		player:SetAttribute("LastSpeedBoostEnd", speedEnd.Value)

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
		local events = player:FindFirstChild("Events")
		local endTime = events and events:FindFirstChild("LuckBoostEndTime")
		local multVal = events and events:FindFirstChild("LuckBoostMultiplier")
		if endTime and multVal and endTime:IsA("NumberValue") and multVal:IsA("NumberValue") and endTime.Value > now then
			player:SetAttribute("LuckBoostMultiplier", math.max(1, multVal.Value))
		else
			player:SetAttribute("LuckBoostMultiplier", 1)
		end

		-- Exponer el +1 global como Attribute para clientes (por si lo quieren usar)
		local allEnd = events and events:FindFirstChild("LuckAllBoostEndTime")
		local allAdd = events and events:FindFirstChild("LuckAllBoostAdd")
		if allEnd and allAdd and allEnd:IsA("NumberValue") and allAdd:IsA("NumberValue") and allEnd.Value > now then
			player:SetAttribute("LuckAllBoostAdd", math.max(0, allAdd.Value))
		else
			player:SetAttribute("LuckAllBoostAdd", 0)
		end
	end
end)

