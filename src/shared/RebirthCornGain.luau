--[[
	Ganancia de moneda **Rebirths** (mapa / maíz): manual por chunks de maíz o pasivo por maíz total.
	Servidor: rebirth maíz (RebirthEvent), bucle pasivo. Cliente: vista previa RebirthBoard0.
	No aplica al prestigio tapping (TappingRebirths fijo en Rebirth server).
]]

local REBIRTHS_GAMEPASS_ID = 1740115835
local MAX_MANUAL_OR_PASSIVE_GAIN = 1e20
local MAX_SAFE = 1e300

local function isFinite(n: number): boolean
	return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end

local function clampFinite(n: number, fallback: number): number
	if not isFinite(n) then
		return fallback
	end
	return math.clamp(n, -MAX_SAFE, MAX_SAFE)
end

local RebirthCornGain = {}

export type Snapshot = {
	playtime: number,
	rebirthValueUpg1: number,
	upgTree1: number,
	upgTree3: number,
	upgTree5: number,
	upgTree6: number,
	clickBooster: number,
	rebirthEnergy: number,
	tier: number,
	upgTree2_3: number,
	upgTree2_9: number,
	upgTree2_10: number,
	goldTreeP3: number,
	rebirthBoostMult: number,
	ascensionBoostMult: number,
	ownsRebirthGamepass: boolean,
}

local function num(v: Instance?, default: number): number
	if v and v:IsA("ValueBase") then
		return v.Value
	end
	return default
end

local function timedBoostWithLuckAll(
	events: Folder,
	nowUnix: number,
	endTimeName: string,
	multiplierName: string
): number
	local mult = 1
	local tEnd = events:FindFirstChild(endTimeName)
	local tMul = events:FindFirstChild(multiplierName)
	if tEnd and tMul and tEnd.Value > nowUnix then
		mult = math.max(1, tMul.Value)
		local allEnd = events:FindFirstChild("LuckAllBoostEndTime")
		local allAdd = events:FindFirstChild("LuckAllBoostAdd")
		if allEnd and allAdd and allEnd:IsA("NumberValue") and allAdd:IsA("NumberValue") and allEnd.Value > nowUnix then
			mult += math.max(0, allAdd.Value)
		end
	end
	return mult
end

-- Devuelve nil si faltan stats mínimos para la cadena de mults.
function RebirthCornGain.snapshot(player: Player): Snapshot?
	local upgrades = player:FindFirstChild("Upgrades")
	local events = player:FindFirstChild("Events")
	if not upgrades or not events then
		return nil
	end

	local playtime = events:FindFirstChild("Playtime")
	local rebirthValue = upgrades:FindFirstChild("RebirthValueUpg1")
	local upgtree1 = upgrades:FindFirstChild("UpgTree1")
	local upgtree3 = upgrades:FindFirstChild("UpgTree3")
	local upgtree5 = upgrades:FindFirstChild("UpgTree5")
	if not playtime or not rebirthValue or not upgtree1 or not upgtree3 or not upgtree5 then
		return nil
	end

	local upgtree6 = upgrades:FindFirstChild("UpgTree6")
	local clickbooster = upgrades:FindFirstChild("RebirthValueUpg2")
	local rebirthenergy = upgrades:FindFirstChild("RebirthEnergy")
	local tier = upgrades:FindFirstChild("Tier")
	local upgtree2_3 = upgrades:FindFirstChild("UpgTree2_3")
	local upgtree2_9 = upgrades:FindFirstChild("UpgTree2_9")
	local upgtree2_10 = upgrades:FindFirstChild("UpgTree2_10")
	local goldTreeP3 = upgrades:FindFirstChild("GoldTreeP3")

	local now = os.time()
	return {
		playtime = num(playtime, 0),
		rebirthValueUpg1 = num(rebirthValue, 0),
		upgTree1 = num(upgtree1, 0),
		upgTree3 = num(upgtree3, 0),
		upgTree5 = num(upgtree5, 0),
		upgTree6 = num(upgtree6, 0),
		clickBooster = num(clickbooster, 0),
		rebirthEnergy = num(rebirthenergy, 0),
		tier = num(tier, 0),
		upgTree2_3 = num(upgtree2_3, 0),
		upgTree2_9 = num(upgtree2_9, 0),
		upgTree2_10 = num(upgtree2_10, 0),
		goldTreeP3 = num(goldTreeP3, 0),
		rebirthBoostMult = timedBoostWithLuckAll(events, now, "RebirthBoostEndTime", "RebirthBoostMultiplier"),
		ascensionBoostMult = timedBoostWithLuckAll(events, now, "AscensionBoostEndTime", "AscensionBoostMultiplier"),
		ownsRebirthGamepass = player:GetAttribute("OwnsGP_" .. tostring(REBIRTHS_GAMEPASS_ID)) == true,
	}
