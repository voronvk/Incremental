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

local upgradesfolder = workspace:WaitForChild("Upgrades")
local boosterboards = upgradesfolder:WaitForChild("BoosterBoards")
local boosterboard0 = boosterboards:WaitForChild("BoosterBoard0")
local boosterlevelboard0 = boosterboard0:WaitForChild("LevelBoard")
local boosterupgradesback = boosterboards:WaitForChild("BoosterUpgradesBack")

local kernelfolder = upgradesfolder:WaitForChild("KernelUpgrades")
local kernelboard0 = kernelfolder:WaitForChild("KernelBoard0")
local kernelboard1 = kernelfolder:WaitForChild("KernelBoard1")
local levelboard1 = kernelboard1:WaitForChild("LevelBoard")
local kernelboard2 = kernelfolder:WaitForChild("KernelBoard2")
local levelboard2 = kernelboard2:WaitForChild("LevelBoard")
local kernelboard3 = kernelfolder:WaitForChild("KernelBoard3")
local levelboard3 = kernelboard3:WaitForChild("LevelBoard")
local kernelboard4 = kernelfolder:WaitForChild("KernelBoard4")
local levelboard4 = kernelboard4:WaitForChild("LevelBoard")
local kernelboard5 = kernelfolder:WaitForChild("KernelBoard5")
local levelboard5 = kernelboard5:WaitForChild("LevelBoard")
local kernelboard0top = kernelfolder:WaitForChild("KernelBoard0Top")
local kernelupgradestop = kernelfolder:WaitForChild("KernelUpgradesTop")
local kernelboard0back = kernelfolder:WaitForChild("KernelBoard0Back")
local kernelupgradesback = kernelfolder:WaitForChild("KernelUpgradesBack")

local upgt1 = upgrades:WaitForChild("UpgTree2_1")
local upgt2 = upgrades:WaitForChild("UpgTree2_2")
local upgt3 = upgrades:WaitForChild("UpgTree2_3")
local upgt4 = upgrades:WaitForChild("UpgTree2_4")
local upgt5 = upgrades:WaitForChild("UpgTree2_5")
local upgt6 = upgrades:WaitForChild("UpgTree2_6")
local upgt7 = upgrades:WaitForChild("UpgTree2_7")
local upgt8 = upgrades:WaitForChild("UpgTree2_8")
local upgt9 = upgrades:WaitForChild("UpgTree2_9")
local upgt10 = upgrades:WaitForChild("UpgTree2_10")
local upgt11 = upgrades:WaitForChild("UpgTree2_11")
local upgt12 = upgrades:WaitForChild("UpgTree2_12")
local upgt13 = upgrades:WaitForChild("UpgTree2_13")
local upgt14 = upgrades:WaitForChild("UpgTree2_14")
local upgt15 = upgrades:WaitForChild("UpgTree2_15")
local upgt16 = upgrades:WaitForChild("UpgTree2_16")
local upgt17 = upgrades:WaitForChild("UpgTree2_17")
local upgt18 = upgrades:WaitForChild("UpgTree2_18")
local upgt19 = upgrades:WaitForChild("UpgTree2_19")
local upgt20 = upgrades:WaitForChild("UpgTree2_20")

local upg1 = upgtreefolder:WaitForChild("Upg1")
local upg1main = upg1:WaitForChild("Main")
local upg1border = upg1:WaitForChild("Border")

local upg2 = upgtreefolder:WaitForChild("Upg2")
local upg2main = upg2:WaitForChild("Main")
local upg2border = upg2:WaitForChild("Border")
local upg2wire1 = upg2:WaitForChild("Wire1")
local upg2wireborder1 = upg2:WaitForChild("WireBorder1")
local upg2wire2 = upg2:WaitForChild("Wire2")
local upg2wireborder2 = upg2:WaitForChild("WireBorder2")

local upg3 = upgtreefolder:WaitForChild("Upg3")
local upg3main = upg3:WaitForChild("Main")
local upg3border = upg3:WaitForChild("Border")
local upg3wire = upg3:WaitForChild("Wire")
local upg3wireborder = upg3:WaitForChild("WireBorder")

