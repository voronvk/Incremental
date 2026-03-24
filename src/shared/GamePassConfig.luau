-- IDs de gamepasses del juego (una fuente de verdad para sync y constantes)
return {
	BUNDLE_GAMEPASS_ID = 1740820575,
	-- Luck (semillas + coherente con tienda)
	LUCK_GAMEPASS_ID = 1740916450,
	-- "Gold" / x2 valor al recolectar maíz (servidor) + x2 suerte spawn maíz (cliente)
	GOLD_CORN_GAMEPASS_ID = 1740516591,
	-- Melon X2: x2 suerte de rareza al spawnear maíz (cliente; apila con Gold)
	MELON_X2_GAMEPASS_ID = 1740686732,
	ASCENSION_GAMEPASS_ID = 1740630375,
	WALKSPEED_GAMEPASS_ID = 1740406688,
	REBIRTH_GAMEPASS_ID = 1740115835,

	-- Todos los pases que el servidor debe comprobar al entrar (incluye bundle aparte en sync)
	GAMEPASS_IDS = {
		1740916450,
		1740686732,
		1740630375,
		1740406688,
		1740115835,
		1740516591,
		1740820575,
	},
}
