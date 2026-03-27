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

local DEBUG_ROBUXGUI = true
local function dbg(...)
	if DEBUG_ROBUXGUI then
		warn("[RobuxGui]", ...)
	end
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

dbg("Buttons found:", "LuckShop=", luckShop and luckShop:GetFullName() or "nil", "SpeedShop=", speedShop and speedShop:GetFullName() or "nil", "MelonShop=", melonShop and melonShop:GetFullName() or "nil")

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
		dbg("PromptProductPurchase", productId, "from", btn:GetFullName())
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
	dbg("BuyLabel not found under RobuxGui")
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
		dbg("Playing reward sound:", reward:GetFullName())
		local s = reward:Clone()
		-- Play locally from SoundService so it always works
		s.Parent = SoundService
		s.Ended:Connect(function()
			s:Destroy()
		end)
		s:Play()
	else
		dbg("Reward sound not found in ReplicatedStorage.Sounds.Reward (or fallbacks).")
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
	dbg("ShowPurchaseToast", productId, "template=", buyLabelTemplate:GetFullName())

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
		textObj.Text = ("Purchase successful! You bought %s for %s!"):format(name, formatTime(duration))
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
	local who = tostring(plr)
	local isLocal = false

	if type(plr) == "number" then
		who = "UserId:" .. tostring(plr)
		isLocal = (plr == player.UserId)
	else
		local okName, name = pcall(function()
			return plr.Name
		end)
		if okName then
			who = tostring(name)
		end
		isLocal = (plr == player)
	end

	dbg("PromptProductPurchaseFinished", "player=", who, "productId=", productId, "purchased=", purchased)
	if isLocal and purchased and type(productId) == "number" then
		showPurchaseToast(productId)
	end
end)

local function startRotationBar()
	-- Progress bar: RobuxGui > Bar (Frame) > Fill (Frame)
	local bar = robuxGui:FindFirstChild("Bar", true)
	local fill = bar and bar:FindFirstChild("Fill", true)

	if not fill then
		dbg("Bar not found")
		return
	end
	if not fill:IsA("GuiObject") then
		dbg("Fill exists but is not GuiObject:", fill.ClassName)
		return
	end

	local function resetFill()
		fill.Size = UDim2.fromScale(0, fill.Size.Y.Scale)
	end

	resetFill()

	task.spawn(function()
		if #rotatingButtons > 0 then
			showOnly(rotatingButtons[1], rotatingButtons)
		else
			dbg("No rotating buttons found")
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

startRotationBar()