local upg4 = upgtreefolder:WaitForChild("Upg4")
local upg4main = upg4:WaitForChild("Main")
local upg4border = upg4:WaitForChild("Border")
local upg4wire1 = upg4:WaitForChild("Wire1")
local upg4wireborder1 = upg4:WaitForChild("WireBorder1")
local upg4wire2 = upg4:WaitForChild("Wire2")
local upg4wireborder2 = upg4:WaitForChild("WireBorder2")

local upg5 = upgtreefolder:WaitForChild("Upg5")
local upg5main = upg5:WaitForChild("Main")
local upg5border = upg5:WaitForChild("Border")
local upg5wire1 = upg5:WaitForChild("Wire1")
local upg5wireborder1 = upg5:WaitForChild("WireBorder1")
local upg5wire2 = upg5:WaitForChild("Wire2")
local upg5wireborder2 = upg5:WaitForChild("WireBorder2")

local upg6 = upgtreefolder:WaitForChild("Upg6")
local upg6main = upg6:WaitForChild("Main")
local upg6border = upg6:WaitForChild("Border")
local upg6wire1 = upg6:WaitForChild("Wire1")
local upg6wireborder1 = upg6:WaitForChild("WireBorder1")
local upg6wire2 = upg6:WaitForChild("Wire2")
local upg6wireborder2 = upg6:WaitForChild("WireBorder2")

local upg7 = upgtreefolder:WaitForChild("Upg7")
local upg7main = upg7:WaitForChild("Main")
local upg7border = upg7:WaitForChild("Border")
local upg7wire1 = upg7:WaitForChild("Wire1")
local upg7wireborder1 = upg7:WaitForChild("WireBorder1")
local upg7wire2 = upg7:WaitForChild("Wire2")
local upg7wireborder2 = upg7:WaitForChild("WireBorder2")

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
local upg17wire1 = upg17:WaitForChild("Wire1")
local upg17wireborder1 = upg17:WaitForChild("WireBorder1")
local upg17wire2 = upg17:WaitForChild("Wire2")
local upg17wireborder2 = upg17:WaitForChild("WireBorder2")

local upg18 = upgtreefolder:WaitForChild("Upg18")
local upg18main = upg18:WaitForChild("Main")
local upg18border = upg18:WaitForChild("Border")
local upg18wire1 = upg18:WaitForChild("Wire1")
local upg18wireborder1 = upg18:WaitForChild("WireBorder1")
local upg18wire2 = upg18:WaitForChild("Wire2")
local upg18wireborder2 = upg18:WaitForChild("WireBorder2")

local upg19 = upgtreefolder:WaitForChild("Upg19")
local upg19main = upg19:WaitForChild("Main")
local upg19border = upg19:WaitForChild("Border")
local upg19wire1 = upg19:WaitForChild("Wire1")
local upg19wireborder1 = upg19:WaitForChild("WireBorder1")
local upg19wire2 = upg19:WaitForChild("Wire2")
local upg19wireborder2 = upg19:WaitForChild("WireBorder2")

local upg20 = upgtreefolder:WaitForChild("Upg20")
local upg20main = upg20:WaitForChild("Main")
local upg20border = upg20:WaitForChild("Border")
local upg20wire1 = upg20:WaitForChild("Wire1")
local upg20wireborder1 = upg20:WaitForChild("WireBorder1")
local upg20wire2 = upg20:WaitForChild("Wire2")
local upg20wireborder2 = upg20:WaitForChild("WireBorder2")

local function checkboosterboard()
	if upgt5.Value >= 1 then
		boosterboard0.Position = Vector3.new(-35.5, 5.125, -118.125)
		boosterlevelboard0.Position = Vector3.new(-35.5, 16.125, -118.125)
		boosterupgradesback.Position = Vector3.new(-36, 6.625, -118.125)
	else
		boosterboard0.Position = Vector3.new(0, -994.5, -43)
		boosterlevelboard0.Position = Vector3.new(0, -994.5, -43)
		boosterupgradesback.Position = Vector3.new(0, -994.5, -43)
	end
end

