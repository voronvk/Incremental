local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FloodCheck = require(game.ServerScriptService.Server:WaitForChild("RemoteFloodCheck") :: ModuleScript)
local DamageConfig = require(ReplicatedStorage.Shared:WaitForChild("TappingDamageConfig"))
local CritConfig = require(ReplicatedStorage.Shared:WaitForChild("TappingCritConfig"))

local MIN_LEVEL = 25

local damageEvent = ReplicatedStorage:WaitForChild("TappingDamageUpgradeRequest")
local critEvent = ReplicatedStorage:WaitForChild("TappingCritUpgradeRequest")

local function handlePurchase(player, mode, upgName, config)
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
	local upg = events:FindFirstChild(upgName)
	if not level or not taps or not upg then
		return
	end
	if not taps:IsA("NumberValue") or not upg:IsA("NumberValue") then
		return
	end

	if level.Value < MIN_LEVEL then
		return
	end

	if upg.Value >= config.MAX_LEVEL then
		return
	end

	if mode == "Buy1" then
		local c = config.costForNextLevel(upg.Value)
		if c <= 0 or taps.Value < c then
			return
		end
		taps.Value -= c
		upg.Value += 1
		return
	end

	local L = upg.Value
	while L < config.MAX_LEVEL do
		local c = config.costForNextLevel(L)
		if c <= 0 or taps.Value < c then
			break
		end
		taps.Value -= c
		L += 1
	end
	if L > upg.Value then
		upg.Value = L
	end
end

damageEvent.OnServerEvent:Connect(function(player, mode)
	if not FloodCheck:Check(player, damageEvent, 12) then
		return
	end
	handlePurchase(player, mode, "TappingDamageLevel", DamageConfig)
end)

critEvent.OnServerEvent:Connect(function(player, mode)
	if not FloodCheck:Check(player, critEvent, 12) then
		return
	end
	handlePurchase(player, mode, "TappingCritLevel", CritConfig)
end)
