--[[
	Rebirth en la PARCELA de Tapping (no RebirthBoard0 de Upgrades).
	Ruta: workspace.ClientTapping.<jugador>/Plot/RebirthBoard → …
	Reglas: RebirthRules.PlotRebirthBoard + PlotRebirthEvent.
	Rebirth pide maíz (Currencies.Corn), no los "+Taps" del melón.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local currencies = player:WaitForChild("Currencies")
local events = player:WaitForChild("Events")
local corn = currencies:WaitForChild("Corn")
local timesRebirthed = events:WaitForChild("TimesRebirthed")
local melonLevel = events:WaitForChild("MelonLevel")

local RebirthRules = require(ReplicatedStorage.Shared:WaitForChild("RebirthRules"))
local plotRules = RebirthRules.PlotRebirthBoard
local plotRebirthEvent = ReplicatedStorage:WaitForChild("PlotRebirthEvent")

local MIN_MELON_LEVEL = plotRules.MinMelonLevel
local REBIRTH_MIN_CORN = plotRules.MinCorn

local COLOR_LOCKED = Color3.fromRGB(58, 58, 58)
local COLOR_READY = Color3.fromRGB(255, 75, 252)

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://140206660137491"
sound.Parent = SoundService

local function isSfxMuted(): boolean
	local settings = player:FindFirstChild("Settings")
	local sfx = settings and settings:FindFirstChild("SfxMuted")
	return sfx ~= nil and sfx:IsA("IntValue") and sfx.Value >= 1
end

local function playRebirthSound()
	if isSfxMuted() then
		return
	end
	sound.Volume = 1
	sound:Play()
end

local function findBisplayRoot(rebirthBoard: Instance): Instance?
	local b = rebirthBoard:FindFirstChild("Bisplay") or rebirthBoard:FindFirstChild("Display")
	return b
end

local function findSurfaceGuiFromBisplay(bisplay: Instance): SurfaceGui?
	if bisplay:IsA("SurfaceGui") then
		return bisplay
	end
	local sg = bisplay:FindFirstChild("SurfaceGui")
	if sg and sg:IsA("SurfaceGui") then
		return sg
	end
	return bisplay:FindFirstChildWhichIsA("SurfaceGui", true)
end

local function findRebirthButtonLabel(rebirthBtn: GuiButton): TextLabel?
	local t = rebirthBtn:FindFirstChild("TextLabel") or rebirthBtn:FindFirstChild("textLabel")
	if t and t:IsA("TextLabel") then
		return t
	end
	for _, ch in rebirthBtn:GetChildren() do
		if ch:IsA("TextLabel") then
			return ch
		end
	end
	return nil
end

local function bindPlotRebirthBoard(rebirthBoard: Instance)
	if rebirthBoard:GetAttribute("PlotRebirthBoardBound") then
		return
	end

	local bisplay = findBisplayRoot(rebirthBoard)
	if not bisplay then
		return
	end

	local surfaceGui = findSurfaceGuiFromBisplay(bisplay)
	if not surfaceGui then
		return
	end

	local frameList = surfaceGui:FindFirstChild("FrameList")
	if not frameList then
		return
	end

	local amountLabel = frameList:FindFirstChild("AmountLabel")
	local rebirthFrame = frameList:FindFirstChild("RebirthFrame")
	if not rebirthFrame then
		return
	end

	local buttonFrame = rebirthFrame:FindFirstChild("ButtonFrame")
	if not buttonFrame then
		return
	end

	local rebirthBtn = buttonFrame:FindFirstChild("Rebirth")
	if not rebirthBtn or not rebirthBtn:IsA("GuiButton") then
		return
	end

	local btnLabel = findRebirthButtonLabel(rebirthBtn)
	if not btnLabel then
		return
	end

	rebirthBoard:SetAttribute("PlotRebirthBoardBound", true)

	local lastClickTime = 0
	local DEBOUNCE = 5

	local function canRebirth(): boolean
		local melonOk = MIN_MELON_LEVEL <= 0 or melonLevel.Value >= MIN_MELON_LEVEL
		return melonOk and corn.Value >= REBIRTH_MIN_CORN
	end

	local function updateAmount()
		if amountLabel and (amountLabel:IsA("TextLabel") or amountLabel:IsA("TextButton")) then
			amountLabel.Text = ("Rebirths: %d"):format(math.floor(timesRebirthed.Value))
		end
	end

	local function updateRebirthButton()
		local ready = canRebirth()
		rebirthBtn.BackgroundColor3 = ready and COLOR_READY or COLOR_LOCKED
		rebirthBtn.Active = ready
		rebirthBtn.AutoButtonColor = ready
		if ready then
			btnLabel.Text = "Rebirth!"
			btnLabel.TextSize = 47
		else
			if MIN_MELON_LEVEL > 0 and melonLevel.Value < MIN_MELON_LEVEL then
				btnLabel.Text = ("Melon %d/%d for Rebirth."):format(math.floor(melonLevel.Value), MIN_MELON_LEVEL)
			elseif corn.Value < REBIRTH_MIN_CORN then
				btnLabel.Text = ("Corn: need %d (have %s). Not taps/melons."):format(
					REBIRTH_MIN_CORN,
					tostring(math.floor(corn.Value))
				)
			else
				btnLabel.Text = "Can't rebirth yet."
			end
			btnLabel.TextSize = 23
		end
	end

	local function refresh()
		updateAmount()
		updateRebirthButton()
	end

	refresh()

	timesRebirthed:GetPropertyChangedSignal("Value"):Connect(refresh)
	melonLevel:GetPropertyChangedSignal("Value"):Connect(refresh)
	corn:GetPropertyChangedSignal("Value"):Connect(refresh)

	local function onClick()
		local now = tick()
		if now - lastClickTime < DEBOUNCE then
			return
		end
		if not canRebirth() then
			return
		end
		lastClickTime = now
		plotRebirthEvent:FireServer()
		playRebirthSound()
	end

	if rebirthBtn:IsA("GuiButton") then
		rebirthBtn.Activated:Connect(onClick)
	end
end

local function tryBindUnderPlot(plot: Instance)
	local board = plot:FindFirstChild("RebirthBoard")
	if board then
		bindPlotRebirthBoard(board)
	end
end

local function watchTappingRoot(tappingRoot: Instance)
	local plot = tappingRoot:FindFirstChild("Plot")
	if plot then
		tryBindUnderPlot(plot)
		plot.ChildAdded:Connect(function(ch)
			if ch.Name == "RebirthBoard" then
				bindPlotRebirthBoard(ch)
			end
		end)
	end
	tappingRoot.DescendantAdded:Connect(function(desc)
		if desc.Name == "RebirthBoard" and desc.Parent and desc.Parent.Name == "Plot" then
			bindPlotRebirthBoard(desc)
		end
	end)
end

local clientTapping = workspace:WaitForChild("ClientTapping")

for _, ch in clientTapping:GetChildren() do
	watchTappingRoot(ch)
end
clientTapping.ChildAdded:Connect(watchTappingRoot)
