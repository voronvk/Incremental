local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local FloodCheck = require(ServerScriptService.Server:WaitForChild("RemoteFloodCheck") :: ModuleScript)

local syncEvent = ReplicatedStorage:WaitForChild("MelonLevelSync")
local MAX_MELON_LEVEL = 100

syncEvent.OnServerEvent:Connect(function(player, level)
	if type(level) ~= "number" then
		return
	end
	if not FloodCheck:Check(player, syncEvent, 40) then
		return
	end

	local events = player:FindFirstChild("Events")
	local melonLevel = events and events:FindFirstChild("MelonLevel")
	if not melonLevel or not (melonLevel:IsA("IntValue") or melonLevel:IsA("NumberValue")) then
		return
	end

	local L = math.clamp(math.floor(level + 0), 0, MAX_MELON_LEVEL)
	if L > melonLevel.Value then
		melonLevel.Value = L
	end
end)
