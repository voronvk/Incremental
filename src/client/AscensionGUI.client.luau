local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")
local currencies = player:WaitForChild("Currencies")
local events = player:FindFirstChild("Events")
local rebirths = currencies:WaitForChild("Rebirths")
local ascensions = currencies:WaitForChild("Ascensions")

local upgradeFolder = workspace:WaitForChild("Island2")
local upgtreefolder = upgradeFolder:WaitForChild("UpgradeTree")
local upgradePart = upgtreefolder:WaitForChild("Upg1"):WaitForChild("Main")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
local costLabel = surfaceGui:WaitForChild("CostLabel")
local effectLabel = surfaceGui:WaitForChild("EffectLabel")
local upgbutton = upgradePart:WaitForChild("ClickDetector")

local SoundService = game:GetService("SoundService")
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://100841669467007"
local function checkmuted()
	if player:WaitForChild("Settings"):WaitForChild("SfxMuted").Value >= 1 then
		sound.Volume = 0
	else
		sound.Volume = 1
	end
end
sound.Parent = SoundService

local upgradeEvent = ReplicatedStorage:WaitForChild("AscensionEvent")

local Cost = 1_000_000_000_000_000_000

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

local function updateLabel()

	local ownsGamepass = false
	local MarketplaceService = game:GetService("MarketplaceService")
	local function checkGamepass()
		local success, result = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, 1595314670)
		end)
		if success then
			ownsGamepass = result
		end
	end
	checkGamepass()

	local cost = Cost
	local boosters = upgrades:WaitForChild("Boosters")
	local kernel2 = upgrades:WaitForChild("Kernel2")
	local mult = (boosters.Value >= 1) and boosters.Value + 1 or 1
	local mult2 = 1 + (0.05 * kernel2.Value)

	local mult3 = 1
	if ownsGamepass then
		mult3 = 2
	end

	local ascgain = math.floor(1 * mult * mult2 * mult3)

	if rebirths.Value >= cost then
		upgradePart:WaitForChild("SurfaceLight").Brightness = 40
		costLabel.Text = "Currently: " .. ascensions.Value .. " (+" .. ascgain .. ")"
	else
		upgradePart:WaitForChild("SurfaceLight").Brightness = 0
		costLabel.Text = "Currently: " .. ascensions.Value .. " (+0)"
	end
end

updateLabel()

rebirths:GetPropertyChangedSignal("Value"):Connect(updateLabel)
ascensions:GetPropertyChangedSignal("Value"):Connect(updateLabel)

upgbutton.MouseClick:Connect(function()
	if rebirths.Value >= Cost then
		upgradeEvent:FireServer()
		sound:Play()
	else
	end
end)

player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkmuted)
checkmuted()
