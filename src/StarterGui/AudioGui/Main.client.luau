-- AudioGui: controles de audio (mute música/SFX)
-- Lógica migrada desde src/client/AudioGui.client.luau
-- Ajusta TurnOnButton/TurnOffButton según tu nueva UI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local setMuteRequest = ReplicatedStorage:WaitForChild("SetMuteRequest")
local audioGui = script.Parent

local HOVER_SCALE = 1.2
local NORMAL_SCALE = 1
local HOVER_ROTATION = 15
local NORMAL_ROTATION = 0
local TWEEN_TIME = 0.2

local turnOnButton = audioGui:FindFirstChild("TurnOnButton", true)
local turnOffButton = audioGui:FindFirstChild("TurnOffButton", true)
if not turnOnButton or not turnOffButton then
	return
end

local function getOrCreateUIScale(guiObject)
	local uiScale = guiObject:FindFirstChildOfClass("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Scale = NORMAL_SCALE
		uiScale.Parent = guiObject
	end
	return uiScale
end

local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad)

local function setupHoverEffect(button)
	local uiScale = getOrCreateUIScale(button)
	button.MouseEnter:Connect(function()
		TweenService:Create(uiScale, tweenInfo, { Scale = HOVER_SCALE }):Play()
		TweenService:Create(button, tweenInfo, { Rotation = HOVER_ROTATION }):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(uiScale, tweenInfo, { Scale = NORMAL_SCALE }):Play()
		TweenService:Create(button, tweenInfo, { Rotation = NORMAL_ROTATION }):Play()
	end)
end

setupHoverEffect(turnOnButton)
setupHoverEffect(turnOffButton)

local function updateButtonsFromSettings()
	local settings = player:FindFirstChild("Settings")
	local musicMuted = settings and settings:FindFirstChild("MusicMuted")
	local muted = musicMuted and musicMuted.Value >= 1
	turnOnButton.Visible = not muted
	turnOffButton.Visible = muted
end

updateButtonsFromSettings()
local settings = player:WaitForChild("Settings")
settings:WaitForChild("MusicMuted").Changed:Connect(updateButtonsFromSettings)

local function connectClick(btn, muted)
	if btn:IsA("GuiButton") then
		btn.Activated:Connect(function()
			turnOnButton.Visible = not muted
			turnOffButton.Visible = muted
			setMuteRequest:FireServer(muted)
		end)
	else
		btn.MouseButton1Click:Connect(function()
			turnOnButton.Visible = not muted
			turnOffButton.Visible = muted
			setMuteRequest:FireServer(muted)
		end)
	end
end

connectClick(turnOnButton, true)
connectClick(turnOffButton, false)
