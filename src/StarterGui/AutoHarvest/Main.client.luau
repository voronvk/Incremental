local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))

local CornFinder
local ok, result = pcall(function()
	return require(ReplicatedStorage.Shared:WaitForChild("CornFinder"))
end)
CornFinder = (ok and type(result) == "table") and result or nil

local MOVE_THRESHOLD = 5
local STUCK_TIME = 0.4
local AUTO_BLOCK_ACTION = "AutoHarvestBlockMovement"
local GROUP_ID = 442873166
local GOLD_GAMEPASS_ID = 1740516591
local WALK_SPEED_MULTIPLIER_GOLD = 2
local events = player:WaitForChild("Events")
local speedBoostEndTime = events:WaitForChild("SpeedBoostEndTime")

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

if player:GetAttribute("Auto") == nil then
	player:SetAttribute("Auto", false)
end
if player:GetAttribute("AutoGold") == nil then
	player:SetAttribute("AutoGold", false)
end

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
local warnStroke = warnLabel and warnLabel:FindFirstChildOfClass("UIStroke")

if not basicContainer then
	-- Fallback: buscar en ancestros por si el script esta dentro de una subcarpeta/frame.
	local ancestor = container
	while ancestor and not basicContainer do
		basicContainer = findFirstDescendantByName(ancestor, "Basic")
		goldContainer = goldContainer or findFirstDescendantByName(ancestor, "Gold")
		warnLabel = warnLabel or findFirstDescendantByName(ancestor, "WarnLabel")
		ancestor = ancestor.Parent
	end
	warnStroke = warnLabel and warnLabel:FindFirstChildOfClass("UIStroke")
end

if not basicContainer then
	warn("[AutoMenu] No se encontro Basic en el arbol de AutoHarvest.")
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
	warn(("[AutoMenu] No se encontro contenedor Frame en %s."):format(debugName))
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
		warn(("[AutoMenu] No se encontro %s.ImageButton (GuiButton)."):format(debugName))
		return nil, nil
	end
	if not label or not label:IsA("TextLabel") then
		warn(("[AutoMenu] No se encontro %s.EncendidoLabel (TextLabel)."):format(debugName))
		return nil, nil
	end

	return button, label
end

local basicButton, basicLabel = resolveButtonAndLabel(basicFrame, "Basic.Frame")
if not basicButton then
	return
end

local goldButton, goldLabel = resolveButtonAndLabel(goldFrame, "Gold.Frame")
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

local hasGoldPass = false
local function refreshGoldPassState()
	hasGoldPass = GamePassCheck.playerOwnsGamePass(player, GOLD_GAMEPASS_ID)
	if goldUnlock and goldUnlock:IsA("GuiObject") then
		goldUnlock.Visible = not hasGoldPass
	end
end

local function updateButtonColor()
	local canUseBasic = GROUP_ID <= 0 or player:IsInGroup(GROUP_ID)
	local canUseGold = hasGoldPass
	local isAuto = player:GetAttribute("Auto") == true
	local isAutoGold = player:GetAttribute("AutoGold") == true

	if basicButton then
		basicButton.ImageColor3 = (canUseBasic and isAuto) and COLOR_IMAGE_ON or COLOR_IMAGE_OFF
	end
	if basicLabel then
		basicLabel.TextColor3 = (canUseBasic and isAuto) and COLOR_LABEL_ON or COLOR_LABEL_OFF
		basicLabel.Text = (isAuto and not isAutoGold) and "On" or "Off"
	end

	if goldButton then
		goldButton.ImageColor3 = (canUseGold and isAuto) and COLOR_IMAGE_ON or COLOR_IMAGE_OFF
	end
	if goldLabel then
		goldLabel.TextColor3 = (canUseGold and isAuto) and COLOR_LABEL_ON or COLOR_LABEL_OFF
		goldLabel.Text = (isAuto and isAutoGold) and "On" or "Off"
	end
end

