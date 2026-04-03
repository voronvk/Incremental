local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local gui = script.Parent

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

local currencies = player:WaitForChild("Currencies")
local corn = currencies:WaitForChild("Corn")
local gold = currencies:WaitForChild("Gold")
local leaderstats = player:WaitForChild("leaderstats")
local tapsStat = leaderstats:WaitForChild("Taps")

local leftBottom = gui:FindFirstChild("LeftBottom")
if not leftBottom then
	return
end

local melonsLabel = leftBottom:FindFirstChild("MelonsLabel")
local tapsLabel = leftBottom:FindFirstChild("TapsLabel")
local goldLabel = leftBottom:FindFirstChild("GoldLabel")

local function updateMelons()
	if melonsLabel and (melonsLabel:IsA("TextLabel") or melonsLabel:IsA("TextButton")) then
		melonsLabel.Text = ("%s Melons"):format(Abbreviate(corn.Value))
	end
end

local function updateTaps()
	if tapsLabel and (tapsLabel:IsA("TextLabel") or tapsLabel:IsA("TextButton")) then
		tapsLabel.Text = ("%s Taps"):format(Abbreviate(tapsStat.Value))
	end
end

local function updateGold()
	if goldLabel and (goldLabel:IsA("TextLabel") or goldLabel:IsA("TextButton")) then
		goldLabel.Text = ("%s Gold"):format(Abbreviate(gold.Value))
	end
end

updateMelons()
updateTaps()
updateGold()
corn.Changed:Connect(updateMelons)
tapsStat.Changed:Connect(updateTaps)
gold.Changed:Connect(updateGold)