local function checkkernels()
	if upgt8.Value >= 1 then
		kernelboard0.Position = Vector3.new(-35.563, 4.125, -133.75)
		kernelboard1.Position = Vector3.new(-35.563, 3.125, -148.75)
		levelboard1.Position = Vector3.new(-35.562, 12.125, -148.75)
		kernelboard2.Position = Vector3.new(-35.563, 3.125, -160.75)
		levelboard2.Position = Vector3.new(-35.563, 12.125, -160.75)
		kernelboard3.Position = Vector3.new(-35.563, 3.125, -172.75)
		levelboard3.Position = Vector3.new(-35.563, 12.125, -172.75)
		kernelboard4.Position = Vector3.new(-35.563, 3.125, -184.75)
		levelboard4.Position = Vector3.new(-35.563, 12.125, -184.75)
		kernelboard5.Position = Vector3.new(-35.563, 3.125, -196.75)
		levelboard5.Position = Vector3.new(-35.563, 12.125, -196.75)
		kernelboard0top.Position = Vector3.new(-35.563, 15.125, -133.75)
		kernelupgradestop.Position = Vector3.new(-35.563, 15.125, -172.75)
		kernelboard0back.Position = Vector3.new(-36.063, 6.625, -133.75)
		kernelupgradesback.Position = Vector3.new(-36.063, 6.625, -172.75)
	else
		kernelboard0.Position = Vector3.new(0,-999,0)
		kernelboard1.Position = Vector3.new(0,-999,0)
		levelboard1.Position = Vector3.new(0,-999,0)
		kernelboard2.Position = Vector3.new(0,-999,0)
		levelboard2.Position = Vector3.new(0,-999,0)
		kernelboard3.Position = Vector3.new(0,-999,0)
		levelboard3.Position = Vector3.new(0,-999,0)
		kernelboard4.Position = Vector3.new(0,-999,0)
		levelboard4.Position = Vector3.new(0,-999,0)
		kernelboard5.Position = Vector3.new(0,-999,0)
		levelboard5.Position = Vector3.new(0,-999,0)
		kernelboard0top.Position = Vector3.new(0,-999,0)
		kernelupgradestop.Position = Vector3.new(0,-999,0)
		kernelboard0back.Position = Vector3.new(0,-999,0)
		kernelupgradesback.Position = Vector3.new(0,-999,0)
	end
end


local function checkupgtree1()
	if tier.Value >= 6 then
		upg1main.Position = Vector3.new(0, -4.375, -108)
		upg1border.Position = Vector3.new(0, -4.581, -108)
	else
		upg1main.Position = Vector3.new(0, -994.375, -43)
		upg1border.Position = Vector3.new(0, -994.5, -43)
	end
end

local function checkupgtree2()
	if timesascended.Value == 0 then
		upg2main.Position = Vector3.new(0, -104.375, -43)
		upg2border.Position = Vector3.new(0, -104.5, -43)
		upg2wire1.Position = Vector3.new(0, -104.5, -43)
		upg2wireborder1.Position = Vector3.new(0, -104.5, -43)
		upg2wire2.Position = Vector3.new(0, -104.5, -43)
		upg2wireborder2.Position = Vector3.new(0, -104.5, -43)
	else
		upg2main.Position = Vector3.new(-10.5, -4.375, -118.603)
		upg2border.Position = Vector3.new(-10.5, -4.5, -118.603)
		upg2wire1.Position = Vector3.new(-9, -4.25, -108)
		upg2wireborder1.Position = Vector3.new(-8.375, -4.625, -108)
		upg2wire2.Position = Vector3.new(-10.5, -4.25, -111.938)
		upg2wireborder2.Position = Vector3.new(-10.5, -4.625, -111.313)
	end
end

local function checkupgtree3()
	if timesascended.Value == 0 then
		upg3main.Position = Vector3.new(0, -104.375, -43)
		upg3border.Position = Vector3.new(0, -104.5, -43)
		upg3wire.Position = Vector3.new(0, -104.5, -43)
		upg3wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg3main.Position = Vector3.new(0, -4.375, -118.603)
		upg3border.Position = Vector3.new(0, -4.5, -118.603)
		upg3wire.Position = Vector3.new(0, -4.25, -114.353)
		upg3wireborder.Position = Vector3.new(0, -4.625, -114.353)
	end
