--[[
	Upgrade XpFrame (Tapping): XP por tap = 1 + nivel (0..MAX_LEVEL).
	Coste: barato al inicio, curva más suave hasta ~nivel 40, luego sube más rápido (idle incremental).
]]

local M = {}

M.MAX_LEVEL = 100

function M.costForNextLevel(currentLevel)
	if currentLevel >= M.MAX_LEVEL then
		return 0
	end
	local L = currentLevel
	if L < 40 then
		return math.max(1, math.floor(5 * (1.122 ^ L)))
	end
	local pivot = 5 * (1.122 ^ 39)
	return math.max(1, math.floor(pivot * (1.19 ^ (L - 39))))
end

return M
