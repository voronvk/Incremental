local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local upgrades = player:WaitForChild("Upgrades")

-- Wait for the autobuy prerequisite
local upg13 = upgrades:WaitForChild("UpgTree13")
local upgtree2_19 = upgrades:WaitForChild("UpgTree2_19")
local upgtree2_20 = upgrades:WaitForChild("UpgTree2_20")
local upgtree2_21 = upgrades:WaitForChild("UpgTree2_21")
local upgtree2_22 = upgrades:WaitForChild("UpgTree2_22")
local upgtree2_23 = upgrades:WaitForChild("UpgTree2_23")
local upgtree2_24 = upgrades:WaitForChild("UpgTree2_24")
local upgtree2_25 = upgrades:WaitForChild("UpgTree2_25")
local upgtree2_26 = upgrades:WaitForChild("UpgTree2_26")

-- Specify the upgrade numbers to autobuy
local upgradeNumbers1 = {1, 2, 4, 6}

-- Gather the events for the specified upgrades
local upgradeEvents1 = {}
for _, i in ipairs(upgradeNumbers1) do
	upgradeEvents1[i] = ReplicatedStorage:WaitForChild("UpgTree" .. i)
end



local upgradeNumbers2 = {3, 5, 7}

-- Gather the events for the specified upgrades
local upgradeEvents2 = {}
for _, i in ipairs(upgradeNumbers2) do
	upgradeEvents2[i] = ReplicatedStorage:WaitForChild("UpgTree" .. i)
end



local upgradeNumbers3 = {9, 11}

-- Gather the events for the specified upgrades
local upgradeEvents3 = {}
for _, i in ipairs(upgradeNumbers3) do
	upgradeEvents3[i] = ReplicatedStorage:WaitForChild("UpgTree" .. i)
end



local upgradeNumbers4 = {14, 16}

-- Gather the events for the specified upgrades
local upgradeEvents4 = {}
for _, i in ipairs(upgradeNumbers4) do
	upgradeEvents4[i] = ReplicatedStorage:WaitForChild("UpgTree" .. i)
end



local upgradeNumbers5 = {6, 8, 10}

-- Gather the events for the specified upgrades
local upgradeEvents5 = {}
for _, i in ipairs(upgradeNumbers5) do
	upgradeEvents5[i] = ReplicatedStorage:WaitForChild("UpgTree" .. i)
end



local upgradeNumbers6 = {12, 13}

-- Gather the events for the specified upgrades
local upgradeEvents6 = {}
for _, i in ipairs(upgradeNumbers6) do
	upgradeEvents6[i] = ReplicatedStorage:WaitForChild("UpgTree" .. i)
end



local upgradeNumbers7 = {18, 20}

-- Gather the events for the specified upgrades
local upgradeEvents7 = {}
for _, i in ipairs(upgradeNumbers7) do
	upgradeEvents7[i] = ReplicatedStorage:WaitForChild("UpgTree" .. i)
end



local upgradeNumbers8 = {15, 17, 19}

-- Gather the events for the specified upgrades
local upgradeEvents8 = {}
for _, i in ipairs(upgradeNumbers8) do
	upgradeEvents8[i] = ReplicatedStorage:WaitForChild("UpgTree" .. i)
end

-- Autobuy loop
task.spawn(function()
	while true do
		if upgtree2_19.Value == 1 then
			for _, event in pairs(upgradeEvents1) do
				event:FireServer()
			end
		end
		if upgtree2_20.Value == 1 then
			for _, event in pairs(upgradeEvents2) do
				event:FireServer()
			end
		end
		if upgtree2_21.Value == 1 then
			for _, event in pairs(upgradeEvents3) do
				event:FireServer()
			end
		end
		if upgtree2_22.Value == 1 and upg13.Value >= 1 then
			for _, event in pairs(upgradeEvents4) do
				event:FireServer()
			end
		end
		if upgtree2_23.Value == 1 then
			for _, event in pairs(upgradeEvents5) do
				event:FireServer()
			end
		end
		if upgtree2_24.Value == 1 then
			for _, event in pairs(upgradeEvents6) do
				event:FireServer()
			end
		end
		if upgtree2_25.Value == 1 and upg13.Value >= 1 then
			for _, event in pairs(upgradeEvents7) do
				event:FireServer()
			end
		end
		if upgtree2_26.Value == 1 and upg13.Value >= 1 then
			for _, event in pairs(upgradeEvents8) do
				event:FireServer()
			end
		end
		task.wait(0.5)
	end
end)