end

local function checkupgtree4()
	if timesascended.Value == 0 then
		upg4main.Position = Vector3.new(0, -104.375, -43)
		upg4border.Position = Vector3.new(0, -104.5, -43)
		upg4wire1.Position = Vector3.new(0, -104.5, -43)
		upg4wireborder1.Position = Vector3.new(0, -104.5, -43)
		upg4wire2.Position = Vector3.new(0, -104.5, -43)
		upg4wireborder2.Position = Vector3.new(0, -104.5, -43)
	else
		upg4main.Position = Vector3.new(10.5, -4.375, -118.603)
		upg4border.Position = Vector3.new(10.5, -4.5, -118.603)
		upg4wire1.Position = Vector3.new(9, -4.25, -107.978)
		upg4wireborder1.Position = Vector3.new(8.375, -4.625, -107.978)
		upg4wire2.Position = Vector3.new(10.5, -4.25, -111.915)
		upg4wireborder2.Position = Vector3.new(10.5, -4.625, -111.29)
	end
end

local function checkupgtree5()
	if upgt2.Value == 0 or upgt3.Value == 0 then
		upg5main.Position = Vector3.new(0, -104.375, -43)
		upg5border.Position = Vector3.new(0, -104.5, -43)
		upg5wire1.Position = Vector3.new(0, -104.5, -43)
		upg5wireborder1.Position = Vector3.new(0, -104.5, -43)
		upg5wire2.Position = Vector3.new(0, -104.5, -43)
		upg5wireborder2.Position = Vector3.new(0, -104.5, -43)
	else
		upg5main.Position = Vector3.new(-5.125, -4.375, -127.081)
		upg5border.Position = Vector3.new(-5.125, -4.5, -127.081)
		upg5wire1.Position = Vector3.new(-2.5, -4.25, -122.853)
		upg5wireborder1.Position = Vector3.new(-2.5, -4.625, -122.853)
		upg5wire2.Position = Vector3.new(-7.875, -4.25, -122.853)
		upg5wireborder2.Position = Vector3.new(-7.875, -4.625, -122.853)
	end
end

local function checkupgtree6()
	if upgt3.Value == 0 or upgt4.Value == 0 then
		upg6main.Position = Vector3.new(0, -104.375, -43)
		upg6border.Position = Vector3.new(0, -104.5, -43)
		upg6wire1.Position = Vector3.new(0, -104.5, -43)
		upg6wireborder1.Position = Vector3.new(0, -104.5, -43)
		upg6wire2.Position = Vector3.new(0, -104.5, -43)
		upg6wireborder2.Position = Vector3.new(0, -104.5, -43)
	else
		upg6main.Position = Vector3.new(5.25, -4.375, -127.081)
		upg6border.Position = Vector3.new(5.25, -4.5, -127.081)
		upg6wire1.Position = Vector3.new(2.625, -4.25, -122.853)
		upg6wireborder1.Position = Vector3.new(2.625, -4.625, -122.853)
		upg6wire2.Position = Vector3.new(7.875, -4.25, -122.853)
		upg6wireborder2.Position = Vector3.new(7.875, -4.625, -122.853)
	end
end

local function checkupgtree7()
	if upgt5.Value == 0 or upgt6.Value == 0 then
		upg7main.Position = Vector3.new(0, -104.375, -43)
		upg7border.Position = Vector3.new(0, -104.5, -43)
		upg7wire1.Position = Vector3.new(0, -104.5, -43)
		upg7wireborder1.Position = Vector3.new(0, -104.5, -43)
		upg7wire2.Position = Vector3.new(0, -104.5, -43)
		upg7wireborder2.Position = Vector3.new(0, -104.5, -43)
	else
		upg7main.Position = Vector3.new(0, -4.375, -135.559)
		upg7border.Position = Vector3.new(0, -4.5, -135.559)
		upg7wire1.Position = Vector3.new(-2.625, -4.25, -131.331)
		upg7wireborder1.Position = Vector3.new(-2.625, -4.625, -131.331)
		upg7wire2.Position = Vector3.new(2.625, -4.25, -131.331)
		upg7wireborder2.Position = Vector3.new(2.625, -4.625, -131.331)
	end
