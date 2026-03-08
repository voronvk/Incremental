local TweenService = game:GetService("TweenService")

local NORMAL_SCALE = 1
local HOVER_SCALE = 1.05 -- ligeramente más grande al hacer hover
local TWEEN_TIME = 0.15

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

	local uiScale = getOrCreateUIScale(imageLabel)
	uiScale.Scale = NORMAL_SCALE
	local tweenInfo = TweenInfo.new(
		TWEEN_TIME,
		Enum.EasingStyle.Quad
	)

	local function scaleTo(value)
		local tween = TweenService:Create(uiScale, tweenInfo, { Scale = value })
		tween:Play()
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
		scaleTo(HOVER_SCALE)
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
