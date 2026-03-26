local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local displayGui = script.Parent

local ButtonScaleEffect = require(ReplicatedStorage.Shared:WaitForChild("ButtonScaleEffect"))
local UIBlur = require(ReplicatedStorage.Shared:WaitForChild("UIBlur"))
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

local questClaimRequest = ReplicatedStorage:FindFirstChild("QuestRewardClaimRequest")
local questClaimed = ReplicatedStorage:FindFirstChild("QuestRewardClaimed")

-- Currencies
local currencies = player:WaitForChild("Currencies")
local corn = currencies:WaitForChild("Corn")
local rebirths = currencies:WaitForChild("Rebirths")

-- Labels en Frame
local frame = displayGui:FindFirstChild("Frame")
if frame then
	local melonsFrame = frame:FindFirstChild("MelonsFrame")
	local rebirthFrame = frame:FindFirstChild("RebirthFrame")

	local function updateMelonsLabel()
		if melonsFrame then
			local label = melonsFrame:FindFirstChild("TextLabel")
			if label then
				label.Text = Abbreviate(corn.Value)
			end
		end
	end

	local function updateRebirthsLabel()
		if rebirthFrame then
			local label = rebirthFrame:FindFirstChild("TextLabel")
			if label then
				label.Text = Abbreviate(rebirths.Value)
			end
		end
	end

	updateMelonsLabel()
	updateRebirthsLabel()
	corn.Changed:Connect(updateMelonsLabel)
	rebirths.Changed:Connect(updateRebirthsLabel)
end

-- Botones que abren frames con animación Scale in (solo uno abierto a la vez)
local SCALE_TWEEN_TIME = 0.15
local TARGET_SCALE = 1
local tweenInfo = TweenInfo.new(SCALE_TWEEN_TIME, Enum.EasingStyle.Quad)

local buttonToFrame = {
	BoostsButton = "BoostShop",
	QuestsButton = "QuestFrame",
	ShopButton = "Shop",
}

-- Datos de cada frame para poder cerrarlos
local frameData = {}

local function closeFrame(data, skipOverlayEnd: boolean?)
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

local function openFrame(data, skipOverlayBegin: boolean?)
	data.frame.Visible = true
	data.isOpen = true
	if not skipOverlayBegin then
		UIBlur.beginModal()
	end
	TweenService:Create(data.uiScale, tweenInfo, { Scale = TARGET_SCALE }):Play()
end

-- Primero preparar todos los frames
for buttonName, frameName in pairs(buttonToFrame) do
	local targetFrame = displayGui:FindFirstChild(frameName)
	if targetFrame then
		local uiScale = targetFrame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		uiScale.Scale = 0
		uiScale.Parent = targetFrame
		targetFrame.Visible = false
		frameData[frameName] = { frame = targetFrame, uiScale = uiScale, isOpen = false }
	end
end

-- Conectar botones
for buttonName, frameName in pairs(buttonToFrame) do
	local button = displayGui:FindFirstChild(buttonName)
	local data = frameData[frameName]

	if button and data then
		local img = button:FindFirstChild("ImageLabel")
		ButtonScaleEffect.applyScaleEffect(button, img or button)

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

		if button:IsA("GuiButton") then
			button.Activated:Connect(toggleFrame)
		else
			button.MouseButton1Click:Connect(toggleFrame)
		end
	end
end

-- Shop: CloseButton y botones de gamepass
local shop = displayGui:FindFirstChild("Shop")
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

	-- Gamepasses: frame -> gamepass ID
	local gamepassFrames = {
		RebirthMultiplier = 1740115835,
		MelonMultiplier = 1740686732,
		EverythingFrame = 1740820575, -- Pack completo
		WalkSpeedMultiplier = 1740406688,
		AscensionMultiplier = 1740630375,
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
			local f = shop:FindFirstChild(frameName)
			if f then
				local buyButton = f:FindFirstChildWhichIsA("GuiButton", true)
				if buyButton then
					updateOwnedLabel(buyButton, gamePassId)
				end
			end
		end
	end

	for frameName, gamePassId in pairs(gamepassFrames) do
		local frame = shop:FindFirstChild(frameName)
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
local boostShop = displayGui:FindFirstChild("BoostShop", true)
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
local questFrame = displayGui:FindFirstChild("QuestFrame")
local questFrameData = frameData["QuestFrame"]
local FILL_TWEEN_TIME = 0.25

if questFrame and questFrameData then
	local events = player:WaitForChild("Events")

	local refreshClaimedFrame: (() -> ())?

	local function formatQuestNumber(qType: number, n: number)
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
		local warnClone: TextLabel? = nil
		local warnScale: UIScale? = nil

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
				warnClone = warnLabelTemplate:Clone() :: TextLabel
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
		local function setEnabled(btn: Instance?, enabled: boolean)
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
		local function formatCountdown(totalSeconds: number): string
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
