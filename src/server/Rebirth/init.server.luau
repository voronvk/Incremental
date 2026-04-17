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
	if not RunService:IsStudio() then
		warn(
			"[Rebirth] RebirthEvent sigue siendo RemoteEvent en producción; publica con Rojo (RemoteFunction) o sustituye el remoto en el lugar."
		)
		return
	end
	existing:Destroy()
	local rf = Instance.new("RemoteFunction")
	rf.Name = "RebirthEvent"
	rf.Parent = ReplicatedStorage
	print("[Rebirth] Studio: RebirthEvent migrado RemoteEvent → RemoteFunction")
end

ensureRebirthEventIsRemoteFunction()

-- NO bloquear todo el script si faltan (mapa viejo): antes el bind de RebirthEvent quedaba después y nunca se ejecutaba.
local clearCornEvent: Instance? = nil
local plotRebirthEvent: Instance? = nil
local FloodCheck = require(ServerScriptService.Server:WaitForChild("RemoteFloodCheck") :: ModuleScript)
local RebirthRules = require(ReplicatedStorage.Shared:WaitForChild("RebirthRules"))
local RebirthCornGain = require(ReplicatedStorage.Shared:WaitForChild("RebirthCornGain"))

local BASE_COST = RebirthRules.UpgradesRebirthBoard.CornChunkSize
-- Bucle pasivo: umbral de melón alto (no acoplar al botón de parcela; ese puede ser más bajo).
local AUTO_GAIN_MIN_MELON = 100

local MAX_SAFE_VALUE = 1e300
-- Por float64 el producto chunks * mults puede ser inf/nan; sin esto el maíz se resetea y la moneda de prestigio casi no sube.
local MAX_REBIRTHS_PER_MANUAL_ACTION = 1e20

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
	for attempt = 1, 3 do
		chunks = math.floor(corn.Value / chunkSize)
		if chunks >= 1 and corn.Value >= rules.MinCorn then
			cornOk = true
			break
		end
		if attempt < 3 then
			task.wait(0.08)
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

-- Prestigio solo minijuego tapping: +TappingRebirths fijo, reset melón/taps/upgrades de tapping. No maíz ni Rebirths.
local function processTappingPlotRebirth(player)
	local rules = RebirthRules.PlotRebirthBoard
	local currencies = player:FindFirstChild("Currencies")
	local events = player:FindFirstChild("Events")
	local leaderstats = player:FindFirstChild("leaderstats")

	if not currencies or not events or not leaderstats then
		rebirthDebug(player, "PlotRebirth (tapping) reject: faltan Currencies/Events/leaderstats")
		return
	end

	local taps = leaderstats:FindFirstChild("Taps")
	local tappingRebirths = currencies:FindFirstChild("TappingRebirths")
	local timesTappingRebirthed = events:FindFirstChild("TimesTappingRebirthed")
	local melonLevel = events:FindFirstChild("MelonLevel")
	local melonXp = events:FindFirstChild("MelonXp")
	local dmg = events:FindFirstChild("TappingDamageLevel")
	local xpB = events:FindFirstChild("TappingXpBonus")
	local crit = events:FindFirstChild("TappingCritLevel")

	if not taps or not taps:IsA("NumberValue") then
		rebirthDebug(player, "PlotRebirth (tapping) reject: sin leaderstats.Taps")
		return
	end
	if not tappingRebirths or not tappingRebirths:IsA("NumberValue") then
		rebirthDebug(player, "PlotRebirth (tapping) reject: sin TappingRebirths")
		return
	end
	if not timesTappingRebirthed or not timesTappingRebirthed:IsA("NumberValue") then
		rebirthDebug(player, "PlotRebirth (tapping) reject: sin TimesTappingRebirthed")
		return
	end

	if rules.MinMelonLevel > 0 then
		if not melonLevel or melonLevel.Value < rules.MinMelonLevel then
			rebirthDebug(
				player,
				"PlotRebirth (tapping) reject: MelonLevel "
					.. (melonLevel and melonLevel.Value or "nil")
					.. " < "
					.. rules.MinMelonLevel
			)
			return
		end
	end

	local gainFixed = rules.TappingRebirthGainFixed
	if type(gainFixed) ~= "number" or gainFixed < 1 then
		gainFixed = 1
	end
	gainFixed = math.floor(gainFixed)

	addRebirthCurrency(tappingRebirths, gainFixed)
	timesTappingRebirthed.Value = timesTappingRebirthed.Value + 1

	taps.Value = 0
	if melonLevel and melonLevel:IsA("ValueBase") then
		melonLevel.Value = 1
	end
	local mx = melonXp or events:FindFirstChild("MelonXp")
	if mx and mx:IsA("ValueBase") then
		mx.Value = 0
	end
	if dmg and dmg:IsA("ValueBase") then
		dmg.Value = 0
	end
	if xpB and xpB:IsA("ValueBase") then
		xpB.Value = 0
	end
	if crit and crit:IsA("ValueBase") then
		crit.Value = 0
	end

	rebirthDebug(
		player,
		"OK PlotRebirth tapping → TappingRebirths: +"
			.. gainFixed
			.. " (fijo); reset solo taps/melón/upgrades tapping (sin tocar maíz ni Rebirths)"
	)
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
				return { ok = false, reason = "server_exception" }
			end
			if type(res) ~= "table" then
				return { ok = false, reason = "bad_result" }
			end
			return res
		end
	elseif ev:IsA("RemoteEvent") then
		-- Mapas viejos con RemoteEvent: mismo procesamiento, sin retorno al cliente.
		ev.OnServerEvent:Connect(function(player)
			rebirthDebug(player, "OnServerEvent UpgradesRebirthBoard (legacy)")
			local ok, err = pcall(processManualRebirth, player, UPGRADES_REBIRTH_RULES)
			if not ok then
				warn("[Rebirth srv] ERROR UpgradesRebirthBoard:", player and player.Name or "?", tostring(err))
			end
		end)
	end
