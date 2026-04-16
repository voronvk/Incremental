-- RuneGuiController.client.luau
-- Control del BasicRune: UI de Keys (visual), compra de runes (gasto), open x1/x3 y WarnLabel (si faltan llaves).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

local UIClickSound = require(ReplicatedStorage.Shared:WaitForChild("UIClickSound"))

-- Ajusta si luego quieres otra animacion/sound
local WARNY_SOUND_ID = "rbxassetid://139009780109934"
local WARN_HIDE_SCALE_SEC = 0.08

local CYCLE_SECONDS = 60

local function getPlayerKeysValue(): NumberValue?
	local currencies = player:FindFirstChild("Currencies")
	if not currencies then return nil end
	local keys = currencies:FindFirstChild("Keys")
	if keys and keys:IsA("NumberValue") then
		return keys
	end
	return nil
end

local function asGuiButton(root: Instance?): GuiButton?
	if not root then return nil end
	if root:IsA("GuiButton") then
		return root
	end
	return root:FindFirstChildWhichIsA("GuiButton", true)
end

local function getOrCreateUIScale(guiObject: Instance): UIScale
	local uiScale = guiObject:FindFirstChildOfClass("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Scale = 1
		uiScale.Parent = guiObject
	end
	return uiScale
end

local function connectButtonEffects(guiRoot: Instance?)
	local btn = asGuiButton(guiRoot)
	if not btn then return end

	btn.Active = true
	btn.Selectable = true

	local uiScale = getOrCreateUIScale(btn)
	uiScale.Scale = 1

	local hovered = false
	local function tweenScale(scale: number, tweenInfo: TweenInfo)
		TweenService:Create(uiScale, tweenInfo, { Scale = scale }):Play()
	end

	local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local clickTween = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	btn.MouseEnter:Connect(function()
		hovered = true
		tweenScale(1.04, hoverTween)
	end)

	btn.MouseLeave:Connect(function()
		hovered = false
		tweenScale(1, hoverTween)
	end)

	btn.MouseButton1Down:Connect(function()
		tweenScale(0.96, clickTween)
	end)

	btn.MouseButton1Up:Connect(function()
		tweenScale(hovered and 1.04 or 1, clickTween)
	end)

	UIClickSound.connectToButton(btn)
end

-- UI references
local playerGui = player:WaitForChild("PlayerGui")
local runeGui = playerGui:WaitForChild("RuneGui")
local frames = runeGui:WaitForChild("Frames")
local basicRuneFrame = frames:WaitForChild("BasicRune")

local holder = basicRuneFrame:WaitForChild("Holder")
local scrolling = holder:WaitForChild("ScrollingFrame")

local amountLabel = scrolling:WaitForChild("AmountFrame"):WaitForChild("AmountLabel")

local timeFrame = scrolling:WaitForChild("TimeFrame")
local timeLabel = timeFrame:WaitForChild("TimeLabel")
local fillFrame = timeFrame:WaitForChild("FillFrame")

local btn50 = scrolling:WaitForChild("50KeysButton")
local btn500 = scrolling:WaitForChild("500KeysButton")
local btn10k = scrolling:WaitForChild("10KButton")

local openArea = scrolling:WaitForChild("Frame", 60)
local openx1 = openArea:WaitForChild("OpenButtonx1", 60) -- en tu UI
local openx3 = openArea:WaitForChild("OpenButtonx3", 60) -- en tu UI

-- WarnLabel (hijo de RuneGui) - por nombre exacto o por caso distinto.
local function findFirstChildByNameInsensitive(root: Instance?, targetName: string): Instance?
	if not root then return nil end
	local lowered = string.lower(targetName)
	for _, inst in ipairs(root:GetDescendants()) do
		if inst.Name and string.lower(inst.Name) == lowered then
			return inst
		end
	end
	-- also check root itself
	if root.Name and string.lower(root.Name) == lowered then
		return root
	end
	return nil
end

local warnTemplate = runeGui:FindFirstChild("WarnLabel", true)
if not warnTemplate then
	warnTemplate = findFirstChildByNameInsensitive(runeGui, "Warnlabel")
end
local warnClone: TextLabel? = nil
local warnScale: UIScale? = nil
local warnCount = 0
local warnToken = 0

local function isSfxMuted(): boolean
	local settings = player:FindFirstChild("Settings")
	local sfx = settings and settings:FindFirstChild("SfxMuted")
	return sfx ~= nil and sfx:IsA("IntValue") and sfx.Value >= 1
end

local function playWarnySound()
	if isSfxMuted() then
		return
	end
	local s = Instance.new("Sound")
	s.SoundId = WARNY_SOUND_ID
	s.Volume = 1
	s.Parent = SoundService
	s:Play()
	s.Ended:Connect(function()
		s:Destroy()
	end)
end

local function showWarnLabel(text: string)
	if not (warnTemplate and warnTemplate:IsA("TextLabel")) then
		return
	end

	warnTemplate.Visible = false

	warnCount += 1
	warnToken += 1
	local myToken = warnToken

	if not warnClone or not warnClone.Parent then
		warnClone = warnTemplate:Clone()
		warnClone.Name = "RuneWarnLabel_Clone"
		warnClone.Visible = true
		warnClone.Parent = warnTemplate.Parent

		warnScale = warnClone:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		warnScale.Scale = 1
		warnScale.Parent = warnClone
	end

	local fullText = (warnCount > 1) and (text .. " (x" .. tostring(warnCount) .. ")") or text
	warnClone.Text = fullText
	warnClone.Visible = true

	if warnScale then
		warnScale.Scale = 0.75
		TweenService:Create(
			warnScale,
			TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
	end

	task.delay(3, function()
		if warnToken ~= myToken then
			return
		end
		warnCount = 0

		local toHide = warnClone
		local scaleObj = warnScale
		warnClone = nil
		warnScale = nil

		if toHide and toHide.Parent and scaleObj then
			local tw = TweenService:Create(
				scaleObj,
				TweenInfo.new(WARN_HIDE_SCALE_SEC, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ Scale = 0 }
			)
			tw.Completed:Connect(function()
				if toHide.Parent then
					toHide:Destroy()
				end
			end)
			tw:Play()
		elseif toHide and toHide.Parent then
			toHide:Destroy()
		end
	end)
end

local function tweenFillTo(alpha: number)
	alpha = math.clamp(alpha, 0, 1)
	local yScale = fillFrame.Size.Y.Scale
	local yOffset = fillFrame.Size.Y.Offset
	TweenService:Create(
		fillFrame,
		TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = UDim2.new(alpha, 0, yScale, yOffset) }
	):Play()
end

-- Visual timer (solo UI)
task.spawn(function()
	local cycleStart = os.clock()
	while basicRuneFrame.Parent do
		-- Usa tiempo real para que avance aunque la UI esté oculta.
		local elapsed = math.floor(os.clock() - cycleStart)
		local phase = elapsed % CYCLE_SECONDS
		-- Mostrar "60/60" en el segundo exacto del reset.
		local t = (phase == 0 and elapsed > 0) and CYCLE_SECONDS or phase
		timeLabel.Text = ("%d/%d"):format(t, CYCLE_SECONDS)
		tweenFillTo(t / CYCLE_SECONDS)
		task.wait(1)
	end
end)

-- Keys UI (espera a que exista)
local keysVal = nil :: NumberValue?
do
	local currencies = player:WaitForChild("Currencies", 30)
	if currencies then
		local kv = currencies:FindFirstChild("Keys")
		if kv and kv:IsA("NumberValue") then
			keysVal = kv
		else
			-- Espera por si se crea un poco después.
			local okKv = currencies:WaitForChild("Keys", 30)
			if okKv and okKv:IsA("NumberValue") then
				keysVal = okKv
			end
		end
	end
end
local function refreshKeysLabel()
	local v = keysVal and keysVal.Value or 0
	amountLabel.Text = tostring(math.floor(v))
end

refreshKeysLabel()
if keysVal then
	keysVal.Changed:Connect(refreshKeysLabel)
end

-- Scale effects on the buttons
connectButtonEffects(btn50)
connectButtonEffects(btn500)
connectButtonEffects(btn10k)
connectButtonEffects(openx1)
connectButtonEffects(openx3)

-- Open requests: x1/x3
local openRequest = ReplicatedStorage:WaitForChild("RuneOpenRequest", 30)

local function hookOpenButton(guiBtn: GuiButton, n: number)
	guiBtn.Activated:Connect(function()
		local kv = getPlayerKeysValue()
		if not kv then return end
		if kv.Value < n then
			playWarnySound()
			showWarnLabel("You dont have keys!")
			return
		end
		openRequest:FireServer(n)
	end)
end

hookOpenButton(openx1, 1)
hookOpenButton(openx3, 3)

-- Inventory sync: unlock rune colors
local runeSlots = {
	CommonRune = openArea:WaitForChild("CommonRune", 60),
	UncommonRune = openArea:WaitForChild("UncommonRune", 60),
	EpicRune = openArea:WaitForChild("EpicRune", 60),
	LegendaryRune = openArea:WaitForChild("LegendaryRune", 60),
}

-- Cache local (para no recalcular si no cambia)
local lastCountsJson = ""

local function decodeCountsJson(json: string): { [string]: number }
	if type(json) ~= "string" or json == "" then
		return {}
	end
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(json)
	end)
	if not ok or type(decoded) ~= "table" then
		return {}
	end
	local out: { [string]: number } = {}
	for k, v in pairs(decoded) do
		if type(k) == "string" then
			local n = tonumber(v)
			if type(n) == "number" and n == n then
				out[k] = math.floor(n)
			end
		end
	end
	return out