local function tryRefreshGoldUnlockHide(timeoutSeconds: number)
	-- A veces el atributo del gamepass tarda en replicar; hacemos un "poll"
	-- corto para que el frame Unlock desaparezca lo antes posible.
	local start = tick()
	while tick() - start < timeoutSeconds do
		refreshGoldPassState()
		updateButtonColor()
		if hasGoldPass then
			if goldUnlock and goldUnlock:IsA("GuiObject") then
				goldUnlock.Visible = false
			end
			return
		end
		task.wait(1)
	end
	-- Última comprobación por si ya replicó al salir del timeout.
	refreshGoldPassState()
	updateButtonColor()
	if goldUnlock and goldUnlock:IsA("GuiObject") then
		goldUnlock.Visible = not hasGoldPass
	end
end

local function blockMovement()
	return Enum.ContextActionResult.Sink
end

local function updateMovementBlock()
	if player:GetAttribute("Auto") then
		ContextActionService:BindAction(
			AUTO_BLOCK_ACTION,
			blockMovement,
			false,
			Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
			Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right,
			Enum.KeyCode.Space
		)
	else
		ContextActionService:UnbindAction(AUTO_BLOCK_ACTION)
	end
end

refreshGoldPassState()
updateButtonColor()
updateMovementBlock()
player:GetAttributeChangedSignal("Auto"):Connect(function()
	updateButtonColor()
	updateMovementBlock()
end)

local activeConnection = nil
local savedWalkSpeed: number? = nil
local savedWalkSpeedHumanoid: Humanoid? = nil

local function stopAutoHarvest()
	if activeConnection then
		activeConnection:Disconnect()
		activeConnection = nil
	end

	-- Restore WalkSpeed after disabling auto (or switching away from Gold).
	if savedWalkSpeedHumanoid and savedWalkSpeed ~= nil then
		pcall(function()
			local speedBoostMultNow = (speedBoostEndTime.Value > os.time()) and 2 or 1
			savedWalkSpeedHumanoid.WalkSpeed = (savedWalkSpeed :: number) * speedBoostMultNow
		end)
	end
	savedWalkSpeed = nil
	savedWalkSpeedHumanoid = nil
end

local function refreshGoldWalkSpeed(humanoid: Humanoid?)
	if not humanoid then
		return
	end

	-- If we're not in Gold mode, restore and clear.
	if player:GetAttribute("AutoGold") ~= true then
		if savedWalkSpeedHumanoid == humanoid and savedWalkSpeed ~= nil then
			pcall(function()
				local speedBoostMultNow = (speedBoostEndTime.Value > os.time()) and 2 or 1
				humanoid.WalkSpeed = (savedWalkSpeed :: number) * speedBoostMultNow
			end)
		end
		savedWalkSpeed = nil
		savedWalkSpeedHumanoid = nil
		return
	end

	-- In Gold mode, capture base WalkSpeed once per humanoid and apply x2.
	if savedWalkSpeed == nil or savedWalkSpeedHumanoid ~= humanoid then
		savedWalkSpeedHumanoid = humanoid
		-- Guardamos la velocidad base SIN boost temporal de speed.
		-- Luego, en cada tick, volvemos a aplicar el multiplicador actual (1 o 2).
		local speedBoostMultAtCapture = (speedBoostEndTime.Value > os.time()) and 2 or 1
		savedWalkSpeed = (speedBoostMultAtCapture == 2) and (humanoid.WalkSpeed / 2) or humanoid.WalkSpeed
	end

	local speedBoostMultNow = (speedBoostEndTime.Value > os.time()) and 2 or 1
	humanoid.WalkSpeed = (savedWalkSpeed :: number) * speedBoostMultNow * WALK_SPEED_MULTIPLIER_GOLD
end

local function isTargetValid(target)
	if not target then
		return false
	end
	local okTarget, valid = pcall(function()
		return target.Parent and target:IsDescendantOf(workspace)
	end)
	return okTarget and valid
end

