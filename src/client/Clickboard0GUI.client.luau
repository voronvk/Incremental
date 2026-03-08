local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local currencies = player:WaitForChild("Currencies")
local upgrades = player:WaitForChild("Upgrades")
local clicks = currencies:WaitForChild("Clicks")

local upgradefolder = workspace:WaitForChild("Upgrades")
local clickfolder = upgradefolder:WaitForChild("ClickUpgrades")
local upgradePart = clickfolder:WaitForChild("ClickBoard0")
local surfaceGui = upgradePart:WaitForChild("UpgradeGUI")
local button = surfaceGui:WaitForChild("ImageButton")
local effectlabel = surfaceGui:WaitForChild("EffectLabel")

local Event = ReplicatedStorage:WaitForChild("ClickEvent")
local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

local SoundService = game:GetService("SoundService")
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://113208204325880"
local function checkmuted()
	if player:WaitForChild("Settings"):WaitForChild("SfxMuted").Value >= 1 then
		sound.Volume = 0
	else
		sound.Volume = 1
	end
end
sound.Parent = SoundService

-- Rate limit variables
local lastClickTime = 0
local clickInterval = 0.2

-- Update label when value changes
local function updateLabel()
	effectlabel.Text = "Clicks: " .. Abbreviate(clicks.Value)
end

updateLabel()
clicks:GetPropertyChangedSignal("Value"):Connect(updateLabel)

local textOptions = {
	":)", ":3", ":o", "^_^",
	":D", ">:)", "xD", ":P",
	";)", ":'(", ">:(", ":|",
	"^o^", "O_O", "-_-", ":]",
	"UwU", "OwO", "T_T", ">w<",
	"^w^", "._.", ">.<", ":<",
	":>", ":V", ":^)",
	":c", "x_x", "D:",
	":-)", ":-(", ":-D", ":-P",
	":-O", "8)", "B)", "O:)",
	">:O", ":-/", ":-|",
	"')",
	":X", "D:<", "DX",
	"QQ", ":>", ":'D", ";-;",
	"._.", ":^) ", ">:D", ":S",
	">:|", "D8", ":B", "-.-",
	"')", "0_0", ">_>", "<_<",
	"-3-", "x3", "*_*", "*-*",
	"o_o", "(^_^)", "(>_<)", "(T_T)",
	"(^.^)", "(o_o)", "(._.)", "(^o^)",
	"(UwU)", "(OwO)", "(>w<)","v_v",
	";_;", ":'-(", ">:/",
}


local currentIndex = 1

-- Function to shuffle the text options randomly
local function shuffle(t)
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
end

shuffle(textOptions) -- Shuffle once at the start

button.MouseButton1Click:Connect(function()
	sound:Play()
	local now = tick()
	if now - lastClickTime >= clickInterval then
		lastClickTime = now
		Event:FireServer()

		button.Text = textOptions[currentIndex]
		currentIndex += 1

		if currentIndex > #textOptions then
			currentIndex = 1
			shuffle(textOptions) -- Shuffle again after each full cycle
		end
	end
end)

player:WaitForChild("Settings"):WaitForChild("SfxMuted"):GetPropertyChangedSignal("Value"):Connect(checkmuted)
checkmuted()
