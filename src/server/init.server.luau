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

setMuteRequest.OnServerEvent:Connect(function(player, a, b)
	local settings = player:FindFirstChild("Settings")
	if not settings then
		return
	end
	if type(a) == "string" and (b == 0 or b == 1) then
		if a == "MusicMuted" or a == "SfxMuted" or a == "PopUpsMuted" then
			local nv = settings:FindFirstChild(a)
			if nv and (nv:IsA("IntValue") or nv:IsA("NumberValue")) then
				nv.Value = b
			end
		end
		return
	end
	local muted = a == true
	local value = muted and 1 or 0
	local musicMuted = settings:FindFirstChild("MusicMuted")
	local sfxMuted = settings:FindFirstChild("SfxMuted")
	if not musicMuted or not sfxMuted then
		return
	end
	musicMuted.Value = value
	sfxMuted.Value = value
end)
