local Players = game:GetService("Players")
local player = Players.LocalPlayer
local events = player:WaitForChild("Events")
local timesrebirthed = events:WaitForChild("TimesRebirthed")
local island1unlocked = events:WaitForChild("Island1Bought")
local currencies = player:WaitForChild("Currencies")
local upgrades = player:WaitForChild("Upgrades")
local rebirths = currencies:WaitForChild("Rebirths")
local level = events:WaitForChild("Level")
local tier = upgrades:WaitForChild("Tier")
local timesascended = events:WaitForChild("TimesAscended")

local island2 = workspace:WaitForChild("Island2")
local upgtreefolder = island2:WaitForChild("UpgradeTree")

local upgt19 = upgrades:WaitForChild("UpgTree2_19")
local upgt20 = upgrades:WaitForChild("UpgTree2_20")
local upgt21 = upgrades:WaitForChild("UpgTree2_21")
local upgt22 = upgrades:WaitForChild("UpgTree2_22")
local upgt23 = upgrades:WaitForChild("UpgTree2_23")
local upgt24 = upgrades:WaitForChild("UpgTree2_24")
local upgt25 = upgrades:WaitForChild("UpgTree2_25")
local upgt26 = upgrades:WaitForChild("UpgTree2_26")
local upgt27 = upgrades:WaitForChild("UpgTree2_27")
local upgt29 = upgrades:WaitForChild("UpgTree2_29")

local upg21 = upgtreefolder:WaitForChild("Upg21")
local upg21main = upg21:WaitForChild("Main")
local upg21border = upg21:WaitForChild("Border")
local upg21wire = upg21:WaitForChild("Wire")
local upg21wireborder = upg21:WaitForChild("WireBorder")

local upg22 = upgtreefolder:WaitForChild("Upg22")
local upg22main = upg22:WaitForChild("Main")
local upg22border = upg22:WaitForChild("Border")
local upg22wire = upg22:WaitForChild("Wire")
local upg22wireborder = upg22:WaitForChild("WireBorder")

local upg23 = upgtreefolder:WaitForChild("Upg23")
local upg23main = upg23:WaitForChild("Main")
local upg23border = upg23:WaitForChild("Border")
local upg23wire = upg23:WaitForChild("Wire")
local upg23wireborder = upg23:WaitForChild("WireBorder")

local upg24 = upgtreefolder:WaitForChild("Upg24")
local upg24main = upg24:WaitForChild("Main")
local upg24border = upg24:WaitForChild("Border")
local upg24wire = upg24:WaitForChild("Wire")
local upg24wireborder = upg24:WaitForChild("WireBorder")

local upg25 = upgtreefolder:WaitForChild("Upg25")
local upg25main = upg25:WaitForChild("Main")
local upg25border = upg25:WaitForChild("Border")
local upg25wire = upg25:WaitForChild("Wire")
local upg25wireborder = upg25:WaitForChild("WireBorder")

local upg26 = upgtreefolder:WaitForChild("Upg26")
local upg26main = upg26:WaitForChild("Main")
local upg26border = upg26:WaitForChild("Border")
local upg26wire = upg26:WaitForChild("Wire")
local upg26wireborder = upg26:WaitForChild("WireBorder")

local upg27 = upgtreefolder:WaitForChild("Upg27")
local upg27main = upg27:WaitForChild("Main")
local upg27border = upg27:WaitForChild("Border")
local upg27wire1 = upg27:WaitForChild("Wire1")
local upg27wireborder1 = upg27:WaitForChild("WireBorder1")
local upg27wire2 = upg27:WaitForChild("Wire2")
local upg27wireborder2 = upg27:WaitForChild("WireBorder2")

local upg28 = upgtreefolder:WaitForChild("Upg28")
local upg28main = upg28:WaitForChild("Main")
local upg28border = upg28:WaitForChild("Border")
local upg28wire = upg28:WaitForChild("Wire")
local upg28wireborder = upg28:WaitForChild("WireBorder")

local upg29 = upgtreefolder:WaitForChild("Upg29")
local upg29main = upg29:WaitForChild("Main")
local upg29border = upg29:WaitForChild("Border")
local upg29wire = upg29:WaitForChild("Wire")
local upg29wireborder = upg29:WaitForChild("WireBorder")

