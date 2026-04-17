local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Players = game:GetService("Players")
local Random = Random

local RunesConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RunesConfig"))
local GamePassCheck = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GamePassCheck"))
local GamePassConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GamePassConfig"))

local MYTHIC_HUNTER_GAMEPASS_ID = GamePassConfig.RUNE_MYTHIC_HUNTER_GAMEPASS_ID or 1798929641

local rng = Random.new()

-- Cache en memoria para evitar Decode/Encode constantes.
-- Clave: Player -> valor.
local inventoryCache = setmetatable({}, { __mode = "k" })
local multipliersCache = setmetatable({}, { __mode = "k" })

local function safeIsNumber(n)
	return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end

local function decodeInventoryJson(json)
	if type(json) ~= "string" or json == "" then
		return {}
	end
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(json)
	end)
	if not ok or type(decoded) ~= "table" then
		return {}
	end

	-- Asegura que los valores sean numeros.
	local out = {}
	for k, v in pairs(decoded) do
		if type(k) == "string" then
			local n = tonumber(v)
			out[k] = safeIsNumber(n) and n or 0
		end
	end
	return out
end

local function encodeInventoryJson(tbl)
	if type(tbl) ~= "table" then
		tbl = {}
	end
	local ok, json = pcall(function()
		return HttpService:JSONEncode(tbl)
	end)
	return ok and json or "{}"
end

local function ensureRunesStringValue(player)
	local events = player:FindFirstChild("Events")
	if not events then
		return nil
	end
	local v = events:FindFirstChild("RunesInventoryJson")
	if v and v:IsA("StringValue") then
		return v
	end
	v = Instance.new("StringValue")
	v.Name = "RunesInventoryJson"
	v.Value = "{}"
	v.Parent = events
	return v
end

local function computeMultipliers(counts)
	local multMelons = 1
	local multTapping = 1

	for _, runeDef in ipairs(RunesConfig.Runes) do
		local id = runeDef.Id
		local count = counts[id] or 0
		if type(count) == "number" and count > 0 then
			local xBoost = runeDef.XBoost
			if safeIsNumber(xBoost) then
				-- Si no se especifica Affects, asumimos que afecta a ambos ingresos.
				local affects = runeDef.Affects
				local applyMelons = (affects == nil) or (affects[RunesConfig.IncomeKeys.Melons] == true)
				local applyTapping = (affects == nil) or (affects[RunesConfig.IncomeKeys.Tapping] == true)

				if applyMelons then
					multMelons *= (xBoost ^ count)
				end
				if applyTapping then
					multTapping *= (xBoost ^ count)
				end
			end
		end
	end

	return multMelons, multTapping
end

local function ensureLoaded(player)
	if not player or not player:IsA("Player") then
		return
	end
	if inventoryCache[player] and multipliersCache[player] then
		return
	end

	local v = ensureRunesStringValue(player)
	if not v then
		inventoryCache[player] = {}
		multipliersCache[player] = { Melons = 1, Tapping = 1 }
		return
	end

	local counts = decodeInventoryJson(v.Value)
	local multMelons, multTapping = computeMultipliers(counts)

	inventoryCache[player] = counts
	multipliersCache[player] = { Melons = multMelons, Tapping = multTapping }

	-- Atributos para que sea facil multiplicar en otros scripts (ej: TappingTap).
	player:SetAttribute("RunesIncomeMultiplier_Melons", multMelons)
	player:SetAttribute("RunesIncomeMultiplier_Tapping", multTapping)
end

local function getCountsCopy(counts)
	local out = {}
	for k, v in pairs(counts or {}) do
		if type(k) == "string" and type(v) == "number" then
			out[k] = v
		end
	end
	return out
end

