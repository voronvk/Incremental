--[[
	DamageFrame: multiplicador de taps / XP por nivel (máx. 500).
	Early: x2 por nivel un poco más largo y costes más bajos; late: coste y poder con más peso.
]]

local M = {}

M.MAX_LEVEL = 500
M.START_COST = 32
M.COST_MULT = 1.19

-- Tras este exponente en 2^x, el resto crece con porcentaje suave (más barato de calcular y acotado).
M.DOUBLE_STEPS = 28
M.POST_DOUBLE_MULT = 1.012
M.MULT_CAP = 1e12

function M.costForNextLevel(currentLevel)
	if currentLevel >= M.MAX_LEVEL then
		return 0
	end
	return math.max(1, math.floor(M.START_COST * (M.COST_MULT ^ currentLevel)))
end

function M.tapDamageMultiplier(level)
	local L = math.clamp(math.floor(level), 0, M.MAX_LEVEL)
	if L <= M.DOUBLE_STEPS then
		return math.min(2 ^ L, M.MULT_CAP)
	end
	local base = 2 ^ M.DOUBLE_STEPS
	local extra = L - M.DOUBLE_STEPS
	return math.min(base * (M.POST_DOUBLE_MULT ^ extra), M.MULT_CAP)
end

return M