end

local rebirthEvent0 = ReplicatedStorage:WaitForChild("RebirthEvent", 60)
if rebirthEvent0 then
	-- Quitar marca vieja que podía bloquear el bind por replicación desde cliente.
	pcall(function()
		rebirthEvent0:SetAttribute("_RebirthMaizeSrv", nil)
	end)
	bindUpgradeBoardRebirth(rebirthEvent0)
else
	warn("[Rebirth] Timeout esperando RebirthEvent (60s). Rebirth maíz desactivado hasta que exista.")
end
ReplicatedStorage.ChildAdded:Connect(function(ch)
	if ch.Name ~= "RebirthEvent" then
		return
	end
	task.defer(function()
		pcall(function()
			ch:SetAttribute("_RebirthMaizeSrv", nil)
		end)
		bindUpgradeBoardRebirth(ch)
	end)
end)

clearCornEvent = ReplicatedStorage:WaitForChild("ClearLocalCornEvent", 8)
if not clearCornEvent then
	warn("[Rebirth] Sin ClearLocalCornEvent tras 8s; rebirth maíz sigue, sin limpiar maíz local del cliente.")
end
plotRebirthEvent = ReplicatedStorage:WaitForChild("PlotRebirthEvent", 8)
if plotRebirthEvent and plotRebirthEvent:IsA("RemoteEvent") then
	plotRebirthEvent.OnServerEvent:Connect(function(player)
		if not FloodCheck:Check(player, plotRebirthEvent :: RemoteEvent, 10) then
			return
		end
		local ok, err = pcall(function()
			processTappingPlotRebirth(player)
		end)
		if not ok then
			warn("[Rebirth srv] ERROR PlotRebirth (tapping):", player and player.Name or "?", tostring(err))
		end
	end)
elseif plotRebirthEvent then
	warn("[Rebirth] PlotRebirthEvent no es RemoteEvent:", plotRebirthEvent.ClassName)
else
	warn("[Rebirth] Sin PlotRebirthEvent tras 8s; rebirth de parcela desactivado.")
end

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
