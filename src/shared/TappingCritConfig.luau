--[[
	CriticFrame: hasta 25 niveles; sube probabilidad de critico (x5 taps + XP en ese hit).
]]

local M = {}

M.MAX_LEVEL = 25
M.START_COST = 140
M.COST_MULT = 1.078
M.CRIT_MULT = 5
M.CHANCE_PER_LEVEL = 0.016
M.MAX_CRIT_CHANCE = 0.4

function M.costForNextLevel(currentLevel)
	if currentLevel >= M.MAX_LEVEL then
		return 0
	end
	return math.max(1, math.floor(M.START_COST * (M.COST_MULT ^ currentLevel)))
end

function M.critChance(level)
	local L = math.clamp(math.floor(level), 0, M.MAX_LEVEL)
	return math.min(L * M.CHANCE_PER_LEVEL, M.MAX_CRIT_CHANCE)
end

return M
