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

	-- Nombres para anuncios en chat al comprar
	GAMEPASS_DISPLAY_NAMES = {
		[1740820575] = "Everything Bundle",
		[1740916450] = "Luck Gamepass",
		[1740516591] = "Gold Corn Gamepass",
		[1740686732] = "Melon x2 Gamepass",
		[1740630375] = "Ascension Gamepass",
		[1740406688] = "Walk Speed Gamepass",
		[1740115835] = "Rebirth Gamepass",
	},

	-- Developer Products (anuncio global en chat, mismo formato que gamepasses)
	DEVELOPER_PRODUCT_DISPLAY_NAMES = {
		-- BoostShop / RobuxGui
		[3553201276] = "Luck Boost (15 min)",
		[3560570963] = "Melon x2 Boost (15 min)",
		[3560571041] = "Melon x2 Boost (1 hour)",
		[3560571168] = "All Boosts (15 min)",
		[3560571293] = "All Boosts (1 hour)",
		[3563363605] = "Double Quest Reward",
		[3564513610] = "Melon x2 (30 min)",
		[3564513530] = "Speed x1.5 (30 min)",
		[3564690970] = "Exclusive Offer",
		[3564690971] = "Advanced Offer (Rebirth x2, 120 min)",
		-- Gemerald packs
		[3461625487] = "10 Gemeralds",
		[3461625810] = "25 Gemeralds",
		[3461626222] = "100 Gemeralds",
		[3461626520] = "250 Gemeralds",
		[3461627003] = "1000 Gemeralds",
		-- Robux donated
		[3461636278] = "10 Robux Donated",
		[3461636401] = "20 Robux Donated",
		[3461636491] = "50 Robux Donated",
		[3461636595] = "100 Robux Donated",
		[3461636718] = "500 Robux Donated",
		[3461636839] = "1000 Robux Donated",
		[3461636909] = "5000 Robux Donated",
		[3461637009] = "10000 Robux Donated",
		-- Corn packs
		[3461631999] = "1K Corn",
		[3461632217] = "1M Corn",
		[3461632548] = "1B Corn",
		[3461632783] = "1T Corn",
	},
}
