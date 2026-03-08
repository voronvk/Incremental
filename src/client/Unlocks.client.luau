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

local upgradefolder = workspace:WaitForChild("Upgrades")
local part = upgradefolder:WaitForChild("RebirthBlockPart")
local islandfolder = upgradefolder:WaitForChild("IslandExpand")
local islandboard1 = islandfolder:WaitForChild("IslandBoard1")
local islandboard1image = islandboard1:WaitForChild("LevelBoard")
local islandblock1 = islandfolder:WaitForChild("IslandBlock1")
local upgtreefolder = workspace:WaitForChild("Island1"):WaitForChild("UpgradeTree")
local clickfolder = upgradefolder:WaitForChild("ClickUpgrades")
local clickboard0 = clickfolder:WaitForChild("ClickBoard0")
local clickboard1 = clickfolder:WaitForChild("ClickBoard1")
local levelboard1 = clickboard1:WaitForChild("LevelBoard")
local clickboard2 = clickfolder:WaitForChild("ClickBoard2")
local levelboard2 = clickboard2:WaitForChild("LevelBoard")
local clickboard3 = clickfolder:WaitForChild("ClickBoard3")
local levelboard3 = clickboard3:WaitForChild("LevelBoard")
local clickboard0top = clickfolder:WaitForChild("ClickBoard0Top")
local clickupgradestop = clickfolder:WaitForChild("ClickUpgradesTop")
local clickboard0back = clickfolder:WaitForChild("ClickBoard0Back")
local clickupgradesback = clickfolder:WaitForChild("ClickUpgradesBack")
local clickblock1 = clickfolder:WaitForChild("ClickBlock1")
local clickblock2 = clickfolder:WaitForChild("ClickBlock2")

local generatorfolder = upgradefolder:WaitForChild("GeneratorUpgrades")
local generatorboard0 = generatorfolder:WaitForChild("GeneratorBoard0")
local generatorboard0back = generatorfolder:WaitForChild("GeneratorBoard0Back")
local generatorboard0top = generatorfolder:WaitForChild("GeneratorBoard0Top")
local energyboard1 = generatorfolder:WaitForChild("EnergyBoard1")
local elevelboard1 = energyboard1:WaitForChild("LevelBoard")
local energyboard2 = generatorfolder:WaitForChild("EnergyBoard2")
local elevelboard2 = energyboard2:WaitForChild("LevelBoard")
local energyboard3 = generatorfolder:WaitForChild("EnergyBoard3")
local elevelboard3 = energyboard3:WaitForChild("LevelBoard")
local energyupgradesback = generatorfolder:WaitForChild("EnergyUpgradesBack")
local energyupgradestop = generatorfolder:WaitForChild("EnergyUpgradesTop")
local energyupgradesbackextended = generatorfolder:WaitForChild("EnergyUpgradesBackExtended")
local energyupgradestopextended = generatorfolder:WaitForChild("EnergyUpgradesTopExtended")

local tierfolder = upgradefolder:WaitForChild("TierBoards")
local tierboard0 = tierfolder:WaitForChild("TierBoard0")
local tierlevelboard0 = tierboard0:WaitForChild("LevelBoard")
local tierboard1 = tierfolder:WaitForChild("TierBoard1")
local tierupgradesback = tierfolder:WaitForChild("TierUpgradesBack")

local gemfolder = upgradefolder:WaitForChild("GemUpgrades")
local dailyblock = gemfolder:WaitForChild("DailyBlock")

local island2 = workspace:WaitForChild("Island2")

--local jeep = workspace:WaitForChild("Jeep")

local upgt1 = upgrades:WaitForChild("UpgTree1")
local upgt2 = upgrades:WaitForChild("UpgTree2")
local upgt3 = upgrades:WaitForChild("UpgTree3")
local upgt4 = upgrades:WaitForChild("UpgTree4")
local upgt5 = upgrades:WaitForChild("UpgTree5")
local upgt6 = upgrades:WaitForChild("UpgTree6")
local upgt7 = upgrades:WaitForChild("UpgTree7")
local upgt8 = upgrades:WaitForChild("UpgTree8")
local upgt9 = upgrades:WaitForChild("UpgTree9")
local upgt10 = upgrades:WaitForChild("UpgTree10")
local upgt11 = upgrades:WaitForChild("UpgTree11")
local upgt12 = upgrades:WaitForChild("UpgTree12")
local upgt13 = upgrades:WaitForChild("UpgTree13")
local upgt14 = upgrades:WaitForChild("UpgTree14")
local upgt15 = upgrades:WaitForChild("UpgTree15")
local upgt16 = upgrades:WaitForChild("UpgTree16")
local upgt17 = upgrades:WaitForChild("UpgTree17")
local upgt18 = upgrades:WaitForChild("UpgTree18")
local upgt19 = upgrades:WaitForChild("UpgTree19")
local upgt20 = upgrades:WaitForChild("UpgTree20")

