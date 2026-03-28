local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local robuxGui = script.Parent

local ButtonScaleEffect = require(ReplicatedStorage.Shared:WaitForChild("ButtonScaleEffect"))

-- Rotating products (Developer Products)
local MELONSHOP_PRODUCT_ID = 3564513610
local SPEEDSHOP_PRODUCT_ID = 3564513530
local LUCKSHOP_PRODUCT_ID = 3553201276

-- StarterFrame: bundle grande (mismo producto que siempre)
local EXCLUSIVE_OFFER_PRODUCT_ID = 3564690970
-- AdvancedFrame: Rebirth x2 durante 120 min — crea este Developer Product en Creator y ajusta el ID si difiere
local ADVANCED_OFFER_PRODUCT_ID = 3564690971
local OFFER_APPEAR_SOUND_ID = "rbxassetid://99608180022223"
-- StarterFrame: tiempos originales (40–200s primera vez, 150–300s si cierra sin comprar)
local OFFER_FIRST_DELAY_MIN = 40
local OFFER_FIRST_DELAY_MAX = 200
local OFFER_RESHOW_DELAY_MIN = 150
local OFFER_RESHOW_DELAY_MAX = 300
-- AdvancedFrame: recurrente cada 360s; pon true para testear cada 15s
local TEST_ADVANCED_OFFER_TIMING = false
local ADVANCED_OFFER_RECUR_INTERVAL_SEC = TEST_ADVANCED_OFFER_TIMING and 15 or 360
local ExclusiveOffer = {
	close = nil,
}
local AdvancedOffer = {
	close = nil,
}

-- Compartido entre StarterFrame y AdvancedFrame (mismo Background / duck de música)
local offerBackdropOpenCount = 0
local offerBackdropDuckedEntries = {}
local offerSuppressedGuiSnapshot = {} -- [ScreenGui] = Enabled antes del offer

local function suppressOtherPlayerGuisForOffer()
	local pg = player:FindFirstChildOfClass("PlayerGui")
	if not pg then
		return
	end
	for _, child in ipairs(pg:GetChildren()) do
		if child:IsA("ScreenGui") and child ~= robuxGui then
			if offerSuppressedGuiSnapshot[child] == nil then
				offerSuppressedGuiSnapshot[child] = child.Enabled
			end
			child.Enabled = false
		end
	end
end

local function restoreOtherPlayerGuisFromOffer()
	for gui, wasEnabled in pairs(offerSuppressedGuiSnapshot) do
		if gui.Parent then
			gui.Enabled = wasEnabled
		end
	end
	table.clear(offerSuppressedGuiSnapshot)
end

local function collectSoundsToDuckOffer()
	local list = {}
	local function addFrom(parent)
		if not parent then
			return
		end
		for _, d in ipairs(parent:GetDescendants()) do
			if d:IsA("Sound") and d.Playing and d.Volume > 0 then
				table.insert(list, d)
			end
		end
	end
	addFrom(SoundService)
	local pg = player:FindFirstChildOfClass("PlayerGui")
	addFrom(pg)
	return list
end

local function duckMusicOfferShared()
	offerBackdropDuckedEntries = {}
	for _, snd in ipairs(collectSoundsToDuckOffer()) do
		table.insert(offerBackdropDuckedEntries, { sound = snd, vol = snd.Volume })
		TweenService:Create(snd, TweenInfo.new(0.45, Enum.EasingStyle.Quad), { Volume = math.max(0.02, snd.Volume * 0.12) }):Play()
	end
end

local function restoreMusicOfferShared()
	for _, entry in ipairs(offerBackdropDuckedEntries) do
		local snd = entry.sound
		if snd and snd.Parent then
			TweenService:Create(snd, TweenInfo.new(0.45, Enum.EasingStyle.Quad), { Volume = entry.vol }):Play()
		end
	end
	offerBackdropDuckedEntries = {}
end

local ROTATE_SECONDS = 30
local BAR_TWEENINFO = TweenInfo.new(ROTATE_SECONDS, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local function findGuiObjectCaseInsensitive(root, targetName)
	local t = string.lower(targetName)
	for _, d in ipairs(root:GetDescendants()) do
		if string.lower(d.Name) == t and d:IsA("GuiObject") then
			return d
		end
	end
	return nil
end

local function getButton(name)
	local obj = robuxGui:FindFirstChild(name, true)
	if obj and obj:IsA("GuiObject") then
		return obj
	end
	return findGuiObjectCaseInsensitive(robuxGui, name)
end

local function ensureUIScale(gui)
	local scale = gui:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Scale = 1
		scale.Parent = gui
	end
	return scale
end

local function tweenScale(gui, target, duration)
	local scale = ensureUIScale(gui)
	local t = TweenService:Create(scale, TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = target })
	t:Play()
	return t