end

local function checkupgtree8()
	if upgt7.Value == 0 then
		upg8main.Position = Vector3.new(0, -104.375, -43)
		upg8border.Position = Vector3.new(0, -104.5, -43)
		upg8wire.Position = Vector3.new(0, -104.5, -43)
		upg8wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg8main.Position = Vector3.new(0, -4.375, -144.037)
		upg8border.Position = Vector3.new(0, -4.5, -144.037)
		upg8wire.Position = Vector3.new(0, -4.25, -139.809)
		upg8wireborder.Position = Vector3.new(0, -4.625, -139.809)
	end
end

local function checkupgtree9()
	if upgt8.Value == 0 then
		upg9main.Position = Vector3.new(0, -104.375, -43)
		upg9border.Position = Vector3.new(0, -104.5, -43)
		upg9wire.Position = Vector3.new(0, -104.5, -43)
		upg9wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg9main.Position = Vector3.new(10.5, -4.375, -139.809)
		upg9border.Position = Vector3.new(10.5, -4.5, -139.809)
		upg9wire.Position = Vector3.new(5.25, -4.25, -141.934)
		upg9wireborder.Position = Vector3.new(5.25, -4.625, -141.934)
	end
end

local function checkupgtree10()
	if upgt9.Value == 0 then
		upg10main.Position = Vector3.new(0, -104.375, -43)
		upg10border.Position = Vector3.new(0, -104.5, -43)
		upg10wire.Position = Vector3.new(0, -104.5, -43)
		upg10wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg10main.Position = Vector3.new(21, -4.375, -135.559)
		upg10border.Position = Vector3.new(21, -4.5, -135.559)
		upg10wire.Position = Vector3.new(15.75, -4.25, -137.684)
		upg10wireborder.Position = Vector3.new(15.75, -4.625, -137.684)
	end
end

local function checkupgtree11()
	if upgt8.Value == 0 then
		upg11main.Position = Vector3.new(0, -104.375, -43)
		upg11border.Position = Vector3.new(0, -104.5, -43)
		upg11wire.Position = Vector3.new(0, -104.5, -43)
		upg11wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg11main.Position = Vector3.new(-10.5, -4.375, -139.875)
		upg11border.Position = Vector3.new(-10.5, -4.5, -139.875)
		upg11wire.Position = Vector3.new(-5.25, -4.25, -142)
		upg11wireborder.Position = Vector3.new(-5.25, -4.625, -142)
	end
end

local function checkupgtree12()
	if upgt11.Value == 0 then
		upg12main.Position = Vector3.new(0, -104.375, -43)
		upg12border.Position = Vector3.new(0, -104.5, -43)
		upg12wire.Position = Vector3.new(0, -104.5, -43)
		upg12wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg12main.Position = Vector3.new(-21, -4.375, -135.625)
		upg12border.Position = Vector3.new(-21, -4.5, -135.625)
		upg12wire.Position = Vector3.new(-15.75, -4.25, -137.75)
		upg12wireborder.Position = Vector3.new(-15.75, -4.625, -137.75)
	end
end

local function checkupgtree13()
	if upgt8.Value == 0 then
		upg13main.Position = Vector3.new(0, -104.375, -43)
		upg13border.Position = Vector3.new(0, -104.5, -43)
		upg13wire.Position = Vector3.new(0, -104.5, -43)
		upg13wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg13main.Position = Vector3.new(-10.5, -4.375, -148.625)
		upg13border.Position = Vector3.new(-10.5, -4.5, -148.625)
		upg13wire.Position = Vector3.new(-5.25, -4.25, -146.287)
		upg13wireborder.Position = Vector3.new(-5.25, -4.625, -146.287)
	end
end

