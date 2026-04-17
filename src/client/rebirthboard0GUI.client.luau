-- SOLO rebirth de Upgrades / maíz: workspace…RebirthBoard0 → ReplicatedStorage.RebirthEvent (maíz → moneda Rebirths).
-- No PlotRebirthEvent ni TappingRebirths; no requisitos del melón de tapping.
-- InvokeServer / FireServer → { ok, reason?, gain? } si es RemoteFunction. Debug: SetAttribute("DebugRebirthGUI", true)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")

local RebirthRules = require(ReplicatedStorage.Shared:WaitForChild("RebirthRules"))
local RebirthCornGain = require(ReplicatedStorage.Shared:WaitForChild("RebirthCornGain"))
local upgradesRules = RebirthRules.UpgradesRebirthBoard

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local events = player:WaitForChild("Events")
local rebirths = currencies:WaitForChild("Rebirths")
local corn = currencies:WaitForChild("Corn")
local timesRebirthed = events:WaitForChild("TimesRebirthed")

local upgradeEvent = ReplicatedStorage:WaitForChild("RebirthEvent")

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://140206660137491"
sound.Parent = SoundService

local function checkmuted()
	local settings = player:FindFirstChild("Settings")
	local sfx = settings and settings:FindFirstChild("SfxMuted")
	if sfx and sfx:IsA("ValueBase") and sfx.Value >= 1 then
		sound.Volume = 0
	else
		sound.Volume = 1
	end
end

local RebirthCost = upgradesRules.MinCorn

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))
local upgTree1 = upgrades:WaitForChild("UpgTree1")
local rebirthValue = upgrades:WaitForChild("RebirthValueUpg1")
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
local REBIRTHS_GAMEPASS_ID = 1740115835

local function debugRebirthGuiEnabled()
	return RunService:IsStudio() or player:GetAttribute("DebugRebirthGUI") == true
end

local LOG_TAG = "[RebirthBoard0·maíz]"

local function dbg(msg)
	if debugRebirthGuiEnabled() then
		print(LOG_TAG, msg)
	end
end

local lastPickFailLog = 0
local function dbgPickThrottled(detail)
	if not debugRebirthGuiEnabled() then
		return
	end
	local t = tick()
	if t - lastPickFailLog < 4 then
		return
	end
	lastPickFailLog = t
	warn(LOG_TAG .. " no bind RebirthBoard0: " .. detail)
end

local function packBoardAndClick(board, holder)
	if not board or not holder then
		return nil, nil, nil
	end
	local click = holder
	if not holder:IsA("GuiButton") then
		click = holder:FindFirstChildWhichIsA("GuiButton", true)
	end
	if click and click:IsA("GuiButton") then
		return board, click, holder
	end
	return nil, nil, nil
end

-- Solo rutas conocidas (sin GetDescendants del Workspace).
local function pickRebirthTargets()
	local uf = workspace:FindFirstChild("Upgrades")
	if not uf then
		dbgPickThrottled("Workspace sin carpeta Upgrades")
	else
		local board = uf:FindFirstChild("RebirthBoard0")
		if not board then
			dbgPickThrottled("Upgrades sin hijo RebirthBoard0")
		else
			local gui = board:FindFirstChild("UpgradeGUI") or board:FindFirstChild("UpgradeGUI", true)
			if not gui then
				dbgPickThrottled("RebirthBoard0 sin UpgradeGUI")
			else
				local holder = gui:FindFirstChild("UpgradeButton") or gui:FindFirstChild("UpgradeButton", true)
				if not holder then
					dbgPickThrottled("UpgradeGUI sin UpgradeButton")
				else
					local b, c, h = packBoardAndClick(board, holder)
					if b then
						return b, c, h
					end
					dbgPickThrottled(
						"UpgradeButton es "
							.. holder.ClassName
							.. " y no contiene GuiButton (pon TextButton/ImageButton dentro o hazlo GuiButton)"
					)
				end
			end
		end
	end

	local root = workspace:FindFirstChild("RebirthBoard0")
	if root then
		local holder = root:FindFirstChild("UpgradeButton", true)
		if holder then
			local b, c, h = packBoardAndClick(root, holder)
			if b then
				return b, c, h
			end
		end
		dbgPickThrottled("Workspace.RebirthBoard0 sin UpgradeButton+GuiButton valido")
	end

	return nil, nil, nil
end

local connections = {}
local coreRebirthConns = {}
local boundBoard = nil
local boundButton = nil

local function disconnectAll()
	for _, c in connections do
		c:Disconnect()
	end
	table.clear(connections)
	table.clear(coreRebirthConns)
end

