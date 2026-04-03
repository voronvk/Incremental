--[[
	Nombres de atributos del jugador (cliente). Una sola fuente para no mezclar sistemas.
	AutoHarvest, AutoHarvestGold: recolección en mapa. AutoTap, AutoTapGold: taps en zona Tapping.
]]

return {
	AUTO_HARVEST = "AutoHarvest",
	AUTO_HARVEST_GOLD = "AutoHarvestGold",
	AUTO_TAP = "AutoTap",
	AUTO_TAP_GOLD = "AutoTapGold",
	IN_TAPPING_ZONE = "InTappingZone",
	CLIENT_LOADING_COMPLETE = "ClientLoadingComplete",
	-- Legado (solo migración en AutoHarvest; no usar en lógica nueva)
	LEGACY_AUTO = "Auto",
	LEGACY_AUTO_GOLD = "AutoGold",
}