local function startAutoHarvest()
	stopAutoHarvest()

	local currentTarget = nil
	local stuckStartTime = nil

	activeConnection = RunService.Heartbeat:Connect(function()
		local okLoop, err = pcall(function()
			if not player:GetAttribute("Auto") then
				stopAutoHarvest()
				return
			end

			local character = player.Character
			if not character then
				return
			end

			local humanoid = character:FindFirstChild("Humanoid")
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if not humanoid or not rootPart or humanoid.Health <= 0 then
				return
			end

			-- Apply Gold speed bonus while autoharvesting.
			refreshGoldWalkSpeed(humanoid)

			if not CornFinder then
				return
			end

			if not isTargetValid(currentTarget) then
				currentTarget = CornFinder.findClosest(rootPart.Position)
				stuckStartTime = nil
			end

			if not currentTarget then
				return
			end

			local targetPos = CornFinder.getPosition(currentTarget)
			if not targetPos then
				currentTarget = nil
				return
			end

			local dist = (rootPart.Position - targetPos).Magnitude
			if dist <= MOVE_THRESHOLD then
				stuckStartTime = stuckStartTime or tick()
				if tick() - stuckStartTime >= STUCK_TIME then
					local stuckTarget = currentTarget
					local nextCorn = CornFinder.findClosest(rootPart.Position, stuckTarget)
					if nextCorn then
						currentTarget = nextCorn
						stuckStartTime = nil
					end
				end
			else
				stuckStartTime = nil
			end

			if currentTarget then
				local pos = CornFinder.getPosition(currentTarget)
				if pos and (rootPart.Position - pos).Magnitude > 1 then
					humanoid:MoveTo(pos)
				end
			end
		end)
		if not okLoop and err then
			warn("[AutoHarvest] Error:", tostring(err))
		end
	end)
end

player:GetAttributeChangedSignal("Auto"):Connect(function()
	if player:GetAttribute("Auto") then
		task.defer(startAutoHarvest)
	else
		stopAutoHarvest()
	end
end)

player:GetAttributeChangedSignal("AutoGold"):Connect(function()
	-- If Auto is currently running, adjust speed immediately when toggling Gold mode.
	if player:GetAttribute("Auto") == true then
		local character = player.Character
		local humanoid = character and character:FindFirstChild("Humanoid") :: Humanoid?
		refreshGoldWalkSpeed(humanoid)
		updateButtonColor()
	else
		-- Ensure we don't leave any modified speed behind.
		if savedWalkSpeedHumanoid and savedWalkSpeed ~= nil then
			pcall(function()
				local speedBoostMultNow = (speedBoostEndTime.Value > os.time()) and 2 or 1
				savedWalkSpeedHumanoid.WalkSpeed = (savedWalkSpeed :: number) * speedBoostMultNow
			end)
		end
		savedWalkSpeed = nil
		savedWalkSpeedHumanoid = nil
		updateButtonColor()
	end
end)

player.CharacterAdded:Connect(function()
	if player:GetAttribute("Auto") then
		task.defer(startAutoHarvest)
	end
end)

if player:GetAttribute("Auto") then
	task.defer(startAutoHarvest)
end

local function playWarn()
	local now = tick()
	if now - lastWarnTime < WARN_COOLDOWN then
		return
	end
	lastWarnTime = now

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

local function setAutoMode(isAuto: boolean, isGold: boolean)
	player:SetAttribute("Auto", isAuto)
	player:SetAttribute("AutoGold", isGold)
end

bindFrameButton(basicButton, basicState, function()
	if not (GROUP_ID > 0 and player:IsInGroup(GROUP_ID)) then
		playWarn()
		return
	end
	if player:GetAttribute("Auto") == true then
		setAutoMode(false, false)
	else
		setAutoMode(true, false)
	end
end)

bindFrameButton(goldButton, goldState, function()
	if not hasGoldPass then
		MarketplaceService:PromptGamePassPurchase(player, GOLD_GAMEPASS_ID)
		task.spawn(function()
			tryRefreshGoldUnlockHide(15)
		end)
		return
	end
	if player:GetAttribute("Auto") == true then
		setAutoMode(false, false)
	else
		setAutoMode(true, true)
	end
end)

if goldUnlock and goldUnlock:IsA("GuiObject") then
	goldUnlock:GetPropertyChangedSignal("Visible"):Connect(function()
		if hasGoldPass and goldUnlock.Visible then
			goldUnlock.Visible = false
		end
	end)
end

player:GetAttributeChangedSignal("Auto"):Connect(updateButtonColor)

player:GetAttributeChangedSignal("GamePassSyncStamp"):Connect(function()
	refreshGoldPassState()
	updateButtonColor()
end)

if goldContainer then
	task.spawn(function()
		while goldContainer.Parent do
			task.wait(5)
			refreshGoldPassState()
			updateButtonColor()
		end
	end)
end
