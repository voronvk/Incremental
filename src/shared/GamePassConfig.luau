-- IDs de gamepasses del juego (una fuente de verdad para sync y constantes)
return {
	--[[
		En Studio, UserOwnsGamePassAsync suele dar falsos positivos (cuenta del creador o juego de grupo):
		apareces como dueño de todos los pases. Con true: no se consulta el marketplace al entrar ni como
		respaldo en GamePassCheck; solo cuentan OwnsGP_* (sync tras compra simulada, remotes de test, etc.).
		En el juego publicado (no Studio) siempre se usa el marketplace con normalidad.
	]]
	STUDIO_DISABLE_GAMEPASS_MARKETPLACE_LOOKUP = true,
	-- Pack "Everything": solo desbloquea Melon x2, Ascension, WalkSpeed y Rebirth (no Luck, Gold Corn, AutoTap, etc.)
	BUNDLE_GAMEPASS_ID = 1740820575,
	-- Pack "All Tapping": los 4 pases de tapping de la tienda
	TAPPING_BUNDLE_GAMEPASS_ID = 1783041277,

	-- Luck (semillas + coherente con tienda)
	LUCK_GAMEPASS_ID = 1740916450,
	-- "Gold" / x2 valor al recolectar maíz (servidor) + x2 suerte spawn maíz (cliente)
	GOLD_CORN_GAMEPASS_ID = 1740516591,
	-- Melon X2: x2 suerte de rareza al spawnear maíz (cliente; apila con Gold)
	MELON_X2_GAMEPASS_ID = 1740686732,
	ASCENSION_GAMEPASS_ID = 1740630375,
	WALKSPEED_GAMEPASS_ID = 1740406688,
	REBIRTH_GAMEPASS_ID = 1740115835,
	-- Auto-tap (zona Tapping): Basic vía pase o DailyRewards; Premium (rápido) con este pase
	AUTOTAP_GAMEPASS_ID = 1783419072,

	-- Tapping (tienda Shop.ScrollingFrame): daño melon, XP melon, taps x2, taps x5
	TAPPING_DOUBLE_DAMAGE_GAMEPASS_ID = 1784531875, -- DoubleTapFrame
	TAPPING_DOUBLE_XP_GAMEPASS_ID = 1784046519, -- DoubleXPFrame
	TAPPING_DOUBLE_CLICK_GAMEPASS_ID = 1784222314, -- DoubleClick
	TAPPING_MULTIPLE_CLICK_GAMEPASS_ID = 1784068395, -- MultipleClick

	-- Boost Pack: Melon + Speed + Rebirth + Ascension durante 1 h (servidor; una vez por sesión + al comprar)
	BOOST_PACK_GAMEPASS_ID = 1783936373,
	-- Better Luck: reservado (sin efecto de gameplay aún); sync + tienda
	BETTER_LUCK_GAMEPASS_ID = 1783996506,

	-- IDs que concede el bundle Everything (además del propio bundle)
	BUNDLE_EVERYTHING_GRANT_IDS = {
		1740686732, -- MELON_X2
		1740630375, -- ASCENSION
		1740406688, -- WALKSPEED
		1740115835, -- REBIRTH
	},

	-- IDs que concede el bundle All Tapping
	BUNDLE_TAPPING_GRANT_IDS = {
		1784531875,
		1784046519,
		1784222314,
		1784068395,
	},

	-- Todos los pases que el servidor comprueba al entrar (individuales + bundles)
	GAMEPASS_IDS = {
		1740916450,
		1740686732,
		1740630375,
		1740406688,
		1740115835,
		1740516591,
		1740820575,
		1783419072,
		1783041277,
		1784531875,
		1784046519,
		1784222314,
		1784068395,
		1783936373,
		1783996506,
	},

	GAMEPASS_DISPLAY_NAMES = {
		[1740820575] = "Everything Bundle",
		[1783041277] = "All Tapping Bundle",
		[1740916450] = "Luck Gamepass",
		[1740516591] = "Gold Corn Gamepass",
		[1740686732] = "Melon x2 Gamepass",
		[1740630375] = "Ascension Gamepass",
		[1740406688] = "Walk Speed Gamepass",
		[1740115835] = "Rebirth Gamepass",
		[1783419072] = "Auto Tap Gamepass",
		[1784531875] = "Double Tap Damage",
		[1784046519] = "Double Melon XP",
		[1784222314] = "Double Clicks",
		[1784068395] = "Multiple Clicks",
		[1783936373] = "Boost Pack",
		[1783996506] = "Better Luck",
	},

	DEVELOPER_PRODUCT_DISPLAY_NAMES = {
		[3553201276] = "Luck Boost (15 min)",
		[3560570963] = "Melon x2 Boost (15 min)",
		[3560571041] = "Melon x2 Boost (1 hour)",
		[3560571168] = "All Boosts (15 min)",
		[3560571293] = "All Boosts (1 hour)",
		[3563363605] = "Double Quest Reward",
		[3564513610] = "Melon x2 (30 min)",
		[3564513530] = "Speed x1.5 (30 min)",
		[3564690970] = "Exclusive Offer",
		[3567514993] = "Advanced Offer (Rebirth x2, 120 min)",
		[3569324327] = "Skip All Daily Rewards",
		[3461625487] = "10 Gemeralds",
		[3461625810] = "25 Gemeralds",
		[3461626222] = "100 Gemeralds",
		[3461626520] = "250 Gemeralds",
		[3461627003] = "1000 Gemeralds",
		[3461636278] = "10 Robux Donated",
		[3461636401] = "20 Robux Donated",
		[3461636491] = "50 Robux Donated",
		[3461636595] = "100 Robux Donated",
		[3461636718] = "500 Robux Donated",
		[3461636839] = "1000 Robux Donated",
		[3461636909] = "5000 Robux Donated",
		[3461637009] = "10000 Robux Donated",
		[3461631999] = "1K Corn",
		[3461632217] = "1M Corn",
		[3461632548] = "1B Corn",
		[3461632783] = "1T Corn",
		[3569370365] = "5 Gold",
		[3569372988] = "10 Gold",
		[3569373149] = "20 Gold",
		[3569373371] = "50 Gold",
	},
}
