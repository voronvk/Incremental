local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- Lugares antiguos: RebirthEvent como RemoteEvent. default.project.json usa RemoteFunction (InvokeServer).
local function ensureRebirthEventIsRemoteFunction()
	local existing = ReplicatedStorage:FindFirstChild("RebirthEvent")
	if not existing or existing:IsA("RemoteFunction") then
		return
	end
	if not existing:IsA("RemoteEvent") then
		warn("[Rebirth] RebirthEvent es", existing.ClassName, "(se espera RemoteFunction).")
		return
	end
	-- Migrar siempre: InvokeServer devuelve resultado al instante y evita flujos legacy frágiles en cliente.
	existing:Destroy()
	local rf = Instance.new("RemoteFunction")
	rf.Name = "RebirthEvent"
	rf.Parent = ReplicatedStorage
	print("[Rebirth] RebirthEvent migrado RemoteEvent → RemoteFunction")
end

ensureRebirthEventIsRemoteFunction()

-- NO bloquear todo el script si faltan (mapa viejo): antes el bind de RebirthEvent quedaba después y nunca se ejecutaba.
local clearCornEvent: Instance? = nil
local rebirthMaizeDone: RemoteEvent? = nil
local RebirthRules = require(ReplicatedStorage.Shared:WaitForChild("RebirthRules"))
local RebirthCornGain = require(ReplicatedStorage.Shared:WaitForChild("RebirthCornGain"))

local BASE_COST = RebirthRules.UpgradesRebirthBoard.CornChunkSize
-- Bucle pasivo: umbral de melón alto (no acoplar al botón de parcela; ese puede ser más bajo).
local AUTO_GAIN_MIN_MELON = 100

local MAX_SAFE_VALUE = 1e300
-- Por float64 el producto chunks * mults puede ser inf/nan; sin esto el maíz se resetea y la moneda de prestigio casi no sube.
-- Debe alinearse con RebirthCornGain (tope por acción); antes 1e20 capaba como ~100Qn por rebirth.
local MAX_REBIRTHS_PER_MANUAL_ACTION = MAX_SAFE_VALUE

local function isFiniteNumber(n)
	return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end

local function clampFinite(n, fallback)
	if not isFiniteNumber(n) then
		return fallback
	end
	return math.clamp(n, -MAX_SAFE_VALUE, MAX_SAFE_VALUE)
end

local function rebirthDebug(player, msg)
	if RunService:IsStudio() or player:GetAttribute("DebugRebirthGUI") == true then
		print("[Rebirth srv]", player.Name, msg)
	end
end

local function addRebirthCurrency(counter: ValueBase, gainRounded: number)
	local now = clampFinite(counter.Value, 0)
	local add = math.floor(math.max(0, gainRounded))
	if add < 1 then
		return
	end
	local sum = now + add
	if not isFiniteNumber(sum) or sum <= now then
		sum = math.min(MAX_SAFE_VALUE, now + math.min(add, MAX_REBIRTHS_PER_MANUAL_ACTION))
		if not isFiniteNumber(sum) or sum <= now then
			sum = math.min(MAX_SAFE_VALUE, now + 1)
		end
	end
	counter.Value = clampFinite(sum, now)
end

