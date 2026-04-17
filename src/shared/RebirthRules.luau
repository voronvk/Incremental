-- Dos prestigios independientes (no mezclar monedas ni resets):
-- - UpgradesRebirthBoard: RebirthBoard0 — maíz → moneda **Rebirths**; reset solo maíz/upgrades de maíz (RebirthEvent).
--   No usa el melón del minijuego de tapping (Events.MelonLevel es solo tapping).
-- - PlotRebirthBoard: parcela tapping — melón minijuego nivel mínimo → moneda **TappingRebirths** (+1 fijo por ahora);
--   reset solo taps / melón tapping / upgrades de tienda tapping (PlotRebirthEvent).
return {
	UpgradesRebirthBoard = {
		MinCorn = 1000,
		CornChunkSize = 1000,
	},
	PlotRebirthBoard = {
		MinMelonLevel = 100,
		-- Ganancia fija por prestigio tapping (futuros boosts del juego pueden leer este valor o otra config).
		TappingRebirthGainFixed = 1,
	},
}
