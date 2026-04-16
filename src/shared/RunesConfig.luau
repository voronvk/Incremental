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

-- Lista de runas.
-- NOTA: "Chance" se usa como peso (weighted chance). Si tus valores son porcentajes, tambien funciona
-- igual de bien (solo cambian las proporciones).
RunesConfig.Runes = {
	{
		Id = "CommonRune",
		DisplayName = "Common Rune",
		Chance = 65,
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
		DisplayName = "Uncommon Rune",
		Chance = 30,
		XBoost = 1.005,
		Affects = {
			[RunesConfig.IncomeKeys.Melons] = true,
			[RunesConfig.IncomeKeys.Tapping] = false,
		},
	},
	{
		Id = "EpicRune",
		DisplayName = "Epic Rune",
		Chance = 4,
		XBoost = 1.015,
		Affects = {
			[RunesConfig.IncomeKeys.Melons] = true,
			[RunesConfig.IncomeKeys.Tapping] = false,
		},
	},
	{
		Id = "LegendaryRune",
		DisplayName = "Legendary Rune",
		Chance = 1,
		XBoost = 1.05,
		Affects = {
			[RunesConfig.IncomeKeys.Melons] = true,
			[RunesConfig.IncomeKeys.Tapping] = false,
		},
	},
}

return RunesConfig

