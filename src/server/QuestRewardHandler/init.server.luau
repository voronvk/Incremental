local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CLAIM_REQUEST_EVENT_NAME = "QuestRewardClaimRequest"
local CLAIM_RESULT_EVENT_NAME = "QuestRewardClaimed"

local function getOrCreateRemoteEvent(name: string)
	local existing = ReplicatedStorage:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	local ev = Instance.new("RemoteEvent")
	ev.Name = name
	ev.Parent = ReplicatedStorage
	return ev
end

local claimRequest = getOrCreateRemoteEvent(CLAIM_REQUEST_EVENT_NAME)
local claimResult = getOrCreateRemoteEvent(CLAIM_RESULT_EVENT_NAME)

local function safelyGetNumberValue(folder: Instance, name: string, defaultValue: number)
	local v = folder:FindFirstChild(name)
	if v and v:IsA("NumberValue") then
		return v
	end
	v = Instance.new("NumberValue")
	v.Name = name
	v.Value = defaultValue
	v.Parent = folder
	return v
end

local function extendBoostEndTime(numberValue: NumberValue, durationSeconds: number)
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

local function canClaimAllQuests(events: Folder)
	for i = 1, 3 do
		local t = events:FindFirstChild("Quest" .. i .. "Target")
		local p = events:FindFirstChild("Quest" .. i .. "Progress")
		if not (t and p and t:IsA("NumberValue") and p:IsA("NumberValue")) then
			return false
		end
		if p.Value < t.Value then
			return false
		end
	end
	local claimed = events:FindFirstChild("QuestRewardClaimed")
	return claimed and claimed:IsA("NumberValue") and claimed.Value == 0
end

local function grantRandomBoost(player: Player, timeMultiplier: number)
	local events = player:FindFirstChild("Events")
	if not (events and events:IsA("Folder")) then
		return false, "no_events"
	end

	if not canClaimAllQuests(events) then
		return false, "not_ready"
	end

	local claimed = events:FindFirstChild("QuestRewardClaimed") :: NumberValue

	local boostKeys = { "Melon", "Speed", "Rebirth", "Ascension" }
	local chosen = boostKeys[math.random(1, #boostKeys)]

	local durationMinutes = math.random(15, 30) * math.max(1, (tonumber(timeMultiplier) or 1))
	local durationSeconds = durationMinutes * 60

	local rolledMult = 1.5 + (math.random() * (3 - 1.5))
	rolledMult = math.floor(rolledMult * 100 + 0.5) / 100

	local endTime = safelyGetNumberValue(events, chosen .. "BoostEndTime", 0)
	local multVal = safelyGetNumberValue(events, chosen .. "BoostMultiplier", 2)

	-- Solo setear multiplicador si el boost no estaba activo (evita “nerfear” un boost ya en marcha).
	if endTime.Value <= os.time() then
		multVal.Value = rolledMult
	end

	extendBoostEndTime(endTime, durationSeconds)
	claimed.Value = 1

	return true, { boost = chosen, minutes = durationMinutes, mult = multVal.Value }
end

claimRequest.OnServerEvent:Connect(function(player)
	if not player or not player.Parent then return end
	local ok, payload = grantRandomBoost(player, 1)
	claimResult:FireClient(player, ok, payload)
end)

Players.PlayerAdded:Connect(function(player)
	-- Asegurar que el RemoteEvent existe para el cliente siempre.
	claimResult:FireClient(player, false, "ready")
end)

