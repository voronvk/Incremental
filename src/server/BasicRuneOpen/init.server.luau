local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Este script funciona aunque `RunesConfig.Enabled` esté en false.
-- Al abrir (x1/x3): gasta Keys y otorga runas, guardando cantidades en RunesInventoryJson.

local REMOTE_NAME = "RuneOpenRequest"
local INVENTORY_CHANGED_REMOTE = "RuneInventoryChanged"
local CATEGORY_BASIC = "BasicRune"
local CATEGORY_GOLD = "GoldRune"
local CURRENCY_KEYS = "Keys"
local CURRENCY_GOLD = "Gold"

local serverRoot = ServerScriptService:WaitForChild("Server")
local runesService = require(serverRoot:WaitForChild("Runes"):WaitForChild("Service"))

local openRequest = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not (openRequest and openRequest:IsA("RemoteEvent")) then
	openRequest = Instance.new("RemoteEvent")
	openRequest.Name = REMOTE_NAME
	openRequest.Parent = ReplicatedStorage
end

local inventoryChanged = ReplicatedStorage:FindFirstChild(INVENTORY_CHANGED_REMOTE)
if not (inventoryChanged and inventoryChanged:IsA("RemoteEvent")) then
	inventoryChanged = Instance.new("RemoteEvent")
	inventoryChanged.Name = INVENTORY_CHANGED_REMOTE
	inventoryChanged.Parent = ReplicatedStorage
end

local function getCurrencyValue(player: Player, currencyName: string): NumberValue?
	local currencies = player:FindFirstChild("Currencies")
	if not currencies then return nil end
	local value = currencies:FindFirstChild(currencyName)
	if value and value:IsA("NumberValue") then
		return value
	end
	return nil
end

openRequest.OnServerEvent:Connect(function(player, n, category, currencyName)
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
	local categoryName = tostring(category or CATEGORY_BASIC)
	if categoryName ~= CATEGORY_BASIC and categoryName ~= CATEGORY_GOLD then
		return
	end
	local currency = tostring(currencyName or CURRENCY_KEYS)
	if currency ~= CURRENCY_KEYS and currency ~= CURRENCY_GOLD then
		return
	end

	local currencyVal = getCurrencyValue(player, currency)
	if not currencyVal then
		return
	end

	if currencyVal.Value < k then
		return
	end

	currencyVal.Value -= k

	local lastGrantRes = nil
	for _ = 1, k do
		lastGrantRes = runesService.grantRandomRune(player, categoryName)
	end

	if inventoryChanged and inventoryChanged:IsA("RemoteEvent") then
		local inv = runesService.getInventorySummary(player)
		inventoryChanged:FireClient(player, {
			lastRuneId = lastGrantRes and lastGrantRes.runeId or nil,
			newCount = lastGrantRes and lastGrantRes.newCount or nil,
			counts = inv.counts,
			multipliers = inv.multipliers,
		})
	end
end)

