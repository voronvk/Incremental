-- Reglas distintas: RebirthBoard0 (Upgrades / maíz) vs parcela Tapping (Plot / melón).
-- Ajusta aquí; cliente y servidor leen lo mismo.
return {
	-- Tablero del mundo principal (workspace.Upgrades.RebirthBoard0): rebirth por maíz, sin exigir melón.
	UpgradesRebirthBoard = {
		MinMelonLevel = 0,
		MinCorn = 1000,
		CornChunkSize = 1000,
	},
	-- Parcela Tapping: aquí sí tiene sentido exigir nivel de melón (progresión del tap).
	PlotRebirthBoard = {
		MinMelonLevel = 100,
		MinCorn = 1000,
		CornChunkSize = 1000,
	},
}
