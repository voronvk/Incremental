local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local gui = script.Parent

local Attr = require(ReplicatedStorage.Shared:WaitForChild("PlayerClientAttributes"))
if gui:IsA("ScreenGui") then
	local function syncTappingGuiWithLoad()
		gui.Enabled = player:GetAttribute(Attr.CLIENT_LOADING_COMPLETE) == true
	end
	syncTappingGuiWithLoad()
	player:GetAttributeChangedSignal(Attr.CLIENT_LOADING_COMPLETE):Connect(syncTappingGuiWithLoad)
end

local ButtonScaleEffect = require(ReplicatedStorage.Shared:WaitForChild("ButtonScaleEffect"))
local UIBlur = require(ReplicatedStorage.Shared:WaitForChild("UIBlur"))
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
local GamePassConfig = require(ReplicatedStorage.Shared:WaitForChild("GamePassConfig"))
local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

local questClaimRequest = ReplicatedStorage:FindFirstChild("QuestRewardClaimRequest")
local questClaimed = ReplicatedStorage:FindFirstChild("QuestRewardClaimed")
local setMuteRequest = ReplicatedStorage:WaitForChild("SetMuteRequest")

--[[
	LocalScript hijo del ScreenGui TappingGui (script.Parent = TappingGui).
	Modales: Shop, QuestFrame, BoostShop, Frames.Settings, Frames.DailyRewards. Gifts: Buttons.Left.Gifts.
]]

-- Botones que abren frames con animación Scale in (solo uno abierto a la vez)
local SCALE_TWEEN_TIME = 0.15
local TARGET_SCALE = 1
local tweenInfo = TweenInfo.new(SCALE_TWEEN_TIME, Enum.EasingStyle.Quad)

-- Datos de cada frame para poder cerrarlos
local frameData = {}

local function closeFrame(data, skipOverlayEnd)
	if not data.isOpen then return end
	data.isOpen = false
	if not skipOverlayEnd then
		UIBlur.endModal()
	end
	local tween = TweenService:Create(data.uiScale, tweenInfo, { Scale = 0 })
	tween.Completed:Connect(function()
		data.frame.Visible = false
	end)
	tween:Play()
end

local function openFrame(data, skipOverlayBegin)
	data.frame.Visible = true
	data.isOpen = true
	if not skipOverlayBegin then
		UIBlur.beginModal()
	end
	TweenService:Create(data.uiScale, tweenInfo, { Scale = TARGET_SCALE }):Play()
end

local MODAL_FRAME_NAMES = { "Shop", "QuestFrame", "BoostShop" }

for _, frameName in ipairs(MODAL_FRAME_NAMES) do
	local targetFrame = gui:FindFirstChild(frameName)
	if targetFrame then
		local uiScale = targetFrame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		uiScale.Scale = 0
		uiScale.Parent = targetFrame
		targetFrame.Visible = false
		frameData[frameName] = { frame = targetFrame, uiScale = uiScale, isOpen = false }
	end
end

local framesFolder = gui:FindFirstChild("Frames")
local settingsModal = framesFolder and framesFolder:FindFirstChild("Settings")
if settingsModal then
	local uiScale = settingsModal:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	uiScale.Scale = 0
	uiScale.Parent = settingsModal
	settingsModal.Visible = false
	frameData["Settings"] = { frame = settingsModal, uiScale = uiScale, isOpen = false }
end

local dailyRewardsModal = framesFolder and framesFolder:FindFirstChild("DailyRewards")
if dailyRewardsModal then
	local uiScale = dailyRewardsModal:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	uiScale.Scale = 0
	uiScale.Parent = dailyRewardsModal
	dailyRewardsModal.Visible = false
	frameData["DailyRewards"] = { frame = dailyRewardsModal, uiScale = uiScale, isOpen = false }
end

local indexModal = framesFolder and framesFolder:FindFirstChild("Index")
if indexModal then
	local uiScale = indexModal:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	uiScale.Scale = 0
	uiScale.Parent = indexModal
	indexModal.Visible = false
	frameData["Index"] = { frame = indexModal, uiScale = uiScale, isOpen = false }
end

-- Si `Store` / `Quests` / `BoostButton` son ya ImageButton o TextButton, se usa ese Instance.
-- Solo si no lo son (p. ej. Frame contenedor) se busca un GuiButton hijo.
local function findOpenerGuiButton(root)
	if not root then
		return nil
	end
	if root:IsA("GuiButton") then
		return root
	end
	return root:FindFirstChildWhichIsA("GuiButton", true)
end

local function wireOpener(root, frameName)
	local data = frameData[frameName]
	if not root then
		return
	end
	if not data then
		warn(("[TappingGui] Falta el frame modal %q bajo TappingGui (no se puede abrir desde %s)"):format(frameName, root:GetFullName()))
		return
	end

	local function toggleFrame()
		if data.isOpen then
			closeFrame(data)
		else
			local hadAnyOtherOpen = false
			for name, other in pairs(frameData) do
				if name ~= frameName and other.isOpen then
					hadAnyOtherOpen = true
					break
				end
			end
			for name, other in pairs(frameData) do
				if name ~= frameName and other.isOpen then
					closeFrame(other, true)
				end
			end
			openFrame(data, hadAnyOtherOpen)
		end
	end

	local clickable = findOpenerGuiButton(root)
	if clickable then
		local img = clickable:FindFirstChild("ImageLabel") or root:FindFirstChild("ImageLabel")
		ButtonScaleEffect.applyScaleEffect(clickable, img or clickable)
		clickable.Activated:Connect(toggleFrame)
		return
	end

	-- Sin ningún GuiButton bajo el nodo: no hay hover estándar; al menos intentar clic en el contenedor
	if root:IsA("GuiObject") then
		root.Active = true
		warn(("[TappingGui] %s: añade un ImageButton/TextButton bajo el opener para hover/click (ruta: %s)"):format(frameName, root:GetFullName()))
		root.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				toggleFrame()
			end
		end)
	end
