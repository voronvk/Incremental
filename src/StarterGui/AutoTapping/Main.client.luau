--[[
	UI parecida a AutoHarvest. Atributos: PlayerClientAttributes (AUTO_TAP, AUTO_TAP_GOLD).
	Taps al melón: sonido, XP, servidor. Sin CornFinder ni movimiento.
	Basic: pase o Daily día 6, ~1 tap por segundo. Gold: mismo pase, ~10 taps por segundo.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local Attr = require(ReplicatedStorage.Shared:WaitForChild("PlayerClientAttributes"))
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
local GamePassConfig = require(ReplicatedStorage.Shared:WaitForChild("GamePassConfig"))

local AUTOTAP_GAMEPASS_ID = GamePassConfig.AUTOTAP_GAMEPASS_ID
local UNLOCK_WARN_TEXT = "Unlock it on FreeRewards or with Gamepass!"

local COLOR_IMAGE_ON = Color3.fromRGB(255, 255, 255)
local COLOR_IMAGE_OFF = Color3.fromRGB(127, 127, 127)
local COLOR_LABEL_ON = Color3.fromRGB(38, 255, 0)
local COLOR_LABEL_OFF = Color3.fromRGB(255, 69, 69)

local SCALE_IDLE = 1
local SCALE_HOVER = 1.04
local SCALE_PRESS = 0.96
local TWEEN_DURATION = 0.1
local WARN_COOLDOWN = 3
local WARN_SLIDE_OFFSET = 80
local WARN_ANIM_DURATION = 0.3

if player:GetAttribute(Attr.AUTO_TAP) == nil then
	player:SetAttribute(Attr.AUTO_TAP, false)
end
if player:GetAttribute(Attr.AUTO_TAP_GOLD) == nil then
	player:SetAttribute(Attr.AUTO_TAP_GOLD, false)
end

local events = player:WaitForChild("Events")
local autoTapBasicUnlocked = events:WaitForChild("AutoTapBasicUnlocked")

local container = script.Parent

local function findFirstDescendantByName(root, name)
	if not root then
		return nil
	end
	if root.Name == name then
		return root
	end
	return root:FindFirstChild(name, true)
end

local basicContainer = findFirstDescendantByName(container, "Basic")
local goldContainer = findFirstDescendantByName(container, "Gold")
local warnLabel = findFirstDescendantByName(container, "WarnLabel")
	or findFirstDescendantByName(container, "WarnLAbel")
local warnStroke = warnLabel and warnLabel:FindFirstChildOfClass("UIStroke")

if not basicContainer then
	local ancestor = container
	while ancestor and not basicContainer do
		basicContainer = findFirstDescendantByName(ancestor, "Basic")
		goldContainer = goldContainer or findFirstDescendantByName(ancestor, "Gold")
		if not warnLabel then
			warnLabel = findFirstDescendantByName(ancestor, "WarnLabel")
				or findFirstDescendantByName(ancestor, "WarnLAbel")
		end
		ancestor = ancestor.Parent
	end
	warnStroke = warnLabel and warnLabel:FindFirstChildOfClass("UIStroke")
end

if not basicContainer then
	warn("[AutoTapping] No se encontro Basic.")
	return
end

local function resolveMainFrame(containerFrame, debugName)
	if not containerFrame then
		return nil
	end
	if containerFrame:IsA("Frame") then
		return containerFrame
	end
	local nested = containerFrame:FindFirstChild("Frame")
	if nested and nested:IsA("Frame") then
		return nested
	end
	warn(("[AutoTapping] Sin Frame en %s."):format(debugName))
	return nil
end

local basicFrame = resolveMainFrame(basicContainer, "Basic")
local goldFrame = resolveMainFrame(goldContainer, "Gold")
if not basicFrame then
	return
end

local function resolveButtonAndLabel(frame, debugName)
	if not frame then
		return nil, nil
	end
	local button = frame:FindFirstChild("ImageButton") or frame:FindFirstChild("Imagebutton")
	local label = frame:FindFirstChild("EncendidoLabel")
	if not button or not button:IsA("GuiButton") then
		return nil, nil
	end
	if not label or not label:IsA("TextLabel") then
		return nil, nil
	end
	return button, label
end

local basicButton, basicLabel = resolveButtonAndLabel(basicFrame, "Basic")
if not basicButton then
	return
end

local goldButton, goldLabel = resolveButtonAndLabel(goldFrame, "Gold")
local goldUnlock = goldContainer and (goldContainer:FindFirstChild("Unlock", true) or (goldFrame and goldFrame:FindFirstChild("Unlock", true)))

local function getOrCreateUIScale(guiObject)
	local uiScale = guiObject:FindFirstChildOfClass("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Scale = SCALE_IDLE
		uiScale.Parent = guiObject
	end
	return uiScale
end

local frameStates = {}
local warnOriginalPosition = warnLabel and warnLabel.Position or UDim2.new(0.5, 0, 0.5, 0)
local lastWarnTime = 0

if warnLabel then
	warnLabel.Visible = false
	if warnStroke then
		warnStroke.Enabled = false
	end
end

local function setupFrameState(frame)
	if not frame then
		return nil
	end
	local state = {
		scale = getOrCreateUIScale(frame),
		isHovering = false,
	}
	frameStates[frame] = state
	return state
end

local basicState = setupFrameState(basicFrame)
local goldState = setupFrameState(goldFrame)

local function tweenScale(state, targetScale)
	if not state then
		return
	end
	TweenService:Create(
		state.scale,
		TweenInfo.new(TWEEN_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Scale = targetScale }
	):Play()
end

local hasAutoTapPass = false

local function refreshPassState()
	hasAutoTapPass = GamePassCheck.playerOwnsGamePass(player, AUTOTAP_GAMEPASS_ID)
	if goldUnlock and goldUnlock:IsA("GuiObject") then
		goldUnlock.Visible = not hasAutoTapPass
	end
end

local function hasBasicAccess()
	return hasAutoTapPass or autoTapBasicUnlocked.Value >= 1
end

local function updateButtonColor()
	local canBasic = hasBasicAccess()
	local canGold = hasAutoTapPass
	local isOn = player:GetAttribute(Attr.AUTO_TAP) == true
	local isGold = player:GetAttribute(Attr.AUTO_TAP_GOLD) == true

	if basicButton then
		basicButton.ImageColor3 = (canBasic and isOn) and COLOR_IMAGE_ON or COLOR_IMAGE_OFF
	end
	if basicLabel then
		basicLabel.TextColor3 = (canBasic and isOn) and COLOR_LABEL_ON or COLOR_LABEL_OFF
		basicLabel.Text = (isOn and not isGold) and "On" or "Off"
	end

	if goldButton then
		goldButton.ImageColor3 = (canGold and isOn) and COLOR_IMAGE_ON or COLOR_IMAGE_OFF
	end
	if goldLabel then
		goldLabel.TextColor3 = (canGold and isOn) and COLOR_LABEL_ON or COLOR_LABEL_OFF
		goldLabel.Text = (isOn and isGold) and "On" or "Off"
	end
end

local function tryRefreshGoldUnlockHide(timeoutSeconds)
	local start = tick()
	while tick() - start < timeoutSeconds do
		refreshPassState()
		updateButtonColor()
		if hasAutoTapPass then
			if goldUnlock and goldUnlock:IsA("GuiObject") then
				goldUnlock.Visible = false
			end
			return
		end
		task.wait(1)
	end
	refreshPassState()
	updateButtonColor()
	if goldUnlock and goldUnlock:IsA("GuiObject") then
		goldUnlock.Visible = not hasAutoTapPass
	end
end

local function playUnlockWarn()
	local now = tick()
	if now - lastWarnTime < WARN_COOLDOWN then
		return
	end
	lastWarnTime = now

	if warnLabel then
		warnLabel.Text = UNLOCK_WARN_TEXT
	end

	local sounds = ReplicatedStorage:FindFirstChild("Sounds")
	if sounds then
		local errorSound = sounds:FindFirstChild("Error")
		if errorSound and errorSound:IsA("Sound") then
			errorSound:Play()
		end
	end

	if warnLabel then
		local startPos = UDim2.new(
			warnOriginalPosition.X.Scale,
			warnOriginalPosition.X.Offset - WARN_SLIDE_OFFSET,
			warnOriginalPosition.Y.Scale,
			warnOriginalPosition.Y.Offset
		)
		warnLabel.Position = startPos
		if warnStroke then
			warnStroke.Enabled = false
		end
		warnLabel.Visible = true
		if warnStroke then
			warnStroke.Enabled = true
		end

		TweenService:Create(warnLabel, TweenInfo.new(WARN_ANIM_DURATION, Enum.EasingStyle.Quad), {
			Position = warnOriginalPosition,
		}):Play()

		task.delay(WARN_COOLDOWN, function()
			if warnLabel and warnLabel.Parent then
				TweenService:Create(warnLabel, TweenInfo.new(WARN_ANIM_DURATION * 0.8, Enum.EasingStyle.Quad), {
					Position = startPos,
				}):Play()
				task.delay(WARN_ANIM_DURATION * 0.8 + 0.05, function()
					if warnLabel and warnLabel.Parent then
						warnLabel.Visible = false
						if warnStroke then
							warnStroke.Enabled = false
						end
					end
				end)
			end
		end)
	end
end

local pendingBasicPrompt = false
local pendingGoldPrompt = false

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr, gamePassId, purchased)
	if plr ~= player then
		return
	end
	if gamePassId ~= AUTOTAP_GAMEPASS_ID then
		return
	end
	if pendingBasicPrompt then
		pendingBasicPrompt = false
		if not purchased then
			playUnlockWarn()
		end
	elseif pendingGoldPrompt then
		pendingGoldPrompt = false
		if not purchased then
			playUnlockWarn()
		end
	end
	refreshPassState()
	updateButtonColor()
end)

local function bindFrameButton(button, state, onClick)
	if not button or not state then
		return
	end
	button.MouseEnter:Connect(function()
		state.isHovering = true
		tweenScale(state, SCALE_HOVER)
	end)
	button.MouseLeave:Connect(function()
		state.isHovering = false
		tweenScale(state, SCALE_IDLE)
	end)
	button.MouseButton1Down:Connect(function()
		tweenScale(state, SCALE_PRESS)
	end)
	button.MouseButton1Up:Connect(function()
		tweenScale(state, state.isHovering and SCALE_HOVER or SCALE_IDLE)
	end)
	button.MouseButton1Click:Connect(onClick)
end

local function setAutoTapMode(isOn, isGold)
	player:SetAttribute(Attr.AUTO_TAP, isOn)
	player:SetAttribute(Attr.AUTO_TAP_GOLD, isGold)
end

bindFrameButton(basicButton, basicState, function()
	if not hasBasicAccess() then
		pendingBasicPrompt = true
		MarketplaceService:PromptGamePassPurchase(player, AUTOTAP_GAMEPASS_ID)
		return
	end
	if player:GetAttribute(Attr.AUTO_TAP) == true then
		setAutoTapMode(false, false)
	else
		setAutoTapMode(true, false)
	end
end)

bindFrameButton(goldButton, goldState, function()
	if not hasAutoTapPass then
		pendingGoldPrompt = true
		MarketplaceService:PromptGamePassPurchase(player, AUTOTAP_GAMEPASS_ID)
		task.spawn(function()
			tryRefreshGoldUnlockHide(15)
		end)
		return
	end
	if player:GetAttribute(Attr.AUTO_TAP) == true then
		setAutoTapMode(false, false)
	else
		setAutoTapMode(true, true)
	end
end)

if goldUnlock and goldUnlock:IsA("GuiObject") then
	goldUnlock:GetPropertyChangedSignal("Visible"):Connect(function()
		if hasAutoTapPass and goldUnlock.Visible then
			goldUnlock.Visible = false
		end
	end)
end

refreshPassState()
updateButtonColor()

player:GetAttributeChangedSignal(Attr.AUTO_TAP):Connect(updateButtonColor)
player:GetAttributeChangedSignal(Attr.AUTO_TAP_GOLD):Connect(updateButtonColor)
player:GetAttributeChangedSignal("GamePassSyncStamp"):Connect(function()
	refreshPassState()
	updateButtonColor()
end)

autoTapBasicUnlocked:GetPropertyChangedSignal("Value"):Connect(function()
	updateButtonColor()
end)

if goldContainer then
	task.spawn(function()
		while goldContainer.Parent do
			task.wait(5)
			refreshPassState()
			updateButtonColor()
		end
	end)
end
