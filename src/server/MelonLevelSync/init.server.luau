local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local FloodCheck = require(ServerScriptService.Server:WaitForChild("RemoteFloodCheck") :: ModuleScript)
local MelonCfg = require(ReplicatedStorage.Shared:WaitForChild("MelonProgressConfig"))

local syncEvent = ReplicatedStorage:WaitForChild("MelonLevelSync")

syncEvent.OnServerEvent:Connect(function(player, level, xpOpt)
	if type(level) ~= "number" then
		return
	end
	-- Debounce en cliente + subida en level-up; límite alto para no perder XP
	if not FloodCheck:Check(player, syncEvent, 200) then
		return
	end

	local events = player:FindFirstChild("Events")
	if not events then
		return
	end

	local melonLevel = events:FindFirstChild("MelonLevel")
	if not melonLevel or not (melonLevel:IsA("IntValue") or melonLevel:IsA("NumberValue")) then
		return
	end

	local melonXp = events:FindFirstChild("MelonXp")
	if not melonXp or not (melonXp:IsA("IntValue") or melonXp:IsA("NumberValue")) then
		melonXp = Instance.new("NumberValue")
		melonXp.Name = "MelonXp"
		melonXp.Value = 0
		melonXp.Parent = events
	end

	local xpIn = 0
	if type(xpOpt) == "number" then
		xpIn = xpOpt
	end

	local L, x = MelonCfg.normalizeLevelXp(level, xpIn)
	melonLevel.Value = L
	melonXp.Value = x
end)