end

local function setUnlocked(slot: Instance?, unlocked: boolean)
	if not slot then return end
	-- En tu UI: cada frame tiene un hijo directo `ImageLabel`
	local img = slot:FindFirstChild("ImageLabel")
	if not img then return end
	img.ImageColor3 = unlocked and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
end

local function applyInventory(counts: { [string]: number }?)
	counts = counts or {}
	for runeId, slot in pairs(runeSlots) do
		local c = counts[runeId] or 0
		local unlocked = type(c) == "number" and c > 0
		setUnlocked(slot, unlocked)
	end
end

local function refreshFromRunesInventoryJson()
	local events = player:FindFirstChild("Events")
	local inv = events and events:FindFirstChild("RunesInventoryJson")
	if not (inv and inv:IsA("StringValue")) then
		return
	end
	local json = inv.Value
	if json == lastCountsJson then
		return
	end
	lastCountsJson = json
	applyInventory(decodeCountsJson(json))
end

task.spawn(function()
	local getInv = ReplicatedStorage:FindFirstChild("RuneGetInventory")
	if getInv and getInv:IsA("RemoteFunction") then
		local ok, res = pcall(function()
			return getInv:InvokeServer()
		end)
		if ok and type(res) == "table" and res.ok == true then
			applyInventory(res.counts)
		end
	end
end)

-- Fuente de verdad persistente (DataStore): `Events.RunesInventoryJson`
task.defer(function()
	refreshFromRunesInventoryJson()
	local events = player:FindFirstChild("Events")
	local inv = events and events:FindFirstChild("RunesInventoryJson")
	if inv and inv:IsA("StringValue") then
		inv.Changed:Connect(refreshFromRunesInventoryJson)
	end
end)

local invChanged = ReplicatedStorage:FindFirstChild("RuneInventoryChanged")
if invChanged and invChanged:IsA("RemoteEvent") then
	invChanged.OnClientEvent:Connect(function(payload)
		if type(payload) ~= "table" then return end
		if type(payload.counts) == "table" then
			applyInventory(payload.counts)
		end
	end)
end