local function rebirthInputAlive()
	if not boundBoard or not boundButton then
		return false
	end
	if not boundBoard.Parent or not boundButton.Parent then
		return false
	end
	if #coreRebirthConns == 0 then
		return false
	end
	for _, c in coreRebirthConns do
		if c.Connected then
			return true
		end
	end
	return false
end

local function enableWorldLayerGui(g)
	if not g then
		return
	end
	if g:IsA("SurfaceGui") or g:IsA("BillboardGui") then
		g.Enabled = true
		return
	end
	local s = g:FindFirstChildWhichIsA("SurfaceGui", true)
	local b = g:FindFirstChildWhichIsA("BillboardGui", true)
	if s then
		s.Enabled = true
	end
	if b then
		b.Enabled = true
	end
end

local rebirthInFlight = false
local lastRebirthOkTime = 0
local DEBOUNCE_AFTER_OK = 0.28
local lastDebounceDbg = 0

local function waitForPlayerDataLoaded(maxWaitSec: number)
	local t0 = tick()
	while player:GetAttribute("PlayerDataLoaded") ~= true and tick() - t0 < maxWaitSec do
		task.wait(0.05)
	end
end

local function fireRebirthAttempt()
	local t = tick()
	if rebirthInFlight then
		if debugRebirthGuiEnabled() and t - lastDebounceDbg > 2 then
			lastDebounceDbg = t
			dbg("clic ignorado (RebirthEvent maíz en curso)")
		end
		return
	end
	if t - lastRebirthOkTime < DEBOUNCE_AFTER_OK then
		if debugRebirthGuiEnabled() and t - lastDebounceDbg > 2 then
			lastDebounceDbg = t
			dbg("clic ignorado (poco después de rebirth maíz OK)")
		end
		return
	end
	waitForPlayerDataLoaded(45)
	if corn.Value < RebirthCost then
		dbg("clic: maiz cliente " .. corn.Value .. " < " .. RebirthCost .. " (no Invoke)")
		return
	end

	rebirthInFlight = true
	task.spawn(function()
		local okRun, runErr = pcall(function()
			local ev = ReplicatedStorage:FindFirstChild("RebirthEvent") or upgradeEvent
			if not ev then
				warn(LOG_TAG .. " No hay RebirthEvent (maíz) en ReplicatedStorage")
				return
			end

			if ev:IsA("RemoteFunction") then
				local rf = ev :: RemoteFunction
				local function invokeOnce()
					return pcall(function()
						return rf:InvokeServer()
					end)
				end

				dbg("InvokeServer RebirthEvent — maíz cliente=" .. tostring(corn.Value))
				local okInvoke, res = invokeOnce()
				local cornRetries = 0
				while okInvoke and type(res) == "table" and res.ok == false and res.reason == "corn_low_on_server" and cornRetries < 5 do
					cornRetries += 1
					task.wait(0.12)
					okInvoke, res = invokeOnce()
				end

				if okInvoke and type(res) == "table" and res.ok == true then
					lastRebirthOkTime = tick()
					dbg("Rebirth maíz OK (gain Rebirths=" .. tostring(res.gain) .. ")")
					sound:Play()
				elseif okInvoke and type(res) == "table" then
					warn(LOG_TAG .. " Rebirth maíz no aplicado:", tostring(res.reason))
				else
					warn(LOG_TAG .. " InvokeServer RebirthEvent (maíz) falló:", tostring(res))
					if RunService:IsStudio() then
						dbg("[Studio] Usa Play con servidor; solo Cliente no ejecuta OnServerInvoke.")
					end
				end
			elseif ev:IsA("RemoteEvent") then
				-- Lugar antiguo / sin Rojo: sigue siendo RemoteEvent; el servidor ya escucha OnServerEvent.
				dbg(
					"FireServer RebirthEvent (maíz) — RemoteEvent legacy; en Rojo preferible RemoteFunction"
				)
				local prevTimes = timesRebirthed.Value
				local prevRebirths = rebirths.Value
				local okFire, fireErr = pcall(function()
					(ev :: RemoteEvent):FireServer()
				end)
				if not okFire then
					warn(LOG_TAG .. " FireServer RebirthEvent (maíz) falló:", tostring(fireErr))
					return
				end
				task.wait(0.05)
				local deadline = tick() + 8
				local okRebirth = false
				while tick() < deadline do
					if
						timesRebirthed.Value > prevTimes
						or corn.Value < RebirthCost
						or rebirths.Value > prevRebirths
					then
						okRebirth = true
						break
					end
					task.wait(0.03)
				end
				if okRebirth then
					lastRebirthOkTime = tick()
					dbg("Rebirth maíz OK (RemoteEvent; Rebirths/Corn/TimesRebirthed actualizados)")
					sound:Play()
				else
					warn(
						LOG_TAG
							.. " Rebirth de maíz sin confirmar tras RebirthEvent:FireServer. Revisa servidor/RebirthEvent. "
							.. "Esto no es PlotRebirth (tapping). TimesRebirthed="
							.. tostring(timesRebirthed.Value)
							.. ", Corn="
							.. tostring(corn.Value)
							.. ", Rebirths="
							.. tostring(rebirths.Value)
					)
				end
			else
				warn(LOG_TAG .. " RebirthEvent (maíz) debe ser RemoteFunction o RemoteEvent; es:", ev.ClassName)
			end
		end)
		if not okRun then
			warn(LOG_TAG .. " error en rebirth maíz (excepción):", runErr)
		end
		rebirthInFlight = false
	end)
