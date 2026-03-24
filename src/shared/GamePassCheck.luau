-- Comprueba gamepass: caché en atributos OwnsGP_* (servidor), pack completo y MarketplaceService
-- Usar en lugar de UserOwnsGamePassAsync directo para soportar bundle y atributos replicados

local MarketplaceService = game:GetService("MarketplaceService")

local Config = require(script.Parent:WaitForChild("GamePassConfig"))

local BUNDLE_GAMEPASS_ID = Config.BUNDLE_GAMEPASS_ID

local function attrName(gamePassId)
	return "OwnsGP_" .. tostring(gamePassId)
end

local function playerOwnsGamePass(player, gamePassId)
	if player:GetAttribute(attrName(gamePassId)) == true then
		return true
	end
	if player:GetAttribute(attrName(BUNDLE_GAMEPASS_ID)) == true then
		return true
	end

	local okBundle, hasBundle = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, BUNDLE_GAMEPASS_ID)
	end)
	if okBundle and hasBundle then
		return true
	end

	local ok, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
	end)
	return ok and owns
end

return {
	playerOwnsGamePass = playerOwnsGamePass,
}
