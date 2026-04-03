--[[
	Recompensas diarias (7 días): estado en Events.DailyRewardNextDay (1–7 siguiente a reclamar, 8 = semana hecha esperando reset),
	Events.DailyRewardLastClaimUnix. Claim vía DailyRewardClaimRequest. Skip all: producto 3569324327 (CobsonHandler).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local FloodCheck = require(ServerScriptService.Server:WaitForChild("RemoteFloodCheck"))
local claimEvent = ReplicatedStorage:WaitForChild("DailyRewardClaimRequest")
local claimResult = ReplicatedStorage:WaitForChild("DailyRewardClaimResult")

local DAY_SECONDS = 86400

local CORN_DAY1 = 100_000
local MELON_BOOST_SEC = 20 * 60
local REBIRTH_BOOST_SEC = 20 * 60
local SPEED_BOOST_SEC = 15 * 60
local REBIRTH_X2_SEC = 20 * 60

local function extendBoostEndTime(numberValue, durationSeconds)
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

local function setBoostMultiplierIfInactive(endTimeValue, multiplierValue, newMultiplier)
	if not (endTimeValue and multiplierValue) then
		return
	end
	local now = os.time()
	if endTimeValue.Value <= now then
		multiplierValue.Value = newMultiplier
	end
end

local function getBoostEnd(player, name)
	local events = player:FindFirstChild("Events")
	if not events then
		return nil
	end
	local v = events:FindFirstChild(name)
	if v and v:IsA("NumberValue") then
		return v
	end
	v = Instance.new("NumberValue")
	v.Name = name
	v.Value = 0
	v.Parent = events
	return v
end

local function getBoostMult(player, name)
	local events = player:FindFirstChild("Events")
	if not events then
		return nil
	end
	local v = events:FindFirstChild(name)
	if v and v:IsA("NumberValue") then
		return v
	end
	v = Instance.new("NumberValue")
	v.Name = name
	v.Value = 2
	v.Parent = events
	return v
end

local function grantRewardForDay(player, dayIndex)
	local currencies = player:FindFirstChild("Currencies")
	local corn = currencies and currencies:FindFirstChild("Corn")
	if dayIndex == 1 then
		if corn and corn:IsA("NumberValue") then
			corn.Value += CORN_DAY1
		end
	elseif dayIndex == 2 then
		local e = getBoostEnd(player, "MelonBoostEndTime")
		local m = getBoostMult(player, "MelonBoostMultiplier")
		if e and m then
			setBoostMultiplierIfInactive(e, m, 2)
			extendBoostEndTime(e, MELON_BOOST_SEC)
		end
	elseif dayIndex == 3 then
		local e = getBoostEnd(player, "RebirthBoostEndTime")
		local m = getBoostMult(player, "RebirthBoostMultiplier")
		if e and m then
			setBoostMultiplierIfInactive(e, m, 2)
			extendBoostEndTime(e, REBIRTH_BOOST_SEC)
		end
	elseif dayIndex == 4 then
		local e = getBoostEnd(player, "SpeedBoostEndTime")
		local m = getBoostMult(player, "SpeedBoostMultiplier")
		if e and m then
			setBoostMultiplierIfInactive(e, m, 1.5)
			extendBoostEndTime(e, SPEED_BOOST_SEC)
		end
	elseif dayIndex == 5 then
		local e = getBoostEnd(player, "RebirthBoostEndTime")
		local m = getBoostMult(player, "RebirthBoostMultiplier")
		if e and m then
			setBoostMultiplierIfInactive(e, m, 2)
			extendBoostEndTime(e, REBIRTH_X2_SEC)
		end
	elseif dayIndex == 6 then
		local events = player:FindFirstChild("Events")
		local flag = events and events:FindFirstChild("AutoTapBasicUnlocked")
		if flag and flag:IsA("NumberValue") then
			flag.Value = 1
		end
	end
end

local function tryResetWeek(events)
	local nextDay = events:FindFirstChild("DailyRewardNextDay")
	local last = events:FindFirstChild("DailyRewardLastClaimUnix")
	if not (nextDay and last) then
		return
	end
	if nextDay.Value >= 8 and last.Value > 0 and (os.time() - last.Value) >= DAY_SECONDS then
		nextDay.Value = 1
		last.Value = 0
	end
end

local function canClaimNow(events)
	tryResetWeek(events)
	local nextDay = events:FindFirstChild("DailyRewardNextDay")
	local last = events:FindFirstChild("DailyRewardLastClaimUnix")
	if not (nextDay and last) then
		return false
	end
	local nd = nextDay.Value
	if nd < 1 or nd > 7 then
		return false
	end
	if last.Value == 0 then
		return true
	end
	return (os.time() - last.Value) >= DAY_SECONDS
end

local function ensureDailyRewardValues(events)
	if not events then
		return
	end
	local nextDay = events:FindFirstChild("DailyRewardNextDay")
	if not nextDay or not nextDay:IsA("NumberValue") then
		nextDay = Instance.new("NumberValue")
		nextDay.Name = "DailyRewardNextDay"
		nextDay.Value = 1
		nextDay.Parent = events
	end
	local last = events:FindFirstChild("DailyRewardLastClaimUnix")
	if not last or not last:IsA("NumberValue") then
		last = Instance.new("NumberValue")
		last.Name = "DailyRewardLastClaimUnix"
		last.Value = 0
		last.Parent = events
	end
end

local function ensureDefaults(events)
	ensureDailyRewardValues(events)
	local nextDay = events:FindFirstChild("DailyRewardNextDay")
	local last = events:FindFirstChild("DailyRewardLastClaimUnix")
	if nextDay and nextDay.Value < 1 then
		nextDay.Value = 1
	end
	if nextDay and nextDay.Value > 8 then
		nextDay.Value = 8
	end
end

local function processClaim(player)
	local events = player:FindFirstChild("Events")
	if not events then
		return false
	end
	ensureDailyRewardValues(events)
	ensureDefaults(events)
	tryResetWeek(events)
	if not canClaimNow(events) then
		return false
	end
	local nextDay = events:FindFirstChild("DailyRewardNextDay")
	local last = events:FindFirstChild("DailyRewardLastClaimUnix")
	if not (nextDay and last) then
		return false
	end
	local nd = nextDay.Value
	if nd < 1 or nd > 7 then
		return false
	end
	grantRewardForDay(player, nd)
	last.Value = os.time()
	if nd >= 7 then
		nextDay.Value = 8
	else
		nextDay.Value = nd + 1
	end
	return true
end

local function grantDailySkipAll(player)
	local events = player:FindFirstChild("Events")
	if not events then
		return false
	end
	ensureDailyRewardValues(events)
	ensureDefaults(events)
	for d = 1, 7 do
		grantRewardForDay(player, d)
	end
	local nextDay = events:FindFirstChild("DailyRewardNextDay")
	local last = events:FindFirstChild("DailyRewardLastClaimUnix")
	if not (nextDay and last) then
		return false
	end
	nextDay.Value = 8
	last.Value = os.time()
	return true
end

local grantBf = Instance.new("BindableFunction")
grantBf.Name = "GrantDailySkipAll"
grantBf.OnInvoke = function(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return false
	end
	return grantDailySkipAll(player)
end
grantBf.Parent = script

Players.PlayerAdded:Connect(function(player)
	task.defer(function()
		local ev = player:WaitForChild("Events", 60)
		if not ev then
			return
		end
		ensureDailyRewardValues(ev)
		ensureDefaults(ev)
	end)
end)

claimEvent.OnServerEvent:Connect(function(player)
	if not FloodCheck:Check(player, claimEvent, 4) then
		claimResult:FireClient(player, false)
		return
	end
	local ok = processClaim(player)
	claimResult:FireClient(player, ok)
end)

task.spawn(function()
	while true do
		task.wait(60)
		for _, p in Players:GetPlayers() do
			local ev = p:FindFirstChild("Events")
			if ev then
				tryResetWeek(ev)
			end
		end
	end
end)
