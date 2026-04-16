local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Este script funciona aunque `RunesConfig.Enabled` esté en false.
-- Para ahora: al abrir (x1/x3) solo se gasta Keys (no animaciones ni probabilidades).

local REMOTE_NAME = "RuneOpenRequest"

local openRequest = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not (openRequest and openRequest:IsA("RemoteEvent")) then
	openRequest = Instance.new("RemoteEvent")
	openRequest.Name = REMOTE_NAME
	openRequest.Parent = ReplicatedStorage
end

local function getKeysValue(player: Player): NumberValue?
	local currencies = player:FindFirstChild("Currencies")
	if not currencies then return nil end
	local keys = currencies:FindFirstChild("Keys")
	if keys and keys:IsA("NumberValue") then
		return keys
	end
	return nil
end

openRequest.OnServerEvent:Connect(function(player, n)
	if not player or not player:IsA("Player") then
		return
	end
	if player:GetAttribute("PlayerDataLoaded") ~= true then
		return
	end

	local k = tonumber(n)
	if k ~= 1 and k ~= 3 then
		return
	end

	local keysVal = getKeysValue(player)
	if not keysVal then
		return
	end

	if keysVal.Value < k then
		return
	end

	keysVal.Value -= k
end)