end

local function tryBind()
	local upgradePart, button, paintTarget = pickRebirthTargets()
	if not upgradePart or not button then
		return false
	end
	if not paintTarget or not paintTarget:IsA("GuiObject") then
		paintTarget = button
	end

	if boundBoard == upgradePart and boundButton == button and rebirthInputAlive() then
		return true
	end

	disconnectAll()
	boundBoard = upgradePart
	boundButton = button
	dbg("bind RebirthBoard0 maíz -> " .. button:GetFullName() .. " (board " .. upgradePart:GetFullName() .. ")")

	enableWorldLayerGui(button:FindFirstAncestorWhichIsA("SurfaceGui"))
	enableWorldLayerGui(button:FindFirstAncestorWhichIsA("BillboardGui"))
	local namedGui = upgradePart:FindFirstChild("UpgradeGUI") or upgradePart:FindFirstChild("UpgradeGUI", true)
	if namedGui then
		enableWorldLayerGui(namedGui)
	end

	local effectLabel = upgradePart:FindFirstChild("EffectLabel", true)
	local levelLabel = upgradePart:FindFirstChild("LevelLabel", true)
	local upgradePremium = upgradePart:FindFirstChild("UpgradePremium", true)
	local deco = upgradePart:FindFirstChild("Deco", true)

	local function updatePremiumVisibility()
		if not upgradePremium or not deco then
			return
		end
		local owns = GamePassCheck.playerOwnsGamePass(player, REBIRTHS_GAMEPASS_ID)
		upgradePremium.Visible = not owns
		deco.Visible = not owns
	end

	if upgradePremium then
		local function promptGamepass()
			MarketplaceService:PromptGamePassPurchase(player, REBIRTHS_GAMEPASS_ID)
		end
		local function connectGamepassClick(obj)
			if not obj:IsA("GuiButton") or obj == button then
				return
			end
			table.insert(connections, obj.Activated:Connect(promptGamepass))
			table.insert(connections, obj.MouseButton1Click:Connect(promptGamepass))
		end
		connectGamepassClick(upgradePremium)
		for _, d in upgradePremium:GetDescendants() do
			if d:IsA("GuiButton") and d ~= button then
				connectGamepassClick(d)
			end
		end
		table.insert(connections, player:GetAttributeChangedSignal("GamePassSyncStamp"):Connect(updatePremiumVisibility))
		updatePremiumVisibility()
	end

	local function getCost()
		return math.floor(RebirthCost)
	end

	local function updateLabel()
		if not effectLabel or not levelLabel then
			return
		end
		local cost = getCost()
		-- Misma fórmula que el servidor (tier, árboles, boosts temporales, gamepass, GoldTreeP3, UpgTree2_10, etc.).
		local bonus = RebirthCornGain.previewManualGain(
			player,
			corn.Value,
			upgradesRules.CornChunkSize,
			upgradesRules.MinCorn
		)
		effectLabel.Text = string.format("Rebirths %s (+%s)", Abbreviate(math.floor(rebirths.Value)), Abbreviate(bonus))
		levelLabel.Text = "Rebirths: " .. tostring(rebirths.Value)

		local canRebirth = corn.Value >= cost
		if paintTarget:IsA("GuiObject") then
			if canRebirth then
				paintTarget.BackgroundColor3 = Color3.new(0, 1, 0)
			else
				paintTarget.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
			end
		end
		if button:IsA("GuiButton") then
			button.Active = true
			button.AutoButtonColor = canRebirth
		end
	end

	if effectLabel and levelLabel then
		updateLabel()
		table.insert(connections, rebirths:GetPropertyChangedSignal("Value"):Connect(updateLabel))
		table.insert(connections, corn:GetPropertyChangedSignal("Value"):Connect(updateLabel))
		table.insert(connections, rebirthValue:GetPropertyChangedSignal("Value"):Connect(updateLabel))
		table.insert(connections, upgTree1:GetPropertyChangedSignal("Value"):Connect(updateLabel))
		local function connectIfValue(inst: Instance?, sig: string)
			if inst and inst:IsA("ValueBase") then
				table.insert(connections, inst:GetPropertyChangedSignal(sig):Connect(updateLabel))
			end
		end
		connectIfValue(upgrades:FindFirstChild("UpgTree3"), "Value")
		connectIfValue(upgrades:FindFirstChild("UpgTree5"), "Value")
		connectIfValue(upgrades:FindFirstChild("UpgTree6"), "Value")
		connectIfValue(upgrades:FindFirstChild("RebirthValueUpg2"), "Value")
		connectIfValue(upgrades:FindFirstChild("RebirthEnergy"), "Value")
		connectIfValue(upgrades:FindFirstChild("Tier"), "Value")
		connectIfValue(upgrades:FindFirstChild("UpgTree2_3"), "Value")
		connectIfValue(upgrades:FindFirstChild("UpgTree2_10"), "Value")
		connectIfValue(upgrades:FindFirstChild("GoldTreeP3"), "Value")
		connectIfValue(events:FindFirstChild("Playtime"), "Value")
		local evBoostEnd = events:FindFirstChild("RebirthBoostEndTime")
		local evBoostMul = events:FindFirstChild("RebirthBoostMultiplier")
		local evLuckEnd = events:FindFirstChild("LuckAllBoostEndTime")
		local evLuckAdd = events:FindFirstChild("LuckAllBoostAdd")
		connectIfValue(evBoostEnd, "Value")
		connectIfValue(evBoostMul, "Value")
		connectIfValue(events:FindFirstChild("AscensionBoostEndTime"), "Value")
		connectIfValue(events:FindFirstChild("AscensionBoostMultiplier"), "Value")
		connectIfValue(evLuckEnd, "Value")
		connectIfValue(evLuckAdd, "Value")
		table.insert(
			connections,
			player:GetAttributeChangedSignal("OwnsGP_" .. tostring(REBIRTHS_GAMEPASS_ID)):Connect(updateLabel)
		)
	end

	-- Solo Activated: evita doble InvokeServer por el mismo toque.
	if button:IsA("GuiButton") then
		local ca = button.Activated:Connect(fireRebirthAttempt)
		table.insert(connections, ca)
		table.insert(coreRebirthConns, ca)
	end

	return true