end

local buttonsRoot = gui:FindFirstChild("Buttons")
if buttonsRoot then
	local right = buttonsRoot:FindFirstChild("Right")
	local left = buttonsRoot:FindFirstChild("Left")
	if right then
		wireOpener(right:FindFirstChild("Store"), "Shop")
		wireOpener(right:FindFirstChild("Settings"), "Settings")
	end
	if left then
		wireOpener(left:FindFirstChild("Quests"), "QuestFrame")
		wireOpener(left:FindFirstChild("Gifts"), "DailyRewards")
		wireOpener(left:FindFirstChild("Index"), "Index")
	end
end
wireOpener(gui:FindFirstChild("BoostButton"), "BoostShop")

-- Settings (Frames.Settings): cierre + toggles Music / Sounds / PopUps
local settingsData = frameData["Settings"]
local COLOR_TOGGLE_ON_BG = Color3.fromRGB(20, 156, 5)
local COLOR_TOGGLE_ON_SWATCH = Color3.fromRGB(66, 255, 72)
local COLOR_TOGGLE_OFF_BG = Color3.fromRGB(156, 5, 5)
local COLOR_TOGGLE_OFF_SWATCH = Color3.fromRGB(255, 74, 74)

local function applyIndicatorColor(inst, c)
	if not inst or not inst:IsA("GuiObject") then
		return
	end
	if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
		inst.ImageColor3 = c
	else
		inst.BackgroundColor3 = c
	end
end

-- Solo Background del Button + hijo "Color". "Title" solo texto On/Off (sin tocar sus colores).
local function applyToggleButtonVisual(btn, featureOn)
	if not btn or not btn:IsA("GuiButton") then
		return
	end
	btn.AutoButtonColor = false
	btn.BackgroundColor3 = featureOn and COLOR_TOGGLE_ON_BG or COLOR_TOGGLE_OFF_BG

	local swatch = featureOn and COLOR_TOGGLE_ON_SWATCH or COLOR_TOGGLE_OFF_SWATCH
	local colorChild = btn:FindFirstChild("Color")
	if colorChild then
		applyIndicatorColor(colorChild, swatch)
	end

	local title = btn:FindFirstChild("Title", true)
	if title and (title:IsA("TextLabel") or title:IsA("TextButton")) then
		title.Text = featureOn and "On" or "Off"
	end
end

if settingsModal and settingsData then
	local top = settingsModal:FindFirstChild("Top")
	local main = top and top:FindFirstChild("Main")
	local closeSettings = main and main:FindFirstChild("Close")
	if closeSettings then
		local img = closeSettings:FindFirstChild("ImageLabel")
		ButtonScaleEffect.applyScaleEffect(closeSettings, img or closeSettings)
		if closeSettings:IsA("GuiButton") then
			closeSettings.Activated:Connect(function()
				closeFrame(settingsData)
			end)
		else
			closeSettings.MouseButton1Click:Connect(function()
				closeFrame(settingsData)
			end)
		end
	end

	local scroll = settingsModal:FindFirstChild("ScrollingFrame")
	local settingsFolder = player:WaitForChild("Settings")
	local musicNv = settingsFolder:WaitForChild("MusicMuted")
	local sfxNv = settingsFolder:WaitForChild("SfxMuted")
	local popNv = settingsFolder:WaitForChild("PopUpsMuted")

	local function bindSettingsRow(rowName, intValue)
		if not scroll then
			return
		end
		local row = scroll:FindFirstChild(rowName)
		local btn = row and row:FindFirstChild("Button")
		if not btn or not btn:IsA("GuiButton") then
			return
		end
		local img = btn:FindFirstChild("ImageLabel")
		ButtonScaleEffect.applyScaleEffect(btn, img or btn)

		local function featureEnabled()
			return intValue.Value < 1
		end

		local function refresh()
			applyToggleButtonVisual(btn, featureEnabled())
		end

		refresh()
		intValue:GetPropertyChangedSignal("Value"):Connect(refresh)

		local function onToggle()
			local newVal = intValue.Value >= 1 and 0 or 1
			setMuteRequest:FireServer(intValue.Name, newVal)
		end
		if btn:IsA("GuiButton") then
			btn.Activated:Connect(onToggle)
		else
			btn.MouseButton1Click:Connect(onToggle)
		end
	end

	-- Verde = Value 0 (música/SFX/popups activos); rojo = Value 1 (mute / sin popups)
	bindSettingsRow("Music", musicNv)
	bindSettingsRow("Sounds", sfxNv)
	bindSettingsRow("PopUps", popNv)
end

-- Daily Rewards (Frames.DailyRewards): Gifts, Top.Main.Close, Day1–Day7 Claim, SkipAll
local DAILY_SKIP_ALL_PRODUCT_ID = 3569324327
local DAY_SECONDS = 86400
local dailyRewardsData = frameData["DailyRewards"]
local dailyClaimRequest = ReplicatedStorage:WaitForChild("DailyRewardClaimRequest")
local dailyClaimResult = ReplicatedStorage:WaitForChild("DailyRewardClaimResult")

local function isSfxMutedSettings()
	local settings = player:FindFirstChild("Settings")
	local sfx = settings and settings:FindFirstChild("SfxMuted")
	return sfx ~= nil and sfx:IsA("ValueBase") and sfx.Value >= 1
end

local function playDailyRewardSound()
	if isSfxMutedSettings() then
		return
	end
	local soundsFolder = ReplicatedStorage:FindFirstChild("Sounds")
	if not soundsFolder then
		return
	end
	local src = soundsFolder:FindFirstChild("Reward")
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