local upgt2_7 = upgrades:WaitForChild("UpgTree2_7")

local upg1 = upgtreefolder:WaitForChild("Upg1")
local upg1main = upg1:WaitForChild("Main")
local upg1border = upg1:WaitForChild("Border")

local upg2 = upgtreefolder:WaitForChild("Upg2")
local upg2main = upg2:WaitForChild("Main")
local upg2border = upg2:WaitForChild("Border")
local upg2wire = upg2:WaitForChild("Wire")
local upg2wireborder = upg2:WaitForChild("WireBorder")

local upg3 = upgtreefolder:WaitForChild("Upg3")
local upg3main = upg3:WaitForChild("Main")
local upg3border = upg3:WaitForChild("Border")
local upg3wire = upg3:WaitForChild("Wire")
local upg3wireborder = upg3:WaitForChild("WireBorder")

local upg4 = upgtreefolder:WaitForChild("Upg4")
local upg4main = upg4:WaitForChild("Main")
local upg4border = upg4:WaitForChild("Border")
local upg4wire = upg4:WaitForChild("Wire")
local upg4wireborder = upg4:WaitForChild("WireBorder")

local upg5 = upgtreefolder:WaitForChild("Upg5")
local upg5main = upg5:WaitForChild("Main")
local upg5border = upg5:WaitForChild("Border")
local upg5wire = upg5:WaitForChild("Wire")
local upg5wireborder = upg5:WaitForChild("WireBorder")

local upg6 = upgtreefolder:WaitForChild("Upg6")
local upg6main = upg6:WaitForChild("Main")
local upg6border = upg6:WaitForChild("Border")
local upg6wire = upg6:WaitForChild("Wire")
local upg6wireborder = upg6:WaitForChild("WireBorder")

local upg7 = upgtreefolder:WaitForChild("Upg7")
local upg7main = upg7:WaitForChild("Main")
local upg7border = upg7:WaitForChild("Border")
local upg7wire = upg7:WaitForChild("Wire")
local upg7wireborder = upg7:WaitForChild("WireBorder")

local upg8 = upgtreefolder:WaitForChild("Upg8")
local upg8main = upg8:WaitForChild("Main")
local upg8border = upg8:WaitForChild("Border")
local upg8wire = upg8:WaitForChild("Wire")
local upg8wireborder = upg8:WaitForChild("WireBorder")

local upg9 = upgtreefolder:WaitForChild("Upg9")
local upg9main = upg9:WaitForChild("Main")
local upg9border = upg9:WaitForChild("Border")
local upg9wire = upg9:WaitForChild("Wire")
local upg9wireborder = upg9:WaitForChild("WireBorder")

local upg10 = upgtreefolder:WaitForChild("Upg10")
local upg10main = upg10:WaitForChild("Main")
local upg10border = upg10:WaitForChild("Border")
local upg10wire = upg10:WaitForChild("Wire")
local upg10wireborder = upg10:WaitForChild("WireBorder")

local upg11 = upgtreefolder:WaitForChild("Upg11")
local upg11main = upg11:WaitForChild("Main")
local upg11border = upg11:WaitForChild("Border")
local upg11wire = upg11:WaitForChild("Wire")
local upg11wireborder = upg11:WaitForChild("WireBorder")

local upg12 = upgtreefolder:WaitForChild("Upg12")
local upg12main = upg12:WaitForChild("Main")
local upg12border = upg12:WaitForChild("Border")
local upg12wire = upg12:WaitForChild("Wire")
local upg12wireborder = upg12:WaitForChild("WireBorder")

local upg13 = upgtreefolder:WaitForChild("Upg13")
local upg13main = upg13:WaitForChild("Main")
local upg13border = upg13:WaitForChild("Border")
local upg13wire = upg13:WaitForChild("Wire")
local upg13wireborder = upg13:WaitForChild("WireBorder")