local function checkupgtree14()
	if upgt13.Value == 0 then
		upg14main.Position = Vector3.new(0, -104.375, -43)
		upg14border.Position = Vector3.new(0, -104.5, -43)
		upg14wire.Position = Vector3.new(0, -104.5, -43)
		upg14wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg14main.Position = Vector3.new(-21, -4.375, -153.25)
		upg14border.Position = Vector3.new(-21, -4.5, -153.25)
		upg14wire.Position = Vector3.new(-15.75, -4.25, -150.912)
		upg14wireborder.Position = Vector3.new(-15.75, -4.625, -150.912)
	end
end

local function checkupgtree15()
	if upgt8.Value == 0 then
		upg15main.Position = Vector3.new(0, -104.375, -43)
		upg15border.Position = Vector3.new(0, -104.5, -43)
		upg15wire.Position = Vector3.new(0, -104.5, -43)
		upg15wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg15main.Position = Vector3.new(10.5, -4.375, -148.5)
		upg15border.Position = Vector3.new(10.5, -4.5, -148.5)
		upg15wire.Position = Vector3.new(5.25, -4.25, -146.25)
		upg15wireborder.Position = Vector3.new(5.25, -4.625, -146.25)
	end
end

local function checkupgtree16()
	if upgt15.Value == 0 then
		upg16main.Position = Vector3.new(0, -104.375, -43)
		upg16border.Position = Vector3.new(0, -104.5, -43)
		upg16wire.Position = Vector3.new(0, -104.5, -43)
		upg16wireborder.Position = Vector3.new(0, -104.5, -43)
	else
		upg16main.Position = Vector3.new(21, -4.375, -153)
		upg16border.Position = Vector3.new(21, -4.5, -153)
		upg16wire.Position = Vector3.new(15.75, -4.25, -150.75)
		upg16wireborder.Position = Vector3.new(15.75, -4.625, -150.75)
	end
end

local function checkupgtree17()
	if upgt10.Value == 0 or upgt16.Value == 0 then
		upg17main.Position = Vector3.new(0, -104.375, -43)
		upg17border.Position = Vector3.new(0, -104.5, -43)
		upg17wire1.Position = Vector3.new(0, -104.5, -43)
		upg17wireborder1.Position = Vector3.new(0, -104.5, -43)
		upg17wire2.Position = Vector3.new(0, -104.5, -43)
		upg17wireborder2.Position = Vector3.new(0, -104.5, -43)
	else
		upg17main.Position = Vector3.new(21, -4.375, -144.184)
		upg17border.Position = Vector3.new(21, -4.5, -144.184)
		upg17wire1.Position = Vector3.new(18.375, -4.25, -139.882)
		upg17wireborder1.Position = Vector3.new(18.375, -4.625, -139.882)
		upg17wire2.Position = Vector3.new(23.625, -4.25, -148.592)
		upg17wireborder2.Position = Vector3.new(23.625, -4.625, -148.592)
	end
end

local function checkupgtree18()
	if upgt12.Value == 0 or upgt14.Value == 0 then
		upg18main.Position = Vector3.new(0, -104.375, -43)
		upg18border.Position = Vector3.new(0, -104.5, -43)
		upg18wire1.Position = Vector3.new(0, -104.5, -43)
		upg18wireborder1.Position = Vector3.new(0, -104.5, -43)
		upg18wire2.Position = Vector3.new(0, -104.5, -43)
		upg18wireborder2.Position = Vector3.new(0, -104.5, -43)
	else
		upg18main.Position = Vector3.new(-21, -4.375, -144.375)
		upg18border.Position = Vector3.new(-21, -4.5, -144.375)
		upg18wire1.Position = Vector3.new(-18.25, -4.25, -140.011)
		upg18wireborder1.Position = Vector3.new(-18.25, -4.625, -140.011)
		upg18wire2.Position = Vector3.new(-23.625, -4.25, -148.813)
		upg18wireborder2.Position = Vector3.new(-23.625, -4.625, -148.813)
	end
end

