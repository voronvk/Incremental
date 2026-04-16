local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local FloodCheck = require(ServerScriptService.Server:WaitForChild("RemoteFloodCheck"))
local DailyGuiService = require(script:WaitForChild("Service"))

local freeClaimRequest = ReplicatedStorage:WaitForChild("DailyGuiFreeClaimRequest")
local freeClaimResult = ReplicatedStorage:WaitForChild("DailyGuiFreeClaimResult")
local clientNotify = ReplicatedStorage:WaitForChild("DailyGuiClientNotify")

local function notifyPlayer(player, message)
	if typeof(message) ~= "string" or message == "" then
		return
	end
	clientNotify:FireClient(player, message)
end

freeClaimRequest.OnServerEvent:Connect(function(player)
	if not (player and player:IsA("Player")) then
		return
	end
	if not FloodCheck:Check(player, freeClaimRequest, 4) then
		freeClaimResult:FireClient(player, false)
		return
	end
	local ok = DailyGuiService.tryFreeClaim(player)
	freeClaimResult:FireClient(player, ok)
	if ok then
		notifyPlayer(
			player,
			"[Daily] Reward claimed! Speed x2 for 5 minutes. Next claim in 24 hours."
		)
	end
end)
