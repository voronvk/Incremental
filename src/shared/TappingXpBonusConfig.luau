--[[
	Upgrade XpFrame (Tapping): XP por tap = 1 + nivel (0..MAX_LEVEL).
	Coste mas alto y curva mas empinada en la segunda mitad.
]]

local M = {}

M.MAX_LEVEL = 100

function M.costForNextLevel(currentLevel)
	if currentLevel >= M.MAX_LEVEL then
		return 0
	end
	local L = currentLevel
	if L < 38 then
		return math.max(1, math.floor(16 * (1.042 ^ L)))
	end
	local pivot = 16 * (1.042 ^ 37)
	return math.max(1, math.floor(pivot * (1.06 ^ (L - 37))))
end

return M
