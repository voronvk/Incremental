local ReplicatedStorage = game:GetService("ReplicatedStorage")

local buyAllRemote = ReplicatedStorage:WaitForChild("BuyAllGamePasses")
local setMuteRequest = ReplicatedStorage:WaitForChild("SetMuteRequest")

local function bumpGamePassStamp(player)
	local stamp = player:GetAttribute("GamePassSyncStamp")
	if type(stamp) ~= "number" then
		stamp = 0
	end
	player:SetAttribute("GamePassSyncStamp", stamp + 1)
end

buyAllRemote.OnServerEvent:Connect(function(player, ids)
	if type(ids) ~= "table" then
		return
	end
	for _, id in ipairs(ids) do
		local n = tonumber(id) or id
		player:SetAttribute("OwnsGP_" .. tostring(n), true)
	end
	bumpGamePassStamp(player)
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
