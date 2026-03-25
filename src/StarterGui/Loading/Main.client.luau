local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

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

-- TipLabel: hijo directo
local tipLabel = loadingGui:FindFirstChild("TipLabel")
if not (tipLabel and tipLabel:IsA("TextLabel")) then
	warn("Loading/Main: no se encontró Loading.TipLabel (TextLabel) como hijo directo")
	return
end

local TIPS = {
	"Join the group to Unlock Autoharvest",
	"Melons are about 90% water, making them very refreshing and hydrating.",
	"There are many types of melons, including watermelon, cantaloupe, and honeydew.",
	"Watermelons can grow very large - some weigh over 100 kg (220 lbs).",
	"In ancient times, melons were considered a luxury fruit and were highly valued.",
}

local seeded = false
local function pickRandomTip(): string
	if not seeded then
		seeded = true
		local userId = player and player.UserId or 0
		math.randomseed(os.time() + userId)
	end
	return TIPS[math.random(1, #TIPS)]
end

-- Mostrar inmediatamente (cuando te unes al juego)
if loadingGui:IsA("ScreenGui") then
	loadingGui.Enabled = true
elseif loadingGui:IsA("GuiObject") then
	loadingGui.Visible = true
end

tipLabel.BackgroundTransparency = 1
tipLabel.TextTransparency = 0
tipLabel.Text = "Tip: " .. pickRandomTip()
tipLabel.Visible = true
pcall(function()
	tipLabel.TextStrokeTransparency = 0
end)

-- bg/Fillbar
local bg = loadingGui:FindFirstChild("bg")
local fillbar: Frame? = nil
if bg and bg:IsA("Frame") then
	fillbar = bg:FindFirstChild("Fillbar")
end

if fillbar and fillbar:IsA("Frame") then
	-- empieza en 0
	local currentSize = fillbar.Size
	local yScale, yOffset = currentSize.Y.Scale, currentSize.Y.Offset
	local xOffset = currentSize.X.Offset
	local targetXScale = currentSize.X.Scale
	if targetXScale == 0 then targetXScale = 1 end

	fillbar.Size = UDim2.new(0, xOffset, yScale, yOffset)

	-- 5s total con fases no-lineales (rapido / lento / rapido)
	local tweenTimeTotal = 5.0
	local phase1 = 1.0
	local phase2 = 3.2
	local phase3 = tweenTimeTotal - (phase1 + phase2) -- 0.8

	local function tweenTo(xScale: number, duration: number, easingDir: Enum.EasingDirection)
		local tween = TweenService:Create(fillbar, TweenInfo.new(duration, Enum.EasingStyle.Quad, easingDir), {
			Size = UDim2.new(xScale, xOffset, yScale, yOffset),
		})
		tween:Play()
		tween.Completed:Wait()
	end

	tweenTo(0.35 * targetXScale, phase1, Enum.EasingDirection.Out)
	tweenTo(0.7 * targetXScale, phase2, Enum.EasingDirection.InOut)
	tweenTo(1.0 * targetXScale, phase3, Enum.EasingDirection.Out)
end

-- Fade-out: al terminar, todo dentro del LoadingGui se vuelve invisible (a transparencia 1)
-- Importante: TipLabel fondo debe quedarse en 1 y solo se desvanece el texto.
local fadeDuration = 0.35
local tweenInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
for _, obj in ipairs(loadingGui:GetDescendants()) do
	if obj == tipLabel then
		TweenService:Create(obj, tweenInfo, { TextTransparency = 1 }):Play()
		pcall(function()
			TweenService:Create(obj, tweenInfo, { TextStrokeTransparency = 1 }):Play()
		end)
	elseif obj:IsA("UIStroke") then
		TweenService:Create(obj, tweenInfo, { Transparency = 1 }):Play()
	elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
		TweenService:Create(obj, tweenInfo, { TextTransparency = 1 }):Play()
		pcall(function()
			TweenService:Create(obj, tweenInfo, { TextStrokeTransparency = 1 }):Play()
		end)
		if obj:IsA("GuiObject") and obj ~= tipLabel then
			TweenService:Create(obj, tweenInfo, { BackgroundTransparency = 1 }):Play()
		end
	elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
		TweenService:Create(obj, tweenInfo, { ImageTransparency = 1 }):Play()
		if obj:IsA("GuiObject") then
			TweenService:Create(obj, tweenInfo, { BackgroundTransparency = 1 }):Play()
		end
	elseif obj:IsA("GuiObject") then
		-- Frames/panels...
		if obj.BackgroundTransparency ~= nil and obj ~= tipLabel then
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