end

local function showOnly(target, all)
	for _, btn in ipairs(all) do
		if btn == target then
			btn.Visible = true
			ensureUIScale(btn).Scale = 0.9
			tweenScale(btn, 1, 0.22)
		else
			if btn.Visible then
				local tween = tweenScale(btn, 0.9, 0.18)
				tween.Completed:Connect(function()
					btn.Visible = false
				end)
			else
				btn.Visible = false
			end
		end
	end
end

local melonShop = getButton("MelonShop")
local speedShop = getButton("SpeedShop")
local luckShop = getButton("LuckShop")

local rotatingButtons = {}
if luckShop then table.insert(rotatingButtons, luckShop) end
if speedShop then table.insert(rotatingButtons, speedShop) end
if melonShop then table.insert(rotatingButtons, melonShop) end

local function hookPurchase(btn, productId)
	local img = btn:FindFirstChild("ImageLabel")
	ButtonScaleEffect.applyScaleEffect(btn, img or btn)
	if productId <= 0 then
		return
	end
	local function prompt()
		MarketplaceService:PromptProductPurchase(player, productId)
	end
	-- Extra: some UI uses ImageButton/TextButton; ensure we always connect.
	if btn:IsA("GuiButton") then
		btn.Activated:Connect(prompt)
	else
		-- Fallback for older button patterns
		btn.MouseButton1Click:Connect(prompt)
	end
end

if melonShop then hookPurchase(melonShop, MELONSHOP_PRODUCT_ID) end
if speedShop then hookPurchase(speedShop, SPEEDSHOP_PRODUCT_ID) end
if luckShop then hookPurchase(luckShop, LUCKSHOP_PRODUCT_ID) end

local function getBuyLabelTemplate()
	-- Prefer: child directo de RobuxGui (como dijiste). Pero damos margen a que tarde en replicar.
	local direct = robuxGui:FindFirstChild("BuyLabel")
	if direct and direct:IsA("GuiObject") then
		return direct
	end
	for _ = 1, 30 do
		local b = robuxGui:FindFirstChild("BuyLabel")
		if b and b:IsA("GuiObject") then
			return b
		end
		task.wait(0.1)
	end
	-- Fallback por si está anidado por error
	local any = robuxGui:FindFirstChild("BuyLabel", true)
	if any and any:IsA("GuiObject") then
		return any
	end
	return nil
end

local function playPurchaseSound()
	-- Prefer: ReplicatedStorage.Sounds.Reward (como dijiste)
	local rsSounds = ReplicatedStorage:FindFirstChild("Sounds")
	local reward = rsSounds and rsSounds:FindFirstChild("Reward")

	-- Fallback: if you ever move it into PlayerGui/RobuxGui later
	if not (reward and reward:IsA("Sound")) then
		local pg = player:FindFirstChildOfClass("PlayerGui")
		local sounds = (pg and pg:FindFirstChild("Sounds", true)) or robuxGui:FindFirstChild("Sounds", true)
		reward = sounds and sounds:FindFirstChild("Reward", true)
	end

	if reward and reward:IsA("Sound") then
		local s = reward:Clone()
		-- Play locally from SoundService so it always works
		s.Parent = SoundService
		s.Ended:Connect(function()
			s:Destroy()
		end)
		s:Play()
	end
end

local function formatTime(seconds)
	seconds = tonumber(seconds) or 0
	if seconds <= 0 then
		return "a moment"
	end
	local minutes = math.floor(seconds / 60 + 0.5)
	if minutes < 60 then
		return tostring(minutes) .. " minutes"
	end
	local hours = math.floor(minutes / 60)
	local rem = minutes % 60
	if rem == 0 then
		return tostring(hours) .. " hours"
	end
	return tostring(hours) .. "h " .. tostring(rem) .. "m"
end

local function productInfo(productId)
	if productId == MELONSHOP_PRODUCT_ID then
		return "MelonShop", 30 * 60
	end
	if productId == SPEEDSHOP_PRODUCT_ID then
		return "SpeedShop", 30 * 60
	end
	if productId == LUCKSHOP_PRODUCT_ID and LUCKSHOP_PRODUCT_ID > 0 then
		return "LuckShop", 15 * 60
	end
	return "Product", 0
end

