local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local displayGui = script.Parent

local Abbreviate = require(ReplicatedStorage:WaitForChild("Abbreviate"))

-- Currencies (melons / rebirths HUD)
local currencies = player:WaitForChild("Currencies")
local corn = currencies:WaitForChild("Corn")
local rebirths = currencies:WaitForChild("Rebirths")

local frame = displayGui:FindFirstChild("Frame")
if frame then
	local melonsFrame = frame:FindFirstChild("MelonsFrame")
	local rebirthFrame = frame:FindFirstChild("RebirthFrame")

	local function updateMelonsLabel()
		if melonsFrame then
			local label = melonsFrame:FindFirstChild("TextLabel")
			if label then
				label.Text = Abbreviate(corn.Value)
			end
		end
	end

	local function updateRebirthsLabel()
		if rebirthFrame then
			local label = rebirthFrame:FindFirstChild("TextLabel")
			if label then
				label.Text = Abbreviate(rebirths.Value)
			end
		end
	end

	updateMelonsLabel()
	updateRebirthsLabel()
	corn.Changed:Connect(updateMelonsLabel)
	rebirths.Changed:Connect(updateRebirthsLabel)
end
