-- RebirthBoard0: Workspace.Upgrades.RebirthBoard0 -> UpgradeGUI -> UpgradeButton -> RebirthEvent.
-- UpgradeButton puede ser GuiButton o Frame con un GuiButton dentro. El servidor valida maiz.
--
-- Debug: en Studio sale print en Output. En vivo, pon atributo en tu personaje o en LocalPlayer:
--   player:SetAttribute("DebugRebirthGUI", true)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")

local RebirthRules = require(ReplicatedStorage.Shared:WaitForChild("RebirthRules"))
local upgradesRules = RebirthRules.UpgradesRebirthBoard

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local events = player:WaitForChild("Events")
local rebirths = currencies:WaitForChild("Rebirths")
local corn = currencies:WaitForChild("Corn")
local melonLevel = events:WaitForChild("MelonLevel")

local upgradeEvent = ReplicatedStorage:WaitForChild("RebirthEvent")

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://140206660137491"
sound.Parent = SoundService

local function checkmuted()
	local settings = player:FindFirstChild("Settings")
	local sfx = settings and settings:FindFirstChild("SfxMuted")
	if sfx and sfx:IsA("ValueBase") and sfx.Value >= 1 then
		sound.Volume = 0
	else
		sound.Volume = 1
	end
end

local RebirthCost = upgradesRules.MinCorn
local MIN_MELON_LEVEL_FOR_REBIRTH = upgradesRules.MinMelonLevel

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))
local upgTree1 = upgrades:WaitForChild("UpgTree1")
local rebirthValue = upgrades:WaitForChild("RebirthValueUpg1")
local GamePassCheck = require(ReplicatedStorage.Shared:WaitForChild("GamePassCheck"))
local REBIRTHS_GAMEPASS_ID = 1740115835

local function debugRebirthGuiEnabled()
	return RunService:IsStudio() or player:GetAttribute("DebugRebirthGUI") == true
end

local function dbg(msg)
	if debugRebirthGuiEnabled() then
		print("[rebirthGUI]", msg)
	end
end

local lastPickFailLog = 0
local function dbgPickThrottled(detail)
	if not debugRebirthGuiEnabled() then
		return
	end
	local t = tick()
	if t - lastPickFailLog < 4 then
		return
	end
	lastPickFailLog = t
	warn("[rebirthGUI] no bind: " .. detail)
end

local function packBoardAndClick(board, holder)
	if not board or not holder then
		return nil, nil, nil
	end
	local click = holder
	if not holder:IsA("GuiButton") then
		click = holder:FindFirstChildWhichIsA("GuiButton", true)
	end
	if click and click:IsA("GuiButton") then
		return board, click, holder
	end
	return nil, nil, nil
end

-- Solo rutas conocidas (sin GetDescendants del Workspace).
local function pickRebirthTargets()
	local uf = workspace:FindFirstChild("Upgrades")
	if not uf then
		dbgPickThrottled("Workspace sin carpeta Upgrades")
	else
		local board = uf:FindFirstChild("RebirthBoard0")
		if not board then
			dbgPickThrottled("Upgrades sin hijo RebirthBoard0")
		else
			local gui = board:FindFirstChild("UpgradeGUI") or board:FindFirstChild("UpgradeGUI", true)
			if not gui then
				dbgPickThrottled("RebirthBoard0 sin UpgradeGUI")
			else
				local holder = gui:FindFirstChild("UpgradeButton") or gui:FindFirstChild("UpgradeButton", true)
				if not holder then
					dbgPickThrottled("UpgradeGUI sin UpgradeButton")
				else
					local b, c, h = packBoardAndClick(board, holder)
					if b then
						return b, c, h
					end
					dbgPickThrottled(
						"UpgradeButton es "
							.. holder.ClassName
							.. " y no contiene GuiButton (pon TextButton/ImageButton dentro o hazlo GuiButton)"
					)
				end
			end
		end
	end

	local root = workspace:FindFirstChild("RebirthBoard0")
	if root then
		local holder = root:FindFirstChild("UpgradeButton", true)
		if holder then
			local b, c, h = packBoardAndClick(root, holder)
			if b then
				return b, c, h
			end
		end
		dbgPickThrottled("Workspace.RebirthBoard0 sin UpgradeButton+GuiButton valido")
	end

	return nil, nil, nil
end

local connections = {}
local coreRebirthConns = {}
local boundBoard = nil
local boundButton = nil

local function disconnectAll()
	for _, c in connections do
		c:Disconnect()
	end
	table.clear(connections)
	table.clear(coreRebirthConns)
end

local function rebirthInputAlive()
	if not boundBoard or not boundButton then
		return false
	end
	if not boundBoard.Parent or not boundButton.Parent then
		return false
	end
	if #coreRebirthConns == 0 then
		return false
	end
	for _, c in coreRebirthConns do
		if c.Connected then
			return true
		end
	end
	return false
