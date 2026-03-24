local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared:WaitForChild("GamePassConfig"))
local syncFn = ReplicatedStorage:WaitForChild("GamePassSyncRequest")

local BUNDLE_ID = Config.BUNDLE_GAMEPASS_ID

local function attrName(id)
	return "OwnsGP_" .. tostring(id)
end

local function bumpStamp(player)
	local stamp = player:GetAttribute("GamePassSyncStamp")
	if type(stamp) ~= "number" then
		stamp = 0
	end
	player:SetAttribute("GamePassSyncStamp", stamp + 1)
end

local function syncOneFromMarketplace(player, gamePassId)
	local ok, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
	end)
	if ok and owns then
		player:SetAttribute(attrName(gamePassId), true)
		return true
	end
	return false
end

local function applyBundleIfOwned(player)
	local okBundle, hasBundle = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, BUNDLE_ID)
	end)
	if okBundle and hasBundle then
		player:SetAttribute(attrName(BUNDLE_ID), true)
		for _, id in ipairs(Config.GAMEPASS_IDS) do
			if id ~= BUNDLE_ID then
				player:SetAttribute(attrName(id), true)
			end
		end
		return true
	end
	return false
end

local function fullSync(player)
	task.spawn(function()
		if applyBundleIfOwned(player) then
			bumpStamp(player)
			return
		end
		for _, id in ipairs(Config.GAMEPASS_IDS) do
			syncOneFromMarketplace(player, id)
		end
		bumpStamp(player)
	end)
end

syncFn.OnServerInvoke = function(player, gamePassId)
	if type(gamePassId) ~= "number" then
		return false
	end
	for _ = 1, 6 do
		if syncOneFromMarketplace(player, gamePassId) then
			bumpStamp(player)
			return true
		end
		if applyBundleIfOwned(player) then
			bumpStamp(player)
			return true
		end
		task.wait(0.2)
	end
	return false
end

Players.PlayerAdded:Connect(fullSync)
for _, p in ipairs(Players:GetPlayers()) do
	fullSync(p)
end
