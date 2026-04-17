local ReplicatedStorage = game:GetService("ReplicatedStorage")

local fn = ReplicatedStorage:WaitForChild("TappingTapFunction")
local FloodCheck = require(game.ServerScriptService.Server:WaitForChild("RemoteFloodCheck") :: ModuleScript)
local DamageConfig = require(ReplicatedStorage.Shared:WaitForChild("TappingDamageConfig"))
local CritConfig = require(ReplicatedStorage.Shared:WaitForChild("TappingCritConfig"))
local GamePassConfig = require(ReplicatedStorage.Shared:WaitForChild("GamePassConfig"))
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))

local MIN_LEVEL = 15

local rng = Random.new()

fn.OnServerInvoke = function(player)
	if not FloodCheck:Check(player, fn, 25) then
		return { ok = false }
	end

	local events = player:FindFirstChild("Events")
	local leaderstats = player:FindFirstChild("leaderstats")
	if not events or not leaderstats then
		return { ok = false }
	end

	local level = events:FindFirstChild("Level")
	local tapsStat = leaderstats:FindFirstChild("Taps")
	local xpBonus = events:FindFirstChild("TappingXpBonus")
	local damageLv = events:FindFirstChild("TappingDamageLevel")
	local critLv = events:FindFirstChild("TappingCritLevel")

	if not level or not tapsStat or not tapsStat:IsA("NumberValue") then
		return { ok = false }
	end
	if not xpBonus or not xpBonus:IsA("NumberValue") then
		return { ok = false }
	end
	if not damageLv or not damageLv:IsA("NumberValue") then
		return { ok = false }
	end
	if not critLv or not critLv:IsA("NumberValue") then
		return { ok = false }
	end

	if level.Value < MIN_LEVEL then
		return { ok = false }
	end

	local upgrades = player:FindFirstChild("Upgrades")

	local dmgMult = DamageConfig.tapDamageMultiplier(damageLv.Value)
	local critChance = CritConfig.critChance(critLv.Value)
	local isCrit = rng:NextNumber() < critChance

	local critMult = 1
	if isCrit then
		critMult = CritConfig.CRIT_MULT
	end

	local tapsAdded = math.max(1, math.floor(dmgMult * critMult))
	local xpBase = 1 + xpBonus.Value
	local xpGain = math.max(1, math.floor(xpBase * dmgMult * critMult))

	if upgrades then
		local p6 = upgrades:FindFirstChild("GoldTreeP6")
		if p6 and p6.Value >= 1 then
			tapsAdded = math.max(1, math.floor(tapsAdded * 2))
		end
		local p4 = upgrades:FindFirstChild("GoldTreeP4")
		if p4 and p4.Value >= 1 then
			xpGain = math.max(1, math.floor(xpGain * 2))
		end
	end

	-- Gamepasses de tapping (Shop)
	if GamePassCheck.playerOwnsGamePass(player, GamePassConfig.TAPPING_DOUBLE_DAMAGE_GAMEPASS_ID) then
		tapsAdded = math.max(1, math.floor(tapsAdded * 2))
	end
	if GamePassCheck.playerOwnsGamePass(player, GamePassConfig.TAPPING_DOUBLE_XP_GAMEPASS_ID) then
		xpGain = math.max(1, math.floor(xpGain * 2))
	end
	if GamePassCheck.playerOwnsGamePass(player, GamePassConfig.TAPPING_DOUBLE_CLICK_GAMEPASS_ID) then
		tapsAdded = math.max(1, math.floor(tapsAdded * 2))
	end
	if GamePassCheck.playerOwnsGamePass(player, GamePassConfig.TAPPING_MULTIPLE_CLICK_GAMEPASS_ID) then
		tapsAdded = math.max(1, math.floor(tapsAdded * 5))
	end

	-- Runes: multiplican los ingresos del minijuego de tapping:
	-- - tapsAdded => "Tapping"
	-- - xpGain => "Melons" (progreso de melon)
	local runeMultTapping = player:GetAttribute("RunesIncomeMultiplier_Tapping")
	if type(runeMultTapping) ~= "number" or runeMultTapping <= 0 then
		runeMultTapping = 1
	end
	local runeMultMelons = player:GetAttribute("RunesIncomeMultiplier_Melons")
	if type(runeMultMelons) ~= "number" or runeMultMelons <= 0 then
		runeMultMelons = 1
	end

	tapsAdded = math.max(1, math.floor(tapsAdded * runeMultTapping))
	xpGain = math.max(1, math.floor(xpGain * runeMultMelons))

	tapsStat.Value += tapsAdded

	return {
		ok = true,
		tapsAdded = tapsAdded,
		crit = isCrit,
		xpGain = xpGain,
	}
end
