--[[
	Puente entre el tap manual del melón y el auto-tap: una sola función onClick (servidor + XP/VFX).
	El auto-tap no mueve al jugador ni busca melones; solo llama performTap() como si hicieras clic.
]]

local M = {}

function M.setTapHandler(fn)
	M._tap = fn
end

function M.performTap()
	local fn = M._tap
	if type(fn) == "function" then
		fn()
	end
end

return M
