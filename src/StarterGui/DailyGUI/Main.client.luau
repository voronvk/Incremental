--[[
	DailyGUI: DailyFrame when claimable. Claim success: hide DailyFrame immediately; only ClaimLabel
	(child of this ScreenGui) pops in with UIScale, then hides.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer
local gui = script.Parent
if gui:IsA("ScreenGui") then
	gui.ResetOnSpawn = false
end

local Attr = require(ReplicatedStorage.Shared:WaitForChild("PlayerClientAttributes"))

local DAY_SECONDS = 86400
local DAILY_DOUBLE_PRODUCT_ID = 3571431653
local CLAIM_LABEL_HOLD_SEC = 4

local SCALE_IDLE = 1
local SCALE_HOVER = 1.06
local SCALE_PRESS = 0.94
local TWEEN_HOVER = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SHOW_TWEEN = TweenInfo.new(0.48, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLAIM_IN_TWEEN = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLAIM_OUT_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local UIBlur = require(ReplicatedStorage.Shared:WaitForChild("UIBlur"))

local freeClaimRequest = ReplicatedStorage:WaitForChild("DailyGuiFreeClaimRequest")
local freeClaimResult = ReplicatedStorage:WaitForChild("DailyGuiFreeClaimResult")
local clientNotify = ReplicatedStorage:WaitForChild("DailyGuiClientNotify")

local dailyBlurActive = false

-- UIBlur already toggles these; do not snapshot/disable here or restore order breaks.
local SKIP_ISOLATION_NAMES: { [string]: boolean } = {
	AutoHarvest = true,
	AutoTapping = true,
}

local savedOtherGuiEnabled: { [ScreenGui]: boolean } = {}
local playerGuiIsolationActive = false
local playerGuiIsolationConn: RBXScriptConnection? = nil

local function shouldSkipScreenGuiForIsolation(sgui: ScreenGui): boolean
	if sgui == gui then
		return true
	end
	return SKIP_ISOLATION_NAMES[sgui.Name] == true
end

local function onPlayerGuiChildAddedWhileDaily(child: Instance)
	if not playerGuiIsolationActive then
		return
	end
	if child:IsA("ScreenGui") and not shouldSkipScreenGuiForIsolation(child) then
		savedOtherGuiEnabled[child] = child.Enabled
		child.Enabled = false
	end
end

local function beginPlayerGuiIsolation()
	if playerGuiIsolationActive then
		return
	end
	local pg = player:FindFirstChild("PlayerGui")
	if not pg then
		return
	end
	playerGuiIsolationActive = true
	for _, child in pg:GetChildren() do
		if child:IsA("ScreenGui") and not shouldSkipScreenGuiForIsolation(child) then
			savedOtherGuiEnabled[child] = child.Enabled
			child.Enabled = false
		end
	end
	playerGuiIsolationConn = pg.ChildAdded:Connect(onPlayerGuiChildAddedWhileDaily)
end

local function endPlayerGuiIsolation()
	if not playerGuiIsolationActive then
		return
	end
	playerGuiIsolationActive = false
	if playerGuiIsolationConn then
		playerGuiIsolationConn:Disconnect()
		playerGuiIsolationConn = nil
	end
	for sgui, wasEnabled in savedOtherGuiEnabled do
		if sgui.Parent then
			sgui.Enabled = wasEnabled
		end
	end
	savedOtherGuiEnabled = {}
end

local function setDailyOverlay(active: boolean)
	if active == dailyBlurActive then
		return
	end
	dailyBlurActive = active
	if active then
		UIBlur.beginModal()
		beginPlayerGuiIsolation()
	else
		UIBlur.endModal()
		endPlayerGuiIsolation()
	end
end

-- Same visibility rules as TappingZoneAndGui after UIBlur restored wrong saved Enabled (e.g. modal opened during loading).
local function restoreHarvestGuisAfterDaily()
	if player:GetAttribute(Attr.CLIENT_LOADING_COMPLETE) ~= true then
		return
	end
	local pg = player:FindFirstChild("PlayerGui")
	if not pg then
		return
	end
	local ah = pg:FindFirstChild("AutoHarvest")
	local at = pg:FindFirstChild("AutoTapping")
	local inZone = player:GetAttribute(Attr.IN_TAPPING_ZONE) == true
	if ah and ah:IsA("ScreenGui") then
		ah.Enabled = not inZone
	end
	if at and at:IsA("ScreenGui") then
		at.Enabled = inZone
	end
end

local function waitForDataLoaded()
	if player:GetAttribute("PlayerDataLoaded") == true then
		return
	end
	player:GetAttributeChangedSignal("PlayerDataLoaded"):Wait()
	repeat
		task.wait()
	until player:GetAttribute("PlayerDataLoaded") == true
end

local function waitForLoadingGuiDone()
	if player:GetAttribute(Attr.CLIENT_LOADING_COMPLETE) == true then
		return
	end
	player:GetAttributeChangedSignal(Attr.CLIENT_LOADING_COMPLETE):Wait()
	repeat
		task.wait()
	until player:GetAttribute(Attr.CLIENT_LOADING_COMPLETE) == true
end

local function showChatSystemMessage(message)
	if type(message) ~= "string" or message == "" then
		return
	end
	local showed = false
	pcall(function()
		local channels = TextChatService:FindFirstChild("TextChannels")
		local general = channels and channels:FindFirstChild("RBXGeneral")
		if general and general:IsA("TextChannel") then
			general:DisplaySystemMessage(message)
			showed = true
		end
	end)
	if showed then
		return
	end
	pcall(function()
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = message,
			Color = Color3.fromRGB(255, 210, 90),
		})
	end)
end

local function isSfxMuted()
	local settings = player:FindFirstChild("Settings")
	local sfx = settings and settings:FindFirstChild("SfxMuted")
	return sfx ~= nil and sfx:IsA("ValueBase") and sfx.Value >= 1
end

local function playRewardSound()
	if isSfxMuted() then
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

local function formatCountdown(totalSeconds)
	totalSeconds = math.max(0, math.floor(totalSeconds))
	local h = math.floor(totalSeconds / 3600)
	local m = math.floor((totalSeconds % 3600) / 60)
	local s = totalSeconds % 60
	return string.format("%02dh %02dm %02ds", h, m, s)
end

local function canClaimFromLast(lastUnix, now)
	now = now or os.time()
	if type(lastUnix) ~= "number" or lastUnix <= 0 then
		return true
	end
	return (now - lastUnix) >= DAY_SECONDS
end

local function secondsUntilClaim(lastUnix, now)
	now = now or os.time()
	if type(lastUnix) ~= "number" or lastUnix <= 0 then
		return 0
	end
	local elapsed = now - lastUnix
	if elapsed >= DAY_SECONDS then
		return 0
	end
	return DAY_SECONDS - elapsed
end

local function getOrCreateUiScale(inst)
	local sc = inst:FindFirstChildOfClass("UIScale")
	if not sc then
		sc = Instance.new("UIScale")
		sc.Scale = 1
		sc.Parent = inst
	end
	return sc
end

local function wireButtonHover(button)
	if not button or not button:IsA("GuiButton") then
		return
	end
	local sc = getOrCreateUiScale(button)
	local activeTween
	local function toScale(target)
		if activeTween then
			activeTween:Cancel()
		end
		activeTween = TweenService:Create(sc, TWEEN_HOVER, { Scale = target })
		activeTween:Play()
	end
	button.MouseEnter:Connect(function()
		if not button.Active then
			return
		end
		toScale(SCALE_HOVER)
	end)
	button.MouseLeave:Connect(function()
		toScale(SCALE_IDLE)
	end)
	button.MouseButton1Down:Connect(function()
		if not button.Active then
			return
		end
		toScale(SCALE_PRESS)
	end)
	button.MouseButton1Up:Connect(function()
		if not button.Active then
			return
		end
		toScale(SCALE_HOVER)
	end)
end

waitForDataLoaded()
waitForLoadingGuiDone()

local events = player:WaitForChild("Events")
local lastClaimNv = events:WaitForChild("DailyGuiLastClaimUnix")

local dailyFrame = gui:WaitForChild("DailyFrame", 60)
if not dailyFrame then
	warn("[DailyGUI] Missing DailyFrame under ScreenGui")
	return
end

local timeLabel = dailyFrame:FindFirstChild("TimeLabel", true)
if not (timeLabel and (timeLabel:IsA("TextLabel") or timeLabel:IsA("TextButton"))) then
	warn("[DailyGUI] Missing TimeLabel inside DailyFrame")
	return
end

local claimLabel = gui:FindFirstChild("ClaimLabel", true)
if claimLabel and not (claimLabel:IsA("TextLabel") or claimLabel:IsA("TextButton")) then
	claimLabel = nil
end
if claimLabel then
	claimLabel.Visible = false
end

local rewardFrame = dailyFrame:FindFirstChild("RewardFrame")
local claimDaily = rewardFrame and rewardFrame:FindFirstChild("ClaimDaily")
local claimDouble = rewardFrame and rewardFrame:FindFirstChild("ClaimDoubleDaily")
if not (claimDaily and claimDaily:IsA("GuiButton") and claimDouble and claimDouble:IsA("GuiButton")) then
	warn("[DailyGUI] RewardFrame needs GuiButton children ClaimDaily and ClaimDoubleDaily")
	return
end

wireButtonHover(claimDaily)
wireButtonHover(claimDouble)

local frameScale = getOrCreateUiScale(dailyFrame)
dailyFrame.Visible = false
frameScale.Scale = 1

local wasClaimable = false
local showTweenPlaying = false
local awaitingLastClaimReplication = false
local lastClaimSnapshotBeforeRequest = 0
local claimFlashActive = false
local claimFlashToken = 0

local function playShow()
	if showTweenPlaying or dailyFrame.Visible then
		return
	end
	showTweenPlaying = true
	dailyFrame.Visible = true
	frameScale.Scale = 0
	local tw = TweenService:Create(frameScale, SHOW_TWEEN, { Scale = 1 })
	tw.Completed:Connect(function()
		showTweenPlaying = false
	end)
	tw:Play()
end

local function hideDailyFrameImmediate()
	dailyFrame.Visible = false
	frameScale.Scale = 1
	showTweenPlaying = false
end

local function playClaimLabelFlash(message: string, token: number)
	if not claimLabel or type(message) ~= "string" then
		return
	end
	local sc = getOrCreateUiScale(claimLabel)
	claimLabel.Text = message
	claimLabel.Visible = true
	sc.Scale = 0
	local twIn = TweenService:Create(sc, CLAIM_IN_TWEEN, { Scale = 1 })
	twIn:Play()
	twIn.Completed:Wait()
	if token ~= claimFlashToken then
		return
	end
	task.wait(CLAIM_LABEL_HOLD_SEC)
	if token ~= claimFlashToken then
		return
	end
	local twOut = TweenService:Create(sc, CLAIM_OUT_TWEEN, { Scale = 0 })
	twOut:Play()
	twOut.Completed:Wait()
	if token == claimFlashToken then
		claimLabel.Visible = false
		sc.Scale = 1
	end
end

local function runClaimSuccessFeedback(isDouble: boolean)
	awaitingLastClaimReplication = true
	lastClaimSnapshotBeforeRequest = lastClaimNv.Value
	setDailyOverlay(false)
	restoreHarvestGuisAfterDaily()
	hideDailyFrameImmediate()
	playRewardSound()

	claimFlashToken += 1
	local myToken = claimFlashToken
	claimFlashActive = true

	local msg = isDouble and "You claimed Double Speed! Come back tomorrow for more!"
		or "You claimed Speed x2 for 5 minutes! Come back tomorrow for more!"

	task.spawn(function()
		playClaimLabelFlash(msg, myToken)
		if myToken ~= claimFlashToken then
			return
		end
		claimFlashActive = false
	end)
end

local claimingFree = false
claimDaily.MouseButton1Click:Connect(function()
	if claimingFree or not canClaimFromLast(lastClaimNv.Value) then
		return
	end
	lastClaimSnapshotBeforeRequest = lastClaimNv.Value
	claimingFree = true
	freeClaimRequest:FireServer()
end)

freeClaimResult.OnClientEvent:Connect(function(ok)
	claimingFree = false
	if ok then
		runClaimSuccessFeedback(false)
	else
		awaitingLastClaimReplication = false
		showChatSystemMessage("[Daily] Could not claim (already claimed today?).")
	end
end)

claimDouble.MouseButton1Click:Connect(function()
	if not canClaimFromLast(lastClaimNv.Value) then
		return
	end
	MarketplaceService:PromptProductPurchase(player, DAILY_DOUBLE_PRODUCT_ID)
end)

clientNotify.OnClientEvent:Connect(function(msg)
	showChatSystemMessage(msg)
	if type(msg) == "string" and string.find(msg, "Double reward claimed", 1, true) then
		runClaimSuccessFeedback(true)
	end
end)

local function refreshUi()
	local replicatedClaimable = canClaimFromLast(lastClaimNv.Value)
	if awaitingLastClaimReplication then
		if lastClaimNv.Value ~= lastClaimSnapshotBeforeRequest then
			awaitingLastClaimReplication = false
		elseif not replicatedClaimable then
			awaitingLastClaimReplication = false
		end
	end
	local claimable = replicatedClaimable and not awaitingLastClaimReplication
	if claimable then
		if not claimFlashActive then
			setDailyOverlay(true)
			timeLabel.Text = "00h 00m 00s"
			if not wasClaimable then
				playShow()
			else
				dailyFrame.Visible = true
			end
			claimDaily.Active = true
			claimDouble.Active = true
		end
	else
		setDailyOverlay(false)
		restoreHarvestGuisAfterDaily()
		local left = secondsUntilClaim(lastClaimNv.Value)
		timeLabel.Text = formatCountdown(left)
		dailyFrame.Visible = false
		claimDaily.Active = false
		claimDouble.Active = false
	end
	wasClaimable = claimable
end

lastClaimNv:GetPropertyChangedSignal("Value"):Connect(function()
	refreshUi()
end)

player:GetAttributeChangedSignal(Attr.IN_TAPPING_ZONE):Connect(function()
	if dailyBlurActive == false then
		restoreHarvestGuisAfterDaily()
	end
end)

task.spawn(function()
	while gui.Parent and dailyFrame.Parent do
		refreshUi()
		task.wait(1)
	end
end)

refreshUi()
