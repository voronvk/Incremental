-- RuneGuiController.client.luau
-- Control del BasicRune: UI de Keys (visual), compra de runes (gasto), open x1/x3 y WarnLabel (si faltan llaves).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer

local UIClickSound = require(ReplicatedStorage.Shared:WaitForChild("UIClickSound"))
local RunesConfig = require(ReplicatedStorage.Shared:WaitForChild("RunesConfig"))
local Attr = require(ReplicatedStorage.Shared:WaitForChild("PlayerClientAttributes"))
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
local GamePassConfig = require(ReplicatedStorage.Shared:WaitForChild("GamePassConfig"))

-- Ajusta si luego quieres otra animacion/sound
local WARNY_SOUND_ID = "rbxassetid://139009780109934"
local WARN_HIDE_SCALE_SEC = 0.08

local CYCLE_SECONDS = 60
local ATTR_RUNE_UNBOXING = "RuneUnboxingActive"
local CATEGORY_BASIC = "BasicRune"
local CATEGORY_GOLD = "GoldRune"
local CURRENCY_KEYS = "Keys"
local CURRENCY_GOLD = "Gold"
local PRODUCT_KEYS_50 = 3577038716
local PRODUCT_KEYS_500 = 3577038852
local PRODUCT_KEYS_10K = 3577038971
local GP_MYTHIC_HUNTER = GamePassConfig.RUNE_MYTHIC_HUNTER_GAMEPASS_ID or 1798929641
local GP_X2_KEYS = GamePassConfig.RUNE_X2_KEYS_GAMEPASS_ID or 1795970950
local GP_FAST_OPEN = GamePassConfig.RUNE_FAST_OPEN_GAMEPASS_ID or 1799822625
local FAST_OPEN_SPEED_MULT = 1.5
local BUTTON_COLOR_UNLOCKED = Color3.fromRGB(255, 255, 255)
local BUTTON_COLOR_LOCKED = Color3.fromRGB(127, 127, 127)
local RUNE_BUTTON_GAMEPASSES = {
	[GP_MYTHIC_HUNTER] = true,
	[GP_FAST_OPEN] = true,
	[GP_X2_KEYS] = true,
}
local pendingRuneButtonGamepassPurchase: { [number]: boolean } = {}
local luckyButton: GuiButton? = nil
local speedButton: GuiButton? = nil
local keysButton: GuiButton? = nil
local goldLuckyButton: GuiButton? = nil
local goldSpeedButton: GuiButton? = nil

local function getPlayerKeysValue(): NumberValue?
	local currencies = player:FindFirstChild("Currencies")
	if not currencies then return nil end
	local keys = currencies:FindFirstChild(CURRENCY_KEYS)
	if keys and keys:IsA("NumberValue") then
		return keys
	end
	return nil
end

local function getPlayerGoldValue(): NumberValue?
	local currencies = player:FindFirstChild("Currencies")
	if not currencies then return nil end
	local gold = currencies:FindFirstChild(CURRENCY_GOLD)
	if gold and gold:IsA("NumberValue") then
		return gold
	end
	return nil
end

local function asGuiButton(root: Instance?): GuiButton?
	if not root then return nil end
	if root:IsA("GuiButton") then
		return root
	end
	return root:FindFirstChildWhichIsA("GuiButton", true)
end

