--[[
	Melon en ClientTapping.Tapping.Plot.Melon (clon desde RS.Tapping).
	XP local, LevelGui, LevelUp. Auto-tap: PlayerClientAttributes AUTO_TAP en zona IN_TAPPING_ZONE.
	Mismo flujo que clic manual vía MelonAutoTapBridge (servidor y VFX). Sin pathfinding.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- Mínimo entre taps que cuentan (debe ser menor que AUTO_TAP_INTERVAL_GOLD para premium a 0.1s)
local TAP_COOLDOWN = 0.08
local AUTO_TAP_INTERVAL_BASIC = 1.0
local AUTO_TAP_INTERVAL_GOLD = 0.1
-- Squash muy suave (más cerca de 1 = menos movimiento)
local MELON_CLICK_SCALE = 0.97
local SCALE_DOWN_TIME = 0.065
local SCALE_UP_TIME = 0.1
local POP_IN_TIME = 0.1
local POP_HOLD_TIME = 0.35
local POP_OUT_TIME = 0.14
local POP_SCALE_START = 0.05
local REWARD_POP_SIZE_MIN = 1.0
local REWARD_POP_SIZE_MAX = 1.45
local REWARD_POP_EXTRA_MULT = 1.65
local REWARD_TEXTSIZE_MULT = 1.75
local VFX_DURATION = 0.35

local BAR_TWEEN_INFO = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local player = Players.LocalPlayer
local Attr = require(ReplicatedStorage.Shared:WaitForChild("PlayerClientAttributes"))
local MelonCfg = require(ReplicatedStorage.Shared:WaitForChild("MelonProgressConfig"))
local tappingTapFunction = ReplicatedStorage:WaitForChild("TappingTapFunction")
local MelonAutoTapBridge = require(ReplicatedStorage.Shared:WaitForChild("MelonAutoTapBridge"))
local melonLevelSync = ReplicatedStorage:WaitForChild("MelonLevelSync")

local latestPushLevel, latestPushXp = 1, 0
local debouncePushThread: thread? = nil

local function pushMelonProgressToServer(level: number, xp: number, urgent: boolean?)
	latestPushLevel, latestPushXp = level, xp
	if urgent then
		if debouncePushThread then
			task.cancel(debouncePushThread)
			debouncePushThread = nil
		end
		pcall(function()
			melonLevelSync:FireServer(latestPushLevel, latestPushXp)
		end)
		return
	end
	if debouncePushThread then
		return
	end
	debouncePushThread = task.delay(0.22, function()
		debouncePushThread = nil
		pcall(function()
			melonLevelSync:FireServer(latestPushLevel, latestPushXp)
		end)
	end)
end

local function isSfxMuted(): boolean
	local settings = player:FindFirstChild("Settings")
	local sfx = settings and settings:FindFirstChild("SfxMuted")
	return sfx ~= nil and sfx:IsA("IntValue") and sfx.Value >= 1
end

local hitSoundToggle = false
local function playAlternateHitSound()
	if isSfxMuted() then
		return
	end
	local soundsFolder = ReplicatedStorage:FindFirstChild("Sounds")
	if not soundsFolder then
		return
	end
	local name = hitSoundToggle and "Hit2" or "Hit1"
	hitSoundToggle = not hitSoundToggle
	local src = soundsFolder:FindFirstChild(name)
	if not src or not src:IsA("Sound") then
		return
	end
	local s = src:Clone()
	s.Parent = SoundService
	s.Ended:Connect(function()
		s:Destroy()
	end)
	s:Play()
end

local function playLevelUpSound()
	if isSfxMuted() then
		return
	end
	local soundsFolder = ReplicatedStorage:FindFirstChild("Sounds")
	if not soundsFolder then
		return
	end
	local src = soundsFolder:FindFirstChild("LevelUp")
	if not src or not src:IsA("Sound") then
		return
	end
	local s = src:Clone()
	s.Parent = SoundService
	s.Ended:Connect(function()
		s:Destroy()
	end)
	s:Play()
end

local function playHitVfx(hitVfx: Instance)
	for _, d in hitVfx:GetDescendants() do
		if d:IsA("ParticleEmitter") then
			local burst = math.clamp(math.floor(d.Rate * 0.05 + 14), 10, 45)
			if d.Rate > 0 then
				local was = d.Enabled
				d.Enabled = true
				task.delay(VFX_DURATION, function()
					if d.Parent then
						d.Enabled = was
					end
				end)
			else
				d:Emit(burst)
			end
		elseif d:IsA("Beam") then
			local was = d.Enabled
			d.Enabled = true
			task.delay(VFX_DURATION, function()
				if d.Parent then
					d.Enabled = was
				end
			end)
		elseif d:IsA("Trail") then
			local was = d.Enabled
			d.Enabled = true
			task.delay(VFX_DURATION, function()
				if d.Parent then
					d.Enabled = was
				end
			end)
		elseif d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") then
			local was = d.Enabled
			d.Enabled = true
			task.delay(VFX_DURATION, function()
				if d.Parent then
					d.Enabled = was
				end
			end)
		elseif d:IsA("Sound") then
			task.defer(function()
				if d.Parent then
					d:Play()
				end
			end)
		end
	end
end

local activeScaleTweens = {}
local melonScaleConn = nil
local melonScaleNv = nil

local function cancelMelonScaleTweens()
	for _, tw in activeScaleTweens do
		tw:Cancel()
	end
	table.clear(activeScaleTweens)
	if melonScaleConn then
		melonScaleConn:Disconnect()
		melonScaleConn = nil
	end
	if melonScaleNv then
		melonScaleNv:Destroy()
		melonScaleNv = nil
	end
end

local function applyMelonScale(melon: Model, scale: number)
	pcall(function()
		melon:ScaleTo(scale)
	end)
end

local function tweenMelonClick(melon: Model, state, onBounceComplete)
	cancelMelonScaleTweens()
	local baseScale = state.displayScale
	if baseScale <= 0 then
		if onBounceComplete then
			task.defer(onBounceComplete)
		end
		return
	end
	local targetScale = math.max(baseScale * MELON_CLICK_SCALE, 0.01)
	local tiDown = TweenInfo.new(SCALE_DOWN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tiUp = TweenInfo.new(SCALE_UP_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

	local nv = Instance.new("NumberValue")
	nv.Value = baseScale
	nv.Parent = melon
	melonScaleNv = nv

	melonScaleConn = nv.Changed:Connect(function()
		applyMelonScale(melon, nv.Value)
	end)

	local tw1 = TweenService:Create(nv, tiDown, { Value = targetScale })
	local tw2 = TweenService:Create(nv, tiUp, { Value = baseScale })
	table.insert(activeScaleTweens, tw1)
	table.insert(activeScaleTweens, tw2)

	tw1.Completed:Connect(function()
		if nv.Parent == nil then
			return
		end
		tw2:Play()
	end)
	tw2.Completed:Connect(function()
		cancelMelonScaleTweens()
		applyMelonScale(melon, state.displayScale)
		if onBounceComplete then
			task.defer(onBounceComplete)
		end
	end)

	tw1:Play()
end

local function setLifeLabel(state)
	local label = state.lifeLabel
	if label and (label:IsA("TextLabel") or label:IsA("TextButton")) then
		label.Text = ("Lvl. %d"):format(state.level)
	end
end

local function cancelLifeBarTween(state)
	if state.lifeBarTween then
		state.lifeBarTween:Cancel()
		state.lifeBarTween = nil
	end
end

-- instant: sin tween (subida de nivel o sync servidor); evita parpadeos de la barra.
local function setLifeBarFraction(state, fraction, instant)
	local life = state.life
	if not life then
		return
	end
	local p = math.clamp(fraction, 0, 1)
	cancelLifeBarTween(state)
	local targetSize = UDim2.new(p, 0, state.lifeYScale, state.lifeYOffset)
	if instant then
		life.Size = targetSize
	else
		state.lifeBarTween = TweenService:Create(life, BAR_TWEEN_INFO, { Size = targetSize })
		state.lifeBarTween:Play()
	end
end

local function tweenLifeBar(state, fraction)
	setLifeBarFraction(state, fraction, false)
end

local function refreshLifeBar(state, instant)
	local useInstant = instant == true
	if state.level >= MelonCfg.MAX_LEVEL then
		setLifeBarFraction(state, 1, useInstant)
		return
	end
	local g = state.goalXp
	if g <= 0 then
		setLifeBarFraction(state, 0, true)
		return
	end
	setLifeBarFraction(state, state.xp / g, useInstant)
end

local function addMelonXp(melon, state, amount)
	if state.level >= MelonCfg.MAX_LEVEL then
		pushMelonProgressToServer(state.level, state.xp, true)
		return
	end

	state.xp += amount

	local levelsGained = 0
	while state.level < MelonCfg.MAX_LEVEL and state.xp >= state.goalXp do
		state.xp -= state.goalXp
		state.level += 1
		state.goalXp = MelonCfg.goalXpForLevel(state.level)
		levelsGained += 1
		state.displayScale += MelonCfg.SCALE_PER_LEVEL
		applyMelonScale(melon, state.displayScale)
		setLifeLabel(state)
	end
	if levelsGained > 0 then
		playLevelUpSound()
	end

	if state.level >= MelonCfg.MAX_LEVEL then
		state.xp = 0
		setLifeBarFraction(state, 1, true)
		setLifeLabel(state)
		pushMelonProgressToServer(state.level, state.xp, true)
		return
	end

	setLifeLabel(state)
	-- Al subir nivel la meta de XP cambia: mejor actualizar la barra al instante.
	refreshLifeBar(state, levelsGained > 0)
	pushMelonProgressToServer(state.level, state.xp, levelsGained > 0)
end

local function resolveMelonLevelUi(melon)
	local base = melon:FindFirstChild("Base")
	if not base then
		return nil, nil
	end
	local levelGui = base:FindFirstChild("LevelGui")
	if not levelGui then
		return nil, nil
	end
	local frame = levelGui:FindFirstChild("Frame")
	if not frame then
		return nil, nil
	end
	local life = frame:FindFirstChild("Life")
	local lifeLabel = frame:FindFirstChild("LifeLabel")
	if life and not life:IsA("GuiObject") then
		life = nil
	end
	return life, lifeLabel
end

local function showRewardPopup(melon, _amount, _isCrit)
	local billboard = melon:FindFirstChild("BillboardGui")
	if not billboard or not billboard:IsA("BillboardGui") then
		return
	end
	local template = billboard:FindFirstChild("RewardLabel")
	if not template or not template:IsA("GuiObject") then
		return
	end

	local pop = template:Clone()
	for _, ch in pop:GetChildren() do
		if ch:IsA("UIScale") then
			ch:Destroy()
		end
	end

	pop.Visible = true
	if pop:IsA("TextLabel") or pop:IsA("TextButton") then
		-- Texto fijo (sin cantidad); el servidor sigue sumando los taps reales.
		pop.Text = "+Tap"
		if not pop.TextScaled and pop.TextSize > 0 then
			pop.TextSize = math.floor(pop.TextSize * REWARD_TEXTSIZE_MULT)
		end
	end

	local r = REWARD_POP_SIZE_MIN + math.random() * (REWARD_POP_SIZE_MAX - REWARD_POP_SIZE_MIN)
	local rx = r * REWARD_POP_EXTRA_MULT
	local ry = (REWARD_POP_SIZE_MIN + math.random() * (REWARD_POP_SIZE_MAX - REWARD_POP_SIZE_MIN)) * REWARD_POP_EXTRA_MULT
	local baseSize = template.Size
	pop.Size = UDim2.new(baseSize.X.Scale * rx, baseSize.X.Offset * rx, baseSize.Y.Scale * ry, baseSize.Y.Offset * ry)
	pop.Rotation = math.random(-10, 10)
	pop.AnchorPoint = Vector2.new(0.5, 0.5)

	local holder = Instance.new("Frame")
	holder.Name = "RewardPopHolder"
	holder.BackgroundTransparency = 1
	holder.BorderSizePixel = 0
	holder.ClipsDescendants = false
	local popPosX = 0.3 + math.random() * 0.4
	holder.AnchorPoint = Vector2.new(0.5, 0.5)
	holder.Position = UDim2.new(popPosX, 0, template.Position.Y.Scale, template.Position.Y.Offset)
	holder.Size = pop.Size
	holder.Rotation = pop.Rotation
	pop.Rotation = 0
	pop.Position = UDim2.fromScale(0.5, 0.5)
	pop.Size = UDim2.fromScale(1, 1)

	local uiScale = Instance.new("UIScale")
	uiScale.Scale = POP_SCALE_START
	uiScale.Parent = holder

	pop.Parent = holder
	holder.Parent = billboard

	local tiIn = TweenInfo.new(POP_IN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tiOut = TweenInfo.new(POP_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	task.defer(function()
		if not holder.Parent then
			return
		end
		TweenService:Create(uiScale, tiIn, { Scale = 1 }):Play()
	end)

	task.delay(POP_IN_TIME + POP_HOLD_TIME, function()
		if not holder.Parent then
			return
		end
		local tw = TweenService:Create(uiScale, tiOut, { Scale = POP_SCALE_START })
		tw.Completed:Connect(function()
			holder:Destroy()
		end)
		tw:Play()
	end)
end

local function bindMelon(melon)
	if melon:GetAttribute("TappingMelonBound") then
		return
	end
	melon:SetAttribute("TappingMelonBound", true)

	local billboard = melon:FindFirstChild("BillboardGui")
	local rewardTemplate = billboard and billboard:FindFirstChild("RewardLabel")
	if rewardTemplate and rewardTemplate:IsA("GuiObject") then
		rewardTemplate.Visible = false
	end

	local hitVfx = melon:FindFirstChild("HitVFX")
	local life, lifeLabel = resolveMelonLevelUi(melon)

	local okScale, startScale = pcall(function()
		return melon:GetScale()
	end)
	if not okScale or type(startScale) ~= "number" or startScale <= 0 then
		startScale = 1
	end

	local lifeYScale = 1
	local lifeYOffset = 0
	if life then
		lifeYScale = life.Size.Y.Scale
		lifeYOffset = life.Size.Y.Offset
	end

	-- DataStore puede tardar; si leemos melón antes, queda nivel 1/0 aunque el save tenga progreso.
	local tData = os.clock()
	while player:GetAttribute("PlayerDataLoaded") ~= true and os.clock() - tData < 45 do
		task.wait(0.05)
	end

	local eventsFolder = player:WaitForChild("Events", 30)
	local savedLevel = 1
	local savedXp = 0
	local ml = nil
	local mx = nil
	if eventsFolder then
		ml = eventsFolder:WaitForChild("MelonLevel", 20)
		mx = eventsFolder:WaitForChild("MelonXp", 20)
		if ml and ml:IsA("ValueBase") then
			savedLevel = ml.Value
		end
		if mx and mx:IsA("ValueBase") then
			savedXp = mx.Value
		end
		-- Un frame extra: a veces el valor replica justo después de PlayerDataLoaded.
		task.wait()
		if ml and ml:IsA("ValueBase") then
			savedLevel = ml.Value
		end
		if mx and mx:IsA("ValueBase") then
			savedXp = mx.Value
		end
	end
	local initLevel, initXp = MelonCfg.normalizeLevelXp(savedLevel, savedXp)
	local initGoal = MelonCfg.goalXpForLevel(initLevel)
	local displayScale = startScale + (initLevel - 1) * MelonCfg.SCALE_PER_LEVEL
	applyMelonScale(melon, displayScale)

	local state = {
		displayScale = displayScale,
		level = initLevel,
		xp = initXp,
		goalXp = initGoal,
		life = life,
		lifeLabel = lifeLabel,
		lifeYScale = lifeYScale,
		lifeYOffset = lifeYOffset,
		lifeBarTween = nil,
	}

	setLifeLabel(state)
	if life then
		if state.level >= MelonCfg.MAX_LEVEL then
			setLifeBarFraction(state, 1, true)
		else
			refreshLifeBar(state, true)
		end
	end

	-- Servidor puede resetear melón (rebirth) o aplicar normalize distinto al debounce del cliente.
	-- Debounce + sin poner ancho a 0: evita parpadeos y peleas con el tween del tap.
	if ml and ml:IsA("ValueBase") and mx and mx:IsA("ValueBase") then
		local reconcileToken = 0
		local function scheduleReconcileFromServer()
			reconcileToken = reconcileToken + 1
			local token = reconcileToken
			task.defer(function()
				if token ~= reconcileToken then
					return
				end
				local L, x = MelonCfg.normalizeLevelXp(ml.Value, mx.Value)
				if
					L == state.level
					and math.abs(x - state.xp) < 0.5
					and state.level < MelonCfg.MAX_LEVEL
				then
					return
				end
				local levelChanged = L ~= state.level
				local xpDropped = x + 2 < state.xp
				state.level = L
				state.xp = x
				state.goalXp = MelonCfg.goalXpForLevel(L)
				state.displayScale = startScale + (L - 1) * MelonCfg.SCALE_PER_LEVEL
				applyMelonScale(melon, state.displayScale)
				setLifeLabel(state)
				if state.level >= MelonCfg.MAX_LEVEL then
					setLifeBarFraction(state, 1, true)
				else
					refreshLifeBar(state, levelChanged or xpDropped)
				end
			end)
		end
		ml:GetPropertyChangedSignal("Value"):Connect(scheduleReconcileFromServer)
		mx:GetPropertyChangedSignal("Value"):Connect(scheduleReconcileFromServer)
	end

	local tapCooldownUntil = 0

	local function onClick()
		local now = os.clock()
		if now < tapCooldownUntil then
			return
		end

		local okInvoke, res = pcall(function()
			return tappingTapFunction:InvokeServer()
		end)
		if not okInvoke or type(res) ~= "table" or not res.ok then
			return
		end

		tapCooldownUntil = now + TAP_COOLDOWN

		local xpGain = math.max(1, math.floor(res.xpGain or 1))
		local tapsShown = math.max(1, math.floor(res.tapsAdded or 1))
		local crit = res.crit == true

		tweenMelonClick(melon, state, function()
			addMelonXp(melon, state, xpGain)
		end)
		playAlternateHitSound()
		if hitVfx then
			playHitVfx(hitVfx)
		end
		showRewardPopup(melon, tapsShown, crit)
	end

	MelonAutoTapBridge.setTapHandler(onClick)

	for _, d in melon:GetDescendants() do
		if d:IsA("ClickDetector") then
			d.MouseClick:Connect(function(clickPlayer)
				if clickPlayer == player then
					onClick()
				end
			end)
		end
	end

	pushMelonProgressToServer(state.level, state.xp, true)
end

local function trySetupTapping(root)
	local plot = root:FindFirstChild("Plot")
	if not plot then
		return
	end
	local melon = plot:FindFirstChild("Melon")
	if melon and melon:IsA("Model") then
		bindMelon(melon)
	end
end

local clientTapping = workspace:WaitForChild("ClientTapping")

local function onTappingChild(child)
	if child.Name == "Tapping" then
		trySetupTapping(child)
		child.DescendantAdded:Connect(function(desc)
			if desc.Name == "Melon" and desc:IsA("Model") and desc.Parent and desc.Parent.Name == "Plot" then
				bindMelon(desc)
			end
		end)
	end
end

for _, ch in clientTapping:GetChildren() do
	onTappingChild(ch)
end
clientTapping.ChildAdded:Connect(onTappingChild)

-- Auto-tap: Basic 1s, Gold 0.1s. Misma logica que clic manual (MelonAutoTapBridge).
task.spawn(function()
	local accum = 0
	while true do
		local dt = task.wait(0.05)
		if player:GetAttribute(Attr.IN_TAPPING_ZONE) == true and player:GetAttribute(Attr.AUTO_TAP) == true then
			local interval = (player:GetAttribute(Attr.AUTO_TAP_GOLD) == true) and AUTO_TAP_INTERVAL_GOLD
				or AUTO_TAP_INTERVAL_BASIC
			accum = accum + dt
			if accum >= interval then
				accum = 0
				MelonAutoTapBridge.performTap()
			end
		else
			accum = 0
		end
	end
end)