end

local function enableWorldLayerGui(g)
	if not g then
		return
	end
	if g:IsA("SurfaceGui") or g:IsA("BillboardGui") then
		g.Enabled = true
		return
	end
	local s = g:FindFirstChildWhichIsA("SurfaceGui", true)
	local b = g:FindFirstChildWhichIsA("BillboardGui", true)
	if s then
		s.Enabled = true
	end
	if b then
		b.Enabled = true
	end
end

local lastClickTime = 0
local DEBOUNCE_TIME = 0.35
local lastDebounceDbg = 0

local function fireRebirthAttempt()
	local t = tick()
	if t - lastClickTime < DEBOUNCE_TIME then
		if debugRebirthGuiEnabled() and t - lastDebounceDbg > 2 then
			lastDebounceDbg = t
			dbg("clic ignorado (debounce)")
		end
		return
	end
	lastClickTime = t
	if MIN_MELON_LEVEL_FOR_REBIRTH > 0 and melonLevel.Value < MIN_MELON_LEVEL_FOR_REBIRTH then
		dbg("clic ignorado: melon " .. melonLevel.Value .. " < " .. MIN_MELON_LEVEL_FOR_REBIRTH)
		return
	end
	if corn.Value < RebirthCost then
		dbg("clic: maiz cliente " .. corn.Value .. " < " .. RebirthCost .. " (no FireServer)")
		return
	end
	dbg("FireServer RebirthEvent (maiz=" .. corn.Value .. ")")
	upgradeEvent:FireServer()
	sound:Play()
end

local function tryBind()
	local upgradePart, button, paintTarget = pickRebirthTargets()
	if not upgradePart or not button then
		return false
	end
	if not paintTarget or not paintTarget:IsA("GuiObject") then
		paintTarget = button
	end

	if boundBoard == upgradePart and boundButton == button and rebirthInputAlive() then
		return true
	end

	disconnectAll()
	boundBoard = upgradePart
	boundButton = button
	dbg("bind -> " .. button:GetFullName() .. " (board " .. upgradePart:GetFullName() .. ")")

	enableWorldLayerGui(button:FindFirstAncestorWhichIsA("SurfaceGui"))
	enableWorldLayerGui(button:FindFirstAncestorWhichIsA("BillboardGui"))
	local namedGui = upgradePart:FindFirstChild("UpgradeGUI") or upgradePart:FindFirstChild("UpgradeGUI", true)
	if namedGui then
		enableWorldLayerGui(namedGui)
	end

	local effectLabel = upgradePart:FindFirstChild("EffectLabel", true)
	local levelLabel = upgradePart:FindFirstChild("LevelLabel", true)
	local upgradePremium = upgradePart:FindFirstChild("UpgradePremium", true)
	local deco = upgradePart:FindFirstChild("Deco", true)

	local function updatePremiumVisibility()
		if not upgradePremium or not deco then
			return
		end
		local owns = GamePassCheck.playerOwnsGamePass(player, REBIRTHS_GAMEPASS_ID)
		upgradePremium.Visible = not owns
		deco.Visible = not owns
	end

	if upgradePremium then
		local function promptGamepass()
			MarketplaceService:PromptGamePassPurchase(player, REBIRTHS_GAMEPASS_ID)
		end
		local function connectGamepassClick(obj)
			if not obj:IsA("GuiButton") or obj == button then
				return
			end
			table.insert(connections, obj.Activated:Connect(promptGamepass))
			table.insert(connections, obj.MouseButton1Click:Connect(promptGamepass))
		end
		connectGamepassClick(upgradePremium)
		for _, d in upgradePremium:GetDescendants() do
			if d:IsA("GuiButton") and d ~= button then
				connectGamepassClick(d)
			end
		end
		table.insert(connections, player:GetAttributeChangedSignal("GamePassSyncStamp"):Connect(updatePremiumVisibility))
		updatePremiumVisibility()
	end

	local function getCost()
		return math.floor(RebirthCost)
	end

	local function updateLabel()
		if not effectLabel or not levelLabel then
			return
		end
		local cost = getCost()
		local playtime = events:WaitForChild("Playtime")
		local upgTree1Now = upgrades:WaitForChild("UpgTree1")
		local rebirthValueNow = upgrades:WaitForChild("RebirthValueUpg1")
		local upgTree3 = upgrades:WaitForChild("UpgTree3")
		local upgtree5 = upgrades:WaitForChild("UpgTree5")
		local upgtree6 = upgrades:WaitForChild("UpgTree6")
		local clickbooster = upgrades:WaitForChild("RebirthValueUpg2")
		local rebirthenergy = upgrades:WaitForChild("RebirthEnergy")
		local tier = upgrades:WaitForChild("Tier")
		local upgtree2_3 = upgrades:WaitForChild("UpgTree2_3")

		local mult1 = 2 ^ rebirthValueNow.Value
		local mult2 = (upgTree1Now.Value == 1) and 2 or 1
		local mult3 = (upgTree3.Value == 1) and 1.5 or 1
		local mult4 = (upgtree5.Value == 1) and math.max(math.log(math.max(playtime.Value + 100, 1), 100), 1) or 1
		local mult5 = (upgtree6.Value == 1) and 2 or 1
		local mult6 = 2 ^ clickbooster.Value
		local mult7 = ((rebirthenergy.Value + 1) ^ (1 / 5))
		local mult8 = (tier.Value >= 1) and 2 or 1
		local mult9 = GamePassCheck.playerOwnsGamePass(player, REBIRTHS_GAMEPASS_ID) and 2 or 1
		local mult10 = (upgtree2_3.Value == 1) and 0.1 or 1

		local bonus = math.floor(
			(corn.Value / RebirthCost) * mult1 * mult2 * mult3 * mult4 * mult5 * mult6 * mult7 * mult8 * mult9 * mult10
		)
		effectLabel.Text = string.format("%s (+%s)", Abbreviate(math.floor(rebirths.Value)), Abbreviate(bonus))
		levelLabel.Text = "Level: " .. tostring(rebirths.Value)

		local melonOk = true
		if MIN_MELON_LEVEL_FOR_REBIRTH > 0 then
			melonOk = melonLevel.Value >= MIN_MELON_LEVEL_FOR_REBIRTH
		end
		local canRebirth = corn.Value >= cost and melonOk
		if paintTarget:IsA("GuiObject") then
			if canRebirth then
				paintTarget.BackgroundColor3 = Color3.new(0, 1, 0)
			else
				paintTarget.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
			end
		end
		if button:IsA("GuiButton") then
			button.Active = true
			button.AutoButtonColor = canRebirth
		end
	end

	if effectLabel and levelLabel then
		updateLabel()
		table.insert(connections, rebirths:GetPropertyChangedSignal("Value"):Connect(updateLabel))
		table.insert(connections, corn:GetPropertyChangedSignal("Value"):Connect(updateLabel))
		table.insert(connections, rebirthValue:GetPropertyChangedSignal("Value"):Connect(updateLabel))
		table.insert(connections, upgTree1:GetPropertyChangedSignal("Value"):Connect(updateLabel))
		table.insert(connections, melonLevel:GetPropertyChangedSignal("Value"):Connect(updateLabel))
	end

	-- Solo Activated: MouseButton1Click + InputBegan duplican el mismo clic (varios FireServer por toque).
	if button:IsA("GuiButton") then
		local ca = button.Activated:Connect(fireRebirthAttempt)
		table.insert(connections, ca)
		table.insert(coreRebirthConns, ca)
	end

	return true
