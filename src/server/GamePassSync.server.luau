local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared:WaitForChild("GamePassConfig"))
local syncFn = ReplicatedStorage:WaitForChild("GamePassSyncRequest")

local function shouldUseMarketplaceForGamePassOwnership(): boolean
	if not RunService:IsStudio() then
		return true
	end
	return Config.STUDIO_DISABLE_GAMEPASS_MARKETPLACE_LOOKUP ~= true
end
local announce = ReplicatedStorage:WaitForChild("GamePassPurchaseAnnounce")

local DISPLAY_NAMES = Config.GAMEPASS_DISPLAY_NAMES or {}

local BUNDLE_ID = Config.BUNDLE_GAMEPASS_ID
local TAPPING_BUNDLE_ID = Config.TAPPING_BUNDLE_GAMEPASS_ID
local BOOST_PACK_ID = Config.BOOST_PACK_GAMEPASS_ID
local BOOST_PACK_DURATION_SEC = 60 * 60

local boostPackGrantedThisSession: { [Player]: boolean } = {}

local function attrName(id: number): string
	return "OwnsGP_" .. tostring(id)
end

local function extendBoostEndTime(numberValue: NumberValue, durationSeconds: number)
	if not numberValue then
		return
	end
	local now = os.time()
	local current = numberValue.Value
	if type(current) ~= "number" then
		current = 0
	end
	if current < now then
		numberValue.Value = now + durationSeconds
	else
		numberValue.Value = current + durationSeconds
	end
end

local function setBoostMultiplierIfInactive(endTimeValue: NumberValue?, multiplierValue: NumberValue?, newMultiplier: number)
	if not (endTimeValue and multiplierValue) then
		return
	end
	local now = os.time()
	if endTimeValue.Value <= now then
		multiplierValue.Value = newMultiplier
	end
end

local function getOrCreateEvents(player: Player): Folder
	local events = player:FindFirstChild("Events")
	if not events then
		events = Instance.new("Folder")
		events.Name = "Events"
		events.Parent = player
	end
	return events
end

local function getOrCreateBoostEndTime(events: Folder, valueName: string): NumberValue
	local v = events:FindFirstChild(valueName)
	if v and v:IsA("NumberValue") then
		return v
	end
	v = Instance.new("NumberValue")
	v.Name = valueName
	v.Value = 0
	v.Parent = events
	return v
end

local function getOrCreateBoostMultiplier(events: Folder, valueName: string): NumberValue
	local v = events:FindFirstChild(valueName)
	if v and v:IsA("NumberValue") then
		return v
	end
	v = Instance.new("NumberValue")
	v.Name = valueName
	v.Value = 2
	v.Parent = events
	return v
end

-- Igual que Melon 1h + All Boosts 1h en CobsonHandler (Melon x2 + Speed/Rebirth/Ascension x2)
local function grantBoostPackOneHour(player: Player)
	local events = getOrCreateEvents(player)
	local d = BOOST_PACK_DURATION_SEC
	local melonEnd = getOrCreateBoostEndTime(events, "MelonBoostEndTime")
	local melonMult = getOrCreateBoostMultiplier(events, "MelonBoostMultiplier")
	setBoostMultiplierIfInactive(melonEnd, melonMult, 2)
	extendBoostEndTime(melonEnd, d)
	local speedEnd = getOrCreateBoostEndTime(events, "SpeedBoostEndTime")
	local rebirthEnd = getOrCreateBoostEndTime(events, "RebirthBoostEndTime")
	local ascEnd = getOrCreateBoostEndTime(events, "AscensionBoostEndTime")
	local speedMult = getOrCreateBoostMultiplier(events, "SpeedBoostMultiplier")
	local rebirthMult = getOrCreateBoostMultiplier(events, "RebirthBoostMultiplier")
	local ascMult = getOrCreateBoostMultiplier(events, "AscensionBoostMultiplier")
	setBoostMultiplierIfInactive(speedEnd, speedMult, 2)
	setBoostMultiplierIfInactive(rebirthEnd, rebirthMult, 2)
	setBoostMultiplierIfInactive(ascEnd, ascMult, 2)
	extendBoostEndTime(speedEnd, d)
	extendBoostEndTime(rebirthEnd, d)
	extendBoostEndTime(ascEnd, d)
	player:SetAttribute("LastBoostProduct", "gamepass_boostpack")
	player:SetAttribute("LastMelonBoostEnd", melonEnd.Value)
	player:SetAttribute("LastSpeedBoostEnd", speedEnd.Value)
	player:SetAttribute("LastRebirthBoostEnd", rebirthEnd.Value)
	player:SetAttribute("LastAscensionBoostEnd", ascEnd.Value)
end

local function tryApplyBoostPackOnceThisSession(player: Player)
	if boostPackGrantedThisSession[player] then
		return
	end
	if player:GetAttribute(attrName(BOOST_PACK_ID)) ~= true then
		return
	end
	boostPackGrantedThisSession[player] = true
	grantBoostPackOneHour(player)