end

local bindScheduled = false
local function scheduleTryBind()
	if bindScheduled then
		return
	end
	bindScheduled = true
	task.defer(function()
		bindScheduled = false
		tryBind()
	end)
end

for _ = 1, 900 do
	if tryBind() then
		break
	end
	task.wait(0.1)
end

if not boundBoard then
	warn("[rebirthboard0GUI] No hay RebirthBoard0 usable: Upgrades/RebirthBoard0/UpgradeGUI + GuiButton.")
end

local watchedUpgrades = {}
local function watchUpgrades(uf)
	for _, f in ipairs(watchedUpgrades) do
		if f == uf then
			return
		end
	end
	table.insert(watchedUpgrades, uf)
	uf.DescendantAdded:Connect(function(desc)
		local n = desc.Name
		if n == "RebirthBoard0" or n == "UpgradeGUI" or n == "UpgradeButton" then
			scheduleTryBind()
		end
	end)
end

workspace.ChildAdded:Connect(function(child)
	if child.Name == "RebirthBoard0" then
		scheduleTryBind()
	end
	if child.Name == "Upgrades" then
		watchUpgrades(child)
		child.ChildAdded:Connect(function(c)
			if c.Name == "RebirthBoard0" then
				scheduleTryBind()
			end
		end)
	end
end)

local uf0 = workspace:FindFirstChild("Upgrades")
if uf0 then
	watchUpgrades(uf0)
	uf0.ChildAdded:Connect(function(c)
		if c.Name == "RebirthBoard0" then
			scheduleTryBind()
		end
	end)
end

workspace.DescendantAdded:Connect(function(d)
	if d.Name ~= "UpgradeButton" then
		return
	end
	local a = d.Parent
	while a do
		if a.Name == "RebirthBoard0" then
			scheduleTryBind()
			break
		end
		a = a.Parent
	end
end)

task.spawn(function()
	while true do
		task.wait(3)
		if not rebirthInputAlive() then
			dbg("conexiones muertas: re-bind RebirthBoard0 (maíz)")
			disconnectAll()
			boundBoard = nil
			boundButton = nil
			tryBind()
		end
	end
end)

player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkmuted)
checkmuted()