-- Devuelve tabla si el remoto es RemoteFunction; con RemoteEvent el servidor ignora el retorno.
local function processManualRebirth(player, rules)
	local currencies = player:FindFirstChild("Currencies")
	local upgrades = player:FindFirstChild("Upgrades")
	local events = player:FindFirstChild("Events")

	if not currencies or not upgrades or not events then
		rebirthDebug(player, "reject: faltan Currencies/Upgrades/Events")
		return { ok = false, reason = "missing_player_folders" }
	end

	local corn = currencies:FindFirstChild("Corn")
	local rebirths = currencies:FindFirstChild("Rebirths")
	local playtime = events:FindFirstChild("Playtime")
	local timesRebirthed = events:FindFirstChild("TimesRebirthed")
	local spawnRate = upgrades:FindFirstChild("SpawnRateUpg1")
	local cornValue = upgrades:FindFirstChild("CornValueUpg1")
	local cornAmount = upgrades:FindFirstChild("CornAmountUpg1")

	if not corn or not rebirths or not playtime or not timesRebirthed then
		rebirthDebug(player, "reject: faltan Corn/Rebirths/Playtime/TimesRebirthed")
		return { ok = false, reason = "missing_corn_or_rebirth_stats" }
	end
	if not spawnRate or not cornValue or not cornAmount then
		rebirthDebug(player, "reject: faltan SpawnRateUpg1/CornValueUpg1/CornAmountUpg1")
		return { ok = false, reason = "missing_corn_upgrades" }
	end

	local chunkSize = rules.CornChunkSize
	if chunkSize < 1 then
		rebirthDebug(player, "reject: CornChunkSize invalido")
		return { ok = false, reason = "bad_chunk_size" }
	end
	-- Varios intentos: el maíz en servidor a veces va varios ticks por detrás del cliente.
	local chunks = 0
	local cornOk = false
	for attempt = 1, 8 do
		chunks = math.floor(corn.Value / chunkSize)
		if chunks >= 1 and corn.Value >= rules.MinCorn then
			cornOk = true
			break
		end
		if attempt < 8 then
			task.wait(0.12)
		end
	end
	if not cornOk then
		rebirthDebug(
			player,
			"reject: maiz servidor "
				.. corn.Value
				.. " (min "
				.. rules.MinCorn
				.. ", chunks "
				.. chunks
				.. ")"
		)
		return { ok = false, reason = "corn_low_on_server" }
	end

	local snap = RebirthCornGain.snapshot(player)
	local gainRounded = snap and RebirthCornGain.manualGainRounded(snap, chunks) or nil
	if gainRounded == nil then
		warn(
			"[Rebirth] RebirthCornGain.manualGainRounded nil → gain=1 fallback para "
				.. player.Name
				.. " chunks="
				.. tostring(chunks)
		)
		rebirthDebug(player, "warn: formula rebirth nil → gain forzado a 1")
		gainRounded = 1
	end

	addRebirthCurrency(rebirths, gainRounded)
	timesRebirthed.Value = timesRebirthed.Value + 1
	corn.Value = 0
	spawnRate.Value = 0
	cornValue.Value = 0
	cornAmount.Value = 0

	if clearCornEvent and clearCornEvent:IsA("RemoteEvent") then
		pcall(function()
			(clearCornEvent :: RemoteEvent):FireClient(player)
		end)
	end
	rebirthDebug(player, "OK rebirth maíz → Rebirths: +" .. gainRounded .. ", maíz/upgrades maíz a 0 (sin tocar tapping)")
	return { ok = true, gain = gainRounded }
end

local function ensureRebirthMaizeAckRemote(): RemoteEvent?
	local x = ReplicatedStorage:FindFirstChild("RebirthMaizeDone")
	if x and x:IsA("RemoteEvent") then
		return x
	end
	if x ~= nil then
		warn("[Rebirth] RebirthMaizeDone existe pero no es RemoteEvent:", x.ClassName)
		return nil
	end
	local e = Instance.new("RemoteEvent")
	e.Name = "RebirthMaizeDone"
	e.Parent = ReplicatedStorage
	print("[Rebirth] Creado RebirthMaizeDone (faltaba en ReplicatedStorage).")
	return e
end

local function fireRebirthMaizeAck(player: Player, res: { ok: boolean, reason: string?, gain: number? }?)
	if not (rebirthMaizeDone and rebirthMaizeDone.Parent) then
		rebirthMaizeDone = ensureRebirthMaizeAckRemote()
	end
	if not rebirthMaizeDone then
		return
	end
	local ok = res and res.ok == true
	local reason = (res and type(res.reason) == "string" and res.reason) or ""
	pcall(function()
		rebirthMaizeDone:FireClient(player, ok, reason)
	end)
end

local rebirthMaizeBound: { [Instance]: boolean } = {}
local UPGRADES_REBIRTH_RULES = RebirthRules.UpgradesRebirthBoard

