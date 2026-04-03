--[[
	Tapping.Plot.GoldTree — modelos P1..P7.
	Desbloqueo: ClickDetector → compra (servidor). Bloqueado: ColorPart(s) RGB(25,25,25).
	Sin oro: aviso estilo Quest (WarnLabel en TappingGui.QuestFrame).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local GoldTreeConfig = require(ReplicatedStorage.Shared:WaitForChild("GoldTreeConfig"))

local upgrades = player:WaitForChild("Upgrades")
local gold = player:WaitForChild("Currencies"):WaitForChild("Gold")

local purchaseRequest = ReplicatedStorage:WaitForChild("GoldTreePurchaseRequest")
local purchaseResult = ReplicatedStorage:WaitForChild("GoldTreePurchaseResult")

local lockedColor = GoldTreeConfig.lockedColor3()

local INSUFFICIENT_GOLD_TEXT = "You dont have enough gold! Buy Gold!"
local WARN_HIDE_SCALE_SEC = 0.08

local goldWarnCount = 0
local goldWarnToken = 0
local goldWarnClone: TextLabel? = nil
local goldWarnScale: UIScale? = nil

local function getQuestWarnTemplate(): TextLabel?
	local pg = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
	local tapping = pg:FindFirstChild("TappingGui") or pg:WaitForChild("TappingGui", 60)
	if not tapping then
		return nil
	end
	local questFrame = tapping:FindFirstChild("QuestFrame") or tapping:WaitForChild("QuestFrame", 30)
	if not questFrame then
		return nil
	end
	local w = questFrame:FindFirstChild("WarnLabel", true)
	if w and w:IsA("TextLabel") then
		return w
	end
	return nil
end

local function showInsufficientGoldWarn()
	local warnLabelTemplate = getQuestWarnTemplate()
	if not warnLabelTemplate then
		return
	end

	warnLabelTemplate.Visible = false

	goldWarnCount += 1
	goldWarnToken += 1
	local myToken = goldWarnToken

	if not goldWarnClone or not goldWarnClone.Parent then
		goldWarnClone = warnLabelTemplate:Clone()
		goldWarnClone.Name = "GoldTreeWarn_Clone"
		goldWarnClone.Visible = true
		goldWarnClone.Parent = warnLabelTemplate.Parent

		goldWarnScale = goldWarnClone:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		goldWarnScale.Scale = 1
		goldWarnScale.Parent = goldWarnClone
	end

	local fullText = (goldWarnCount > 1) and (INSUFFICIENT_GOLD_TEXT .. " (x" .. tostring(goldWarnCount) .. ")") or INSUFFICIENT_GOLD_TEXT
	goldWarnClone.Text = fullText
	goldWarnClone.Visible = true

	if goldWarnScale then
		goldWarnScale.Scale = 0.75
		TweenService:Create(goldWarnScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	end

	task.delay(3, function()
		if goldWarnToken ~= myToken then
			return
		end
		goldWarnCount = 0
		local toHide = goldWarnClone
		local scaleObj = goldWarnScale
		goldWarnClone = nil
		goldWarnScale = nil
		if toHide and toHide.Parent and scaleObj then
			local tw = TweenService:Create(scaleObj, TweenInfo.new(WARN_HIDE_SCALE_SEC, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0 })
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

local function isSfxMuted(): boolean
	local settings = player:FindFirstChild("Settings")
	local sfx = settings and settings:FindFirstChild("SfxMuted")
	return sfx ~= nil and sfx:IsA("IntValue") and sfx.Value >= 1
end

-- Mismo sonido de desbloqueo que GamePassPurchaseSync.client.luau
local UNLOCK_SOUND_ID = "rbxassetid://140206660137491"

local function playGoldTreeUnlockSound()
	if isSfxMuted() then
		return
	end
	local s = Instance.new("Sound")
	s.SoundId = UNLOCK_SOUND_ID
	s.Volume = 0.65
	s.Parent = SoundService
	s.Ended:Connect(function()
		s:Destroy()
	end)
	s:Play()
end

local function ensureUIScale(gui)
	local scale = gui:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Scale = 1
		scale.Parent = gui
	end
	return scale
end

-- Toast como compra en RobuxGui (plantilla BuyLabel)
local function showGoldTreeUnlockToast(index)
	if type(index) ~= "number" then
		return
	end
	local pg = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
	local robuxGui = pg:FindFirstChild("RobuxGui") or pg:WaitForChild("RobuxGui", 20)
	if not robuxGui then
		return
	end
	local buyLabelTemplate = robuxGui:FindFirstChild("BuyLabel") or robuxGui:FindFirstChild("BuyLabel", true)
	if not buyLabelTemplate or not buyLabelTemplate:IsA("GuiObject") then
		return
	end

	local toast = buyLabelTemplate:Clone()
	toast.Visible = true
	toast.Parent = robuxGui

	local textObj = nil
	if toast:IsA("TextLabel") then
		textObj = toast
	else
		local t = toast:FindFirstChildWhichIsA("TextLabel", true)
		if t then
			textObj = t
		end
	end

	local displayName = GoldTreeConfig.displayNameForAnnounce(index)
	if textObj then
		textObj.Text = ("Unlocked! %s"):format(displayName)
	end

	local scale = ensureUIScale(toast)
	scale.Scale = 0
	TweenService:Create(scale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

	local toastToDestroy = toast
	local scaleToTween = scale
	task.delay(1.6, function()
		if not toastToDestroy or not toastToDestroy.Parent then
			return
		end
		local out = TweenService:Create(scaleToTween, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0 })
		out.Completed:Connect(function()
			if toastToDestroy.Parent then
				toastToDestroy:Destroy()
			end
		end)
		out:Play()
	end)
end

local function setGuiText(root, nameVariants, text)
	for _, nm in nameVariants do
		local inst = root:FindFirstChild(nm, true)
		if inst then
			if inst:IsA("TextLabel") or inst:IsA("TextButton") then
				inst.Text = text
				return
			end
			if inst:IsA("StringValue") then
				inst.Value = text
				return
			end
		end
	end
end

local function parsePindex(modelName)
	if string.sub(modelName, 1, 1) ~= "P" then
		return nil
	end
	local n = tonumber(string.sub(modelName, 2))
	if not n or n < 1 or n > 7 then
		return nil
	end
	return n
end

local function collectColorParts(model)
	local parts = {}
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") and string.lower(d.Name) == "colorpart" then
			table.insert(parts, d)
		end
	end
	if #parts == 0 then
		local p = model:FindFirstChild("ColorPart", true)
		if p and p:IsA("BasePart") then
			table.insert(parts, p)
		end
	end
	return parts
end

local function bindGoldTree(goldTree)
	if goldTree:GetAttribute("PlotGoldTreeBound") then
		return
	end

	local nodes = {}

	local function refreshOne(index)
		local entry = nodes[index]
		if not entry then
			return
		end
		local unlocked = entry.upgrade.Value >= 1
		local c = if unlocked then GoldTreeConfig.unlockedColor3(index) else lockedColor
		for _, part in entry.colorParts do
			if part.Parent then
				part.Color = c
			end
		end
	end

	local function tryRegisterModel(child)
		if not child:IsA("Model") then
			return
		end
		local index = parsePindex(child.Name)
		if not index then
			return
		end
		if nodes[index] then
			return
		end

		local def = GoldTreeConfig.NODES[index]
		if not def then
			return
		end

		local colorParts = collectColorParts(child)

		local upgName = GoldTreeConfig.upgradeName(index)
		local upg = upgrades:WaitForChild(upgName, 30)
		if not upg or not upg:IsA("NumberValue") then
			return
		end

		setGuiText(child, { "Coste", "Cost", "CostLabel" }, def.costText)
		setGuiText(child, { "Ventaja", "Benefit", "BenefitLabel" }, def.benefit)

		nodes[index] = {
			colorParts = colorParts,
			upgrade = upg,
			lastFire = 0,
			cost = def.cost,
		}

		upg:GetPropertyChangedSignal("Value"):Connect(function()
			refreshOne(index)
		end)

		local function bindClickDetector(cd)
			if cd:GetAttribute("GoldTreeClickBound") then
				return
			end
			cd:SetAttribute("GoldTreeClickBound", true)
			cd.MouseClick:Connect(function(clickPlayer)
				if clickPlayer ~= player then
					return
				end
				local entryNow = nodes[index]
				if not entryNow then
					return
				end
				local now = tick()
				if now - entryNow.lastFire < 0.35 then
					return
				end
				entryNow.lastFire = now
				if upg.Value >= 1 then
					return
				end
				if gold.Value < entryNow.cost then
					showInsufficientGoldWarn()
					return
				end
				purchaseRequest:FireServer(index)
			end)
		end

		for _, desc in child:GetDescendants() do
			if desc:IsA("ClickDetector") then
				bindClickDetector(desc)
			end
		end

		child.DescendantAdded:Connect(function(desc)
			if desc:IsA("ClickDetector") then
				bindClickDetector(desc)
			elseif desc:IsA("BasePart") and string.lower(desc.Name) == "colorpart" then
				local entry = nodes[index]
				if entry then
					table.insert(entry.colorParts, desc)
					refreshOne(index)
				end
			end
		end)

		refreshOne(index)
	end

	for _, ch in goldTree:GetChildren() do
		tryRegisterModel(ch)
	end

	goldTree.ChildAdded:Connect(tryRegisterModel)

	goldTree:SetAttribute("PlotGoldTreeBound", true)
end

purchaseResult.OnClientEvent:Connect(function(index, ok, reason)
	if ok == true then
		playGoldTreeUnlockSound()
		showGoldTreeUnlockToast(index)
	elseif reason == "nogold" then
		showInsufficientGoldWarn()
	end
end)

local function tryBindPlot(plot)
	local tree = plot:FindFirstChild("GoldTree")
	if tree then
		bindGoldTree(tree)
	end
end

local function watchTappingRoot(tappingRoot)
	local plot = tappingRoot:FindFirstChild("Plot")
	if plot then
		tryBindPlot(plot)
		plot.ChildAdded:Connect(function(ch)
			if ch.Name == "GoldTree" then
				bindGoldTree(ch)
			end
		end)
	end
	tappingRoot.DescendantAdded:Connect(function(desc)
		if desc.Name == "GoldTree" and desc.Parent and desc.Parent.Name == "Plot" then
			bindGoldTree(desc)
		end
	end)
end

local clientTapping = workspace:WaitForChild("ClientTapping")

for _, ch in clientTapping:GetChildren() do
	watchTappingRoot(ch)
end
clientTapping.ChildAdded:Connect(watchTappingRoot)