end

local function multiplierProduct(s: Snapshot): number
	local mult1 = 2 ^ s.rebirthValueUpg1
	local mult2 = (s.upgTree1 == 1) and 2 or 1
	local mult3 = (s.upgTree3 == 1) and 1.5 or 1
	local mult4 = (s.upgTree5 == 1) and math.max(math.log(math.max(s.playtime + 100, 1), 100), 1) or 1
	local mult5 = (s.upgTree6 == 1) and 2 or 1
	local mult6 = 2 ^ s.clickBooster
	local mult7Base = math.max(s.rebirthEnergy + 1, 1e-9)
	local mult7 = mult7Base ^ (1 / 5)
	if not isFinite(mult7) or mult7 <= 0 then
		mult7 = 1
	end
	mult7 = math.clamp(mult7, 1e-9, 1e9)
	local mult8 = (s.tier >= 1) and 2 or 1
	local mult9 = s.ownsRebirthGamepass and 2 or 1
	local mult10 = (s.upgTree2_3 == 1) and 1.1 or 1
	local mult11 = (s.upgTree2_10 == 1) and 1.25 or 1

	return mult1
		* mult2
		* mult3
		* mult4
		* mult5
		* mult6
		* mult7
		* mult8
		* mult9
		* mult10
		* mult11
		* s.rebirthBoostMult
		* s.ascensionBoostMult
end

local function applyGoldAndClamp(raw: number, goldTreeP3: number): number
	local gain = raw
	if goldTreeP3 >= 1 then
		gain *= 2
	end
	if not isFinite(gain) or gain < 0 then
		gain = MAX_MANUAL_OR_PASSIVE_GAIN
	elseif gain > MAX_MANUAL_OR_PASSIVE_GAIN then
		gain = MAX_MANUAL_OR_PASSIVE_GAIN
	end
	gain = clampFinite(gain, 0)
	return math.max(0, math.floor(gain + 0.5))
end

--[[
	chunks = math.floor(corn / CornChunkSize), entero >= 1 para rebirth manual de maíz (o pasivo).
]]
function RebirthCornGain.manualGainRounded(s: Snapshot, chunks: number): number?
	if chunks < 1 then
		return nil
	end
	local raw = chunks * multiplierProduct(s)
	local rounded = applyGoldAndClamp(raw, s.goldTreeP3)
	if chunks >= 1 and rounded < 1 then
		return 1
	end
	return rounded
end

--[[
	Pasivo: (maíz / baseCost) * mults / autogain; autogain 1 o 10 según UpgTree2_9.
]]
function RebirthCornGain.passiveGainRounded(s: Snapshot, cornAmount: number, baseCost: number): number
	if baseCost < 1 or cornAmount < baseCost then
		return 0
	end
	local autogain = (s.upgTree2_9 == 1) and 1 or 10
	local raw = (cornAmount / baseCost) * multiplierProduct(s) / autogain
	return applyGoldAndClamp(raw, s.goldTreeP3)
end

--[[
	Vista previa en cliente: mismos chunks que usa el servidor si corn >= minChunk equiv.
]]
function RebirthCornGain.previewManualGain(player: Player, cornValue: number, chunkSize: number, minCorn: number): number
	if chunkSize < 1 or cornValue < minCorn then
		return 0
	end
	local s = RebirthCornGain.snapshot(player)
	if not s then
		return 0
	end
	local chunks = math.floor(cornValue / chunkSize)
	local g = RebirthCornGain.manualGainRounded(s, chunks)
	return g or 0
end

return RebirthCornGain