local function getWeightedRunesForPlayer(player: Player?, category: string?)
	local weighted = {}
	local total = 0
	local hasMythicHunter = false
	if player and player:IsA("Player") then
		hasMythicHunter = GamePassCheck.playerOwnsGamePass(player, MYTHIC_HUNTER_GAMEPASS_ID)
	end

	local rarestIndex = nil
	local rarestWeight = math.huge
	local highestWeightIndex = nil
	local highestWeight = -math.huge

	for idx, runeDef in ipairs(RunesConfig.Runes) do
		local runeCategory = runeDef.Category
		if category and category ~= "" and runeCategory ~= category then
			continue
		end
		local w = tonumber(runeDef.Chance) or 0
		local entry = {
			runeDef = runeDef,
			weight = math.max(0, w),
		}
		table.insert(weighted, entry)
		if entry.weight > 0 then
			total += entry.weight
		end
		if entry.weight > 0 and entry.weight < rarestWeight then
			rarestWeight = entry.weight
			rarestIndex = idx
		end
		if entry.weight > highestWeight then
			highestWeight = entry.weight
			highestWeightIndex = idx
		end
	end

	-- +1 punto porcentual absoluto para la más rara de la categoría (restando de la más común).
	if hasMythicHunter and rarestIndex and highestWeightIndex then
		weighted[rarestIndex].weight += 1
		if highestWeightIndex ~= rarestIndex and weighted[highestWeightIndex].weight > 0 then
			weighted[highestWeightIndex].weight = math.max(0, weighted[highestWeightIndex].weight - 1)
		end
	end

	return weighted
end

local function pickWeightedRune(player: Player?, category: string?)
	local weighted = getWeightedRunesForPlayer(player, category)
	local total = 0
	for _, entry in ipairs(weighted) do
		if entry.weight > 0 then
			total += entry.weight
		end
	end

	if total <= 0 then
		for _, runeDef in ipairs(RunesConfig.Runes) do
			if not category or category == "" or runeDef.Category == category then
				return runeDef
			end
		end
		return RunesConfig.Runes[1]
	end

	local roll = rng:NextNumber(0, total)
	local acc = 0
	for _, entry in ipairs(weighted) do
		local w = entry.weight
		if w > 0 then
			acc += w
			if roll <= acc then
				return entry.runeDef
			end
		end
	end

	for i = #weighted, 1, -1 do
		local entry = weighted[i]
		if entry and entry.runeDef then
			return entry.runeDef
		end
	end
	return RunesConfig.Runes[#RunesConfig.Runes]
end

local M = {}

function M.getInventorySummary(player)
	ensureLoaded(player)
	local counts = inventoryCache[player] or {}
	local mults = multipliersCache[player] or { Melons = 1, Tapping = 1 }
	return {
		ok = true,
		counts = getCountsCopy(counts),
		multipliers = mults,
	}
end

function M.rollRandomRuneId(player: Player?, category: string?)
	local runeDef = pickWeightedRune(player, category)
	return runeDef and runeDef.Id or nil
end

function M.grantRuneById(player, runeId)
	if not player or not player:IsA("Player") then
		return { ok = false, reason = "bad_player" }
	end
	if type(runeId) ~= "string" or runeId == "" then
		return { ok = false, reason = "bad_runeId" }
	end

	ensureLoaded(player)
	local counts = inventoryCache[player] or {}

	local newCount = (counts[runeId] or 0) + 1
	counts[runeId] = newCount
	inventoryCache[player] = counts

	local v = ensureRunesStringValue(player)
	if v then
		v.Value = encodeInventoryJson(counts)
	end

	local multMelons, multTapping = computeMultipliers(counts)
	multipliersCache[player] = { Melons = multMelons, Tapping = multTapping }

	player:SetAttribute("RunesIncomeMultiplier_Melons", multMelons)
	player:SetAttribute("RunesIncomeMultiplier_Tapping", multTapping)

	return {
		ok = true,
		runeId = runeId,
		newCount = newCount,
		multipliers = { Melons = multMelons, Tapping = multTapping },
	}
end

function M.grantRandomRune(player, category: string?)
	local runeId = M.rollRandomRuneId(player, category)
	if not runeId then
		return { ok = false, reason = "no_runes_defined" }
	end
	return M.grantRuneById(player, runeId)
end

function M.getIncomeMultiplier(player, incomeKey)
	ensureLoaded(player)
	local mults = multipliersCache[player]
	if not mults then
		return 1
	end
	return incomeKey == RunesConfig.IncomeKeys.Tapping and mults.Tapping or mults.Melons
end

return M

