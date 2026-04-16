--[[
	DailyGUI reward: one claim per 24h via Events.DailyGuiLastClaimUnix.
	Free: Speed x2, 5 min. Dev product 3571431653: Speed x2, 10 min.
]]

local DAILY_GUI_LAST_CLAIM = "DailyGuiLastClaimUnix"
local DAY_SECONDS = 86400
local FREE_SPEED_SEC = 5 * 60
local DOUBLE_SPEED_SEC = 10 * 60

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

local function ensureLastClaim(events)
	local v = events:FindFirstChild(DAILY_GUI_LAST_CLAIM)
	if v and v:IsA("NumberValue") then
		return v
	end
	v = Instance.new("NumberValue")
	v.Name = DAILY_GUI_LAST_CLAIM
	v.Value = 0
	v.Parent = events
	return v
end

local function grantSpeedBoost(player, durationSec)
	local e = getBoostEnd(player, "SpeedBoostEndTime")
	local m = getBoostMult(player, "SpeedBoostMultiplier")
	if not (e and m) then
		return false
	end
	setBoostMultiplierIfInactive(e, m, 2)
	extendBoostEndTime(e, durationSec)
	player:SetAttribute("LastSpeedBoostEnd", e.Value)
	return true
end

local M = {}

M.DAY_SECONDS = DAY_SECONDS
M.FREE_SPEED_SEC = FREE_SPEED_SEC
M.DOUBLE_SPEED_SEC = DOUBLE_SPEED_SEC
M.LAST_CLAIM_NAME = DAILY_GUI_LAST_CLAIM

function M.canClaimNow(events, now)
	if not events then
		return false
	end
	now = now or os.time()
	local last = ensureLastClaim(events)
	local lv = last.Value
	if type(lv) ~= "number" or lv <= 0 then
		return true
	end
	return (now - lv) >= DAY_SECONDS
end

function M.secondsUntilCanClaim(events, now)
	if not events then
		return DAY_SECONDS
	end
	now = now or os.time()
	local last = ensureLastClaim(events)
	local lv = last.Value
	if type(lv) ~= "number" or lv <= 0 then
		return 0
	end
	local elapsed = now - lv
	if elapsed >= DAY_SECONDS then
		return 0
	end
	return DAY_SECONDS - elapsed
end

function M.tryFreeClaim(player)
	local events = player:FindFirstChild("Events")
	if not events then
		return false, "no_events"
	end
	if not M.canClaimNow(events) then
		return false, "cooldown"
	end
	if not grantSpeedBoost(player, FREE_SPEED_SEC) then
		return false, "boost_failed"
	end
	ensureLastClaim(events).Value = os.time()
	return true
end

function M.tryDoublePurchaseClaim(player)
	local events = player:FindFirstChild("Events")
	if not events then
		return false
	end
	if not M.canClaimNow(events) then
		return false
	end
	if not grantSpeedBoost(player, DOUBLE_SPEED_SEC) then
		return false
	end
	ensureLastClaim(events).Value = os.time()
	return true
end

return M
