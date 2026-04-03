--[[
	Tapping boards: XpFrame, DamageFrame, CriticFrame bajo FrameList (clon ClientTapping).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local events = player:WaitForChild("Events")
local leaderstats = player:WaitForChild("leaderstats")
local tapsStat = leaderstats:WaitForChild("Taps")

local xpBonus = events:WaitForChild("TappingXpBonus")
local damageLevel = events:WaitForChild("TappingDamageLevel")
local critLevel = events:WaitForChild("TappingCritLevel")

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))
local ButtonScaleEffect = require(ReplicatedStorage.Shared:WaitForChild("ButtonScaleEffect"))
local XpConfig = require(ReplicatedStorage.Shared:WaitForChild("TappingXpBonusConfig"))
local DamageConfig = require(ReplicatedStorage.Shared:WaitForChild("TappingDamageConfig"))
local CritConfig = require(ReplicatedStorage.Shared:WaitForChild("TappingCritConfig"))

local xpPurchase = ReplicatedStorage:WaitForChild("TappingXpBonusRequest")
local damagePurchase = ReplicatedStorage:WaitForChild("TappingDamageUpgradeRequest")
local critPurchase = ReplicatedStorage:WaitForChild("TappingCritUpgradeRequest")

local COLOR_BROKE = Color3.fromRGB(76, 76, 76)
local COLOR_AFFORD = Color3.fromRGB(81, 255, 0)

local function isSfxMuted(): boolean
	local settings = player:FindFirstChild("Settings")
	local sfx = settings and settings:FindFirstChild("SfxMuted")
	return sfx ~= nil and sfx:IsA("IntValue") and sfx.Value >= 1
end

local lastUpgSoundTime = 0
local UPG_SOUND_DEBOUNCE = 0.18

local function playUpgSound()
	if isSfxMuted() then
		return
	end
	local now = os.clock()
	if now - lastUpgSoundTime < UPG_SOUND_DEBOUNCE then
		return
	end
	lastUpgSoundTime = now
	local soundsFolder = ReplicatedStorage:FindFirstChild("Sounds")
	if not soundsFolder then
		return
	end
	local src = soundsFolder:FindFirstChild("Upg")
	if not src or not src:IsA("Sound") then
		return
	end
	local s = src:Clone()
	s.Parent = SoundService
	s.Ended:Connect(function()
		s:Destroy()
	end)
	s:Play()
end

local function findNamedBoardFrame(root, frameName)
	for _, d in root:GetDescendants() do
		if d.Name == frameName and d:IsA("GuiObject") then
			local buttonFrame = d:FindFirstChild("ButtonFrame")
			if
				buttonFrame
				and d:FindFirstChild("CostLabel")
				and d:FindFirstChild("LevelLabel")
				and buttonFrame:FindFirstChild("Buy1Button")
				and buttonFrame:FindFirstChild("MaxButton")
			then
				return d
			end
		end
	end
	return nil
end

local function bindStandardBoard(frame, opts)
	local costLabel = frame:FindFirstChild("CostLabel")
	local levelLabel = frame:FindFirstChild("LevelLabel")
	local buttonFrame = frame:FindFirstChild("ButtonFrame")
	local buy1 = buttonFrame:FindFirstChild("Buy1Button")
	local maxBtn = buttonFrame:FindFirstChild("MaxButton")

	local function updateUi()
		local L = math.clamp(math.floor(opts.stat.Value), 0, opts.maxLevel)
		if levelLabel:IsA("TextLabel") or levelLabel:IsA("TextButton") then
			levelLabel.Text = opts.formatLevel(L)
		end

		if L >= opts.maxLevel then
			if costLabel:IsA("TextLabel") or costLabel:IsA("TextButton") then
				costLabel.Text = "Cost: Max Level!"
			end
			buy1.BackgroundColor3 = COLOR_BROKE
			maxBtn.BackgroundColor3 = COLOR_BROKE
			buy1.Active = false
			maxBtn.Active = false
			return
		end

		buy1.Active = true
		maxBtn.Active = true

		local cost = opts.costForNext(L)
		local taps = tapsStat.Value
		if costLabel:IsA("TextLabel") or costLabel:IsA("TextButton") then
			costLabel.Text = ("Cost: %s Taps"):format(Abbreviate(cost))
		end

		local canBuy = taps >= cost
		local col = COLOR_BROKE
		if canBuy then
			col = COLOR_AFFORD
		end
		buy1.BackgroundColor3 = col
		maxBtn.BackgroundColor3 = col
	end

	local lastStat = opts.stat.Value
	local function onStatChanged()
		local now = opts.stat.Value
		if now > lastStat then
			playUpgSound()
		end
		lastStat = now
		updateUi()
	end

	updateUi()
	opts.stat:GetPropertyChangedSignal("Value"):Connect(onStatChanged)
	tapsStat:GetPropertyChangedSignal("Value"):Connect(updateUi)

	local function hookButton(btn)
		if not (btn:IsA("TextButton") or btn:IsA("ImageButton")) then
			return
		end
		local img = btn:FindFirstChild("ImageLabel")
		ButtonScaleEffect.applyScaleEffect(btn, img or btn)
	end

	hookButton(buy1)
	hookButton(maxBtn)

	local function connectPurchase(btn, mode)
		if btn:IsA("GuiButton") then
			btn.Activated:Connect(function()
				opts.remote:FireServer(mode)
			end)
		else
			btn.MouseButton1Click:Connect(function()
				opts.remote:FireServer(mode)
			end)
		end
	end

	connectPurchase(buy1, "Buy1")
	connectPurchase(maxBtn, "Max")
end

local BOARD_FRAMES = {
	{
		name = "XpFrame",
		stat = xpBonus,
		maxLevel = XpConfig.MAX_LEVEL,
		costForNext = XpConfig.costForNextLevel,
		remote = xpPurchase,
		formatLevel = function(L)
			return ("Level %d/%d"):format(L, XpConfig.MAX_LEVEL)
		end,
	},
	{
		name = "DamageFrame",
		stat = damageLevel,
		maxLevel = DamageConfig.MAX_LEVEL,
		costForNext = DamageConfig.costForNextLevel,
		remote = damagePurchase,
		formatLevel = function(L)
			return ("Level %d/%d"):format(L, DamageConfig.MAX_LEVEL)
		end,
	},
	{
		name = "CriticFrame",
		stat = critLevel,
		maxLevel = CritConfig.MAX_LEVEL,
		costForNext = CritConfig.costForNextLevel,
		remote = critPurchase,
		formatLevel = function(L)
			local pct = math.floor(CritConfig.critChance(L) * 1000 + 0.5) / 10
			return ("Level %d/%d · %.1f%% crit"):format(L, CritConfig.MAX_LEVEL, pct)
		end,
	},
}

local function tryBindBoard(tappingRoot)
	for _, cfg in BOARD_FRAMES do
		local fr = findNamedBoardFrame(tappingRoot, cfg.name)
		if fr and not fr:GetAttribute("TappingBoardBound") then
			fr:SetAttribute("TappingBoardBound", true)
			bindStandardBoard(fr, cfg)
		end
	end
end

local clientTapping = workspace:WaitForChild("ClientTapping")

local function watchTappingRoot(root)
	tryBindBoard(root)
	task.defer(function()
		tryBindBoard(root)
	end)
	root.DescendantAdded:Connect(function()
		tryBindBoard(root)
	end)
end

for _, ch in clientTapping:GetChildren() do
	watchTappingRoot(ch)
end
clientTapping.ChildAdded:Connect(watchTappingRoot)