local upg14 = upgtreefolder:WaitForChild("Upg14")
local upg14main = upg14:WaitForChild("Main")
local upg14border = upg14:WaitForChild("Border")
local upg14wire = upg14:WaitForChild("Wire")
local upg14wireborder = upg14:WaitForChild("WireBorder")

local upg15 = upgtreefolder:WaitForChild("Upg15")
local upg15main = upg15:WaitForChild("Main")
local upg15border = upg15:WaitForChild("Border")
local upg15wire = upg15:WaitForChild("Wire")
local upg15wireborder = upg15:WaitForChild("WireBorder")

local upg16 = upgtreefolder:WaitForChild("Upg16")
local upg16main = upg16:WaitForChild("Main")
local upg16border = upg16:WaitForChild("Border")
local upg16wire = upg16:WaitForChild("Wire")
local upg16wireborder = upg16:WaitForChild("WireBorder")

local upg17 = upgtreefolder:WaitForChild("Upg17")
local upg17main = upg17:WaitForChild("Main")
local upg17border = upg17:WaitForChild("Border")
local upg17wire = upg17:WaitForChild("Wire")
local upg17wireborder = upg17:WaitForChild("WireBorder")

local upg18 = upgtreefolder:WaitForChild("Upg18")
local upg18main = upg18:WaitForChild("Main")
local upg18border = upg18:WaitForChild("Border")
local upg18wire = upg18:WaitForChild("Wire")
local upg18wireborder = upg18:WaitForChild("WireBorder")

local upg19 = upgtreefolder:WaitForChild("Upg19")
local upg19main = upg19:WaitForChild("Main")
local upg19border = upg19:WaitForChild("Border")
local upg19wire = upg19:WaitForChild("Wire")
local upg19wireborder = upg19:WaitForChild("WireBorder")

local upg20 = upgtreefolder:WaitForChild("Upg20")
local upg20main = upg20:WaitForChild("Main")
local upg20border = upg20:WaitForChild("Border")
local upg20wire = upg20:WaitForChild("Wire")
local upg20wireborder = upg20:WaitForChild("WireBorder")

local function checkifrebirthed()
	if timesrebirthed.Value >= 1 then
		part.Position = Vector3.new(-35.25, -104.125, 3)
	else
		part.Position = Vector3.new(-35, 6.125, 3)
	end
end

local function checkifisland1unlocked()
	if island1unlocked.Value >= 1 then
		workspace:WaitForChild("Island1").Position = Vector3.new(-0, -12.875, -80)
	else
		workspace:WaitForChild("Island1").Position = Vector3.new(-0, -112.875, -80)
	end
end

local function checkifisland2unlocked()
	if tier.Value >= 6 then
		island2.Position = Vector3.new(-0, -12.875, -164)
	else
		island2.Position = Vector3.new(-0, -112.875, -80)
	end
end

local function checkclickboard()
	if island1unlocked.Value >= 1 then
		clickboard0.Position = Vector3.new(35.25, 4.125, -90)
		clickboard1.Position = Vector3.new(35.25, 3.125, -75)
		levelboard1.Position = Vector3.new(35.25, 12.125, -75)
		clickboard2.Position = Vector3.new(35.25, 3.125, -63)
		levelboard2.Position = Vector3.new(35.25, 12.125, -63)
		clickboard3.Position = Vector3.new(35.25, 3.125, -51)
		levelboard3.Position = Vector3.new(35.25, 12.125, -51)
		clickboard0top.Position = Vector3.new(35.25, 15.125, -90)
		clickboard0back.Position = Vector3.new(35.75, 6.625, -90)
		clickupgradestop.Position = Vector3.new(35.25, 15.125, -63)
		clickupgradesback.Position = Vector3.new(35.75, 6.625, -63)

		if level.Value <= 21 then
			clickblock1.Position = Vector3.new(34.875, 6.125, -90)
			clickblock2.Position = Vector3.new(34.875, 6.125, -63)
		else
			clickblock1.Position = Vector3.new(-0, -112.875, -80)
			clickblock2.Position = Vector3.new(-0, -112.875, -80)
		end
	else
		clickboard0.Position = Vector3.new(-0, -112.875, -80)
		clickboard1.Position = Vector3.new(-0, -112.875, -80)
		levelboard1.Position = Vector3.new(-0, -112.875, -80)
		clickboard2.Position = Vector3.new(-0, -112.875, -80)
		levelboard2.Position = Vector3.new(-0, -112.875, -80)
		clickboard3.Position = Vector3.new(-0, -112.875, -80)
		levelboard3.Position = Vector3.new(-0, -112.875, -80)
		clickboard0top.Position = Vector3.new(-0, -112.875, -80)
		clickboard0back.Position = Vector3.new(-0, -112.875, -80)
		clickupgradestop.Position = Vector3.new(-0, -112.875, -80)
		clickupgradesback.Position = Vector3.new(-0, -112.875, -80)
		clickblock1.Position = Vector3.new(-0, -112.875, -80)
		clickblock2.Position = Vector3.new(-0, -112.875, -80)
		clickblock1.Position = Vector3.new(-0, -112.875, -80)
		clickblock2.Position = Vector3.new(-0, -112.875, -80)
	end