local function applyClaimRowVisual(claim, state, titleOverride)
	if not claim or not claim:IsA("GuiButton") then
		return
	end
	claim.AutoButtonColor = false
	local title = claim:FindFirstChild("Title", true)
	local colorChild = claim:FindFirstChild("Color")
	local stroke = claim:FindFirstChildOfClass("UIStroke")

	local function strokeCol(c)
		if stroke then
			stroke.Color = c
		end
	end

	local function swatchCol(c)
		if colorChild then
			if colorChild:IsA("ImageLabel") or colorChild:IsA("ImageButton") then
				colorChild.ImageColor3 = c
			elseif colorChild:IsA("GuiObject") then
				colorChild.BackgroundColor3 = c
			end
		end
	end

	if state == "claim" then
		if title and (title:IsA("TextLabel") or title:IsA("TextButton")) then
			title.Text = "Claim!"
		end
		swatchCol(Color3.fromRGB(56, 255, 42))
		strokeCol(Color3.fromRGB(8, 43, 0))
		claim.BackgroundColor3 = Color3.fromRGB(14, 107, 0)
		claim.Active = true
	elseif state == "claimed" then
		if title and (title:IsA("TextLabel") or title:IsA("TextButton")) then
			title.Text = "Claimed"
		end
		swatchCol(Color3.fromRGB(193, 193, 193))
		strokeCol(Color3.fromRGB(43, 43, 43))
		claim.BackgroundColor3 = Color3.fromRGB(107, 107, 107)
		claim.Active = false
	else
		local t = titleOverride or "Wait"
		if title and (title:IsA("TextLabel") or title:IsA("TextButton")) then
			title.Text = t
		end
		swatchCol(Color3.fromRGB(255, 48, 48))
		strokeCol(Color3.fromRGB(70, 38, 38))
		claim.BackgroundColor3 = Color3.fromRGB(156, 5, 5)
		claim.Active = false
	end
end

local function formatDailyCountdown(totalSeconds)
	totalSeconds = math.max(0, math.floor(totalSeconds))
	local h = math.floor(totalSeconds / 3600)
	local m = math.floor((totalSeconds % 3600) / 60)
	return string.format("%dh %dm", h, m)
end

if dailyRewardsModal and dailyRewardsData then
	local top = dailyRewardsModal:FindFirstChild("Top")
	local main = top and top:FindFirstChild("Main")
	local closeDr = main and main:FindFirstChild("Close")
	if closeDr then
		local img = closeDr:FindFirstChild("ImageLabel")
		ButtonScaleEffect.applyScaleEffect(closeDr, img or closeDr)
		if closeDr:IsA("GuiButton") then
			closeDr.Activated:Connect(function()
				closeFrame(dailyRewardsData)
			end)
		else
			closeDr.MouseButton1Click:Connect(function()
				closeFrame(dailyRewardsData)
			end)
		end
	end

	local scrollDr = dailyRewardsModal:FindFirstChild("ScrollingFrame")
	local eventsDr = player:WaitForChild("Events")
	local nextDayNv = eventsDr:WaitForChild("DailyRewardNextDay")
	local lastClaimNv = eventsDr:WaitForChild("DailyRewardLastClaimUnix")

	-- 0 = dato viejo / por defecto: tratar como día 1 (evita Day1 en "Wait" por 1 > 0)
	local function effectiveNextDay()
		local v = nextDayNv.Value
		if v < 1 then
			return 1
		end
		if v > 8 then
			return 8
		end
		return v
	end

	local function canClaimNow()
		local nd = effectiveNextDay()
		if nd < 1 or nd > 7 then
			return false
		end
		if lastClaimNv.Value == 0 then
			return true
		end
		return (os.time() - lastClaimNv.Value) >= DAY_SECONDS
	end

	local function refreshDailyRows()
		local now = os.time()
		local nextD = effectiveNextDay()
		local lastV = lastClaimNv.Value

		for day = 1, 7 do
			local row = scrollDr and scrollDr:FindFirstChild("Day" .. day)
			local claim = row and row:FindFirstChild("Claim")
			if claim and claim:IsA("GuiButton") then
				if nextD >= 8 then
					applyClaimRowVisual(claim, "claimed")
				elseif day < nextD then
					applyClaimRowVisual(claim, "claimed")
				elseif day > nextD then
					applyClaimRowVisual(claim, "wait")
				else
					if canClaimNow() then
						applyClaimRowVisual(claim, "claim")
					elseif lastV > 0 then
						local remain = (lastV + DAY_SECONDS) - now
						applyClaimRowVisual(claim, "countdown", formatDailyCountdown(remain))
					else
						applyClaimRowVisual(claim, "claim")
					end
				end
			end
		end
	end

	for day = 1, 7 do
		local row = scrollDr and scrollDr:FindFirstChild("Day" .. day)
		local claim = row and row:FindFirstChild("Claim")
		if claim and claim:IsA("GuiButton") then
			local img = claim:FindFirstChild("ImageLabel")
			ButtonScaleEffect.applyScaleEffect(claim, img or claim)
			claim.Activated:Connect(function()
				if not canClaimNow() or effectiveNextDay() ~= day then
					return
				end
				dailyClaimRequest:FireServer()
			end)
		end
	end

	nextDayNv:GetPropertyChangedSignal("Value"):Connect(refreshDailyRows)
	lastClaimNv:GetPropertyChangedSignal("Value"):Connect(refreshDailyRows)

	dailyClaimResult.OnClientEvent:Connect(function(ok)
		if ok == true then
			playDailyRewardSound()
		end
		refreshDailyRows()
	end)

	task.spawn(function()
		while dailyRewardsModal.Parent do
			if dailyRewardsData.isOpen then
				refreshDailyRows()
			end
			task.wait(1)
		end
	end)

	refreshDailyRows()

	local skipAll = dailyRewardsModal:FindFirstChild("SkipAll")
	if skipAll and skipAll:IsA("GuiButton") then
		local simg = skipAll:FindFirstChild("ImageLabel")
		ButtonScaleEffect.applyScaleEffect(skipAll, simg or skipAll)
		skipAll.Activated:Connect(function()
			MarketplaceService:PromptProductPurchase(player, DAILY_SKIP_ALL_PRODUCT_ID)
		end)
	end
