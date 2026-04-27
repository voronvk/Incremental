-- Prestigio principal: maíz en mapa → **Rebirths** (RebirthEvent / RebirthBoard0).
-- PlotRebirthBoard (tapping en parcela → TappingRebirths) está desactivado: Enabled = false.
return {
	UpgradesRebirthBoard = {
		MinCorn = 1000,
		CornChunkSize = 1000,
	},
	-- Legacy / desactivado: no registrar PlotRebirthEvent ni bind del tablero de parcela.
	PlotRebirthBoard = {
		Enabled = false,
		MinMelonLevel = 100,
		TappingRebirthGainFixed = 1,
	},
}
