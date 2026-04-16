local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RunesService = require(script:WaitForChild("Service"))
local RunesConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RunesConfig"))

-- Sistema desactivado por defecto: no crea remotes ni concede runas.
if RunesConfig.Enabled ~= true then
	return
end

local REMOTE_GET_INVENTORY = "RuneGetInventory"
local REMOTE_INVENTORY_CHANGED = "RuneInventoryChanged"
local REMOTE_OPEN_REQUEST = "RuneOpenRequest"

local function getOrCreateRemoteEvent(name)
	local r = ReplicatedStorage:FindFirstChild(name)
	if r and r:IsA("RemoteEvent") then
		return r
	end
	if not r then
		r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = ReplicatedStorage
		return r
	end
	return nil
end

local function getOrCreateRemoteFunction(name)
	local r = ReplicatedStorage:FindFirstChild(name)
	if r and r:IsA("RemoteFunction") then
		return r
	end
	if not r then
		r = Instance.new("RemoteFunction")
		r.Name = name
		r.Parent = ReplicatedStorage
		return r
	end
	return nil
end

local getInventoryFn = getOrCreateRemoteFunction(REMOTE_GET_INVENTORY)
local inventoryChanged = getOrCreateRemoteEvent(REMOTE_INVENTORY_CHANGED)
local openRequest = getOrCreateRemoteEvent(REMOTE_OPEN_REQUEST)

if getInventoryFn then
	getInventoryFn.OnServerInvoke = function(player)
		local res = RunesService.getInventorySummary(player)
		return res
	end
end

if not inventoryChanged then
	warn("[Runes] No se pudo crear RemoteEvent:", REMOTE_INVENTORY_CHANGED)
end

if not openRequest then
	warn("[Runes] No se pudo crear RemoteEvent:", REMOTE_OPEN_REQUEST)
end

-- Debounce por jugador para evitar grants repetidos por la misma colision.
local lastGrantAtByUserId = {}
local GRANT_COOLDOWN_SEC = 0.75

local function getPlayerFromTouchedPart(otherPart)
	if not otherPart or not otherPart:IsA("BasePart") then
		return nil
	end
	local character = otherPart:FindFirstAncestorOfClass("Model")
	if not character then
		return nil
	end
	return Players:GetPlayerFromCharacter(character)
end

local function connectBasicRuneTouch()
	local basicRune = Workspace:FindFirstChild("BasicRune")
	if not basicRune then
		warn("[Runes] No existe Workspace.BasicRune. El roll por toque no se conectara.")
		return
	end

	local runeParts = {}
	for _, desc in ipairs(basicRune:GetDescendants()) do
		if desc:IsA("BasePart") then
			table.insert(runeParts, desc)
		end
	end

	if #runeParts == 0 then
		warn("[Runes] Workspace.BasicRune no tiene BaseParts para touch.")
		return
	end

	for _, part in ipairs(runeParts) do
		part.Touched:Connect(function(otherPart)
			local player = getPlayerFromTouchedPart(otherPart)
			if not player then
				return
			end
			-- Evita otorgar runas antes de cargar DataStore (para no pisar inventario).
			if player:GetAttribute("PlayerDataLoaded") ~= true then
				return
			end

			local now = os.clock()
			local uid = player.UserId
			local last = lastGrantAtByUserId[uid] or 0
			if now - last < GRANT_COOLDOWN_SEC then
				return
			end
			lastGrantAtByUserId[uid] = now

			local grantRes = RunesService.grantRandomRune(player)
			if not grantRes or grantRes.ok ~= true then
				return
			end

			if inventoryChanged then
				local inv = RunesService.getInventorySummary(player)
				inventoryChanged:FireClient(player, {
					lastRuneId = grantRes.runeId,
					newCount = grantRes.newCount,
					counts = inv.counts,
					multipliers = inv.multipliers,
				})
			end
		end)
	end
end

connectBasicRuneTouch()

-- Abrir "cajas" (gasta Keys y otorga runas random)
local function getKeysValue(player)
	local currencies = player:FindFirstChild("Currencies")
	if not currencies then return nil end
	local keys = currencies:FindFirstChild("Keys")
	if keys and keys:IsA("NumberValue") then
		return keys
	end
	return nil
end

if openRequest then
	openRequest.OnServerEvent:Connect(function(player, count)
		if not player or not player:IsA("Player") then
			return
		end
		if player:GetAttribute("PlayerDataLoaded") ~= true then
			return
		end
		local n = tonumber(count)
		if not n then return end
		n = math.floor(n)
		if n ~= 1 and n ~= 3 then
			return
		end

		local keysVal = getKeysValue(player)
		if not keysVal then
			return
		end
		if keysVal.Value < n then
			-- No alcanza
			return
		end

		keysVal.Value -= n

		local lastGrantRes = nil
		for _ = 1, n do
			lastGrantRes = RunesService.grantRandomRune(player)
		end

		if inventoryChanged then
			local inv = RunesService.getInventorySummary(player)
			inventoryChanged:FireClient(player, {
				lastRuneId = lastGrantRes and lastGrantRes.runeId or nil,
				newCount = lastGrantRes and lastGrantRes.newCount or nil,
				counts = inv.counts,
				multipliers = inv.multipliers,
			})
		end
	end)
end

