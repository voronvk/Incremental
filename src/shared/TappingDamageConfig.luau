--[[
	DamageFrame: multiplicador de taps / XP (max 100 niveles).
	Antes: 2^L en early => pocos niveles multiplicaban miles de veces y rompian melón/coste.
	Ahora: PER_LEVEL_MULT^L (~+9.8% por nivel) => sube fuerte al final pero no explota al principio.
]]

local M = {}

M.MAX_LEVEL = 100
M.START_COST = 52
M.COST_MULT = 1.033
-- ~2.5x a nivel 10, ~6.5x a nivel 20, ~120x a nivel 50, ~14kx a nivel 100 (vs millones con 2^L).
M.PER_LEVEL_MULT = 1.098
M.MULT_CAP = 1e12

function M.costForNextLevel(currentLevel)
	if currentLevel >= M.MAX_LEVEL then
		return 0
	end
	return math.max(1, math.floor(M.START_COST * (M.COST_MULT ^ currentLevel)))
end

function M.tapDamageMultiplier(level)
	local L = math.clamp(math.floor(level), 0, M.MAX_LEVEL)
	local m = M.PER_LEVEL_MULT ^ L
	if m ~= m or m == math.huge then
		return M.MULT_CAP
	end
	return math.min(m, M.MULT_CAP)
end

return M