end

local function checkgenerator()
	if upgt11.Value >= 1 or upgt2_7.Value >= 1 then
		generatorboard0.Position = Vector3.new(-35.5, 4.625, -57.125)
		generatorboard0back.Position = Vector3.new(-36, 6.625, -57.125)
		generatorboard0top.Position = Vector3.new(-35.5, 15.625, -57.125)
		energyboard1.Position = Vector3.new(-35.5, 3.125, -78.125)
		elevelboard1.Position = Vector3.new(-35.5, 12.125, -78.125)
		energyboard2.Position = Vector3.new(-35.5, 3.125, -90.125)
		elevelboard2.Position = Vector3.new(-35.5, 12.125, -90.125)
		energyboard3.Position = Vector3.new(0, -112.875, -80)
		elevelboard3.Position = Vector3.new(0, -112.875, -80)
		energyupgradesback.Position = Vector3.new(-36, 6.625, -84.125)
		energyupgradestop.Position = Vector3.new(-35.5, 15.125, -84.125)
		energyupgradesbackextended.Position = Vector3.new(0, -112.875, -80)
		energyupgradestopextended.Position = Vector3.new(0, -112.875, -80)
		if upgt19.Value >= 1 or upgt2_7.Value >= 1 then
			energyupgradesback.Position = Vector3.new(0, -112.875, -80)
			energyupgradestop.Position = Vector3.new(0, -112.875, -80)
			energyupgradesbackextended.Position = Vector3.new(-36, 6.625, -90.125)
			energyupgradestopextended.Position = Vector3.new(-35.5, 15.125, -90.125)
			energyboard3.Position = Vector3.new(-35.5, 3.125, -102.125)
			elevelboard3.Position = Vector3.new(-35.5, 12.125, -102.125)
		end
	else
		generatorboard0.Position = Vector3.new(0, -112.875, -80)
		generatorboard0back.Position = Vector3.new(0, -112.875, -80)
		generatorboard0top.Position = Vector3.new(0, -112.875, -80)
		energyboard1.Position = Vector3.new(0, -112.875, -80)
		elevelboard1.Position = Vector3.new(0, -112.875, -80)
		energyboard2.Position = Vector3.new(0, -112.875, -80)
		elevelboard2.Position = Vector3.new(0, -112.875, -80)
		energyboard3.Position = Vector3.new(0, -112.875, -80)
		elevelboard3.Position = Vector3.new(0, -112.875, -80)
		energyupgradesback.Position = Vector3.new(0, -112.875, -80)
		energyupgradestop.Position = Vector3.new(0, -112.875, -80)
		energyupgradesbackextended.Position = Vector3.new(0, -112.875, -80)
		energyupgradestopextended.Position = Vector3.new(0, -112.875, -80)
	end
end

local function checkislandboard1()
	if island1unlocked.Value == 0 then
		if level.Value >= 16 then
			islandblock1.Position = Vector3.new(-2, -91.875, -38.5)
		else
			islandblock1.Position = Vector3.new(-0.125, 4.438, -38.5)
		end
		islandboard1.Position = Vector3.new(-0.125, 3.125, -38.5)
		islandboard1image.Position = Vector3.new(-0.125, 8.125, -38.5)
	else
		islandboard1.Position = Vector3.new(-2, -96.875, -38.5)
		islandboard1image.Position = Vector3.new(-2, -91.875, -38.5)
		islandblock1.Position = Vector3.new(-2, -91.875, -38.5)
	end
end

