-- Wrapper para comprobar si el jugador tiene un gamepass (real, simulado o pack completo)
-- Usar en lugar de MarketplaceService:UserOwnsGamePassAsync para soportar BuyAll y Pack

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local BUNDLE_GAMEPASS_ID = 1740820575 -- Pack completo: si tiene este, tiene todos

local function playerOwnsGamePass(player, gamePassId)
	-- 1. Si tiene el pack completo, tiene todos los gamepasses
	local okBundle, hasBundle = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, BUNDLE_GAMEPASS_ID)
	end)
	if okBundle and hasBundle then
		return true
	end

	-- 2. Simulated (BuyAll)
	local simulated = player:GetAttribute("SimulatedGamePasses")
	if type(simulated) == "table" then
		for _, id in ipairs(simulated) do
			if id == gamePassId then
				return true
			end
		end
	end

	-- 3. Gamepass real individual
	local ok, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
	end)
	return ok and owns
end

return {
	playerOwnsGamePass = playerOwnsGamePass,
}