end

local function displayNameFor(gamePassId)
	local n = DISPLAY_NAMES[gamePassId]
	if type(n) == "string" and n ~= "" then
		return n
	end
	return "a Gamepass"
end

local function announcePurchase(player, gamePassId)
	local msg = string.format("%s just bought %s!", player.Name, displayNameFor(gamePassId))
	announce:FireAllClients(msg)
end

local function bumpStamp(player)
	local stamp = player:GetAttribute("GamePassSyncStamp")
	if type(stamp) ~= "number" then
		stamp = 0
	end
	player:SetAttribute("GamePassSyncStamp", stamp + 1)
end

local function syncOneFromMarketplace(player, gamePassId)
	if not shouldUseMarketplaceForGamePassOwnership() then
		return false
	end
	local ok, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
	end)
	if ok and owns then
		player:SetAttribute(attrName(gamePassId), true)
		return true
	end
	return false
end

-- Everything: solo Melon x2, Ascension, WalkSpeed, Rebirth (+ el propio bundle)
local function applyEverythingBundleIfOwned(player)
	if not shouldUseMarketplaceForGamePassOwnership() then
		return false
	end
	local okB, hasB = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, BUNDLE_ID)
	end)
	if okB and hasB then
		player:SetAttribute(attrName(BUNDLE_ID), true)
		for _, id in ipairs(Config.BUNDLE_EVERYTHING_GRANT_IDS) do
			player:SetAttribute(attrName(id), true)
		end
		return true
	end
	return false
end

-- All Tapping: los 4 pases de tapping (+ el propio bundle)
local function applyTappingBundleIfOwned(player)
	if not shouldUseMarketplaceForGamePassOwnership() then
		return false
	end
	local okB, hasB = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, TAPPING_BUNDLE_ID)
	end)
	if okB and hasB then
		player:SetAttribute(attrName(TAPPING_BUNDLE_ID), true)
		for _, id in ipairs(Config.BUNDLE_TAPPING_GRANT_IDS) do
			player:SetAttribute(attrName(id), true)
		end
		return true
	end
	return false
end

local function fullSync(player)
	task.spawn(function()
		if shouldUseMarketplaceForGamePassOwnership() then
			applyEverythingBundleIfOwned(player)
			applyTappingBundleIfOwned(player)
			for _, id in ipairs(Config.GAMEPASS_IDS) do
				syncOneFromMarketplace(player, id)
			end
		end
		bumpStamp(player)
		tryApplyBoostPackOnceThisSession(player)
	end)
end

-- Studio: tras PromptGamePassPurchaseFinished el marketplace a veces no actualiza; confiamos en el id (solo Studio).
local function applyStudioTrustedGamePassPurchase(player, gamePassId): boolean
	if shouldUseMarketplaceForGamePassOwnership() then
		return false
	end
	if not table.find(Config.GAMEPASS_IDS, gamePassId) then
		return false
	end
	player:SetAttribute(attrName(gamePassId), true)
	if gamePassId == BUNDLE_ID then
		for _, id in ipairs(Config.BUNDLE_EVERYTHING_GRANT_IDS) do
			player:SetAttribute(attrName(id), true)
		end
	elseif gamePassId == TAPPING_BUNDLE_ID then
		for _, id in ipairs(Config.BUNDLE_TAPPING_GRANT_IDS) do
			player:SetAttribute(attrName(id), true)
		end
	end
	bumpStamp(player)
	if gamePassId == BOOST_PACK_ID then
		boostPackGrantedThisSession[player] = true
		grantBoostPackOneHour(player)
	end
	announcePurchase(player, gamePassId)
	return true
end

syncFn.OnServerInvoke = function(player, gamePassId)
	if type(gamePassId) ~= "number" then
		return false
	end
	if applyStudioTrustedGamePassPurchase(player, gamePassId) then
		return true
	end
	for _ = 1, 6 do
		if syncOneFromMarketplace(player, gamePassId) then
			applyEverythingBundleIfOwned(player)
			applyTappingBundleIfOwned(player)
			bumpStamp(player)
			if gamePassId == BOOST_PACK_ID then
				boostPackGrantedThisSession[player] = true
				grantBoostPackOneHour(player)
			end
			announcePurchase(player, gamePassId)
			return true
		end
		if applyEverythingBundleIfOwned(player) then
			bumpStamp(player)
			announcePurchase(player, BUNDLE_ID)
			return true
		end
		if applyTappingBundleIfOwned(player) then
			bumpStamp(player)
			announcePurchase(player, TAPPING_BUNDLE_ID)
			return true
		end
		task.wait(0.2)
	end
	return false
end

Players.PlayerAdded:Connect(fullSync)
Players.PlayerRemoving:Connect(function(player)
	boostPackGrantedThisSession[player] = nil
end)
for _, p in ipairs(Players:GetPlayers()) do
	fullSync(p)
end