local function checktierboard()
	if upgt20.Value >= 1 and tier.Value <= 5 or tier.Value >= 1 and tier.Value <= 5 then
		tierboard0.Position = Vector3.new(-12, 5.125, -114.969)
		tierboard0.Orientation = Vector3.new(0, 180, 0)
		tierlevelboard0.Position = Vector3.new(-12, 16.125, -114.969)
		tierlevelboard0.Orientation = Vector3.new(0, 180, 0)
		tierboard1.Position = Vector3.new(6, 6.125, -114.969)
		tierboard1.Orientation = Vector3.new(0, 180, 0)
		tierupgradesback.Position = Vector3.new(-0, 6.625, -115.469)
		tierupgradesback.Orientation = Vector3.new(0, 180, 0)
	elseif tier.Value >= 6 then
		tierboard0.Position = Vector3.new(35.25, 5.125, -131)
		tierboard0.Orientation = Vector3.new(0, 90, 0)
		tierlevelboard0.Position = Vector3.new(35.25, 16.125, -131)
		tierlevelboard0.Orientation = Vector3.new(0, 90, 0)
		tierboard1.Position = Vector3.new(35.25, 6.125, -113)
		tierboard1.Orientation = Vector3.new(0, 90, 0)
		tierupgradesback.Position = Vector3.new(35.75, 6.625, -119)
		tierupgradesback.Orientation = Vector3.new(0, 90, 0)
	else
		tierboard0.Position = Vector3.new(0, -112.875, -112.5)
		tierboard0.Orientation = Vector3.new(0, 180, 0)
		tierlevelboard0.Position = Vector3.new(0, -112.375, -112.5)
		tierlevelboard0.Orientation = Vector3.new(0, 180, 0)
		tierboard1.Position = Vector3.new(0, -112.375, -112.5)
		tierboard1.Orientation = Vector3.new(0, 180, 0)
		tierupgradesback.Position = Vector3.new(0, -112.375, -112.5)
		tierupgradesback.Orientation = Vector3.new(0, 180, 0)
	end
end

local function checkdaily()
	if level.Value >= 5 then
		dailyblock.Position = Vector3.new(2, -96.875, -140.5)
	else
		dailyblock.Position = Vector3.new(27.125, 4.125, 35.125)
	end
end

local function checkupgtree1()
	if island1unlocked.Value == 0 then
		upg1main.Position = Vector3.new(0, -104.375, -43)
		upg1border.Position = Vector3.new(0, -104.5, -43)
	else
		upg1main.Position = Vector3.new(0, -4.375, -43)
		upg1border.Position = Vector3.new(0, -4.5, -43)
	end
end

local function checkupgtree2()
	if upgt1.Value == 0 then
		upg2main.Position = Vector3.new(0, -104.375, -43)
		upg2border.Position = Vector3.new(0, -104.5, -43)
		upg2wire.Position = Vector3.new(0, -104.5, -43)
		upg2wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg2main.Position = Vector3.new(0, -4.375, -51.5)
		upg2border.Position = Vector3.new(0, -4.5, -51.5)
		upg2wire.Position = Vector3.new(0, -4.25, -47.25)
		upg2wireborder.Position = Vector3.new(0, -4.625, -47.25)
	end
end

local function checkupgtree3()
	if upgt2.Value == 0 then
		upg3main.Position = Vector3.new(0, -104.375, -43)
		upg3border.Position = Vector3.new(0, -104.5, -43)
		upg3wire.Position = Vector3.new(0, -104.5, -43)
		upg3wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg3main.Position = Vector3.new(5.25, -4.375, -60)
		upg3border.Position = Vector3.new(5.25, -4.5, -60)
		upg3wire.Position = Vector3.new(2.625, -4.25, -55.75)
		upg3wireborder.Position = Vector3.new(2.625, -4.625, -55.75)
	end
end

local function checkupgtree4()
	if upgt2.Value == 0 then
		upg4main.Position = Vector3.new(0, -104.375, -43)
		upg4border.Position = Vector3.new(0, -104.5, -43)
		upg4wire.Position = Vector3.new(0, -104.5, -43)
		upg4wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg4main.Position = Vector3.new(-5.25, -4.375, -60)
		upg4border.Position = Vector3.new(-5.25, -4.5, -60)
		upg4wire.Position = Vector3.new(-2.625, -4.25, -55.75)
		upg4wireborder.Position = Vector3.new(-2.625, -4.625, -55.75)
	end
end

