local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ButtonScaleEffect = require(ReplicatedStorage.Shared:WaitForChild("ButtonScaleEffect"))
local UIBlur = require(ReplicatedStorage.Shared:WaitForChild("UIBlur"))

local NEWS_CLICK_SOUND = 3657879622
local SCALE_TWEEN_TIME = 0.15
local TARGET_SCALE = 1
local tweenInfo = TweenInfo.new(SCALE_TWEEN_TIME, Enum.EasingStyle.Quad)

local newsGui = script.Parent
local newsFrame = newsGui:WaitForChild("NewsFrame")

local uiScale = newsFrame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
uiScale.Scale = 0
uiScale.Parent = newsFrame
newsFrame.Visible = false

local isOpen = false

local function closeNews()
	if not isOpen then
		return
	end
	isOpen = false
	UIBlur.endModal()
	local tween = TweenService:Create(uiScale, tweenInfo, { Scale = 0 })
	tween.Completed:Connect(function()
		newsFrame.Visible = false
	end)
	tween:Play()
end

local function openNews()
	if isOpen then
		return
	end
	isOpen = true
	newsFrame.Visible = true
	UIBlur.beginModal()
	TweenService:Create(uiScale, tweenInfo, { Scale = TARGET_SCALE }):Play()
end

-- Botón que abre NewsFrame
local newsButtonGui = newsGui:WaitForChild("NewsButton")
local button: GuiButton? = if newsButtonGui:IsA("GuiButton")
	then newsButtonGui
	else newsButtonGui:FindFirstChildWhichIsA("GuiButton")

if button then
	local img = button:FindFirstChild("ImageLabel")
	ButtonScaleEffect.applyScaleEffect(button, img or button, { clickSoundId = NEWS_CLICK_SOUND })
	local function onOpen()
		if not isOpen then
			openNews()
		end
	end
	if button:IsA("GuiButton") then
		button.Activated:Connect(onOpen)
	else
		button.MouseButton1Click:Connect(onOpen)
	end
end

-- CloseButton dentro de NewsFrame
local closeButton = newsFrame:FindFirstChild("CloseButton", true)
if closeButton then
	local img = closeButton:FindFirstChild("ImageLabel")
	ButtonScaleEffect.applyScaleEffect(closeButton, img or closeButton, { clickSoundId = NEWS_CLICK_SOUND })
	if closeButton:IsA("GuiButton") then
		closeButton.Activated:Connect(closeNews)
	else
		closeButton.MouseButton1Click:Connect(closeNews)
	end
end
