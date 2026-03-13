local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local setMuteRequest = ReplicatedStorage:WaitForChild("SetMuteRequest")

local HOVER_SCALE = 1.2
local NORMAL_SCALE = 1
local HOVER_ROTATION = 15
local NORMAL_ROTATION = 0
local TWEEN_TIME = 0.2

local audioGui = player:WaitForChild("PlayerGui"):WaitForChild("AudioGui", 30)
if not audioGui then
	return
end

local turnOnButton = audioGui:WaitForChild("TurnOnButton", 10)
local turnOffButton = audioGui:WaitForChild("TurnOffButton", 10)
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

turnOnButton.MouseButton1Click:Connect(function()
	turnOnButton.Visible = false
	turnOffButton.Visible = true
	setMuteRequest:FireServer(true)
end)

turnOffButton.MouseButton1Click:Connect(function()
	turnOffButton.Visible = false
	turnOnButton.Visible = true
	setMuteRequest:FireServer(false)
end)
