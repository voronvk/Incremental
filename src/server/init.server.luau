local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local buyAllRemote = ReplicatedStorage:WaitForChild("BuyAllGamePasses")
local setMuteRequest = ReplicatedStorage:WaitForChild("SetMuteRequest")

buyAllRemote.OnServerEvent:Connect(function(player, ids)
	if type(ids) ~= "table" then
		return
	end
	local current = player:GetAttribute("SimulatedGamePasses")
	if type(current) ~= "table" then
		current = {}
	end
	for _, id in ipairs(ids) do
		table.insert(current, tonumber(id) or id)
	end
	player:SetAttribute("SimulatedGamePasses", current)
end)

setMuteRequest.OnServerEvent:Connect(function(player, muted)
	local settings = player:FindFirstChild("Settings")
	if not settings then return end
	local musicMuted = settings:FindFirstChild("MusicMuted")
	local sfxMuted = settings:FindFirstChild("SfxMuted")
	if not musicMuted or not sfxMuted then return end
	local value = (muted == true) and 1 or 0
	musicMuted.Value = value
	sfxMuted.Value = value
end)
