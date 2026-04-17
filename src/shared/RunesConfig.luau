-- RunesConfig: definicion data-driven de todas las runas.
-- Cuando me pases tu lista real (Id, Chance, X Boost, etc.), solo hay que reemplazar este contenido.

local RunesConfig = {}

-- IMPORTANT: sistema desactivado por defecto.
-- Cuando quieras activarlo, ponlo en true.
RunesConfig.Enabled = false

-- Como se apilan los boosts cuando el jugador tiene N copias:
-- - "multiplicative": multiplier = (XBoost ^ count) por cada rune (y luego multiplicas todas)
RunesConfig.StackMode = "multiplicative"

-- Convencion de "ingresos" que el sistema va a multiplicar:
RunesConfig.IncomeKeys = {
	-- Multiplicador para el XP de melon que gana el tapping (se convierte en Melon progreso).
	Melons = "Melons",
	-- Multiplicador para los taps que suma el minijuego de tapping.
	Tapping = "Tapping",
}

RunesConfig.Categories = {
	BasicRune = "BasicRune",
	GoldRune = "GoldRune",
}

-- Lista de runas.
-- NOTA: "Chance" se usa como peso (weighted chance). Si tus valores son porcentajes, tambien funciona
-- igual de bien (solo cambian las proporciones).
RunesConfig.Runes = {
	-- BasicRune
	{
		Id = "CommonRune",
		Category = RunesConfig.Categories.BasicRune,
		DisplayName = "Common Rune",
		Chance = 65,
		ImageId = "rbxassetid://78868552600621",
		-- Interpretacion: XBoost es multiplicador por copia.
		-- Ej: XBoost=1.001 y count=1000 => 1.001 ^ 1000
		XBoost = 1.001,
		Affects = {
			[RunesConfig.IncomeKeys.Melons] = true,
			[RunesConfig.IncomeKeys.Tapping] = false,
		},
	},
	{
		Id = "UncommonRune",
		Category = RunesConfig.Categories.BasicRune,
		DisplayName = "Uncommon Rune",
		Chance = 30,
		ImageId = "rbxassetid://82273294738836",
		XBoost = 1.005,
		Affects = {
			[RunesConfig.IncomeKeys.Melons] = true,
			[RunesConfig.IncomeKeys.Tapping] = false,
		},
	},
	{
		Id = "EpicRune",
		Category = RunesConfig.Categories.BasicRune,
		DisplayName = "Epic Rune",
		Chance = 4,
		ImageId = "rbxassetid://119763620401713",
		XBoost = 1.015,
		Affects = {
			[RunesConfig.IncomeKeys.Melons] = true,
			[RunesConfig.IncomeKeys.Tapping] = false,
		},
	},
	{
		Id = "LegendaryRune",
		Category = RunesConfig.Categories.BasicRune,
		DisplayName = "Legendary Rune",
		Chance = 1,
		ImageId = "rbxassetid://76653304818461",
		XBoost = 1.05,
		Affects = {
			[RunesConfig.IncomeKeys.Melons] = true,
			[RunesConfig.IncomeKeys.Tapping] = false,
		},
	},
	{
		Id = "DivineRune",
		Category = RunesConfig.Categories.BasicRune,
		DisplayName = "Divine Rune",
		Chance = 0.01,
		ImageId = "rbxassetid://89893307831301",
		XBoost = 2,
		Affects = {
			[RunesConfig.IncomeKeys.Melons] = true,
			[RunesConfig.IncomeKeys.Tapping] = false,
		},
	},
	-- GoldRune
	{
		Id = "CommonGoldyRune",
		Category = RunesConfig.Categories.GoldRune,
		DisplayName = "Common Goldy",
		Chance = 75,
		ImageId = "rbxassetid://121505167765042",
		XBoost = 1.25,
		Affects = {
			[RunesConfig.IncomeKeys.Melons] = true,
			[RunesConfig.IncomeKeys.Tapping] = false,
		},
	},
	{
		Id = "EpicGoldyRune",
		Category = RunesConfig.Categories.GoldRune,
		DisplayName = "Epic Goldy",
		Chance = 24,
		ImageId = "rbxassetid://92267659470793",
		XBoost = 1.75,
		Affects = {
			[RunesConfig.IncomeKeys.Melons] = true,
			[RunesConfig.IncomeKeys.Tapping] = false,
		},
	},
	{
		Id = "MythicGoldyRune",
		Category = RunesConfig.Categories.GoldRune,
		DisplayName = "Mythic Goldy",
		Chance = 1,
		ImageId = "rbxassetid://111110214031646",
		XBoost = 3,
		Affects = {
			[RunesConfig.IncomeKeys.Melons] = true,
			[RunesConfig.IncomeKeys.Tapping] = false,
		},
	},
	{
		Id = "SecretGoldyRune",
		Category = RunesConfig.Categories.GoldRune,
		DisplayName = "Secret Goldy",
		Chance = 0.01,
		ImageId = "rbxassetid://91586412981314",
		XBoost = 10,
		Affects = {
			[RunesConfig.IncomeKeys.Melons] = true,
			[RunesConfig.IncomeKeys.Tapping] = false,
		},
	},
}

return RunesConfig