end

-- Index (Frames.Index): Top.Main.Close
local indexData = frameData["Index"]
if indexModal and indexData then
	local top = indexModal:FindFirstChild("Top")
	local main = top and top:FindFirstChild("Main")
	-- Busca recursivo por si `Close` no es hijo directo
	local closeIndex = main and main:FindFirstChild("Close", true)
	if closeIndex then
		local img = closeIndex:FindFirstChild("ImageLabel")
		ButtonScaleEffect.applyScaleEffect(closeIndex, img or closeIndex)
		if closeIndex:IsA("GuiButton") then
			closeIndex.Activated:Connect(function()
				closeFrame(indexData)
			end)
		else
			closeIndex.MouseButton1Click:Connect(function()
				closeFrame(indexData)
			end)
		end
	end
end

-- Shop: CloseButton y botones de gamepass
local shop = gui:FindFirstChild("Shop")
local shopData = frameData["Shop"]

if shop and shopData then
	-- CloseButton cierra la tienda
	local closeButton = shop:FindFirstChild("CloseButton", true)
	if closeButton then
		local img = closeButton:FindFirstChild("ImageLabel")
		ButtonScaleEffect.applyScaleEffect(closeButton, img or closeButton)
		local function connectClose(obj)
			if obj:IsA("GuiButton") then
				obj.Activated:Connect(function() closeFrame(shopData) end)
			else
				obj.MouseButton1Click:Connect(function() closeFrame(shopData) end)
			end
		end
		connectClose(closeButton)
	end

	-- Frames bajo Shop o Shop.ScrollingFrame (CloseButton sigue en Shop)
	local function findShopGamePassFrame(frameName)
		local direct = shop:FindFirstChild(frameName)
		if direct then
			return direct
		end
		local scroll = shop:FindFirstChild("ScrollingFrame")
		if scroll then
			local f = scroll:FindFirstChild(frameName)
			if f then
				return f
			end
		end
		return shop:FindFirstChild(frameName, true)
	end

	-- Gamepasses: nombre del frame -> ID (IDs en GamePassConfig)
	local gamepassFrames = {
		RebirthMultiplier = GamePassConfig.REBIRTH_GAMEPASS_ID,
		MelonMultiplier = GamePassConfig.MELON_X2_GAMEPASS_ID,
		EverythingFrame = GamePassConfig.BUNDLE_GAMEPASS_ID,
		WalkSpeedMultiplier = GamePassConfig.WALKSPEED_GAMEPASS_ID,
		AscensionMultiplier = GamePassConfig.ASCENSION_GAMEPASS_ID,
		AllTappingFrame = GamePassConfig.TAPPING_BUNDLE_GAMEPASS_ID,
		DoubleTapFrame = GamePassConfig.TAPPING_DOUBLE_DAMAGE_GAMEPASS_ID,
		DoubleXPFrame = GamePassConfig.TAPPING_DOUBLE_XP_GAMEPASS_ID,
		DoubleClick = GamePassConfig.TAPPING_DOUBLE_CLICK_GAMEPASS_ID,
		MultipleClick = GamePassConfig.TAPPING_MULTIPLE_CLICK_GAMEPASS_ID,
		BoostPack = GamePassConfig.BOOST_PACK_GAMEPASS_ID,
		BetterLuck = GamePassConfig.BETTER_LUCK_GAMEPASS_ID,
	}

	local function getBuyLabel(buyButton)
		return buyButton:FindFirstChildOfClass("TextLabel")
			or buyButton:FindFirstChildWhichIsA("TextLabel", true)
	end

	local function updateOwnedLabel(buyButton, gamePassId)
		local label = getBuyLabel(buyButton)
		if not label then
			return
		end
		if GamePassCheck.playerOwnsGamePass(player, gamePassId) then
			label.Text = "Owned"
		end
	end

	local function refreshAllShopOwnedLabels()
		for frameName, gamePassId in pairs(gamepassFrames) do
			local f = findShopGamePassFrame(frameName)
			if f then
				local buyButton = f:FindFirstChildWhichIsA("GuiButton", true)
				if buyButton then
					updateOwnedLabel(buyButton, gamePassId)
				end
			end
		end
	end

	for frameName, gamePassId in pairs(gamepassFrames) do
		local frame = findShopGamePassFrame(frameName)
		if frame then
			local buyButton = frame:FindFirstChildWhichIsA("GuiButton", true)
			if buyButton then
				local img = buyButton:FindFirstChild("ImageLabel")
				ButtonScaleEffect.applyScaleEffect(buyButton, img or buyButton)
				updateOwnedLabel(buyButton, gamePassId)
				buyButton.Activated:Connect(function()
					MarketplaceService:PromptGamePassPurchase(player, gamePassId)
				end)
			end
		end
	end

	player:GetAttributeChangedSignal("GamePassSyncStamp"):Connect(function()
		task.defer(refreshAllShopOwnedLabels)
	end)

	task.defer(refreshAllShopOwnedLabels)
end

