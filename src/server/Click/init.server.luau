local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Event = ReplicatedStorage:WaitForChild("ClickEvent")

Event.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local events = player:FindFirstChild("Events")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not events or not upgrades then return end

	local groupMulti = 1
	local success, inGroup = pcall(function()
		return player:IsInGroup(117519888)
	end)
	if success and inGroup then
		groupMulti = 1.2
	end

	local upgtree9 = upgrades:FindFirstChild("UpgTree9")
	local upgtree12 = upgrades:FindFirstChild("UpgTree12")
	local upgtree13 = upgrades:FindFirstChild("UpgTree13")
	local upgtree18 = upgrades:FindFirstChild("UpgTree18")
	local tier = upgrades:FindFirstChild("Tier")
	local upgtree2_3 = upgrades:FindFirstChild("UpgTree2_3")
	local upgtree2_12 = upgrades:FindFirstChild("UpgTree2_12")
	local generators = upgrades:FindFirstChild("Generators")
	local clicks = currencies:FindFirstChild("Clicks")
	local Level = events:FindFirstChild("Level")
	if not (clicks and Level) then return end

	local mult = (upgtree9 and upgtree9.Value == 1) and 3 or 1
	local mult2 = (upgtree12 and upgtree12.Value == 1) and 3 or 1
	local mult3 = (upgtree13 and upgtree13.Value == 1) and 5 or 1
	local mult4 = (generators and generators.Value == 0) and 1 or (generators and generators.Value) or 1
	local mult5 = (tier and tier.Value >= 1) and 2 or 1
	local mult6 = (tier and tier.Value >= 2) and tier.Value or 1
	local manualmult = (upgtree18 and upgtree18.Value == 1) and 100 or 1
	local mult7 = (upgtree2_3 and upgtree2_3.Value >= 1) and 5 or 1
	local mult8 = (upgtree2_12 and upgtree2_12.Value == 1) and 0 or 1

	clicks.Value = clicks.Value + (Level.Value * mult * mult2 * mult3 * mult4 * manualmult * mult5 * mult6 * mult7 * mult8 * groupMulti)
end)

local AutoClickEvent = ReplicatedStorage:WaitForChild("AutoClickEvent")

AutoClickEvent.OnServerEvent:Connect(function(player)
	local currencies = player:FindFirstChild("Currencies")
	local events = player:FindFirstChild("Events")
	local upgrades = player:FindFirstChild("Upgrades")
	if not currencies or not events or not upgrades then return end

	local groupMulti = 1
	local success, inGroup = pcall(function()
		return player:IsInGroup(117519888)
	end)
	if success and inGroup then
		groupMulti = 1.2
	end

	local upgtree9 = upgrades:FindFirstChild("UpgTree9")
	local upgtree12 = upgrades:FindFirstChild("UpgTree12")
	local upgtree13 = upgrades:FindFirstChild("UpgTree13")
	local upgtree18 = upgrades:FindFirstChild("UpgTree18")
	local tier = upgrades:FindFirstChild("Tier")
	local upgtree2_3 = upgrades:FindFirstChild("UpgTree2_3")
	local upgtree2_11 = upgrades:FindFirstChild("UpgTree2_11")
	local upgtree2_12 = upgrades:FindFirstChild("UpgTree2_12")
	local generators = upgrades:FindFirstChild("Generators")
	local clicks = currencies:FindFirstChild("Clicks")
	local Level = events:FindFirstChild("Level")
	if not (clicks and Level) then return end

	local mult = (upgtree9 and upgtree9.Value == 1) and 3 or 1
	local mult2 = (upgtree12 and upgtree12.Value == 1) and 3 or 1
	local mult3 = (upgtree13 and upgtree13.Value == 1) and 5 or 1
	local mult4 = (generators and generators.Value == 0) and 1 or (generators and generators.Value) or 1
	local mult5 = (tier and tier.Value >= 1) and 2 or 1
	local mult6 = (tier and tier.Value >= 2) and tier.Value or 1
	local manualmult = (upgtree18 and upgtree2_11 and upgtree18.Value == 1 and upgtree2_11.Value == 1) and 100 or 1
	local mult7 = (upgtree2_3 and upgtree2_3.Value >= 1) and 5 or 1
	local mult8 = (upgtree2_12 and upgtree2_12.Value == 1) and 10 or 1

	clicks.Value = clicks.Value + (Level.Value * mult * mult2 * mult3 * mult4 * mult5 * mult6 * manualmult * mult7 * mult8 * groupMulti)
end)
