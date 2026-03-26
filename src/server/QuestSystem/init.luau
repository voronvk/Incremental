-- Sistema de misiones: Play X min, Collect X melons, Rebirth X times
-- Resetea cada 24h, progreso persistido en DataStore
-- ModuleScript para poder ser requerido por CollectCornHandler

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local QUEST_TYPES = { "play", "melons", "rebirth" }
local PLAY_RANGE = { 10, 35 }
local MELONS_RANGE = { 10_000_000, 1_000_000_000_000 }
local REBIRTH_RANGE = { 500_000, 1_000_000_000_000 }
local RESET_INTERVAL_SEC = 24 * 60 * 60 -- 24 horas

-- Luau: math.random(m, n) solo acepta enteros en un rango acotado (~2^31-1).
-- Objetivos de melons/rebirth pueden ser > 2^31; usar float + floor.
local MAX_INT_RANDOM = 2147483647

local function randomInRange(min, max)
	if min > max then
		min, max = max, min
	end
	if max <= MAX_INT_RANDOM then
		return math.random(min, max)
	end
	return min + math.floor(math.random() * (max - min + 1))
end

local function generateQuest()
	local t = QUEST_TYPES[math.random(1, 3)]
	local target
	if t == "play" then
		target = randomInRange(PLAY_RANGE[1], PLAY_RANGE[2])
	elseif t == "melons" then
		target = randomInRange(MELONS_RANGE[1], MELONS_RANGE[2])
	else
		target = randomInRange(REBIRTH_RANGE[1], REBIRTH_RANGE[2])
	end
	return t, target
end

local function getTypeNumber(t)
	if t == "play" then return 1 end
	if t == "melons" then return 2 end
	if t == "rebirth" then return 3 end
	return 1
end

local function getTypeFromNumber(n)
	if n == 1 then return "play" end
	if n == 2 then return "melons" end
	if n == 3 then return "rebirth" end
	return "play"
end

local function ensureQuestValues(player)
	local events = player:FindFirstChild("Events")
	if not events then return false end

	local names = {
		"Quest1Type", "Quest1Target", "Quest1Progress",
		"Quest2Type", "Quest2Target", "Quest2Progress",
		"Quest3Type", "Quest3Target", "Quest3Progress",
		"QuestLastResetTime", "QuestPlaytimeAtReset", "QuestRebirthsAtReset", "QuestMelonsCollected",
		"QuestRewardClaimed",
	}
	for _, name in ipairs(names) do
		if not events:FindFirstChild(name) then
			local v = Instance.new("NumberValue")
			v.Name = name
			v.Value = 0
			v.Parent = events
		end
	end
	return true
end

local function resetQuests(player)
	local events = player:FindFirstChild("Events")
	local currencies = player:FindFirstChild("Currencies")
	if not events or not currencies then return end

	local playtime = events:FindFirstChild("Playtime")
	local rebirths = currencies:FindFirstChild("Rebirths")
	local now = os.time()

	for i = 1, 3 do
		local t, target = generateQuest()
		events:FindFirstChild("Quest" .. i .. "Type").Value = getTypeNumber(t)
		events:FindFirstChild("Quest" .. i .. "Target").Value = target
		events:FindFirstChild("Quest" .. i .. "Progress").Value = 0
	end

	events:FindFirstChild("QuestLastResetTime").Value = now
	events:FindFirstChild("QuestPlaytimeAtReset").Value = playtime and playtime.Value or 0
	events:FindFirstChild("QuestRebirthsAtReset").Value = rebirths and rebirths.Value or 0
	events:FindFirstChild("QuestMelonsCollected").Value = 0
	local claimed = events:FindFirstChild("QuestRewardClaimed")
	if claimed then
		claimed.Value = 0
	end
end

local function updateQuestProgress(player)
	local events = player:FindFirstChild("Events")
	local currencies = player:FindFirstChild("Currencies")
	if not events or not currencies then return end

	local playtime = events:FindFirstChild("Playtime")
	local rebirths = currencies:FindFirstChild("Rebirths")
	local lastReset = events:FindFirstChild("QuestLastResetTime")
	local playtimeAtReset = events:FindFirstChild("QuestPlaytimeAtReset")
	local rebirthsAtReset = events:FindFirstChild("QuestRebirthsAtReset")
	local questMelons = events:FindFirstChild("QuestMelonsCollected")

	if not (playtime and rebirths and lastReset and playtimeAtReset and rebirthsAtReset and questMelons) then
		return
	end

	local now = os.time()
	if now - lastReset.Value >= RESET_INTERVAL_SEC then
		resetQuests(player)
		return
	end

	local playProgress = math.max(0, (playtime.Value - playtimeAtReset.Value) / 60) -- minutos
	local melonsProgress = questMelons.Value
	local rebirthProgress = math.max(0, rebirths.Value - rebirthsAtReset.Value)

	for i = 1, 3 do
		local qType = events:FindFirstChild("Quest" .. i .. "Type")
		local qTarget = events:FindFirstChild("Quest" .. i .. "Target")
		local qProgress = events:FindFirstChild("Quest" .. i .. "Progress")
		if not (qType and qTarget and qProgress) then continue end

		local target = qTarget.Value
		local progress
		if getTypeFromNumber(qType.Value) == "play" then
			progress = math.min(playProgress, target)
		elseif getTypeFromNumber(qType.Value) == "melons" then
			progress = math.min(melonsProgress, target)
		else
			progress = math.min(rebirthProgress, target)
		end
		qProgress.Value = math.floor(progress)
	end
end

local function onCollectCorn(player, amount)
	local events = player:FindFirstChild("Events")
	if not events then return end
	local questMelons = events:FindFirstChild("QuestMelonsCollected")
	if questMelons then
		questMelons.Value = questMelons.Value + amount
	end
end

Players.PlayerAdded:Connect(function(player)
	task.defer(function()
		player:WaitForChild("Events", 30)
		player:WaitForChild("Currencies", 30)
		if not player.Parent then return end
		if not ensureQuestValues(player) then return end

		-- Primera vez o cargar desde DataStore (los valores vienen de loadData)
		local lastReset = player.Events:FindFirstChild("QuestLastResetTime")
		local now = os.time()
		if not lastReset or lastReset.Value == 0 or (now - lastReset.Value >= RESET_INTERVAL_SEC) then
			resetQuests(player)
		end

		RunService.Heartbeat:Connect(function()
			if not player.Parent then return end
			updateQuestProgress(player)
		end)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.defer(function()
		player:WaitForChild("Events", 30)
		player:WaitForChild("Currencies", 30)
		if not player.Parent then return end
		if not ensureQuestValues(player) then return end
		local lastReset = player.Events:FindFirstChild("QuestLastResetTime")
		local now = os.time()
		if not lastReset or lastReset.Value == 0 or (now - lastReset.Value >= RESET_INTERVAL_SEC) then
			resetQuests(player)
		end
		RunService.Heartbeat:Connect(function()
			if not player.Parent then return end
			updateQuestProgress(player)
		end)
	end)
end

return {
	onCollectCorn = onCollectCorn,
}
