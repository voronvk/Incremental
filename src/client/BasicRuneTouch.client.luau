-- BasicRuneTouch.client.luau
-- Abre/cierra la UI RuneGui.Frames.BasicRune al tocar el modelo Workspace.BasicRune.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local Attr = require(ReplicatedStorage.Shared:WaitForChild("PlayerClientAttributes"))

local function ensureUIScale(guiObject: Instance): UIScale
	local uiScale = guiObject:FindFirstChildOfClass("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Scale = 1
		uiScale.Parent = guiObject
	end
	return uiScale
end

local runeModel = workspace:WaitForChild("BasicRune", 60)
if not runeModel then
	warn("[BasicRuneTouch] Sin Workspace.BasicRune tras 60s.")
	return
end

-- UI (en PlayerGui)
local playerGui = player:WaitForChild("PlayerGui")
local runeGui = playerGui:WaitForChild("RuneGui")
local frames = runeGui:WaitForChild("Frames")
local basicRuneFrame = frames:WaitForChild("BasicRune")
local tappingGui = playerGui:FindFirstChild("TappingGui")

local uiScale = ensureUIScale(basicRuneFrame)
basicRuneFrame.Visible = false
uiScale.Scale = 0

local BLUR_NAME = "BasicRuneBlur"
local BLUR_SIZE_OPEN = 16
local FOV_OPEN_DELTA = -8
local FOV_TWEEN_IN = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FOV_TWEEN_OUT = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local defaultFov = nil :: number?
local cameraTween: Tween? = nil
local blurTween: Tween? = nil

local function getOrCreateBlur(): BlurEffect
	local blur = Lighting:FindFirstChild(BLUR_NAME)
	if blur and blur:IsA("BlurEffect") then
		return blur
	end
	blur = Instance.new("BlurEffect")
	blur.Name = BLUR_NAME
	blur.Size = 0
	blur.Parent = Lighting
	return blur
end

local function cancelVisualTweens()
	if cameraTween then
		cameraTween:Cancel()
		cameraTween = nil
	end
	if blurTween then
		blurTween:Cancel()
		blurTween = nil
	end
end

local function applyOpenVisuals()
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	if defaultFov == nil then
		defaultFov = cam.FieldOfView
	end
	cancelVisualTweens()
	local targetFov = math.clamp((defaultFov :: number) + FOV_OPEN_DELTA, 25, 120)
	cameraTween = TweenService:Create(cam, FOV_TWEEN_IN, { FieldOfView = targetFov })
	cameraTween:Play()

	local blur = getOrCreateBlur()
	blurTween = TweenService:Create(blur, FOV_TWEEN_IN, { Size = BLUR_SIZE_OPEN })
	blurTween:Play()
end

local function applyCloseVisuals()
	local cam = workspace.CurrentCamera
	cancelVisualTweens()
	if cam then
		local restoreFov = defaultFov or cam.FieldOfView
		cameraTween = TweenService:Create(cam, FOV_TWEEN_OUT, { FieldOfView = restoreFov })
		cameraTween:Play()
	end
	local blur = Lighting:FindFirstChild(BLUR_NAME)
	if blur and blur:IsA("BlurEffect") then
		blurTween = TweenService:Create(blur, FOV_TWEEN_OUT, { Size = 0 })
		blurTween:Play()
	end
end

local function setTappingGuiForRuneUi(runeUiOpen: boolean)
	if not (tappingGui and tappingGui:IsA("ScreenGui")) then
		tappingGui = playerGui:FindFirstChild("TappingGui")
	end
	if not (tappingGui and tappingGui:IsA("ScreenGui")) then
		return
	end
	if runeUiOpen then
		tappingGui.Enabled = false
	else
		-- Evita quedar atascado en false por solapes de estados.
		tappingGui.Enabled = true
	end
end

local tweenId = 0
local isOpen = false
local proximityWatchSeq = 0
local character: Model? = player.Character
local touchingCharParts: { [Instance]: boolean } = {}
local touchCount = 0

local function pointInObb(cframe: CFrame, size: Vector3, worldPoint: Vector3): boolean
	local half = size * 0.5
	local localPos = cframe:PointToObjectSpace(worldPoint)
	return math.abs(localPos.X) <= half.X + 0.05 and math.abs(localPos.Y) <= half.Y + 0.05 and math.abs(localPos.Z) <= half.Z + 0.05
end

local function hrpStillNearRune(): boolean
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not hrp or not hrp:IsA("BasePart") then
		return true
	end
	local ok, cf, size = pcall(function()
		return (runeModel :: Instance):GetBoundingBox()
	end)
	if not ok or typeof(cf) ~= "CFrame" or typeof(size) ~= "Vector3" then
		return true
	end
	local pad = Vector3.new(6, 10, 6)
	return pointInObb(cf, size + pad, hrp.Position)
end

local function stopProximityWatch()
	proximityWatchSeq += 1
end

local function hideUI()
	if not isOpen then
		return
	end
	stopProximityWatch()
	player:SetAttribute(Attr.RUNE_TOUCH_SHOP_OPEN, false)
	isOpen = false
	tweenId += 1
	local id = tweenId

	local t = TweenService:Create(
		uiScale,
		TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Scale = 0 }
	)
	applyCloseVisuals()
	setTappingGuiForRuneUi(false)
	t:Play()

	t.Completed:Connect(function()
		if id == tweenId then
			basicRuneFrame.Visible = false
		end
	end)
