-- Comprueba gamepass: caché OwnsGP_*, bundles parciales (Everything / All Tapping) y MarketplaceService
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local Config = require(script.Parent:WaitForChild("GamePassConfig"))

local BUNDLE_GAMEPASS_ID = Config.BUNDLE_GAMEPASS_ID
local TAPPING_BUNDLE_GAMEPASS_ID = Config.TAPPING_BUNDLE_GAMEPASS_ID
local AUTOTAP_GAMEPASS_ID = Config.AUTOTAP_GAMEPASS_ID
local EVERYTHING_GRANTS = Config.BUNDLE_EVERYTHING_GRANT_IDS
local TAPPING_GRANTS = Config.BUNDLE_TAPPING_GRANT_IDS

--[[
	[SOLO TEST EN STUDIO] Pon true para fingir que NO tienes el pase de Auto Tap.
]]
local DEBUG_STUDIO_FORCE_NOT_OWN_AUTOTAP = false

local function attrName(gamePassId)
	return "OwnsGP_" .. tostring(gamePassId)
end

local function idInList(id, list)
	if type(list) ~= "table" then
		return false
	end
	for _, v in ipairs(list) do
		if v == id then
			return true
		end
	end
	return false
end

local function userOwnsGamePass(userId, gamePassId)
	if RunService:IsStudio() and Config.STUDIO_DISABLE_GAMEPASS_MARKETPLACE_LOOKUP == true then
		return false
	end
	local ok, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(userId, gamePassId)
	end)
	return ok and owns == true
end

local function playerOwnsGamePass(player, gamePassId)
	if
		DEBUG_STUDIO_FORCE_NOT_OWN_AUTOTAP
		and RunService:IsStudio()
		and gamePassId == AUTOTAP_GAMEPASS_ID
	then
		return false
	end

	if player:GetAttribute(attrName(gamePassId)) == true then
		return true
	end

	-- Everything bundle solo cuenta para el bundle y Melon, Ascension, WalkSpeed, Rebirth
	if gamePassId == BUNDLE_GAMEPASS_ID or idInList(gamePassId, EVERYTHING_GRANTS) then
		if player:GetAttribute(attrName(BUNDLE_GAMEPASS_ID)) == true then
			return true
		end
		if userOwnsGamePass(player.UserId, BUNDLE_GAMEPASS_ID) then
			return true
		end
	end

	-- All Tapping bundle solo cuenta para ese bundle y los 4 pases de tapping
	if gamePassId == TAPPING_BUNDLE_GAMEPASS_ID or idInList(gamePassId, TAPPING_GRANTS) then
		if player:GetAttribute(attrName(TAPPING_BUNDLE_GAMEPASS_ID)) == true then
			return true
		end
		if userOwnsGamePass(player.UserId, TAPPING_BUNDLE_GAMEPASS_ID) then
			return true
		end
	end

	return userOwnsGamePass(player.UserId, gamePassId)
end

return {
	playerOwnsGamePass = playerOwnsGamePass,
}
