-- Progresión del melon (tapping): misma fórmula en cliente y servidor para validar / guardar XP.
-- Curva más exigente: bastante más XP total hasta nivel 100.
local M = {
	MAX_LEVEL = 100,
	SCALE_PER_LEVEL = 0.05,
	XP_GOAL_START = 34,
	XP_GOAL_MULT = 1.051,
}

function M.goalXpForLevel(level: number): number
	local L = math.clamp(math.floor(level + 0.5), 1, M.MAX_LEVEL)
	if L >= M.MAX_LEVEL then
		return math.max(
			1,
			math.floor(M.XP_GOAL_START * (M.XP_GOAL_MULT ^ (M.MAX_LEVEL - 2)))
		)
	end
	return math.max(1, math.floor(M.XP_GOAL_START * (M.XP_GOAL_MULT ^ (L - 1))))
end

-- Lleva (level, xp) a forma canónica (xp < meta del nivel, o nivel MAX con xp 0)
function M.normalizeLevelXp(level: number, xp: number): (number, number)
	local L = math.clamp(math.floor(level + 0.5), 1, M.MAX_LEVEL)
	local x = xp
	if type(x) ~= "number" or x ~= x then
		x = 0
	end
	x = math.max(0, x)
	while L < M.MAX_LEVEL do
		local g = M.goalXpForLevel(L)
		if x < g - 1e-6 then
			break
		end
		x -= g
		L += 1
	end
	if L >= M.MAX_LEVEL then
		return M.MAX_LEVEL, 0
	end
	local gFinal = M.goalXpForLevel(L)
	if x > gFinal then
		x = gFinal
	end
	return L, x
end

return M