end

local function startProximityWatch()
	stopProximityWatch()
	proximityWatchSeq += 1
	local seq = proximityWatchSeq
	task.spawn(function()
		while seq == proximityWatchSeq and isOpen do
			task.wait(0.35)
			if seq ~= proximityWatchSeq or not isOpen then
				break
			end
			if not hrpStillNearRune() then
				touchingCharParts = {}
				touchCount = 0
				hideUI()
				break
			end
		end
	end)
end

local function showUI()
	if isOpen then
		return
	end
	isOpen = true
	player:SetAttribute(Attr.RUNE_TOUCH_SHOP_OPEN, true)
	tweenId += 1
	local id = tweenId

	basicRuneFrame.Visible = true
	setTappingGuiForRuneUi(true)
	applyOpenVisuals()
	TweenService:Create(
		uiScale,
		TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 }
	):Play()

	-- Asegura estado final si hay solapes de tween.
	task.spawn(function()
		local ok, err = pcall(function()
			task.wait(0.18)
			if id == tweenId then
				basicRuneFrame.Visible = true
			end
		end)
		if not ok then
			warn("[BasicRuneTouch] showUI tween wait failed:", err)
		end
	end)
	startProximityWatch()
end

local function isPartOfCharacter(part: Instance?): boolean
	if not part or not character then
		return false
	end
	return part:IsDescendantOf(character)
end

local function onTouchEnter(otherPart: Instance)
	if not isPartOfCharacter(otherPart) then
		return
	end
	if touchingCharParts[otherPart] then
		return
	end

	touchingCharParts[otherPart] = true
	touchCount += 1

	if touchCount > 0 then
		showUI()
	end
end

local function onTouchExit(otherPart: Instance)
	if not isPartOfCharacter(otherPart) then
		return
	end
	if not touchingCharParts[otherPart] then
		return
	end

	touchingCharParts[otherPart] = nil
	touchCount -= 1
	if touchCount < 0 then touchCount = 0 end

	-- Si ya no tocas el modelo, la UI debe desaparecer.
	if touchCount == 0 then
		-- Pequeno delay para evitar cierre instantaneo por flicker de fisicas.
		task.delay(0.08, function()
			if touchCount == 0 then
				hideUI()
			end
		end)
	end
end

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	touchingCharParts = {}
	touchCount = 0
	hideUI()
end)

local touchesWired = false

local function collectRuneParts(): { BasePart }
	local runeParts: { BasePart } = {}
	for _, desc in ipairs(runeModel:GetDescendants()) do
		if desc:IsA("BasePart") then
			table.insert(runeParts, desc)
		end
	end
	return runeParts
end

local function wireRuneTouches(): boolean
	if touchesWired then
		return true
	end
	local runeParts = collectRuneParts()
	if #runeParts == 0 then
		return false
	end
	touchesWired = true
	for _, part in ipairs(runeParts) do
		part.Touched:Connect(function(otherPart)
			if otherPart then
				onTouchEnter(otherPart)
			end
		end)
		if part.TouchEnded then
			part.TouchEnded:Connect(function(otherPart)
				if otherPart then
					onTouchExit(otherPart)
				end
			end)
		end
	end
	return true
end

if not wireRuneTouches() then
	local warned: boolean = false
	local conn: RBXScriptConnection? = nil
	conn = runeModel.DescendantAdded:Connect(function(d)
		if touchesWired then
			if conn then
				conn:Disconnect()
			end
			return
		end
		if d:IsA("BasePart") and wireRuneTouches() and conn then
			conn:Disconnect()
		end
	end)
	task.delay(45, function()
		if conn and conn.Connected then
			conn:Disconnect()
		end
		if not touchesWired and not warned then
			warned = true
			warn("[BasicRuneTouch] BasicRune sigue sin BaseParts tras 45s (streaming o modelo vacío).")
		end
	end)
end

