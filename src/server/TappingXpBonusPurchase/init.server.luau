local ReplicatedStorage = game:GetService("ReplicatedStorage")

local event = ReplicatedStorage:WaitForChild("TappingXpBonusRequest")
local FloodCheck = require(game.ServerScriptService.Server:WaitForChild("RemoteFloodCheck") :: ModuleScript)
local Config = require(ReplicatedStorage.Shared:WaitForChild("TappingXpBonusConfig"))

local MIN_LEVEL = 15

event.OnServerEvent:Connect(function(player, mode)
	if not FloodCheck:Check(player, event, 12) then
		return
	end
	if mode ~= "Buy1" and mode ~= "Max" then
		return
	end

	local events = player:FindFirstChild("Events")
	local leaderstats = player:FindFirstChild("leaderstats")
	if not events or not leaderstats then
		return
	end

	local level = events:FindFirstChild("Level")
	local taps = leaderstats:FindFirstChild("Taps")
	local upg = events:FindFirstChild("TappingXpBonus")
	if not level or not taps or not upg then
		return
	end
	if not taps:IsA("NumberValue") or not upg:IsA("NumberValue") then
		return
	end

	if level.Value < MIN_LEVEL then
		return
	end

	if upg.Value >= Config.MAX_LEVEL then
		return
	end

	if mode == "Buy1" then
		local c = Config.costForNextLevel(upg.Value)
		if c <= 0 or taps.Value < c then
			return
		end
		taps.Value -= c
		upg.Value += 1
		return
	end

	local L = upg.Value
	while L < Config.MAX_LEVEL do
		local c = Config.costForNextLevel(L)
		if c <= 0 or taps.Value < c then
			break
		end
		taps.Value -= c
		L += 1
	end
	if L > upg.Value then
		upg.Value = L
	end
end)