-- BoostShop: CloseButton y botones de boost (Developer Products)
-- `BoostShop` puede estar anidado (no necesariamente es hijo directo)
local boostShop = gui:FindFirstChild("BoostShop", true)
local boostShopData = frameData["BoostShop"]

-- IDs de productos de boost
local MELON_BOOST_15MIN_PRODUCT_ID = 3560570963
local MELON_BOOST_1HOUR_PRODUCT_ID = 3560571041
local EVERYTHING_BOOST_15MIN_PRODUCT_ID = 3560571168
local EVERYTHING_BOOST_1HOUR_PRODUCT_ID = 3560571293

local function connectButtonWithProduct(button, productId)
	if not button or productId == 0 then
		return
	end
	local img = button:FindFirstChild("ImageLabel")
	ButtonScaleEffect.applyScaleEffect(button, img or button)
	local function prompt()
		MarketplaceService:PromptProductPurchase(player, productId)
	end
	if button:IsA("GuiButton") then
		button.Activated:Connect(prompt)
	else
		button.MouseButton1Click:Connect(prompt)
	end
end

if boostShop and boostShopData then
	-- CloseButton
	local closeButton = boostShop:FindFirstChild("CloseButton", true)
	if closeButton then
		local img = closeButton:FindFirstChild("ImageLabel")
		ButtonScaleEffect.applyScaleEffect(closeButton, img or closeButton)
		if closeButton:IsA("GuiButton") then
			closeButton.Activated:Connect(function() closeFrame(boostShopData) end)
		else
			closeButton.MouseButton1Click:Connect(function() closeFrame(boostShopData) end)
		end
	end

	-- MelonFrame: x2 melones durante 15 min o 1 hora
	local melonFrame = boostShop:FindFirstChild("MelonFrame")
	if melonFrame then
		local btn15 = melonFrame:FindFirstChild("15MinutesButton")
		local btn1h = melonFrame:FindFirstChild("1HourButton")
		connectButtonWithProduct(btn15, MELON_BOOST_15MIN_PRODUCT_ID)
		connectButtonWithProduct(btn1h, MELON_BOOST_1HOUR_PRODUCT_ID)
	end

	-- EverythingFrame (BoostShop): x2 todo excepto melones (Rebirths, Ascension, Speed) durante 15 min o 1 hora
	local everythingFrameBoost = boostShop:FindFirstChild("EverythingFrame")
	if everythingFrameBoost then
		local btn15 = everythingFrameBoost:FindFirstChild("15MinutesButton")
		local btn1h = everythingFrameBoost:FindFirstChild("1HourButton")
		connectButtonWithProduct(btn15, EVERYTHING_BOOST_15MIN_PRODUCT_ID)
		connectButtonWithProduct(btn1h, EVERYTHING_BOOST_1HOUR_PRODUCT_ID)
	end
end

