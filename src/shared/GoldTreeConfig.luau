--[[
	GoldTree: P1–P7 bajo Tapping.Plot.GoldTree. Prerrequisitos y datos de UI.
]]

local M = {}

M.LOCKED_RGB = { 25, 25, 25 }

-- coste en Gold, color desbloqueado, texto ventaja, texto coste para labels opcionales
M.NODES = {
	[1] = { cost = 1, r = 51, g = 159, b = 161, benefit = "+3 WalkSpeed", costText = "1 Gold" },
	[2] = { cost = 3, r = 74, g = 255, b = 71, benefit = "X2 MELONS", costText = "3 Gold" },
	[3] = { cost = 3, r = 196, g = 40, b = 28, benefit = "X2 DE REBIRTHS", costText = "3 Gold" },
	[4] = { cost = 9, r = 91, g = 154, b = 76, benefit = "X2 XP LEVEL", costText = "9 Gold" },
	[5] = { cost = 8, r = 204, g = 101, b = 49, benefit = "X2 ASCENSION", costText = "8 Gold" },
	[6] = { cost = 14, r = 255, g = 0, b = 0, benefit = "X2 DE TAP POWER", costText = "14 Gold" },
	[7] = { cost = 39, r = 225, g = 0, b = 255, benefit = "", costText = "39 Gold" },
}

-- Índices de nodos requeridos antes de desbloquear este (vacío = solo P1 implícito donde aplica)
M.PREREQS = {
	[1] = {},
	[2] = { 1 },
	[3] = { 1 },
	[4] = { 3 },
	[5] = { 2 },
	[6] = { 4, 5 },
	[7] = { 6 },
}

function M.upgradeName(index)
	return "GoldTreeP" .. tostring(index)
end

function M.unlockedColor3(index)
	local n = M.NODES[index]
	if not n then
		return Color3.fromRGB(25, 25, 25)
	end
	return Color3.fromRGB(n.r, n.g, n.b)
end

function M.lockedColor3(): Color3
	local c = M.LOCKED_RGB
	return Color3.fromRGB(c[1], c[2], c[3])
end

-- Texto para chat global / toast (mismo estilo que "just bought X")
function M.displayNameForAnnounce(index)
	local n = M.NODES[index]
	if not n then
		return "Gold Tree"
	end
	local base = "Gold Tree P" .. tostring(index)
	if type(n.benefit) == "string" and n.benefit ~= "" then
		return base .. " (" .. n.benefit .. ")"
	end
	return base
end

return M