local function checkupgtree19()
	if upgt17.Value == 0 then
		upg19main.Position = Vector3.new(0, -104.375, -43)
		upg19border.Position = Vector3.new(0, -104.5, -43)
		upg19wire1.Position = Vector3.new(0, -104.5, -43)
		upg19wireborder1.Position = Vector3.new(0, -104.5, -43)
		upg19wire2.Position = Vector3.new(0, -104.5, -43)
		upg19wireborder2.Position = Vector3.new(0, -104.5, -43)
	else
		upg19main.Position = Vector3.new(26.25, -4.375, -161.434)
		upg19border.Position = Vector3.new(26.25, -4.5, -161.434)
		upg19wire1.Position = Vector3.new(27.312, -4.25, -144.184)
		upg19wireborder1.Position = Vector3.new(27.437, -4.625, -144.184)
		upg19wire2.Position = Vector3.new(28.875, -4.25, -150.934)
		upg19wireborder2.Position = Vector3.new(28.875, -4.625, -151.088)
	end
end

local function checkupgtree20()
	if upgt18.Value == 0 then
		upg20main.Position = Vector3.new(0, -104.375, -43)
		upg20border.Position = Vector3.new(0, -104.5, -43)
		upg20wire1.Position = Vector3.new(0, -104.5, -43)
		upg20wireborder1.Position = Vector3.new(0, -104.5, -43)
		upg20wire2.Position = Vector3.new(0, -104.5, -43)
		upg20wireborder2.Position = Vector3.new(0, -104.5, -43)
	else
		upg20main.Position = Vector3.new(-26.25, -4.375, -161.434)
		upg20border.Position = Vector3.new(-26.25, -4.5, -161.434)
		upg20wire1.Position = Vector3.new(-27.313, -4.25, -144.184)
		upg20wireborder1.Position = Vector3.new(-27.438, -4.625, -144.184)
		upg20wire2.Position = Vector3.new(-28.875, -4.25, -150.934)
		upg20wireborder2.Position = Vector3.new(-28.875, -4.625, -151.088)
	end
end

checkboosterboard()
checkkernels()
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

upgt5:GetPropertyChangedSignal("Value"):Connect(checkboosterboard)

tier:GetPropertyChangedSignal("Value"):Connect(checkupgtree1)

upgt1:GetPropertyChangedSignal("Value"):Connect(checkupgtree2)
upgt2:GetPropertyChangedSignal("Value"):Connect(checkupgtree5)
upgt3:GetPropertyChangedSignal("Value"):Connect(checkupgtree5)
upgt3:GetPropertyChangedSignal("Value"):Connect(checkupgtree6)
upgt4:GetPropertyChangedSignal("Value"):Connect(checkupgtree6)
upgt5:GetPropertyChangedSignal("Value"):Connect(checkupgtree7)
upgt6:GetPropertyChangedSignal("Value"):Connect(checkupgtree7)
upgt7:GetPropertyChangedSignal("Value"):Connect(checkupgtree8)
upgt8:GetPropertyChangedSignal("Value"):Connect(checkupgtree9)
upgt8:GetPropertyChangedSignal("Value"):Connect(checkupgtree11)
upgt8:GetPropertyChangedSignal("Value"):Connect(checkupgtree13)
upgt8:GetPropertyChangedSignal("Value"):Connect(checkupgtree15)
upgt9:GetPropertyChangedSignal("Value"):Connect(checkupgtree10)
upgt10:GetPropertyChangedSignal("Value"):Connect(checkupgtree17)
upgt11:GetPropertyChangedSignal("Value"):Connect(checkupgtree12)
upgt12:GetPropertyChangedSignal("Value"):Connect(checkupgtree18)
upgt13:GetPropertyChangedSignal("Value"):Connect(checkupgtree14)
upgt14:GetPropertyChangedSignal("Value"):Connect(checkupgtree18)
upgt15:GetPropertyChangedSignal("Value"):Connect(checkupgtree16)
upgt16:GetPropertyChangedSignal("Value"):Connect(checkupgtree17)
upgt17:GetPropertyChangedSignal("Value"):Connect(checkupgtree19)
upgt18:GetPropertyChangedSignal("Value"):Connect(checkupgtree20)

timesascended:GetPropertyChangedSignal("Value"):Connect(checkupgtree2)
timesascended:GetPropertyChangedSignal("Value"):Connect(checkupgtree3)
timesascended:GetPropertyChangedSignal("Value"):Connect(checkupgtree4)

upgt8:GetPropertyChangedSignal("Value"):Connect(checkkernels)
