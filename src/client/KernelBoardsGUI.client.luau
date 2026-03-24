--[[
	KernelBoardsGUI - Todos los kernel boards (Respec + Kernel1-5) en un solo script.
	Añade/modifica entradas en KERNEL_BOARDS para nuevos kernels.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = game.Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local events = player:FindFirstChild("Events")
local level = events and events:WaitForChild("Level")

local upgradefolder = workspace:WaitForChild("Upgrades")
local kernelFolder = upgradefolder:WaitForChild("KernelUpgrades")
local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://140206660137491"
sound.Parent = SoundService

local function checkMuted()
	sound.Volume = (player:WaitForChild("Settings"):WaitForChild("SfxMuted").Value >= 1) and 0 or 1
end
player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkMuted)
checkMuted()

-- Kernel1-5: cada uno con su fórmula de efecto
local KERNEL_BOARDS = {
	{ board = "KernelBoard1", upg = "Kernel1", event = "Kernel1", eventMax = "Kernel1Max", effect = function(L) return 1.15^L end },
	{ board = "KernelBoard2", upg = "Kernel2", event = "Kernel2", eventMax = "Kernel2Max", effect = function(L) return 1 + 0.05*L end },
	{ board = "KernelBoard3", upg = "Kernel3", event = "Kernel3", eventMax = "Kernel3Max", effect = function(L) return 1 + 0.25*L end, fmt = function(cur,nxt) return "/"..string.format("%.2f",cur).." ➡ /"..string.format("%.2f",nxt) end },
	{ board = "KernelBoard4", upg = "Kernel4", event = "Kernel4", eventMax = "Kernel4Max", effect = function(L) return 1 + 0.05*L end },
	{ board = "KernelBoard5", upg = "Kernel5", event = "Kernel5", eventMax = "Kernel5Max", effect = function(L) return 1 + 0.02*L end },
}

local kernel1 = upgrades:WaitForChild("Kernel1")
local kernel2 = upgrades:WaitForChild("Kernel2")
local kernel3 = upgrades:WaitForChild("Kernel3")
local kernel4 = upgrades:WaitForChild("Kernel4")
local kernel5 = upgrades:WaitForChild("Kernel5")
local upgtree2_17 = upgrades:WaitForChild("UpgTree2_17")
local upgtree2_18 = upgrades:WaitForChild("UpgTree2_18")

local KERNELS = { kernel1, kernel2, kernel3, kernel4, kernel5 }
local MAX_LEVEL = 50
local COST = 1

local function getUnspentKernels()
	local mult = (upgtree2_17.Value >= 1) and 1.25 or 1
	local mult2 = (upgtree2_18.Value >= 1) and 1.25 or 1
	return math.floor(level.Value * mult * mult2 - kernel1.Value - kernel2.Value - kernel3.Value - kernel4.Value - kernel5.Value)
end

local function connectAll(callback)
	level:GetPropertyChangedSignal("Value"):Connect(callback)
	for _, k in ipairs(KERNELS) do k:GetPropertyChangedSignal("Value"):Connect(callback) end
	upgtree2_17:GetPropertyChangedSignal("Value"):Connect(callback)
	upgtree2_18:GetPropertyChangedSignal("Value"):Connect(callback)
end

-- KernelBoard0: Respec
do
	local upgradePart = kernelFolder:WaitForChild("KernelBoard0")
	local levelPart = kernelFolder:WaitForChild("KernelBoard0Top")
	local levelLabel = levelPart:WaitForChild("SurfaceGui"):WaitForChild("TextLabel")
	local button = upgradePart:WaitForChild("UpgradeGUI"):WaitForChild("RespecButton")
	local respecevent = ReplicatedStorage:WaitForChild("RespecEvent")

	local function updateRespecLabel()
		levelLabel.Text = "Pumpkins: " .. getUnspentKernels()
	end
	updateRespecLabel()
	connectAll(updateRespecLabel)

	local lastRespecTime, COOLDOWN = 0, 300
	button.MouseButton1Click:Connect(function()
		if os.time() - lastRespecTime >= COOLDOWN then
			lastRespecTime = os.time()
			respecevent:FireServer()
			sound:Play()
			button.AutoButtonColor = false
			button.Text = "Cooldown: 5:00"
			task.spawn(function()
				for _ = 1, COOLDOWN do
					task.wait(1)
					local t = COOLDOWN - (os.time() - lastRespecTime)
					if t <= 0 then button.Text = "Respec"; button.AutoButtonColor = true; break end
					button.Text = string.format("Cooldown: %d:%02d", math.floor(t/60), t%60)
				end
			end)
		end
	end)
end

-- KernelBoard1-5
for _, cfg in ipairs(KERNEL_BOARDS) do
	local upgradePart = kernelFolder:WaitForChild(cfg.board)
	local levelPart = upgradePart:WaitForChild("LevelBoard")
	local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
	local levelGui = levelPart:WaitForChild("LevelGUI")
	local button = surfaceGui:WaitForChild("UpgradeButton")
	local buttonmax = surfaceGui:WaitForChild("UpgradeMaxButton")
	local costlabel = surfaceGui:WaitForChild("CostLabel")
	local effectlabel = surfaceGui:WaitForChild("EffectLabel")
	local levellabel = levelGui:WaitForChild("LevelLabel")

	local upg = upgrades:WaitForChild(cfg.upg)
	local upgradeEvent = ReplicatedStorage:WaitForChild(cfg.event)
	local upgradeEventMax = ReplicatedStorage:WaitForChild(cfg.eventMax)

	local function updateLabel()
		local unspent = getUnspentKernels()
		levellabel.Text = "Level: " .. upg.Value .. "/" .. MAX_LEVEL
		if unspent >= COST and upg.Value < MAX_LEVEL then
			button.BackgroundColor3 = Color3.new(0,1,0)
			buttonmax.BackgroundColor3 = Color3.new(0,1,0)
		else
			button.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
			buttonmax.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
		end
		if upg.Value < MAX_LEVEL then
			local cur, nxt = cfg.effect(upg.Value), cfg.effect(upg.Value + 1)
			effectlabel.Text = cfg.fmt and cfg.fmt(cur, nxt) or string.format("%.2fx ➡ %.2fx", cur, nxt)
			costlabel.Text = "Cost: " .. Abbreviate(COST) .. " Pumpkin"
		else
			local cur = cfg.effect(upg.Value)
			effectlabel.Text = cfg.fmt and ("/" .. string.format("%.2f", cur)) or string.format("%.2fx", cur)
			costlabel.Text = "Cost: Max Level!"
		end
	end

	connectAll(updateLabel)
	updateLabel()

	button.MouseButton1Click:Connect(function() upgradeEvent:FireServer(); sound:Play() end)
	buttonmax.MouseButton1Click:Connect(function() upgradeEventMax:FireServer(); sound:Play() end)
end