end

local bindScheduled = false
local function scheduleTryBind()
	if bindScheduled then
		return
	end
	bindScheduled = true
	task.defer(function()
		bindScheduled = false
		tryBind()
	end)
end

for _ = 1, 900 do
	if tryBind() then
		break
	end
	task.wait(0.1)
end

if not boundBoard then
	warn("[rebirthboard0GUI] No hay RebirthBoard0 usable: Upgrades/RebirthBoard0/UpgradeGUI + GuiButton.")
end

local watchedUpgrades = {}
local function watchUpgrades(uf)
	for _, f in ipairs(watchedUpgrades) do
		if f == uf then
			return
		end
	end
	table.insert(watchedUpgrades, uf)
	uf.DescendantAdded:Connect(function(desc)
		local n = desc.Name
		if n == "RebirthBoard0" or n == "UpgradeGUI" or n == "UpgradeButton" then
			scheduleTryBind()
		end
	end)
end

workspace.ChildAdded:Connect(function(child)
	if child.Name == "RebirthBoard0" then
		scheduleTryBind()
	end
	if child.Name == "Upgrades" then
		watchUpgrades(child)
		child.ChildAdded:Connect(function(c)
			if c.Name == "RebirthBoard0" then
				scheduleTryBind()
			end
		end)
	end
end)

local uf0 = workspace:FindFirstChild("Upgrades")
if uf0 then
	watchUpgrades(uf0)
	uf0.ChildAdded:Connect(function(c)
		if c.Name == "RebirthBoard0" then
			scheduleTryBind()
		end
	end)
end

workspace.DescendantAdded:Connect(function(d)
	if d.Name ~= "UpgradeButton" then
		return
	end
	local a = d.Parent
	while a do
		if a.Name == "RebirthBoard0" then
			scheduleTryBind()
			break
		end
		a = a.Parent
	end
end)

task.spawn(function()
	while true do
		task.wait(3)
		if not rebirthInputAlive() then
			dbg("conexiones muertas: re-bind")
			disconnectAll()
			boundBoard = nil
			boundButton = nil
			tryBind()
		end
	end
end)

player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkmuted)
checkmuted()
