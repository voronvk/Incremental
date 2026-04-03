--[[
	Autobuy filas del árbol principal (UpgTree1–20): cada fila exige el upgrade UpgTree2_XX
	y opcionalmente UpgTree13. El cliente dispara FireServer("autobuy", source); el servidor
	comprueba gate + índice y sube el nodo sin gastar moneda si hay saldo suficiente.
]]

local rows = {
	{ source = "UpgTree2_19", trees = { 1, 2, 4, 6 }, needsUpgTree13 = false },
	{ source = "UpgTree2_20", trees = { 3, 5, 7 }, needsUpgTree13 = false },
	{ source = "UpgTree2_21", trees = { 9, 11 }, needsUpgTree13 = false },
	{ source = "UpgTree2_22", trees = { 14, 16 }, needsUpgTree13 = true },
	{ source = "UpgTree2_23", trees = { 6, 8, 10 }, needsUpgTree13 = false },
	{ source = "UpgTree2_24", trees = { 12, 13 }, needsUpgTree13 = false },
	{ source = "UpgTree2_25", trees = { 18, 20 }, needsUpgTree13 = true },
	{ source = "UpgTree2_26", trees = { 15, 17, 19 }, needsUpgTree13 = true },
}

local bySource = {}
for _, row in ipairs(rows) do
	bySource[row.source] = row
end

return {
	rows = rows,
	bySource = bySource,
}