local function checkupgtree5()
	if upgt3.Value == 0 then
		upg5main.Position = Vector3.new(0, -104.375, -43)
		upg5border.Position = Vector3.new(0, -104.5, -43)
		upg5wire.Position = Vector3.new(0, -104.5, -43)
		upg5wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg5main.Position = Vector3.new(10.5, -4.375, -68.5)
		upg5border.Position = Vector3.new(10.5, -4.5, -68.5)
		upg5wire.Position = Vector3.new(7.875, -4.25, -64.25)
		upg5wireborder.Position = Vector3.new(7.875, -4.625, -64.25)
	end
end

local function checkupgtree6()
	if upgt4.Value == 0 then
		upg6main.Position = Vector3.new(0, -104.375, -43)
		upg6border.Position = Vector3.new(0, -104.5, -43)
		upg6wire.Position = Vector3.new(0, -104.5, -43)
		upg6wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg6main.Position = Vector3.new(-10.5, -4.375, -68.5)
		upg6border.Position = Vector3.new(-10.5, -4.5, -68.5)
		upg6wire.Position = Vector3.new(-7.875, -4.25, -64.25)
		upg6wireborder.Position = Vector3.new(-7.875, -4.625, -64.25)
	end
end

local function checkupgtree7()
	if upgt5.Value == 0 then
		upg7main.Position = Vector3.new(0, -104.375, -43)
		upg7border.Position = Vector3.new(0, -104.5, -43)
		upg7wire.Position = Vector3.new(0, -104.5, -43)
		upg7wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg7main.Position = Vector3.new(10.5, -4.375, -77)
		upg7border.Position = Vector3.new(10.5, -4.5, -77)
		upg7wire.Position = Vector3.new(10.5, -4.25, -72.75)
		upg7wireborder.Position = Vector3.new(10.5, -4.625, -72.75)
	end
end

local function checkupgtree8()
	if upgt6.Value == 0 then
		upg8main.Position = Vector3.new(0, -104.375, -43)
		upg8border.Position = Vector3.new(0, -104.5, -43)
		upg8wire.Position = Vector3.new(0, -104.5, -43)
		upg8wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg8main.Position = Vector3.new(-10.5, -4.375, -77)
		upg8border.Position = Vector3.new(-10.5, -4.5, -77)
		upg8wire.Position = Vector3.new(-10.5, -4.25, -72.75)
		upg8wireborder.Position = Vector3.new(-10.5, -4.625, -72.75)
	end
end

local function checkupgtree9()
	if upgt7.Value == 0 then
		upg9main.Position = Vector3.new(0, -104.375, -43)
		upg9border.Position = Vector3.new(0, -104.5, -43)
		upg9wire.Position = Vector3.new(0, -104.5, -43)
		upg9wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg9main.Position = Vector3.new(0, -4.375, -77)
		upg9border.Position = Vector3.new(0, -4.5, -77)
		upg9wire.Position = Vector3.new(5.25, -4.25, -77)
		upg9wireborder.Position = Vector3.new(5.25, -4.625, -77)
	end
end

local function checkupgtree10()
	if upgt8.Value == 0 then
		upg10main.Position = Vector3.new(0, -104.375, -43)
		upg10border.Position = Vector3.new(0, -104.5, -43)
		upg10wire.Position = Vector3.new(0, -104.5, -43)
		upg10wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg10main.Position = Vector3.new(-5.25, -4.375, -85.5)
		upg10border.Position = Vector3.new(-5.25, -4.5, -85.5)
		upg10wire.Position = Vector3.new(-7.875, -4.25, -81.25)
		upg10wireborder.Position = Vector3.new(-7.875, -4.625, -81.25)
	end
end

local function checkupgtree11()
	if upgt9.Value == 0 then
		upg11main.Position = Vector3.new(0, -104.375, -43)
		upg11border.Position = Vector3.new(0, -104.5, -43)
		upg11wire.Position = Vector3.new(0, -104.5, -43)
		upg11wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg11main.Position = Vector3.new(0, -4.375, -68.5)
		upg11border.Position = Vector3.new(0, -4.5, -68.5)
		upg11wire.Position = Vector3.new(0, -4.25, -72.75)
		upg11wireborder.Position = Vector3.new(0, -4.625, -72.75)
	end
end

local function checkupgtree12()
	if upgt10.Value == 0 then
		upg12main.Position = Vector3.new(0, -104.375, -43)
		upg12border.Position = Vector3.new(0, -104.5, -43)
		upg12wire.Position = Vector3.new(0, -104.5, -43)
		upg12wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg12main.Position = Vector3.new(5.25, -4.375, -85.5)
		upg12border.Position = Vector3.new(5.25, -4.5, -85.5)
		upg12wire.Position = Vector3.new(0, -4.25, -85.5)
		upg12wireborder.Position = Vector3.new(0, -4.625, -85.5)
	end