local island3 = workspace:WaitForChild("Island3")
local farmborder = island3:WaitForChild("FarmBorder")
local farmplot = island3:WaitForChild("FarmPlot")
local upgradefolder = workspace:WaitForChild("Upgrades")
local seedfolder = upgradefolder:WaitForChild("SeedBoards")
local seedboard0 = seedfolder:WaitForChild("SeedBoard0")
local seedboard1 = seedfolder:WaitForChild("SeedBoard1")
local seedboard0back = seedfolder:WaitForChild("SeedBoard0Back")
local seedboard1back = seedfolder:WaitForChild("SeedBoard1Back")

local function checkupgtree21()
	if upgt20.Value == 0 then
		upg21main.Position = Vector3.new(0, -104.375, -43)
		upg21border.Position = Vector3.new(0, -104.5, -43)
		upg21wire.Position = Vector3.new(0, -104.5, -43)
		upg21wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg21main.Position = Vector3.new(-15.75, -4.5, -161.434)
		upg21border.Position = Vector3.new(-15.75, -4.5, -161.434)
		upg21wire.Position = Vector3.new(-21, -4.25, -161.434)
		upg21wireborder.Position = Vector3.new(-21, -4.625, -161.434)
	end
end

local function checkupgtree22()
	if upgt21.Value == 0 then
		upg22main.Position = Vector3.new(0, -104.375, -43)
		upg22border.Position = Vector3.new(0, -104.5, -43)
		upg22wire.Position = Vector3.new(0, -104.5, -43)
		upg22wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg22main.Position = Vector3.new(-5.25, -4.375, -157.184)
		upg22border.Position = Vector3.new(-5.25, -4.5, -157.184)
		upg22wire.Position = Vector3.new(-10.5, -4.25, -159.309)
		upg22wireborder.Position = Vector3.new(-10.5, -4.625, -159.309)
	end
end

local function checkupgtree23()
	if upgt19.Value == 0 then
		upg23main.Position = Vector3.new(0, -104.375, -43)
		upg23border.Position = Vector3.new(0, -104.5, -43)
		upg23wire.Position = Vector3.new(0, -104.5, -43)
		upg23wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg23main.Position = Vector3.new(15.75, -4.375, -161.434)
		upg23border.Position = Vector3.new(15.75, -4.5, -161.434)
		upg23wire.Position = Vector3.new(21, -4.25, -161.434)
		upg23wireborder.Position = Vector3.new(21, -4.625, -161.434)
	end
end

local function checkupgtree24()
	if upgt23.Value == 0 then
		upg24main.Position = Vector3.new(0, -104.375, -43)
		upg24border.Position = Vector3.new(0, -104.5, -43)
		upg24wire.Position = Vector3.new(0, -104.5, -43)
		upg24wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg24main.Position = Vector3.new(5.25, -4.375, -157.184)
		upg24border.Position = Vector3.new(5.25, -4.5, -157.184)
		upg24wire.Position = Vector3.new(10.5, -4.25, -159.309)
		upg24wireborder.Position = Vector3.new(10.5, -4.625, -159.309)
	end
end

local function checkupgtree25()
	if upgt22.Value == 0 then
		upg25main.Position = Vector3.new(0, -104.375, -43)
		upg25border.Position = Vector3.new(0, -104.5, -43)
		upg25wire.Position = Vector3.new(0, -104.5, -43)
		upg25wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg25main.Position = Vector3.new(-5.25, -4.375, -165.684)
		upg25border.Position = Vector3.new(-5.25, -4.5, -165.684)
		upg25wire.Position = Vector3.new(-5.25, -4.25, -161.434)
		upg25wireborder.Position = Vector3.new(-5.25, -4.625, -161.434)
	end
end

local function checkupgtree26()
	if upgt24.Value == 0 then
		upg26main.Position = Vector3.new(0, -104.375, -43)
		upg26border.Position = Vector3.new(0, -104.5, -43)
		upg26wire.Position = Vector3.new(0, -104.5, -43)
		upg26wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg26main.Position = Vector3.new(5.25, -4.375, -165.684)
		upg26border.Position = Vector3.new(5.25, -4.5, -165.684)
		upg26wire.Position = Vector3.new(5.25, -4.25, -161.434)
		upg26wireborder.Position = Vector3.new(5.25, -4.625, -161.434)
	end
end