-- BoostShop: ActiveFrame timers + multiplicadores (x2)
task.spawn(function()
	-- `ActiveFrame` puede estar anidado dentro de `BoostShop`
	local boostShopActiveFrame = boostShop and boostShop:FindFirstChild("ActiveFrame", true)

	local function findDescendantByNameInsensitive(root, name)
		if not root then return nil end
		local target = string.lower(name)
		for _, d in ipairs(root:GetDescendants()) do
			if string.lower(d.Name) == target then
				return d
			end
		end
		return nil
	end

	local function findDescendantByKeywords(root, keywords)
		if not root then return nil end
		if type(keywords) ~= "table" then return nil end
		local lowered = {}
		for i, k in ipairs(keywords) do
			lowered[i] = string.lower(tostring(k))
		end
		for _, d in ipairs(root:GetDescendants()) do
			local n = string.lower(d.Name)
			local ok = true
			for i = 1, #lowered do
				if n:find(lowered[i], 1, true) == nil then
					ok = false
					break
				end
			end
			if ok then
				return d
			end
		end
		return nil
	end

	if not boostShopActiveFrame then
		-- Esperar un poco por si la UI se construye después del start
		for _ = 1, 50 do
			boostShopActiveFrame = boostShop and boostShop:FindFirstChild("ActiveFrame", true)
				or findDescendantByNameInsensitive(boostShop, "ActiveFrame")
				or findDescendantByKeywords(boostShop, { "active", "frame" })
			if boostShopActiveFrame then break end
			task.wait(0.1)
		end
	end
	if not boostShopActiveFrame then
		-- Debug: qué nodos contienen "active" dentro de BoostShop
		local activeCandidates = {}
		if boostShop then
			for _, d in ipairs(boostShop:GetDescendants()) do
				local n = string.lower(d.Name)
				if n:find("active", 1, true) ~= nil then
					table.insert(activeCandidates, d.Name)
				end
			end
		end
		table.sort(activeCandidates)
		-- Fallback: aun si no encontramos ActiveFrame, la UI se puede actualizar buscando labels directamente dentro de BoostShop.
		boostShopActiveFrame = boostShop
	end

	local function findDescendantByNameInsensitive(root, name)
		if not root then return nil end
		local target = string.lower(name)
		for _, d in ipairs(root:GetDescendants()) do
			if string.lower(d.Name) == target then
				return d
			end
		end
		return nil
	end

	local function findDescendantByKeywords(root, keywords)
		if not root then return nil end
		if type(keywords) ~= "table" then return nil end
		local lowered = {}
		for i, k in ipairs(keywords) do
			lowered[i] = string.lower(tostring(k))
		end
		for _, d in ipairs(root:GetDescendants()) do
			local n = string.lower(d.Name)
			local ok = true
			for i = 1, #lowered do
				if n:find(lowered[i], 1, true) == nil then
					ok = false
					break
				end
			end
			if ok then
				return d
			end
		end
		return nil
	end

	local function getTextLabel(nodeOrMaybeFrame, fallbackName)
		if nodeOrMaybeFrame and nodeOrMaybeFrame:IsA("TextLabel") then
			return nodeOrMaybeFrame
		end
		-- If we were given a frame/container, take its first TextLabel.
		if nodeOrMaybeFrame then
			local t = nodeOrMaybeFrame:FindFirstChildWhichIsA("TextLabel", true)
			if t then return t end
		end
		-- If nothing found, try to find a descendant named fallbackName.
		if fallbackName and boostShopActiveFrame then
			local byName = findDescendantByNameInsensitive(boostShopActiveFrame, fallbackName)
			if byName and byName:IsA("TextLabel") then
				return byName
			end
			if byName then
				return byName:FindFirstChildWhichIsA("TextLabel", true)
			end
		end
		return nil
	end

	local function formatTime(totalSeconds)
		totalSeconds = math.max(0, math.floor(totalSeconds))
		if totalSeconds >= 3600 then
			local h = math.floor(totalSeconds / 3600)
			local m = math.floor((totalSeconds % 3600) / 60)
			local s = totalSeconds % 60
			return string.format("%d:%02d:%02d", h, m, s)
		else
			local m = math.floor(totalSeconds / 60)
			local s = totalSeconds % 60
			return string.format("%d:%02d", m, s)
		end
	end

	local events = player:WaitForChild("Events")

	-- Lookups toleran mayus/minusculas y sufijos/prefixes.
	local melonTimerNode = findDescendantByKeywords(boostShopActiveFrame, { "melon", "timer" })
	local melonBoostNode = findDescendantByKeywords(boostShopActiveFrame, { "melon", "boost" })
	local speedTimerNode = findDescendantByKeywords(boostShopActiveFrame, { "speed", "timer" })
	local speedBoostNode = findDescendantByKeywords(boostShopActiveFrame, { "speed", "boost" })
	local rebirthTimerNode = findDescendantByKeywords(boostShopActiveFrame, { "rebirth", "timer" })
	local rebirthBoostNode = findDescendantByKeywords(boostShopActiveFrame, { "rebirth", "boost" })
	local ascensionTimerNode = findDescendantByKeywords(boostShopActiveFrame, { "ascension", "timer" })
	local ascensionBoostNode = findDescendantByKeywords(boostShopActiveFrame, { "ascension", "boost" })

	local melonTimerLabel
	local melonBoostLabel
	local speedTimerLabel
	local speedBoostLabel
	local rebirthTimerLabel
	local rebirthBoostLabel
	local ascensionTimerLabel
	local ascensionBoostLabel

	local function refreshLabels()
		-- Re-resolver por si los labels se crean después de abrir la UI.
		local melonTimerNow = findDescendantByNameInsensitive(boostShopActiveFrame, "MelonTimer")
		local melonBoostNow = findDescendantByNameInsensitive(boostShopActiveFrame, "MelonBoost")
		local speedTimerNow = findDescendantByNameInsensitive(boostShopActiveFrame, "SpeedTimer")
		local speedBoostNow = findDescendantByNameInsensitive(boostShopActiveFrame, "SpeedBoost")
		local rebirthTimerNow = findDescendantByNameInsensitive(boostShopActiveFrame, "RebirthTimer")
		local rebirthBoostNow = findDescendantByNameInsensitive(boostShopActiveFrame, "RebirthBoost")
		local ascensionTimerNow = findDescendantByNameInsensitive(boostShopActiveFrame, "AscensionTimer")
		local ascensionBoostNow = findDescendantByNameInsensitive(boostShopActiveFrame, "AscensionBoost")

		melonTimerLabel = getTextLabel(melonTimerNow)
		melonBoostLabel = getTextLabel(melonBoostNow)
		speedTimerLabel = getTextLabel(speedTimerNow)
		speedBoostLabel = getTextLabel(speedBoostNow)
		rebirthTimerLabel = getTextLabel(rebirthTimerNow)
		rebirthBoostLabel = getTextLabel(rebirthBoostNow)
		ascensionTimerLabel = getTextLabel(ascensionTimerNow)
		ascensionBoostLabel = getTextLabel(ascensionBoostNow)
	end

	refreshLabels()

	local function setBoost(timerLabel, boostLabel, endTimeValue, multValue)
		-- Permite que falte uno de los dos (timer o boost label).
		if not (timerLabel or boostLabel) then return end
		local now = os.time()
		local remaining = 0
		local active = false
		if endTimeValue and type(endTimeValue.Value) == "number" then
			remaining = endTimeValue.Value - now
			active = remaining > 0
		end

		if timerLabel then
			-- Nunca mostrar "0". Cuando expira: "0:00".
			timerLabel.Text = active and formatTime(remaining) or "0:00"
		end
		if boostLabel then
			-- Nunca mostrar "0". Cuando expira: "x0".
			local mult = (multValue and type(multValue.Value) == "number") and multValue.Value or 2
			boostLabel.Text = active and ("x" .. tostring(mult)) or "x0"
		end
	end

	while player.Parent do
		-- Si alguno de los labels aún es nil, re-resolver.
		if not (melonTimerLabel and melonBoostLabel and speedTimerLabel and speedBoostLabel and rebirthTimerLabel and rebirthBoostLabel and ascensionTimerLabel and ascensionBoostLabel) then
			refreshLabels()
		end

		setBoost(melonTimerLabel, melonBoostLabel, events:FindFirstChild("MelonBoostEndTime"), events:FindFirstChild("MelonBoostMultiplier"))
		setBoost(speedTimerLabel, speedBoostLabel, events:FindFirstChild("SpeedBoostEndTime"), events:FindFirstChild("SpeedBoostMultiplier"))
		setBoost(rebirthTimerLabel, rebirthBoostLabel, events:FindFirstChild("RebirthBoostEndTime"), events:FindFirstChild("RebirthBoostMultiplier"))
		setBoost(ascensionTimerLabel, ascensionBoostLabel, events:FindFirstChild("AscensionBoostEndTime"), events:FindFirstChild("AscensionBoostMultiplier"))
		task.wait(1)
	end
end)