local function showPurchaseToast(productId)
	local buyLabelTemplate = getBuyLabelTemplate()
	if not buyLabelTemplate then
		return
	end

	local name, duration = productInfo(productId)
	local toast = buyLabelTemplate:Clone()
	toast.Visible = true
	toast.Parent = robuxGui

	local textObj = nil
	if toast:IsA("TextLabel") then
		textObj = toast
	else
		local t = toast:FindFirstChildWhichIsA("TextLabel", true)
		if t then
			textObj = t
		end
	end

	if textObj then
		if productId == EXCLUSIVE_OFFER_PRODUCT_ID then
			textObj.Text = "You Bought the Exclusive Offer"
		elseif productId == ADVANCED_OFFER_PRODUCT_ID then
			textObj.Text = "You Bought the Advanced Offer (Rebirth x2, 120 min)"
		else
			textObj.Text = ("Purchase successful! You bought %s for %s!"):format(name, formatTime(duration))
		end
	end

	local scale = ensureUIScale(toast)
	scale.Scale = 0
	TweenService:Create(scale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

	playPurchaseSound()

	local toastToDestroy = toast
	local scaleToTween = scale
	task.delay(1.6, function()
		if not toastToDestroy then
			return
		end
		if not toastToDestroy.Parent then
			return
		end
		local out = TweenService:Create(scaleToTween, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0 })
		out.Completed:Connect(function()
			if toastToDestroy then
				toastToDestroy:Destroy()
			end
		end)
		out:Play()
	end)
end

MarketplaceService.PromptProductPurchaseFinished:Connect(function(plr, productId, purchased)
	local isLocal = false
	if type(plr) == "number" then
		isLocal = (plr == player.UserId)
	else
		isLocal = (plr == player)
	end

	if isLocal and purchased and type(productId) == "number" then
		if productId == EXCLUSIVE_OFFER_PRODUCT_ID then
			local fn = ExclusiveOffer.close
			if fn then
				fn()
			end
		elseif productId == ADVANCED_OFFER_PRODUCT_ID then
			local fn = AdvancedOffer.close
			if fn then
				fn()
			end
		end
	end

	if isLocal and purchased and type(productId) == "number" then
		showPurchaseToast(productId)
	end
end)

local function startRotationBar()
	-- Progress bar: RobuxGui > Bar (Frame) > Fill (Frame)
	local bar = robuxGui:FindFirstChild("Bar", true)
	local fill = bar and bar:FindFirstChild("Fill", true)

	if not fill then
		return
	end
	if not fill:IsA("GuiObject") then
		return
	end

	local function resetFill()
		fill.Size = UDim2.fromScale(0, fill.Size.Y.Scale)
	end

	resetFill()

	task.spawn(function()
		if #rotatingButtons > 0 then
			showOnly(rotatingButtons[1], rotatingButtons)
		end

		local idx = 1
		while robuxGui.Parent do
			resetFill()
			local tw = TweenService:Create(fill, BAR_TWEENINFO, { Size = UDim2.fromScale(1, fill.Size.Y.Scale) })
			tw:Play()
			task.wait(ROTATE_SECONDS)

			if #rotatingButtons > 0 then
				idx = idx + 1
				if idx > #rotatingButtons then
					idx = 1
				end
				showOnly(rotatingButtons[idx], rotatingButtons)
			end
		end
	end)
end

