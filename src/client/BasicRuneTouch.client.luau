-- BasicRuneTouch.client.luau
-- Abre/cierra la UI RuneGui.Frames.BasicRune al tocar el modelo Workspace.BasicRune.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local function ensureUIScale(guiObject: Instance): UIScale
	local uiScale = guiObject:FindFirstChildOfClass("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Scale = 1
		uiScale.Parent = guiObject
	end
	return uiScale
end

local runeModel = workspace:WaitForChild("BasicRune")

-- UI (en PlayerGui)
local playerGui = player:WaitForChild("PlayerGui")
local runeGui = playerGui:WaitForChild("RuneGui")
local frames = runeGui:WaitForChild("Frames")
local basicRuneFrame = frames:WaitForChild("BasicRune")

local uiScale = ensureUIScale(basicRuneFrame)
basicRuneFrame.Visible = false
uiScale.Scale = 0

local tweenId = 0
local function showUI()
	tweenId += 1
	local id = tweenId

	basicRuneFrame.Visible = true
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
end

local function hideUI()
	tweenId += 1
	local id = tweenId

	local t = TweenService:Create(
		uiScale,
		TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Scale = 0 }
	)
	t:Play()

	t.Completed:Connect(function()
		if id == tweenId then
			basicRuneFrame.Visible = false
		end
	end)
end

local character: Model? = player.Character
local touchingCharParts: { [Instance]: boolean } = {}
local touchCount = 0

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
		hideUI()
	end
end

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	touchingCharParts = {}
	touchCount = 0
	hideUI()
end)

-- Conectamos Touched/TouchEnded a TODOS los BaseParts del modelo.
local runeParts = {}
for _, desc in ipairs(runeModel:GetDescendants()) do
	if desc:IsA("BasePart") then
		table.insert(runeParts, desc)
	end
end

if #runeParts == 0 then
	warn("[BasicRuneTouch] El modelo Workspace.BasicRune no tiene BaseParts descendants.")
end

for _, part in ipairs(runeParts) do
	part.Touched:Connect(function(otherPart)
		if otherPart then
			onTouchEnter(otherPart)
		end
	end)

	-- TouchEnded existe en BasePart en engines recientes.
	if part.TouchEnded then
		part.TouchEnded:Connect(function(otherPart)
			if otherPart then
				onTouchExit(otherPart)
			end
		end)
	end
end

