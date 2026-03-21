local TweenService = game:GetService("TweenService")

local NORMAL_SCALE = 1
local HOVER_SCALE = 1.04 -- sutil
local CLICK_SCALE = 0.96 -- efecto de "press" al hacer click (sutil)
local TWEEN_TIME = 0.15
local CLICK_TWEEN_TIME = 0.08 -- más rápido para el click

local UIClickSound = require(script.Parent:WaitForChild("UIClickSound"))

local function getOrCreateUIScale(guiObject)
	local uiScale = guiObject:FindFirstChildOfClass("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Scale = 1
		uiScale.Parent = guiObject
	end
	return uiScale
end

local function applyScaleEffect(button, imageLabel)
	if not button or not imageLabel then
		return
	end

	-- Sonido pop en cada click
	UIClickSound.connectToButton(button)

	local uiScale = getOrCreateUIScale(imageLabel)
	uiScale.Scale = NORMAL_SCALE
	local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad)
	local clickTweenInfo = TweenInfo.new(CLICK_TWEEN_TIME, Enum.EasingStyle.Quad)

	local function scaleTo(value)
		TweenService:Create(uiScale, tweenInfo, { Scale = value }):Play()
	end

	local function scaleToClick(value)
		TweenService:Create(uiScale, clickTweenInfo, { Scale = value }):Play()
	end

	local isHovered = false
	button.MouseEnter:Connect(function()
		isHovered = true
		scaleTo(HOVER_SCALE)
	end)

	button.MouseLeave:Connect(function()
		isHovered = false
		scaleTo(NORMAL_SCALE)
	end)

	button.MouseButton1Down:Connect(function()
		scaleToClick(CLICK_SCALE)
	end)

	button.MouseButton1Up:Connect(function()
		if isHovered then
			scaleTo(HOVER_SCALE)
		else
			scaleTo(NORMAL_SCALE)
		end
	end)
end

return {
	applyScaleEffect = applyScaleEffect,
}