--- Misma lógica que StarterFrame: Background, YesButton, CloseButton, duck música, sonido aparición.
--- Si recurringIntervalSec es un número, la oferta se muestra cada X segundos (no usa delays aleatorios ni re-show al cerrar).
--- Si no es recurring: bucle con primera espera + re-shows (Starter). Recurring: intervalo fijo (Advanced).
local function setupOfferFrame(
	offerState,
	frameName: string,
	firstDelayMin: number,
	firstDelayMax: number,
	reshowDelayMin: number,
	reshowDelayMax: number,
	productId: number,
	recurringIntervalSec: number?
)
	task.spawn(function()
		local events = player:WaitForChild("Events")
		local purchasedFlag = events:WaitForChild("ExclusiveOfferPurchased", 120)
		if not purchasedFlag then
			return
		end
		local popupFrame = robuxGui:WaitForChild(frameName, 60)
		local background = robuxGui:WaitForChild("Background", 60)
		if not popupFrame or not background then
			return
		end
		if not background:IsA("GuiObject") then
			return
		end

		local yesButton = popupFrame:WaitForChild("YesButton", 30)
		local closeButton = popupFrame:WaitForChild("CloseButton", 30)
		if not yesButton or not closeButton then
			return
		end

		local scheduleToken = 0
		local recurringMode = type(recurringIntervalSec) == "number" and recurringIntervalSec > 0

		local function isPurchased()
			return purchasedFlag and purchasedFlag:IsA("NumberValue") and purchasedFlag.Value >= 1
		end

		local uiScale = popupFrame:FindFirstChildOfClass("UIScale")
		if not uiScale then
			uiScale = Instance.new("UIScale")
			uiScale.Scale = 1
			uiScale.Parent = popupFrame
		end

		popupFrame.Visible = false
		uiScale.Scale = 0
		background.BackgroundTransparency = 1

		local function playOfferAppearSound()
			local s = Instance.new("Sound")
			s.SoundId = OFFER_APPEAR_SOUND_ID
			s.Volume = 0.85
			s.Parent = SoundService
			s.Ended:Connect(function()
				s:Destroy()
			end)
			s:Play()
		end

		for _, desc in ipairs(popupFrame:GetDescendants()) do
			if desc:IsA("GuiButton") then
				local img = desc:FindFirstChild("ImageLabel")
				ButtonScaleEffect.applyScaleEffect(desc, img or desc)
			end
		end

		local showOffer
		local closeOffer

		closeOffer = function()
			if not popupFrame.Parent then
				return
			end
			scheduleToken = scheduleToken + 1
			offerBackdropOpenCount = math.max(0, offerBackdropOpenCount - 1)
			TweenService:Create(uiScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0 }):Play()
			if offerBackdropOpenCount <= 0 then
				offerBackdropOpenCount = 0
				TweenService:Create(background, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
				restoreMusicOfferShared()
				restoreOtherPlayerGuisFromOffer()
			end
			task.delay(0.25, function()
				if popupFrame.Parent then
					popupFrame.Visible = false
				end
			end)
		end

		showOffer = function()
			if isPurchased() then
				return
			end
			scheduleToken = scheduleToken + 1
			offerBackdropOpenCount += 1
			if offerBackdropOpenCount == 1 then
				duckMusicOfferShared()
				suppressOtherPlayerGuisForOffer()
				background.BackgroundTransparency = 1
				TweenService:Create(background, TweenInfo.new(0.4, Enum.EasingStyle.Quad), { BackgroundTransparency = 0.1 }):Play()
			end
			playOfferAppearSound()
			popupFrame.Visible = true
			uiScale.Scale = 0
			TweenService:Create(uiScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		end

		offerState.close = closeOffer

		local function promptPurchase()
			MarketplaceService:PromptProductPurchase(player, productId)
		end

		if yesButton:IsA("GuiButton") then
			yesButton.Activated:Connect(promptPurchase)
		else
			yesButton.MouseButton1Click:Connect(promptPurchase)
		end

		if closeButton:IsA("GuiButton") then
			closeButton.Activated:Connect(closeOffer)
		else
			closeButton.MouseButton1Click:Connect(closeOffer)
		end

		purchasedFlag.Changed:Connect(function()
			if isPurchased() then
				scheduleToken = scheduleToken + 1
				if popupFrame.Visible then
					closeOffer()
				end
			end
		end)

		if recurringMode then
			while robuxGui.Parent do
				task.wait(recurringIntervalSec :: number)
				if isPurchased() then
					continue
				end
				if popupFrame.Visible then
					continue
				end
				showOffer()
			end
		else
			-- Starter: primera vez delay largo; si cierran sin comprar, espera re-show y vuelve a salir en bucle
			local firstCycle = true
			while robuxGui.Parent do
				if isPurchased() then
					return
				end
				local dmin, dmax
				if firstCycle then
					dmin, dmax = firstDelayMin, firstDelayMax
				else
					dmin, dmax = reshowDelayMin, reshowDelayMax
				end
				task.wait(math.random(dmin, dmax))
				firstCycle = false
				if isPurchased() then
					return
				end
				showOffer()
				while popupFrame.Visible and robuxGui.Parent and not isPurchased() do
					task.wait(0.2)
				end
				if isPurchased() then
					return
				end
			end
		end
	end)
end

local function setupExclusiveOffer()
	setupOfferFrame(
		ExclusiveOffer,
		"StarterFrame",
		OFFER_FIRST_DELAY_MIN,
		OFFER_FIRST_DELAY_MAX,
		OFFER_RESHOW_DELAY_MIN,
		OFFER_RESHOW_DELAY_MAX,
		EXCLUSIVE_OFFER_PRODUCT_ID,
		nil
	)
	setupOfferFrame(
		AdvancedOffer,
		"AdvancedFrame",
		0,
		0,
		0,
		0,
		ADVANCED_OFFER_PRODUCT_ID,
		ADVANCED_OFFER_RECUR_INTERVAL_SEC
	)
end

startRotationBar()
setupExclusiveOffer()
