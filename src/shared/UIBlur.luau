local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local BLUR_SIZE = 24
local FOV_DELTA = -8
local FOV_TWEEN_TIME = 0.28
local fovTweenInfo = TweenInfo.new(FOV_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local openCount = 0
local savedFieldOfView: number? = nil
local savedAutoHarvestEnabled: boolean? = nil
local savedAutoTappingEnabled: boolean? = nil
local fovTween: Tween? = nil

local function getBlurEffect(): BlurEffect
	local blur = Lighting:FindFirstChild("Blur")
	if blur and blur:IsA("BlurEffect") then
		return blur
	end
	local existing = Lighting:FindFirstChildOfClass("BlurEffect")
	if existing then
		return existing
	end
	local created = Instance.new("BlurEffect")
	created.Name = "Blur"
	created.Size = 0
	created.Parent = Lighting
	return created
end

local function cancelFovTween()
	if fovTween then
		fovTween:Cancel()
		fovTween = nil
	end
end

local function applyOverlay()
	local blur = getBlurEffect()
	blur.Size = BLUR_SIZE

	local cam = workspace.CurrentCamera
	if cam then
		cancelFovTween()
		savedFieldOfView = cam.FieldOfView
		local targetFov = savedFieldOfView + FOV_DELTA
		fovTween = TweenService:Create(cam, fovTweenInfo, { FieldOfView = targetFov })
		fovTween:Play()
	end

	local player = Players.LocalPlayer
	local pg = player:FindFirstChild("PlayerGui")
	if pg then
		local ah = pg:FindFirstChild("AutoHarvest")
		if ah and ah:IsA("ScreenGui") then
			savedAutoHarvestEnabled = ah.Enabled
			ah.Enabled = false
		end
		local at = pg:FindFirstChild("AutoTapping")
		if at and at:IsA("ScreenGui") then
			savedAutoTappingEnabled = at.Enabled
			at.Enabled = false
		end
	end
end

local function clearOverlay()
	local blur = getBlurEffect()
	blur.Size = 0

	local cam = workspace.CurrentCamera
	local restoreTo = savedFieldOfView
	savedFieldOfView = nil
	if cam and restoreTo ~= nil then
		cancelFovTween()
		fovTween = TweenService:Create(cam, fovTweenInfo, { FieldOfView = restoreTo })
		fovTween.Completed:Connect(function()
			fovTween = nil
		end)
		fovTween:Play()
	end

	local player = Players.LocalPlayer
	local pg = player:FindFirstChild("PlayerGui")
	if pg then
		if savedAutoHarvestEnabled ~= nil then
			local ah = pg:FindFirstChild("AutoHarvest")
			if ah and ah:IsA("ScreenGui") then
				ah.Enabled = savedAutoHarvestEnabled
			end
			savedAutoHarvestEnabled = nil
		end
		if savedAutoTappingEnabled ~= nil then
			local at = pg:FindFirstChild("AutoTapping")
			if at and at:IsA("ScreenGui") then
				at.Enabled = savedAutoTappingEnabled
			end
			savedAutoTappingEnabled = nil
		end
	end
end

-- Refcount: efectos solo 0→1 y 1→0 (no se acumula FOV ni blur)
local function beginModal()
	openCount += 1
	if openCount == 1 then
		applyOverlay()
	end
end

local function endModal()
	if openCount <= 0 then
		return
	end
	openCount -= 1
	if openCount == 0 then
		clearOverlay()
	end
end

return {
	beginModal = beginModal,
	endModal = endModal,
}