local function bindUpgradeBoardRebirth(ev: Instance)
	if not ev then
		return
	end
	if rebirthMaizeBound[ev] then
		return
	end
	if not ev:IsA("RemoteFunction") and not ev:IsA("RemoteEvent") then
		warn("[Rebirth] RebirthEvent no es RemoteEvent/RemoteFunction:", ev.ClassName, ev:GetFullName())
		return
	end
	rebirthMaizeBound[ev] = true
	if ev:IsA("RemoteFunction") then
		ev.OnServerInvoke = function(player)
			rebirthDebug(player, "OnServerInvoke UpgradesRebirthBoard")
			local ok, res = pcall(processManualRebirth, player, UPGRADES_REBIRTH_RULES)
			if not ok then
				warn("[Rebirth srv] ERROR UpgradesRebirthBoard:", player and player.Name or "?", tostring(res))
				local fail = { ok = false, reason = "server_exception" }
				fireRebirthMaizeAck(player, fail)
				return fail
			end
			if type(res) ~= "table" then
				local fail = { ok = false, reason = "bad_result" }
				fireRebirthMaizeAck(player, fail)
				return fail
			end
			fireRebirthMaizeAck(player, res)
			return res
		end
	elseif ev:IsA("RemoteEvent") then
		-- Mapas viejos con RemoteEvent: mismo procesamiento, sin retorno al cliente.
		ev.OnServerEvent:Connect(function(player)
			rebirthDebug(player, "OnServerEvent UpgradesRebirthBoard (legacy)")
			local invokeOk, payload = pcall(processManualRebirth, player, UPGRADES_REBIRTH_RULES)
			local res: { ok: boolean, reason: string?, gain: number? }
			if invokeOk then
				res = payload :: any
			else
				warn("[Rebirth srv] ERROR UpgradesRebirthBoard:", player and player.Name or "?", tostring(payload))
				res = { ok = false, reason = "server_exception" }
			end
			if type(res) ~= "table" then
				res = { ok = false, reason = "bad_result" }
			end
			fireRebirthMaizeAck(player, res)
		end)
	end
end

rebirthMaizeDone = ensureRebirthMaizeAckRemote()

local rebirthEvent0 = ReplicatedStorage:WaitForChild("RebirthEvent", 60)
if rebirthEvent0 then
	-- Si RebirthEvent era nil en el primer ensure(), aquí puede ser RemoteEvent viejo: migrar antes de bind.
	ensureRebirthEventIsRemoteFunction()
	rebirthEvent0 = ReplicatedStorage:WaitForChild("RebirthEvent", 5)
	if not rebirthEvent0 then
		warn("[Rebirth] RebirthEvent no reapareció tras migración (5s); rebirth maíz desactivado.")
	else
		-- Quitar marca vieja que podía bloquear el bind por replicación desde cliente.
		pcall(function()
			rebirthEvent0:SetAttribute("_RebirthMaizeSrv", nil)
		end)
		bindUpgradeBoardRebirth(rebirthEvent0)
	end
else
	warn("[Rebirth] Timeout esperando RebirthEvent (60s). Rebirth maíz desactivado hasta que exista.")
end
ReplicatedStorage.ChildAdded:Connect(function(ch)
	if ch.Name ~= "RebirthEvent" then
		return
	end
	task.defer(function()
		ensureRebirthEventIsRemoteFunction()
		local ev = ReplicatedStorage:FindFirstChild("RebirthEvent")
		if not ev then
			return
		end
		pcall(function()
			ev:SetAttribute("_RebirthMaizeSrv", nil)
		end)
		bindUpgradeBoardRebirth(ev)
	end)
end)

clearCornEvent = ReplicatedStorage:WaitForChild("ClearLocalCornEvent", 8)
if not clearCornEvent then
	warn("[Rebirth] Sin ClearLocalCornEvent tras 8s; rebirth maíz sigue, sin limpiar maíz local del cliente.")
end
-- PlotRebirthEvent / tapping prestige: desactivado (RebirthRules.PlotRebirthBoard.Enabled = false).

task.spawn(function()
	while true do
		for _, player in pairs(game.Players:GetPlayers()) do
			local currencies = player:FindFirstChild("Currencies")
			local upgrades = player:FindFirstChild("Upgrades")
			local events = player:FindFirstChild("Events")

			if currencies and upgrades and events then
				local corn = currencies:FindFirstChild("Corn")
				local rebirths = currencies:FindFirstChild("Rebirths")
				local tier = upgrades:FindFirstChild("Tier")
				local melonLevel = events:FindFirstChild("MelonLevel")

				if corn and rebirths and tier and melonLevel then
					if tier.Value >= 4 and melonLevel.Value >= AUTO_GAIN_MIN_MELON and corn.Value >= BASE_COST then
						local snap = RebirthCornGain.snapshot(player)
						if snap then
							local gain = RebirthCornGain.passiveGainRounded(snap, corn.Value, BASE_COST)
							addRebirthCurrency(rebirths, gain)
						end
					end
				end
			end
		end
		task.wait(1)
	end
end)
