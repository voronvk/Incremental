local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ButtonScaleEffect = require(ReplicatedStorage.Shared:WaitForChild("ButtonScaleEffect"))

local player = Players.LocalPlayer
local function resolveLoadingGui()
	local parent = script.Parent
	-- ScreenGui ES un GuiObject, pero dejamos el check explícito para que sea claro.
	if parent and parent:IsA("ScreenGui") then
		return parent
	end

	-- Fallback: buscar ScreenGui llamada "Loading" en PlayerGui.
	local pg = player:WaitForChild("PlayerGui")
	local existing = pg:FindFirstChild("Loading")
	if existing and existing:IsA("ScreenGui") then
		return existing
	end

	return nil
end

local loadingGui = resolveLoadingGui()
if not loadingGui then
	warn("Loading/Main: no se encontró el ScreenGui 'Loading' (script.Parent o PlayerGui).")
	return
end

-- Mostrar inmediatamente (cuando te unes al juego)
if loadingGui:IsA("ScreenGui") then
	loadingGui.Enabled = true
elseif loadingGui:IsA("GuiObject") then
	loadingGui.Visible = true
end

-- bg/Fillbar
local bg = loadingGui:FindFirstChild("bg")
local fillbar: Frame? = nil
if bg and bg:IsA("Frame") then
	fillbar = bg:FindFirstChild("Fillbar")
end

local loadingUsedSkip = false
local skipRequested = false

local skipButton = loadingGui:FindFirstChild("SkipButton", true)
if skipButton and skipButton:IsA("GuiButton") then
	local img = skipButton:FindFirstChild("ImageLabel")
	ButtonScaleEffect.applyScaleEffect(skipButton, img or skipButton)
	skipButton.Activated:Connect(function()
		skipRequested = true
	end)
end

if fillbar and fillbar:IsA("Frame") then
	-- empieza en 0
	local currentSize = fillbar.Size
	local yScale, yOffset = currentSize.Y.Scale, currentSize.Y.Offset
	local xOffset = currentSize.X.Offset
	local targetXScale = currentSize.X.Scale
	if targetXScale == 0 then targetXScale = 1 end

	fillbar.Size = UDim2.new(0, xOffset, yScale, yOffset)

	local fullScale = 1.0 * targetXScale
	local function sizeAt(xScale: number)
		return UDim2.new(xScale, xOffset, yScale, yOffset)
	end

	-- Completa la barra rápido (Skip)
	local SKIP_FILL_SEC = 0.22

	local function tweenToFullFast()
		local tw = TweenService:Create(fillbar, TweenInfo.new(SKIP_FILL_SEC, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = sizeAt(fullScale),
		})
		tw:Play()
		tw.Completed:Wait()
	end

	-- Espera un tween o interrumpe si Skip: cancela y va a lleno rápido
	local function playTweenOrSkipToEnd(tween: Tween)
		local finished = false
		tween.Completed:Connect(function()
			finished = true
		end)
		tween:Play()
		while not finished do
			if skipRequested then
				tween:Cancel()
				tweenToFullFast()
				return true
			end
			task.wait()
		end
		return false
	end

	local function tweenTo(xScale: number, duration: number, easingDir: Enum.EasingDirection)
		if skipRequested then
			tweenToFullFast()
			return true
		end
		local tw = TweenService:Create(fillbar, TweenInfo.new(duration, Enum.EasingStyle.Quad, easingDir), {
			Size = sizeAt(xScale),
		})
		return playTweenOrSkipToEnd(tw)
	end

	-- 5s total con fases no-lineales (rapido / lento / rapido)
	local tweenTimeTotal = 5.0
	local phase1 = 1.0
	local phase2 = 3.2
	local phase3 = tweenTimeTotal - (phase1 + phase2) -- 0.8

	if tweenTo(0.35 * targetXScale, phase1, Enum.EasingDirection.Out) then
		-- ya llenó por skip
	elseif tweenTo(0.7 * targetXScale, phase2, Enum.EasingDirection.InOut) then
	elseif tweenTo(fullScale, phase3, Enum.EasingDirection.Out) then
	end

	-- Skip antes de empezar o entre fases: asegurar lleno
	if skipRequested then
		fillbar.Size = sizeAt(fullScale)
	end
	loadingUsedSkip = skipRequested
end

-- Fade-out: al terminar, todo dentro del LoadingGui se vuelve invisible (a transparencia 1)
local fadeDuration = loadingUsedSkip and 0.2 or 0.35
local tweenInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
for _, obj in ipairs(loadingGui:GetDescendants()) do
	if obj:IsA("UIStroke") then
		TweenService:Create(obj, tweenInfo, { Transparency = 1 }):Play()
	elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
		TweenService:Create(obj, tweenInfo, { TextTransparency = 1 }):Play()
		pcall(function()
			TweenService:Create(obj, tweenInfo, { TextStrokeTransparency = 1 }):Play()
		end)
		if obj:IsA("GuiObject") then
			TweenService:Create(obj, tweenInfo, { BackgroundTransparency = 1 }):Play()
		end
	elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
		TweenService:Create(obj, tweenInfo, { ImageTransparency = 1 }):Play()
		if obj:IsA("GuiObject") then
			TweenService:Create(obj, tweenInfo, { BackgroundTransparency = 1 }):Play()
		end
	elseif obj:IsA("GuiObject") then
		-- Frames/panels...
		if obj.BackgroundTransparency ~= nil then
			TweenService:Create(obj, tweenInfo, { BackgroundTransparency = 1 }):Play()
		end
	end
end

task.wait(fadeDuration + 0.05)

if loadingGui:IsA("ScreenGui") then
	loadingGui.Enabled = false
elseif loadingGui:IsA("GuiObject") then
	loadingGui.Visible = false
end