end

local function checkupgtree13()
	if upgt12.Value == 0 then
		upg13main.Position = Vector3.new(0, -104.375, -43)
		upg13border.Position = Vector3.new(0, -104.5, -43)
		upg13wire.Position = Vector3.new(0, -104.5, -43)
		upg13wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg13main.Position = Vector3.new(0, -4.375, -94)
		upg13border.Position = Vector3.new(0, -4.5, -94)
		upg13wire.Position = Vector3.new(2.625, -4.25, -89.75)
		upg13wireborder.Position = Vector3.new(2.625, -4.625, -89.75)
	end
end

local function checkupgtree14()
	if upgt13.Value == 0 then
		upg14main.Position = Vector3.new(0, -104.375, -43)
		upg14border.Position = Vector3.new(0, -104.5, -43)
		upg14wire.Position = Vector3.new(0, -104.5, -43)
		upg14wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg14main.Position = Vector3.new(10.5, -4.375, -51.5)
		upg14border.Position = Vector3.new(10.5, -4.5, -51.5)
		upg14wire.Position = Vector3.new(5.25, -4.25, -51.5)
		upg14wireborder.Position = Vector3.new(5.25, -4.625, -51.5)
	end
end

local function checkupgtree15()
	if upgt13.Value == 0 then
		upg15main.Position = Vector3.new(0, -104.375, -43)
		upg15border.Position = Vector3.new(0, -104.5, -43)
		upg15wire.Position = Vector3.new(0, -104.5, -43)
		upg15wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg15main.Position = Vector3.new(-10.5, -4.375, -51.5)
		upg15border.Position = Vector3.new(-10.5, -4.5, -51.5)
		upg15wire.Position = Vector3.new(-5.25, -4.25, -51.5)
		upg15wireborder.Position = Vector3.new(-5.25, -4.625, -51.5)
	end
end

local function checkupgtree16()
	if upgt14.Value == 0 then
		upg16main.Position = Vector3.new(0, -104.375, -43)
		upg16border.Position = Vector3.new(0, -104.5, -43)
		upg16wire.Position = Vector3.new(0, -104.5, -43)
		upg16wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg16main.Position = Vector3.new(15.75, -4.375, -60)
		upg16border.Position = Vector3.new(15.75, -4.5, -60)
		upg16wire.Position = Vector3.new(13.125, -4.25, -55.75)
		upg16wireborder.Position = Vector3.new(13.125, -4.625, -55.75)
	end
end

local function checkupgtree17()
	if upgt15.Value == 0 then
		upg17main.Position = Vector3.new(0, -104.375, -43)
		upg17border.Position = Vector3.new(0, -104.5, -43)
		upg17wire.Position = Vector3.new(0, -104.5, -43)
		upg17wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg17main.Position = Vector3.new(-15.75, -4.375, -60)
		upg17border.Position = Vector3.new(-15.75, -4.5, -60)
		upg17wire.Position = Vector3.new(-13.125, -4.25, -55.75)
		upg17wireborder.Position = Vector3.new(-13.125, -4.625, -55.75)
	end
end

local function checkupgtree18()
	if upgt16.Value == 0 then
		upg18main.Position = Vector3.new(0, -104.375, -43)
		upg18border.Position = Vector3.new(0, -104.5, -43)
		upg18wire.Position = Vector3.new(0, -104.5, -43)
		upg18wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg18main.Position = Vector3.new(21, -4.375, -68.5)
		upg18border.Position = Vector3.new(21, -4.5, -68.5)
		upg18wire.Position = Vector3.new(18.375, -4.25, -64.25)
		upg18wireborder.Position = Vector3.new(18.375, -4.625, -64.25)
	end
end

local function checkupgtree19()
	if upgt17.Value == 0 then
		upg19main.Position = Vector3.new(0, -104.375, -43)
		upg19border.Position = Vector3.new(0, -104.5, -43)
		upg19wire.Position = Vector3.new(0, -104.5, -43)
		upg19wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg19main.Position = Vector3.new(-21, -4.375, -68.5)
		upg19border.Position = Vector3.new(-21, -4.5, -68.5)
		upg19wire.Position = Vector3.new(-18.375, -4.25, -64.25)
		upg19wireborder.Position = Vector3.new(-18.375, -4.625, -64.25)
	end