-- QuestFrame: CloseButton y sistema de misiones (Quest1, Quest2, Quest3)
local questFrame = gui:FindFirstChild("QuestFrame")
local questFrameData = frameData["QuestFrame"]
local FILL_TWEEN_TIME = 0.25

if questFrame and questFrameData then
	local events = player:WaitForChild("Events")

	local refreshClaimedFrame

	local function formatQuestNumber(qType, n)
		-- Solo abreviar para objetivos/progreso gigantes (melons / rebirth). Playtime queda en minutos normales.
		if qType == 1 then
			return tostring(math.floor(n))
		end
		return Abbreviate(n)
	end

	local function getQuestName(qType, target)
		if qType == 1 then
			return "Play for " .. formatQuestNumber(qType, target) .. " Minutes"
		elseif qType == 2 then
			return "Collect " .. formatQuestNumber(qType, target) .. " Melons"
		else
			return "Rebirth " .. formatQuestNumber(qType, target) .. " times"
		end
	end

	local function setupQuestUI(questSlot, questFrameChild)
		local questLabel = questFrameChild:FindFirstChild("QuestLabel")
		local questButton = questFrameChild:FindFirstChild("QuestButton")
		local frameFill = questFrameChild:FindFirstChild("FrameFill")
		local fill = frameFill and frameFill:FindFirstChild("Fill")

		local qTypeVal = events:FindFirstChild("Quest" .. questSlot .. "Type")
		local qTargetVal = events:FindFirstChild("Quest" .. questSlot .. "Target")
		local qProgressVal = events:FindFirstChild("Quest" .. questSlot .. "Progress")
		if not (qTypeVal and qTargetVal and qProgressVal) then return end

		local function updateUI()
			local qType = qTypeVal.Value
			local target = qTargetVal.Value
			local progress = qProgressVal.Value
			local isDone = progress >= target

			if questLabel then
				questLabel.Text = getQuestName(qType, target)
			end

			local progressLabel = questButton and (questButton:FindFirstChildOfClass("TextLabel") or questButton:FindFirstChildWhichIsA("TextLabel", true))
			if progressLabel then
				progressLabel.Text = isDone and "Done!" or (formatQuestNumber(qType, progress) .. "/" .. formatQuestNumber(qType, target))
			end

			if fill then
				local targetScaleX = (target > 0) and (math.min(progress, target) / target) or 0
				TweenService:Create(fill, TweenInfo.new(FILL_TWEEN_TIME, Enum.EasingStyle.Quad), {
					Size = UDim2.new(targetScaleX, 0, fill.Size.Y.Scale, fill.Size.Y.Offset)
				}):Play()
			end
		end

		updateUI()
		qTypeVal.Changed:Connect(updateUI)
		qTargetVal.Changed:Connect(updateUI)
		qProgressVal.Changed:Connect(updateUI)

		if questButton then
			local img = questButton:FindFirstChild("ImageLabel")
			ButtonScaleEffect.applyScaleEffect(questButton, img or questButton)
		end
	end

	-- CloseButton
	local closeButton = questFrame:FindFirstChild("CloseButton", true)
	if closeButton then
		local img = closeButton:FindFirstChild("ImageLabel")
		ButtonScaleEffect.applyScaleEffect(closeButton, img or closeButton)
		if closeButton:IsA("GuiButton") then
			closeButton.Activated:Connect(function() closeFrame(questFrameData) end)
		else
			closeButton.MouseButton1Click:Connect(function() closeFrame(questFrameData) end)
		end
	end

	-- Quest1, Quest2, Quest3
	for i = 1, 3 do
		local q = questFrame:FindFirstChild("Quest" .. i)
		if q then
			setupQuestUI(i, q)
		end
	end

	-- RewardFrame: ClaimQuest2 + ClaimDoubleQuest
	local rewardFrame = questFrame:FindFirstChild("RewardFrame", true)
	if rewardFrame then
		local claimButton = rewardFrame:FindFirstChild("ClaimQuest2", true)
		local claimDoubleButton = rewardFrame:FindFirstChild("ClaimDoubleQuest", true)
		-- `WarnLabel` es un TextLabel (hijo de QuestFrame o debajo)
		local warnLabelTemplate = questFrame:FindFirstChild("WarnLabel", true)

		local warnCount = 0
		local warnToken = 0
		local warnClone = nil
		local warnScale = nil

		local WARN_HIDE_SCALE_SEC = 0.08

		local function showWarn()
			if not (warnLabelTemplate and warnLabelTemplate:IsA("TextLabel")) then
				return
			end

			-- Ocultar la plantilla; el aviso visible es el clon
			warnLabelTemplate.Visible = false

			warnCount += 1
			warnToken += 1
			local myToken = warnToken

			if not warnClone or not warnClone.Parent then
				warnClone = warnLabelTemplate:Clone()
				warnClone.Name = "WarnLabel_Clone"
				warnClone.Visible = true
				warnClone.Parent = warnLabelTemplate.Parent

				warnScale = warnClone:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
				warnScale.Scale = 1
				warnScale.Parent = warnClone
			end

			local baseText = "You need to complete the quest First!"
			local fullText = (warnCount > 1) and (baseText .. " (x" .. tostring(warnCount) .. ")") or baseText
			warnClone.Text = fullText
			warnClone.Visible = true

			if warnScale then
				warnScale.Scale = 0.75
				TweenService:Create(warnScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
			end

			task.delay(3, function()
				if warnToken ~= myToken then
					return
				end
				warnCount = 0
				local toHide = warnClone
				local scaleObj = warnScale
				warnClone = nil
				warnScale = nil
				if toHide and toHide.Parent and scaleObj then
					local tw = TweenService:Create(scaleObj, TweenInfo.new(WARN_HIDE_SCALE_SEC, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0 })
					tw.Completed:Connect(function()
						if toHide.Parent then
							toHide:Destroy()
						end
					end)
					tw:Play()
				elseif toHide and toHide.Parent then
					toHide:Destroy()
				end
			end)
		end

		local function allDone()
			for i = 1, 3 do
				local t = events:FindFirstChild("Quest" .. i .. "Target")
				local p = events:FindFirstChild("Quest" .. i .. "Progress")
				if not (t and p) then
					return false
				end
				if p.Value < t.Value then
					return false
				end
			end
			local claimed = events:FindFirstChild("QuestRewardClaimed")
			return claimed and claimed.Value == 0
		end

		-- Nunca poner Active=false: si no, Roblox no dispara Activated y no puede salir el WarnLabel.
		local function setEnabled(btn, enabled)
			if not btn or not btn:IsA("GuiButton") then return end
			btn.Active = true
			btn.AutoButtonColor = enabled
			if btn:IsA("TextButton") then
				btn.BackgroundTransparency = enabled and 0 or 0.35
			end
		end

		local function refreshRewardButtons()
			local ok = allDone()
			setEnabled(claimButton, ok)
			setEnabled(claimDoubleButton, ok)
		end

		if claimButton and claimButton:IsA("GuiButton") then
			local img = claimButton:FindFirstChild("ImageLabel")
			ButtonScaleEffect.applyScaleEffect(claimButton, img or claimButton)
			claimButton.Activated:Connect(function()
				refreshRewardButtons()
				if not allDone() then
					showWarn()
					return
				end
				if questClaimRequest and questClaimRequest:IsA("RemoteEvent") then
					questClaimRequest:FireServer()
				end
			end)
		end

		if claimDoubleButton and claimDoubleButton:IsA("GuiButton") then
			local img = claimDoubleButton:FindFirstChild("ImageLabel")
			ButtonScaleEffect.applyScaleEffect(claimDoubleButton, img or claimDoubleButton)
			claimDoubleButton.Activated:Connect(function()
				refreshRewardButtons()
				if not allDone() then
					showWarn()
					return
				end
				MarketplaceService:PromptProductPurchase(player, 3563363605)
			end)
		end

		for i = 1, 3 do
			local p = events:FindFirstChild("Quest" .. i .. "Progress")
			local t = events:FindFirstChild("Quest" .. i .. "Target")
			if p then p.Changed:Connect(refreshRewardButtons) end
			if t then t.Changed:Connect(refreshRewardButtons) end
		end
		local claimed = events:FindFirstChild("QuestRewardClaimed")
		if claimed then claimed.Changed:Connect(refreshRewardButtons) end

		refreshRewardButtons()
	end

	-- ClaimedFrame: visible solo tras reclamar (QuestRewardClaimed == 1); timerLabel = tiempo hasta el reset diario
	local QUEST_RESET_SEC = 24 * 60 * 60
	local claimedFrame = questFrame:FindFirstChild("ClaimedFrame", true)
	local timerLabelClaimed = claimedFrame and (claimedFrame:FindFirstChild("timerLabel", true) or claimedFrame:FindFirstChild("TimerLabel", true))

	if claimedFrame and claimedFrame:IsA("GuiObject") then
		local function formatCountdown(totalSeconds)
			totalSeconds = math.max(0, math.floor(totalSeconds))
			local h = math.floor(totalSeconds / 3600)
			local m = math.floor((totalSeconds % 3600) / 60)
			local s = totalSeconds % 60
			return string.format("%dh %dm %ds", h, m, s)
		end

		refreshClaimedFrame = function()
			local claimedVal = events:FindFirstChild("QuestRewardClaimed")
			local lastResetVal = events:FindFirstChild("QuestLastResetTime")
			local isClaimed = claimedVal and claimedVal:IsA("NumberValue") and claimedVal.Value == 1
			if not isClaimed then
				claimedFrame.Visible = false
				return
			end
			claimedFrame.Visible = true
			if timerLabelClaimed and timerLabelClaimed:IsA("TextLabel") then
				local lr = (lastResetVal and lastResetVal:IsA("NumberValue") and lastResetVal.Value) or 0
				local nextReset = lr + QUEST_RESET_SEC
				local remaining = nextReset - os.time()
				timerLabelClaimed.Text = formatCountdown(remaining)
			end
		end

		task.spawn(function()
			while player.Parent do
				refreshClaimedFrame()
				task.wait(1)
			end
		end)

		local claimedNv = events:FindFirstChild("QuestRewardClaimed")
		if claimedNv then
			claimedNv.Changed:Connect(refreshClaimedFrame)
		end
		local lastResetNv = events:FindFirstChild("QuestLastResetTime")
		if lastResetNv then
			lastResetNv.Changed:Connect(refreshClaimedFrame)
		end

		refreshClaimedFrame()
	end

	-- Sonido al claimear recompensa
	if questClaimed and questClaimed:IsA("RemoteEvent") then
		questClaimed.OnClientEvent:Connect(function(ok)
			if ok ~= true then
				return
			end
			if refreshClaimedFrame then
				refreshClaimedFrame()
			end
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://129349771709668"
			sound.Volume = 1
			sound.Parent = game:GetService("SoundService")
			sound:Play()
			sound.Ended:Connect(function()
				sound:Destroy()
			end)
		end)
	end
end