local function checkupgtree27()
	if upgt25.Value == 0 or upgt26.Value == 0 then
		upg27main.Position = Vector3.new(0, -104.375, -43)
		upg27border.Position = Vector3.new(0, -104.5, -43)
		upg27wire1.Position = Vector3.new(0, -104.5, -43)
		upg27wireborder1.Position = Vector3.new(0, -104.5, -43)
		upg27wire2.Position = Vector3.new(0, -104.5, -43)
		upg27wireborder2.Position = Vector3.new(0, -104.5, -43)
	else
		upg27main.Position = Vector3.new(-0.125, -4.375, -178.199)
		upg27border.Position = Vector3.new(-0.125, -4.596, -178.199)
		upg27wire1.Position = Vector3.new(5.25, -4.25, -170.699)
		upg27wireborder1.Position = Vector3.new(5.25, -4.625, -170.699)
		upg27wire2.Position = Vector3.new(-5.25, -4.25, -170.699)
		upg27wireborder2.Position = Vector3.new(-5.25, -4.625, -170.699)
	end
end

local function checkupgtree28()
	if upgt20.Value == 0 then
		upg28main.Position = Vector3.new(0, -104.375, -43)
		upg28border.Position = Vector3.new(0, -104.5, -43)
		upg28wire.Position = Vector3.new(0, -104.5, -43)
		upg28wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg28main.Position = Vector3.new(-26.25, -4.375, -169.934)
		upg28border.Position = Vector3.new(-26.25, -4.5, -169.934)
		upg28wire.Position = Vector3.new(-26.25, -4.25, -165.684)
		upg28wireborder.Position = Vector3.new(-26.25, -4.625, -165.684)
	end
end

local function checkupgtree29()
	if upgt19.Value == 0 then
		upg29main.Position = Vector3.new(0, -104.375, -43)
		upg29border.Position = Vector3.new(0, -104.5, -43)
		upg29wire.Position = Vector3.new(0, -104.5, -43)
		upg29wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg29main.Position = Vector3.new(26.25, -4.375, -169.934)
		upg29border.Position = Vector3.new(26.25, -4.5, -169.934)
		upg29wire.Position = Vector3.new(26.25, -4.25, -165.684)
		upg29wireborder.Position = Vector3.new(26.25, -4.625, -165.684)
	end
end

local function checkisland3()
	if upgt27.Value >= 1 then
		island3.Position = Vector3.new(80, -12.875, -168)
		farmborder.Position = Vector3.new(78.375, -4.125, -168)
		farmplot.Position = Vector3.new(78.375, -4.375, -168)
		seedboard0.Position = Vector3.new(114.813, 6.25, -168.625)
		seedboard1.Position = Vector3.new(108.544, 1.125, -195.106)
		seedboard0back.Position = Vector3.new(115.313, 6.625, -168.625)
		seedboard1back.Position = Vector3.new(108.897, 1.625, -195.46)
	else
		island3.Position = Vector3.new(80, -192.875, -168)
		farmborder.Position = Vector3.new(78.375, -9994.125, -168)
		farmplot.Position = Vector3.new(78.375, -994.375, -168)
		seedboard0.Position = Vector3.new(78.375, -994.375, -168)
		seedboard1.Position = Vector3.new(78.375, -994.375, -168)
		seedboard0back.Position = Vector3.new(78.375, -994.375, -168)
		seedboard1back.Position = Vector3.new(78.375, -994.375, -168)
	end
end


checkupgtree21()
checkupgtree22()
checkupgtree23()
checkupgtree24()
checkupgtree25()
checkupgtree26()
checkupgtree27()
checkupgtree28()
checkupgtree29()

checkisland3()

upgt19:GetPropertyChangedSignal("Value"):Connect(checkupgtree23)
upgt19:GetPropertyChangedSignal("Value"):Connect(checkupgtree29)
upgt20:GetPropertyChangedSignal("Value"):Connect(checkupgtree21)
upgt20:GetPropertyChangedSignal("Value"):Connect(checkupgtree28)
upgt21:GetPropertyChangedSignal("Value"):Connect(checkupgtree22)
upgt22:GetPropertyChangedSignal("Value"):Connect(checkupgtree25)
upgt23:GetPropertyChangedSignal("Value"):Connect(checkupgtree24)
upgt24:GetPropertyChangedSignal("Value"):Connect(checkupgtree26)
upgt25:GetPropertyChangedSignal("Value"):Connect(checkupgtree27)
upgt26:GetPropertyChangedSignal("Value"):Connect(checkupgtree27)
upgt27:GetPropertyChangedSignal("Value"):Connect(checkisland3)