end

local function checkupgtree20()
	if upgt18.Value == 0 then
		upg20main.Position = Vector3.new(0, -104.375, -43)
		upg20border.Position = Vector3.new(0, -104.5, -43)
		upg20wire.Position = Vector3.new(0, -104.5, -43)
		upg20wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg20main.Position = Vector3.new(21, -4.375, -77)
		upg20border.Position = Vector3.new(21, -4.5, -77)
		upg20wire.Position = Vector3.new(21, -4.25, -72.75)
		upg20wireborder.Position = Vector3.new(21, -4.625, -72.75)
	end
end

-- Run once on startup
checkifrebirthed()
checkifisland1unlocked()
checkifisland2unlocked()
checkislandboard1()
checkclickboard()
checkgenerator()
checktierboard()
checkdaily()
checkupgtree1()
checkupgtree2()
checkupgtree3()
checkupgtree4()
checkupgtree5()
checkupgtree6()
checkupgtree7()
checkupgtree8()
checkupgtree9()
checkupgtree10()
checkupgtree11()
checkupgtree12()
checkupgtree13()
checkupgtree14()
checkupgtree15()
checkupgtree16()
checkupgtree17()
checkupgtree18()
checkupgtree19()
checkupgtree20()

-- Update automatically when the value changes
timesrebirthed:GetPropertyChangedSignal("Value"):Connect(checkifrebirthed)

island1unlocked:GetPropertyChangedSignal("Value"):Connect(checkifisland1unlocked)

rebirths:GetPropertyChangedSignal("Value"):Connect(checkislandboard1)
island1unlocked:GetPropertyChangedSignal("Value"):Connect(checkislandboard1)
island1unlocked:GetPropertyChangedSignal("Value"):Connect(checkupgtree1)
island1unlocked:GetPropertyChangedSignal("Value"):Connect(checkclickboard)

level:GetPropertyChangedSignal("Value"):Connect(checkislandboard1)
level:GetPropertyChangedSignal("Value"):Connect(checkclickboard)
level:GetPropertyChangedSignal("Value"):Connect(checkdaily)

upgt11:GetPropertyChangedSignal("Value"):Connect(checkgenerator)
upgt19:GetPropertyChangedSignal("Value"):Connect(checkgenerator)
upgt20:GetPropertyChangedSignal("Value"):Connect(checktierboard)
tier:GetPropertyChangedSignal("Value"):Connect(checktierboard)
tier:GetPropertyChangedSignal("Value"):Connect(checkifisland2unlocked)

upgt1:GetPropertyChangedSignal("Value"):Connect(checkupgtree2)
upgt2:GetPropertyChangedSignal("Value"):Connect(checkupgtree3)
upgt2:GetPropertyChangedSignal("Value"):Connect(checkupgtree4)
upgt3:GetPropertyChangedSignal("Value"):Connect(checkupgtree5)
upgt4:GetPropertyChangedSignal("Value"):Connect(checkupgtree6)
upgt5:GetPropertyChangedSignal("Value"):Connect(checkupgtree7)
upgt6:GetPropertyChangedSignal("Value"):Connect(checkupgtree8)
upgt7:GetPropertyChangedSignal("Value"):Connect(checkupgtree9)
upgt8:GetPropertyChangedSignal("Value"):Connect(checkupgtree10)
upgt9:GetPropertyChangedSignal("Value"):Connect(checkupgtree11)
upgt10:GetPropertyChangedSignal("Value"):Connect(checkupgtree12)
upgt12:GetPropertyChangedSignal("Value"):Connect(checkupgtree13)
upgt13:GetPropertyChangedSignal("Value"):Connect(checkupgtree14)
upgt13:GetPropertyChangedSignal("Value"):Connect(checkupgtree15)
upgt14:GetPropertyChangedSignal("Value"):Connect(checkupgtree16)
upgt15:GetPropertyChangedSignal("Value"):Connect(checkupgtree17)
upgt16:GetPropertyChangedSignal("Value"):Connect(checkupgtree18)
upgt17:GetPropertyChangedSignal("Value"):Connect(checkupgtree19)
upgt18:GetPropertyChangedSignal("Value"):Connect(checkupgtree20)
upgt2_7:GetPropertyChangedSignal("Value"):Connect(checkgenerator)