local function getOrCreateUIScale(guiObject: Instance): UIScale
	local uiScale = guiObject:FindFirstChildOfClass("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Scale = 1
		uiScale.Parent = guiObject
	end
	return uiScale
end

local function connectButtonEffects(guiRoot: Instance?)
	local btn = asGuiButton(guiRoot)
	if not btn then return end

	btn.Active = true
	btn.Selectable = true

	local uiScale = getOrCreateUIScale(btn)
	uiScale.Scale = 1

	local hovered = false
	local function tweenScale(scale: number, tweenInfo: TweenInfo)
		TweenService:Create(uiScale, tweenInfo, { Scale = scale }):Play()
	end

	local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local clickTween = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	btn.MouseEnter:Connect(function()
		hovered = true
		tweenScale(1.04, hoverTween)
	end)

	btn.MouseLeave:Connect(function()
		hovered = false
		tweenScale(1, hoverTween)
	end)

	btn.MouseButton1Down:Connect(function()
		tweenScale(0.96, clickTween)
	end)

	btn.MouseButton1Up:Connect(function()
		tweenScale(hovered and 1.04 or 1, clickTween)
	end)

	UIClickSound.connectToButton(btn)
end

local function connectPurchaseGamepassButton(guiRoot: Instance?, gamePassId: number)
	local btn = asGuiButton(guiRoot)
	if not btn then
		return
	end
	btn.Activated:Connect(function()
		pendingRuneButtonGamepassPurchase[gamePassId] = true
		MarketplaceService:PromptGamePassPurchase(player, gamePassId)
	end)
end

local function setButtonVisualOwned(btn: GuiButton?, owned: boolean)
	if not btn then
		return
	end
	local targetColor = owned and BUTTON_COLOR_UNLOCKED or BUTTON_COLOR_LOCKED
	btn.ImageColor3 = targetColor
	local imageLabel = btn:FindFirstChild("ImageLabel")
	if imageLabel and imageLabel:IsA("ImageLabel") then
		imageLabel.ImageColor3 = targetColor
	end
end

local function refreshRuneGamepassButtonsColor()
	setButtonVisualOwned(luckyButton, GamePassCheck.playerOwnsGamePass(player, GP_MYTHIC_HUNTER))
	setButtonVisualOwned(speedButton, GamePassCheck.playerOwnsGamePass(player, GP_FAST_OPEN))
	setButtonVisualOwned(keysButton, GamePassCheck.playerOwnsGamePass(player, GP_X2_KEYS))
	setButtonVisualOwned(goldLuckyButton, GamePassCheck.playerOwnsGamePass(player, GP_MYTHIC_HUNTER))
	setButtonVisualOwned(goldSpeedButton, GamePassCheck.playerOwnsGamePass(player, GP_FAST_OPEN))
end

-- UI references
local playerGui = player:WaitForChild("PlayerGui")
local runeGui = playerGui:WaitForChild("RuneGui")
local frames = runeGui:WaitForChild("Frames")
local basicRuneFrame = frames:WaitForChild("BasicRune")
local goldRuneFrame = frames:FindFirstChild("GoldRune")

local holder = basicRuneFrame:WaitForChild("Holder")
local scrolling = holder:WaitForChild("ScrollingFrame")

local amountLabel = scrolling:WaitForChild("AmountFrame"):WaitForChild("AmountLabel")

local timeFrame = scrolling:WaitForChild("TimeFrame")
local timeLabel = timeFrame:WaitForChild("TimeLabel")
local fillFrame = timeFrame:WaitForChild("FillFrame")

local btn50 = scrolling:WaitForChild("50KeysButton")
local btn500 = scrolling:WaitForChild("500KeysButton")
local btn10k = scrolling:WaitForChild("10KButton")
-- Estos 3 botones viven como hijos de BasicRune (hermanos de Holder).
-- Dejamos fallback al Scrolling por compatibilidad con layouts viejos.
local luckyButtonRoot = basicRuneFrame:FindFirstChild("LuckyButton", true) or scrolling:FindFirstChild("LuckyButton", true)
local speedButtonRoot = basicRuneFrame:FindFirstChild("SpeedButton", true) or scrolling:FindFirstChild("SpeedButton", true)
local keysButtonRoot = basicRuneFrame:FindFirstChild("KeysButton", true) or scrolling:FindFirstChild("KeysButton", true)
luckyButton = asGuiButton(luckyButtonRoot)
speedButton = asGuiButton(speedButtonRoot)
keysButton = asGuiButton(keysButtonRoot)

-- GoldRune: mismos gamepasses (Mythic Hunter, Fast Open), sin botón de Keys.
local goldLuckyButtonRoot = goldRuneFrame and goldRuneFrame:FindFirstChild("LuckyButton", true)
local goldSpeedButtonRoot = goldRuneFrame and goldRuneFrame:FindFirstChild("SpeedButton", true)
goldLuckyButton = asGuiButton(goldLuckyButtonRoot)
goldSpeedButton = asGuiButton(goldSpeedButtonRoot)

local openArea = scrolling:WaitForChild("Frame", 60)
local openx1 = openArea:WaitForChild("OpenButtonx1", 60) -- en tu UI
local openx3 = openArea:WaitForChild("OpenButtonx3", 60) -- en tu UI
local goldHolder = goldRuneFrame and goldRuneFrame:FindFirstChild("Holder")
local goldScrolling = goldHolder and goldHolder:FindFirstChild("ScrollingFrame")
local goldAmountLabel = goldScrolling and goldScrolling:FindFirstChild("AmountFrame")
	and goldScrolling.AmountFrame:FindFirstChild("AmountLabel")
local goldOpenArea = goldScrolling and goldScrolling:FindFirstChild("Frame")
local goldOpenx1 = goldOpenArea and goldOpenArea:FindFirstChild("OpenButtonx1")
local goldOpenx3 = goldOpenArea and goldOpenArea:FindFirstChild("OpenButtonx3")
local confettiFolder = runeGui:FindFirstChild("Folder")
local confettiSizesHolder = confettiFolder and confettiFolder:FindFirstChild("Sizes")
local confettiContainer = confettiFolder and confettiFolder:FindFirstChild("Container")
local deco = runeGui:FindFirstChild("Deco", true)
local black = deco and deco:FindFirstChild("Black")
local frame1 = runeGui:FindFirstChild("Frame1", true)
local frame2 = runeGui:FindFirstChild("Frame2", true)
local frame3 = runeGui:FindFirstChild("Frame3", true)
local tappingGui = playerGui:FindFirstChild("TappingGui")
local tappingFrames = tappingGui and tappingGui:FindFirstChild("Frames")

local function refreshTappingGuiRef()
	if not (tappingGui and tappingGui:IsA("ScreenGui")) then
		tappingGui = playerGui:FindFirstChild("TappingGui")
	end
	return tappingGui
end

-- TappingGui debe ocultarse solo cuando el frame de tienda runa sigue visible; no usar el Enabled
-- capturado al inicio del unboxing (suele ser false con la runa abierta y deja el HUD pegado en false).
local function syncTappingGuiToRuneShopFrames()
	local tg = refreshTappingGuiRef()
	if not (tg and tg:IsA("ScreenGui")) then
		return
	end
	if player:GetAttribute(Attr.CLIENT_LOADING_COMPLETE) ~= true then
		return
	end
	if player:GetAttribute(ATTR_RUNE_UNBOXING) == true then
		tg.Enabled = false
		return
	end
	if player:GetAttribute(Attr.RUNE_TOUCH_SHOP_OPEN) ~= true then
		tg.Enabled = true
		return
	end
	local goldOpen = goldRuneFrame and goldRuneFrame:IsA("GuiObject") and goldRuneFrame.Visible
	local basicOpen = basicRuneFrame:IsA("GuiObject") and basicRuneFrame.Visible
	tg.Enabled = not (basicOpen or goldOpen)
end
local indexFrame = tappingFrames and tappingFrames:FindFirstChild("Index")
local indexHolder = indexFrame and indexFrame:FindFirstChild("Holder")
local indexScrolling = indexHolder and indexHolder:FindFirstChild("ScrollingFrame")
local isUnboxing = false
local weightedRng = Random.new()
local previewRng = Random.new()
local confettiRng = Random.new()
local playNamedSfx: (string) -> ()
local startNamedLoopSfx: (string) -> Sound?
local playUnlockSoundForChance: (number) -> ()

local CONFETTI_COLORS = {
	Color3.fromRGB(0, 34, 255),
	Color3.fromRGB(170, 255, 0),
	Color3.fromRGB(0, 255, 255),
	Color3.fromRGB(0, 255, 170),
	Color3.fromRGB(255, 170, 0),
	Color3.fromRGB(255, 0, 255),
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(255, 255, 0),
}

local function tweenAndWait(instance: Instance, tweenInfo: TweenInfo, goals: { [string]: any })
	local tween = TweenService:Create(instance, tweenInfo, goals)
	tween:Play()
	tween.Completed:Wait()
end

local function setBlackTransparency(value: number)
	if not (black and black:IsA("GuiObject")) then
		return
	end
	if black:IsA("ImageLabel") or black:IsA("ImageButton") then
		black.ImageTransparency = value
	else
		black.BackgroundTransparency = value
	end
end

local function tweenBlackTransparency(value: number, tweenInfo: TweenInfo)
	if not (black and black:IsA("GuiObject")) then
		return
	end
	if black:IsA("ImageLabel") or black:IsA("ImageButton") then
		tweenAndWait(black, tweenInfo, { ImageTransparency = value })
	else
		tweenAndWait(black, tweenInfo, { BackgroundTransparency = value })
	end
end

local function formatChance(chanceValue: number): string
	local rounded = math.floor(chanceValue)
	if math.abs(chanceValue - rounded) < 0.0001 then
		return tostring(rounded) .. "%"
	end
	return string.format("%.2f%%", chanceValue)
end

local function pickWeightedRuneDef(runes: { any })
	local weighted = {}
	local total = 0
	local hasMythicHunter = GamePassCheck.playerOwnsGamePass(player, GP_MYTHIC_HUNTER)
	local rarestIndex = nil
	local rarestWeight = math.huge
	local highestWeightIndex = nil
	local highestWeight = -math.huge

	for idx, runeDef in ipairs(runes) do
		local w = math.max(0, tonumber(runeDef.Chance) or 0)
		weighted[idx] = { runeDef = runeDef, weight = w }
		if w > 0 then
			total += w
		end
		if w > 0 and w < rarestWeight then
			rarestWeight = w
			rarestIndex = idx
		end
		if w > highestWeight then
			highestWeight = w
			highestWeightIndex = idx
		end
	end

	if hasMythicHunter and rarestIndex and highestWeightIndex then
		weighted[rarestIndex].weight += 1
		if highestWeightIndex ~= rarestIndex and weighted[highestWeightIndex].weight > 0 then
			weighted[highestWeightIndex].weight = math.max(0, weighted[highestWeightIndex].weight - 1)
		end
	end

	total = 0
	for _, entry in ipairs(weighted) do
		if entry.weight > 0 then
			total += entry.weight
		end
	end
	if total <= 0 then
		return runes[1]
	end

	local roll = weightedRng:NextNumber(0, total)
	local acc = 0
	for _, entry in ipairs(weighted) do
		local w = entry.weight
		if w > 0 then
			acc += w
			if roll <= acc then
				return entry.runeDef
			end
		end
	end
	return weighted[#weighted] and weighted[#weighted].runeDef or runes[#runes]
end

local function pickPreviewRuneDef(runes: { any })
	if #runes <= 0 then
		return nil
	end
	local idx = previewRng:NextInteger(1, #runes)
	return runes[idx]
end

local function getRunesByCategory(category: string): { any }
	local out = {}
	for _, runeDef in ipairs(RunesConfig.Runes or {}) do
		if runeDef.Category == category then
			table.insert(out, runeDef)
		end
	end
	return out
end

local function applyFrameRune(frameObj: Instance?, runeDef: any, isFinal: boolean)
	if not (frameObj and frameObj:IsA("GuiObject")) then
		return
	end
	if not runeDef then
		return
	end
	local chanceLabel = frameObj:FindFirstChild("ChanceLabel", true)
	local nameLabel = frameObj:FindFirstChild("NameLabel", true)
	local runeLabel = frameObj:FindFirstChild("RuneLabel", true)
	if chanceLabel and chanceLabel:IsA("TextLabel") then
		chanceLabel.Text = formatChance(tonumber(runeDef.Chance) or 0)
	end
	if nameLabel and nameLabel:IsA("TextLabel") then
		nameLabel.Text = tostring(runeDef.DisplayName or runeDef.Id or "Unknown Rune")
	end
	if runeLabel and runeLabel:IsA("ImageLabel") then
		local imageId = runeDef.ImageId
		if type(imageId) == "string" and imageId ~= "" then
			runeLabel.Image = imageId
		end
		runeLabel.ImageColor3 = isFinal and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
	end
end

local function playConfetti(num: number)
	if num <= 0 then
		return
	end
	if not (confettiSizesHolder and confettiSizesHolder:IsA("Folder")) then
		return
	end

	local sizeTemplates = confettiSizesHolder:GetChildren()
	if #sizeTemplates == 0 then
		return
	end

	local parentContainer = confettiContainer
	if not parentContainer then
		parentContainer = confettiFolder
	end
	if not parentContainer then
		return
	end

	task.spawn(function()
		for _ = 1, num do
			task.wait(0.001)

			local template = sizeTemplates[confettiRng:NextInteger(1, #sizeTemplates)]
			if not template:IsA("Frame") then
				continue
			end

			local piece = template:Clone()
			piece.BackgroundColor3 = CONFETTI_COLORS[confettiRng:NextInteger(1, #CONFETTI_COLORS)]
			piece.Position = UDim2.new(confettiRng:NextNumber(0, 1), 0, confettiRng:NextNumber(-0.6, -0.2), 0)
			piece.Rotation = confettiRng:NextNumber(10, 350)
			piece.Visible = true
			piece.Parent = parentContainer

			local startX = piece.Position.X.Scale
			local horizontalOffset = confettiRng:NextNumber(-0.12, 0.12)
			local tweenDown = TweenService:Create(
				piece,
				TweenInfo.new(confettiRng:NextNumber(0.8, 1.35), Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{ Position = UDim2.new(startX + horizontalOffset, 0, confettiRng:NextNumber(1.15, 1.4), 0) }
			)
			tweenDown:Play()
			tweenDown.Completed:Connect(function()
				task.wait(2)
				if piece and piece.Parent then
					piece:Destroy()
				end
			end)
		end
	end)
end

local function playUnboxingAnimation(openCount: number, sourceFrame: GuiObject, category: string)
	if isUnboxing then
		return
	end
	if not (frame1 and frame1:IsA("GuiObject")) then
		return
	end
	isUnboxing = true
	player:SetAttribute(ATTR_RUNE_UNBOXING, true)
	player:SetAttribute(Attr.AUTO_TAP, false)
	player:SetAttribute(Attr.AUTO_TAP_GOLD, false)
	player:SetAttribute(Attr.AUTO_HARVEST, false)
	player:SetAttribute(Attr.AUTO_HARVEST_GOLD, false)
	local hasFastOpen = GamePassCheck.playerOwnsGamePass(player, GP_FAST_OPEN)
	local speedMult = hasFastOpen and FAST_OPEN_SPEED_MULT or 1

	local function scaled(seconds: number): number
		return seconds / speedMult
	end

	local function makeTweenInfo(seconds: number, style: Enum.EasingStyle, direction: Enum.EasingDirection): TweenInfo
		return TweenInfo.new(scaled(seconds), style, direction)
	end

	local runes = getRunesByCategory(category)
	if #runes == 0 then
		player:SetAttribute(ATTR_RUNE_UNBOXING, false)
		isUnboxing = false
		return
	end
	local whileOpeningSound = startNamedLoopSfx("WhileOpening")
	local activeFrames = {}
	if frame1 and frame1:IsA("GuiObject") then table.insert(activeFrames, frame1) end
	if openCount >= 3 then
		if frame2 and frame2:IsA("GuiObject") then table.insert(activeFrames, frame2) end
		if frame3 and frame3:IsA("GuiObject") then table.insert(activeFrames, frame3) end
	end
	local frameScales = {}
	for _, frameObj in ipairs(activeFrames) do
		frameObj.Visible = true
		local s = getOrCreateUIScale(frameObj)
		s.Scale = 0.6
		frameScales[frameObj] = s
		local runeLabel = frameObj:FindFirstChild("RuneLabel", true)
		if runeLabel and runeLabel:IsA("ImageLabel") then
			runeLabel.ImageColor3 = Color3.fromRGB(0, 0, 0)
		end
	end

	refreshTappingGuiRef()
	if tappingGui and tappingGui:IsA("ScreenGui") then
		tappingGui.Enabled = false
	end

	sourceFrame.Visible = false

	local ok, err = pcall(function()
		if black and black:IsA("GuiObject") then
			setBlackTransparency(1)
			tweenBlackTransparency(0.2, makeTweenInfo(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
		end

		local totalCycles = 4
		for cycle = 1, totalCycles do
			local isLast = cycle == totalCycles
			local finalBestChance = nil
			for _, frameObj in ipairs(activeFrames) do
				local runeDef = isLast and pickWeightedRuneDef(runes) or pickPreviewRuneDef(runes)
				applyFrameRune(frameObj, runeDef, isLast)
				if isLast then
					local c = tonumber(runeDef and runeDef.Chance) or 0
					if finalBestChance == nil or c < finalBestChance then
						finalBestChance = c
					end
				end
			end

			playNamedSfx("Woosh")
			for _, frameObj in ipairs(activeFrames) do
				local scaleObj = frameScales[frameObj]
				if scaleObj then
					scaleObj.Scale = 0.6
					TweenService:Create(scaleObj, makeTweenInfo(0.36, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Scale = 1.2,
					}):Play()
				end
			end
			task.wait(scaled(0.36))

			if isLast and finalBestChance then
				playUnlockSoundForChance(finalBestChance)
				playConfetti(180)
			end

			if not isLast then
				for _, frameObj in ipairs(activeFrames) do
					local scaleObj = frameScales[frameObj]
					if scaleObj then
						TweenService:Create(scaleObj, makeTweenInfo(0.36, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Scale = 0.6,
						}):Play()
					end
				end
				task.wait(scaled(0.36))
			end
		end
		task.wait(scaled(1.2))

		for _, frameObj in ipairs(activeFrames) do
			local scaleObj = frameScales[frameObj]
			if scaleObj then
				TweenService:Create(scaleObj, makeTweenInfo(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0 }):Play()
			end
		end
		task.wait(scaled(0.2))
		for _, frameObj in ipairs(activeFrames) do
			frameObj.Visible = false
		end

		if black and black:IsA("GuiObject") then
			tweenBlackTransparency(1, makeTweenInfo(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
		end
	end)

	if not ok then
		warn("[RuneGuiController] Unboxing animation failed:", err)
		for _, frameObj in ipairs(activeFrames) do
			frameObj.Visible = false
		end
		if black and black:IsA("GuiObject") then
			setBlackTransparency(1)
		end
	end

	-- Quitar unboxing ANTES de sync: si no, sync ve RuneUnboxingActive y deja TappingGui en false
	-- aunque el jugador ya haya salido del pedestal (BasicRuneTouch ya lo había puesto en true).
	if whileOpeningSound then
		whileOpeningSound:Stop()
		whileOpeningSound:Destroy()
	end
	player:SetAttribute(ATTR_RUNE_UNBOXING, false)
	isUnboxing = false

	-- No reabrir la tienda si el jugador ya salió del pedestal mientras animaba.
	if player:GetAttribute(Attr.RUNE_TOUCH_SHOP_OPEN) == true then
		sourceFrame.Visible = true
	end
	syncTappingGuiToRuneShopFrames()
end

-- WarnLabel (hijo de RuneGui) - por nombre exacto o por caso distinto.
local function findFirstChildByNameInsensitive(root: Instance?, targetName: string): Instance?
	if not root then return nil end
	local lowered = string.lower(targetName)
	for _, inst in ipairs(root:GetDescendants()) do
		if inst.Name and string.lower(inst.Name) == lowered then
			return inst
		end
	end
	-- also check root itself
	if root.Name and string.lower(root.Name) == lowered then
		return root
	end
	return nil
end

local warnTemplate = runeGui:FindFirstChild("WarnLabel", true)
if not warnTemplate then
	warnTemplate = findFirstChildByNameInsensitive(runeGui, "Warnlabel")
end
local warnClone: TextLabel? = nil
local warnScale: UIScale? = nil
local warnCount = 0
local warnToken = 0

local function isSfxMuted(): boolean
	local settings = player:FindFirstChild("Settings")
	local sfx = settings and settings:FindFirstChild("SfxMuted")
	return sfx ~= nil and sfx:IsA("IntValue") and sfx.Value >= 1
end

local function playWarnySound()
	if isSfxMuted() then
		return
	end
	local s = Instance.new("Sound")
	s.SoundId = WARNY_SOUND_ID
	s.Volume = 1
	s.Parent = SoundService
	s:Play()
	s.Ended:Connect(function()
		s:Destroy()
	end)
end

function playNamedSfx(soundName: string)
	if isSfxMuted() then
		return
	end
	local template = SoundService:FindFirstChild(soundName)
	if not template then
		local sfxFolder = ReplicatedStorage:FindFirstChild("SFX")
		if sfxFolder then
			template = sfxFolder:FindFirstChild(soundName)
		end
	end
	if not template then
		local soundsFolder = ReplicatedStorage:FindFirstChild("Sounds")
		if soundsFolder then
			template = soundsFolder:FindFirstChild(soundName)
		end
	end
	if not (template and template:IsA("Sound")) then
		return
	end
	local s = template:Clone()
	s.Parent = SoundService
	s:Play()
	s.Ended:Connect(function()
		s:Destroy()
	end)
end

function startNamedLoopSfx(soundName: string): Sound?
	if isSfxMuted() then
		return nil
	end
	local template = SoundService:FindFirstChild(soundName)
	if not template then
		local sfxFolder = ReplicatedStorage:FindFirstChild("SFX")
		if sfxFolder then
			template = sfxFolder:FindFirstChild(soundName)
		end
	end
	if not template then
		local soundsFolder = ReplicatedStorage:FindFirstChild("Sounds")
		if soundsFolder then
			template = soundsFolder:FindFirstChild(soundName)
		end
	end
	if not (template and template:IsA("Sound")) then
		return nil
	end
	local s = template:Clone()
	s.Looped = true
	s.Parent = SoundService
	s:Play()
	return s
end

function playUnlockSoundForChance(chanceValue: number)
	if chanceValue <= 2 then
		playNamedSfx("UnlockLegendary")
	elseif chanceValue <= 10 then
		playNamedSfx("UnlockEpic")
	elseif chanceValue <= 30 then
		playNamedSfx("UnlockRare")
	else
		playNamedSfx("UnlockBasic")
	end
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr, gamePassId, purchased)
	if plr ~= player then
		return
	end
	if not RUNE_BUTTON_GAMEPASSES[gamePassId] then
		return
	end
	if not pendingRuneButtonGamepassPurchase[gamePassId] then
		return
	end

	pendingRuneButtonGamepassPurchase[gamePassId] = nil
	if not purchased then
		refreshRuneGamepassButtonsColor()
		return
	end

	playNamedSfx("UnlockBasic")
	playConfetti(140)
	refreshRuneGamepassButtonsColor()
end)

local function showWarnLabel(text: string)
	if not (warnTemplate and warnTemplate:IsA("TextLabel")) then
		return
	end

	warnTemplate.Visible = false

	warnCount += 1
	warnToken += 1
	local myToken = warnToken

	if not warnClone or not warnClone.Parent then
		warnClone = warnTemplate:Clone()
		warnClone.Name = "RuneWarnLabel_Clone"
		warnClone.Visible = true
		warnClone.Parent = warnTemplate.Parent

		warnScale = warnClone:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		warnScale.Scale = 1
		warnScale.Parent = warnClone
	end

	local fullText = (warnCount > 1) and (text .. " (x" .. tostring(warnCount) .. ")") or text
	warnClone.Text = fullText
	warnClone.Visible = true

	if warnScale then
		warnScale.Scale = 0.75
		TweenService:Create(
			warnScale,
			TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
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
			local tw = TweenService:Create(
				scaleObj,
				TweenInfo.new(WARN_HIDE_SCALE_SEC, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ Scale = 0 }
			)
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

local function tweenFillTo(alpha: number)
	alpha = math.clamp(alpha, 0, 1)
	local yScale = fillFrame.Size.Y.Scale
	local yOffset = fillFrame.Size.Y.Offset
	TweenService:Create(
		fillFrame,
		TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = UDim2.new(alpha, 0, yScale, yOffset) }
	):Play()
end

-- Visual timer (solo UI)
task.spawn(function()
	local cycleStart = os.clock()
	while basicRuneFrame.Parent do
		-- Usa tiempo real para que avance aunque la UI esté oculta.
		local elapsed = math.floor(os.clock() - cycleStart)
		local phase = elapsed % CYCLE_SECONDS
		-- Mostrar "60/60" en el segundo exacto del reset.
		local t = (phase == 0 and elapsed > 0) and CYCLE_SECONDS or phase
		timeLabel.Text = ("%d/%d"):format(t, CYCLE_SECONDS)
		tweenFillTo(t / CYCLE_SECONDS)
		task.wait(1)
	end
end)

-- Keys UI (espera a que exista)
local keysVal = nil :: NumberValue?
do
	local currencies = player:WaitForChild("Currencies", 30)
	if currencies then
		local kv = currencies:FindFirstChild("Keys")
		if kv and kv:IsA("NumberValue") then
			keysVal = kv
		else
			-- Espera por si se crea un poco después.
			local okKv = currencies:WaitForChild("Keys", 30)
			if okKv and okKv:IsA("NumberValue") then
				keysVal = okKv
			end
		end
	end
end
local function refreshKeysLabel()
	local v = keysVal and keysVal.Value or 0
	amountLabel.Text = tostring(math.floor(v))
	if goldAmountLabel and goldAmountLabel:IsA("TextLabel") then
		local gv = getPlayerGoldValue()
		goldAmountLabel.Text = tostring(math.floor(gv and gv.Value or 0))
	end
end

refreshKeysLabel()
if keysVal then
	keysVal.Changed:Connect(refreshKeysLabel)
end
local goldVal = getPlayerGoldValue()
if goldVal then
	goldVal.Changed:Connect(refreshKeysLabel)
end

-- Scale effects on the buttons
connectButtonEffects(btn50)
connectButtonEffects(btn500)
connectButtonEffects(btn10k)
connectButtonEffects(openx1)
connectButtonEffects(openx3)
connectButtonEffects(goldOpenx1)
connectButtonEffects(goldOpenx3)
connectButtonEffects(luckyButton)
connectButtonEffects(speedButton)
connectButtonEffects(keysButton)
connectButtonEffects(goldLuckyButton)
connectButtonEffects(goldSpeedButton)

btn50.Activated:Connect(function()
	MarketplaceService:PromptProductPurchase(player, PRODUCT_KEYS_50)
end)
btn500.Activated:Connect(function()
	MarketplaceService:PromptProductPurchase(player, PRODUCT_KEYS_500)
end)
btn10k.Activated:Connect(function()
	MarketplaceService:PromptProductPurchase(player, PRODUCT_KEYS_10K)
end)
connectPurchaseGamepassButton(luckyButton, GP_MYTHIC_HUNTER)
connectPurchaseGamepassButton(speedButton, GP_FAST_OPEN)
connectPurchaseGamepassButton(keysButton, GP_X2_KEYS)
connectPurchaseGamepassButton(goldLuckyButton, GP_MYTHIC_HUNTER)
connectPurchaseGamepassButton(goldSpeedButton, GP_FAST_OPEN)
refreshRuneGamepassButtonsColor()
player:GetAttributeChangedSignal("GamePassSyncStamp"):Connect(refreshRuneGamepassButtonsColor)

-- Open requests: x1/x3
local openRequest = ReplicatedStorage:WaitForChild("RuneOpenRequest", 30)

local function hookOpenButton(
	guiBtn: GuiButton,
	n: number,
	sourceFrame: GuiObject,
	currencyName: string,
	category: string
)
	guiBtn.Activated:Connect(function()
		if isUnboxing then
			return
		end
		local valueObj = (currencyName == CURRENCY_GOLD) and getPlayerGoldValue() or getPlayerKeysValue()
		if not valueObj then return end
		if valueObj.Value < n then
			playWarnySound()
			showWarnLabel((currencyName == CURRENCY_GOLD) and "You dont have gold!" or "You dont have keys!")
			return
		end
		openRequest:FireServer(n, category, currencyName)
		task.spawn(function()
			playUnboxingAnimation(n, sourceFrame, category)
		end)
	end)
end

hookOpenButton(openx1, 1, basicRuneFrame, CURRENCY_KEYS, CATEGORY_BASIC)
hookOpenButton(openx3, 3, basicRuneFrame, CURRENCY_KEYS, CATEGORY_BASIC)
if goldRuneFrame and goldOpenx1 and goldOpenx1:IsA("GuiButton") then
	hookOpenButton(goldOpenx1, 1, goldRuneFrame, CURRENCY_GOLD, CATEGORY_GOLD)
end
if goldRuneFrame and goldOpenx3 and goldOpenx3:IsA("GuiButton") then
	hookOpenButton(goldOpenx3, 3, goldRuneFrame, CURRENCY_GOLD, CATEGORY_GOLD)
end

-- Inventory sync: unlock rune colors
local function normalizeNameToken(s: string?): string
	if type(s) ~= "string" then
		return ""
	end
	return string.lower((string.gsub(s, "[^%w]", "")))
end

local function findDescendantByAliases(root: Instance?, aliases: { string }): Instance?
	if not root then
		return nil
	end
	local aliasMap = {}
	for _, alias in ipairs(aliases) do
		local key = normalizeNameToken(alias)
		if key ~= "" then
			aliasMap[key] = true
		end
	end
	for _, inst in ipairs(root:GetDescendants()) do
		local key = normalizeNameToken(inst.Name)
		if aliasMap[key] then
			return inst
		end
	end
	return nil
end

local function getRuneSlotAliases(runeDef: any): { string }
	local out = {}
	local id = tostring(runeDef and runeDef.Id or "")
	local displayName = tostring(runeDef and runeDef.DisplayName or "")
	if id ~= "" then table.insert(out, id) end
	if displayName ~= "" then table.insert(out, displayName) end
	-- aliases comunes para layouts de UI previos
	if id == "LegendaryRune" then
		table.insert(out, "Legendary")
		table.insert(out, "Legend")
	end
	if id == "UncommonRune" then
		table.insert(out, "Uncommon")
	end
	if id == "CommonRune" then
		table.insert(out, "Common")
	end
	if id == "EpicRune" then
		table.insert(out, "Epic")
	end
	return out
end

local runeSlots: { [string]: Instance? } = {}
for _, runeDef in ipairs(RunesConfig.Runes or {}) do
	local runeId = runeDef.Id
	if type(runeId) == "string" and runeId ~= "" then
		local aliases = getRuneSlotAliases(runeDef)
		local category = runeDef.Category
		local searchRoot: Instance? = nil
		if category == CATEGORY_BASIC then
			searchRoot = openArea
		elseif category == CATEGORY_GOLD then
			searchRoot = goldOpenArea
		end
		runeSlots[runeId] = findDescendantByAliases(searchRoot, aliases)
		if searchRoot and not runeSlots[runeId] then
			warn(("[RuneGuiController] Slot de UI no encontrado para rune '%s' (aliases: %s)"):format(
				runeId,
				table.concat(aliases, ", ")
			))
		end
	end
end

-- Cache local (para no recalcular si no cambia)
local lastCountsJson = ""

local function decodeCountsJson(json: string): { [string]: number }
	if type(json) ~= "string" or json == "" then
		return {}
	end
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(json)
	end)
	if not ok or type(decoded) ~= "table" then
		return {}
	end
	local out: { [string]: number } = {}
	for k, v in pairs(decoded) do
		if type(k) == "string" then
			local n = tonumber(v)
			if type(n) == "number" and n == n then
				out[k] = math.floor(n)
			end
		end
	end
	return out
end

local function formatMultiplierWithComma(mult: number): string
	local safe = (type(mult) == "number" and mult == mult and mult > 0) and mult or 1
	local txt = string.format("%.3f", safe)
	txt = string.gsub(txt, "0+$", "")
	txt = string.gsub(txt, "%.$", "")
	txt = string.gsub(txt, "%.", ",")
	return txt
end

local function getRuneDefById(runeId: string)
	for _, runeDef in ipairs(RunesConfig.Runes or {}) do
		if runeDef.Id == runeId then
			return runeDef
		end
	end
	return nil
end

local function getSingleAffectLabel(runeDef: any): string
	local affects = runeDef and runeDef.Affects
	if type(affects) ~= "table" then
		return "Melon"
	end
	if affects[RunesConfig.IncomeKeys.Melons] == true then
		return "Melon"
	end
	if affects[RunesConfig.IncomeKeys.Tapping] == true then
		return "Tapping"
	end
	return "Melon"
end

local function applyIndexInventory(counts: { [string]: number }?)
	if not (indexScrolling and indexScrolling:IsA("ScrollingFrame")) then
		return
	end
	counts = counts or {}
	for _, runeDef in ipairs(RunesConfig.Runes or {}) do
		local runeId = runeDef.Id
		if type(runeId) == "string" and runeId ~= "" then
			local runeFrame = indexScrolling:FindFirstChild(runeId)
			if not runeFrame then
				runeFrame = findDescendantByAliases(indexScrolling, getRuneSlotAliases(runeDef))
			end
			if not runeFrame then
				warn(("[RuneIndex] Frame no encontrado para runeId: %s"):format(runeId))
			else
				local count = counts[runeId] or 0
				if type(count) ~= "number" then
					count = tonumber(count) or 0
				end
				count = math.max(0, math.floor(count))
				local unlocked = count > 0

				local icon = runeFrame:FindFirstChild("Icon")
				if icon and icon:IsA("ImageLabel") then
					icon.ImageColor3 = unlocked and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
				end

				local boostLabel = runeFrame:FindFirstChild("BoostLabel")
				if boostLabel and boostLabel:IsA("TextLabel") then
					boostLabel.Visible = unlocked
					if unlocked then
						local xBoost = tonumber(runeDef.XBoost) or 1
						local totalBoost = xBoost ^ count
						local affectLabel = getSingleAffectLabel(runeDef)
						boostLabel.Text = ("x%s %s"):format(formatMultiplierWithComma(totalBoost), affectLabel)
					end
				end
			end
		end
	end
end

local function setUnlocked(slot: Instance?, unlocked: boolean)
	if not slot then return end
	-- En tu UI: cada frame tiene un hijo directo `ImageLabel`
	local img = slot:FindFirstChild("ImageLabel")
	if not img then return end
	img.ImageColor3 = unlocked and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
end

local function applyInventory(counts: { [string]: number }?)
	counts = counts or {}
	for runeId, slot in pairs(runeSlots) do
		local c = counts[runeId] or 0
		local unlocked = type(c) == "number" and c > 0
		setUnlocked(slot, unlocked)
	end
	applyIndexInventory(counts)
end

local function refreshFromRunesInventoryJson()
	local events = player:FindFirstChild("Events")
	local inv = events and events:FindFirstChild("RunesInventoryJson")
	if not (inv and inv:IsA("StringValue")) then
		return
	end
	local json = inv.Value
	if json == lastCountsJson then
		return
	end
	lastCountsJson = json
	applyInventory(decodeCountsJson(json))
end

task.spawn(function()
	local getInv = ReplicatedStorage:FindFirstChild("RuneGetInventory")
	if getInv and getInv:IsA("RemoteFunction") then
		local ok, res = pcall(function()
			return getInv:InvokeServer()
		end)
		if ok and type(res) == "table" and res.ok == true then
			applyInventory(res.counts)
		end
	end
end)

-- Fuente de verdad persistente (DataStore): `Events.RunesInventoryJson`
task.defer(function()
	refreshFromRunesInventoryJson()
	local events = player:FindFirstChild("Events")
	local inv = events and events:FindFirstChild("RunesInventoryJson")
	if inv and inv:IsA("StringValue") then
		inv.Changed:Connect(refreshFromRunesInventoryJson)
	end
end)

local invChanged = ReplicatedStorage:FindFirstChild("RuneInventoryChanged")
if invChanged and invChanged:IsA("RemoteEvent") then
	invChanged.OnClientEvent:Connect(function(payload)
		if type(payload) ~= "table" then return end
		if type(payload.counts) == "table" then
			applyInventory(payload.counts)
		end
	end)
end

