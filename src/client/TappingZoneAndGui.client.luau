--[[
	workspace.TappingZone: zona de taps al melón (no recolección en mapa).
	Atributos: ver ReplicatedStorage.Shared.PlayerClientAttributes.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Attr = require(ReplicatedStorage.Shared:WaitForChild("PlayerClientAttributes"))

local ZONE_NAME = "TappingZone"
local TITLE_IN_ZONE = "Zone: Tapping"
local TITLE_OUT_ZONE = "Zone: Melon"

if player:GetAttribute(Attr.IN_TAPPING_ZONE) == nil then
	player:SetAttribute(Attr.IN_TAPPING_ZONE, false)
end
if player:GetAttribute(Attr.AUTO_TAP) == nil then
	player:SetAttribute(Attr.AUTO_TAP, false)
end
if player:GetAttribute(Attr.AUTO_TAP_GOLD) == nil then
	player:SetAttribute(Attr.AUTO_TAP_GOLD, false)
end

local function getZonePart()
	local z = workspace:FindFirstChild(ZONE_NAME)
	if not z then
		return nil
	end
	if z:IsA("BasePart") then
		return z
	end
	if z:IsA("Model") then
		return z.PrimaryPart or z:FindFirstChildWhichIsA("BasePart", true)
	end
	return nil
end

local function pointInObb(cframe, size, worldPoint)
	local half = size * 0.5
	local localPos = cframe:PointToObjectSpace(worldPoint)
	return math.abs(localPos.X) <= half.X + 0.01 and math.abs(localPos.Y) <= half.Y + 0.01 and math.abs(localPos.Z) <= half.Z + 0.01
end

local function findSlowModeTitle()
	local pg = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
	local tg = pg:FindFirstChild("TappingGui") or pg:WaitForChild("TappingGui", 60)
	if not tg then
		return nil
	end
	local buttons = tg:FindFirstChild("Buttons") or tg:FindFirstChild("buttons")
	if not buttons then
		return nil
	end
	local folder = buttons:FindFirstChild("Folder") or buttons:FindFirstChild("folder")
	if not folder then
		return nil
	end
	local slow = folder:FindFirstChild("SlowMode") or folder:FindFirstChild("slowmode")
	if not slow then
		return nil
	end
	local title = slow:FindFirstChild("Title") or slow:FindFirstChild("title")
	if title and (title:IsA("TextLabel") or title:IsA("TextButton")) then
		return title
	end
	return nil
end

local function updateSlowModeTitle(inZone)
	local title = findSlowModeTitle()
	if title then
		title.Text = inZone and TITLE_IN_ZONE or TITLE_OUT_ZONE
	end
end

local function updateHarvestGuis(inZone)
	local pg = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
	local ah = pg:FindFirstChild("AutoHarvest")
	local at = pg:FindFirstChild("AutoTapping")
	if player:GetAttribute(Attr.CLIENT_LOADING_COMPLETE) ~= true then
		if ah and ah:IsA("ScreenGui") then
			ah.Enabled = false
		end
		if at and at:IsA("ScreenGui") then
			at.Enabled = false
		end
		return
	end
	if ah and ah:IsA("ScreenGui") then
		ah.Enabled = not inZone
	end
	if at and at:IsA("ScreenGui") then
		at.Enabled = inZone
	end
end

local function refreshHarvestGuisAfterLoading()
	if player:GetAttribute(Attr.CLIENT_LOADING_COMPLETE) ~= true then
		return
	end
	updateHarvestGuis(player:GetAttribute(Attr.IN_TAPPING_ZONE) == true)
end

player:GetAttributeChangedSignal(Attr.CLIENT_LOADING_COMPLETE):Connect(refreshHarvestGuisAfterLoading)
task.defer(refreshHarvestGuisAfterLoading)

local lastZoneState = nil

local function tickZone()
	local part = getZonePart()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local inZone = false
	if part and hrp then
		inZone = pointInObb(part.CFrame, part.Size, hrp.Position)
	end

	if lastZoneState ~= inZone then
		lastZoneState = inZone
		player:SetAttribute(Attr.IN_TAPPING_ZONE, inZone)
		if inZone then
			-- En zona de tapping: cortar recolección en mapa (evita CornFinder/MoveTo con AutoTap encendido).
			player:SetAttribute(Attr.AUTO_HARVEST, false)
			player:SetAttribute(Attr.AUTO_HARVEST_GOLD, false)
		else
			player:SetAttribute(Attr.AUTO_TAP, false)
			player:SetAttribute(Attr.AUTO_TAP_GOLD, false)
		end
		updateSlowModeTitle(inZone)
		updateHarvestGuis(inZone)
	end
end

RunService.Heartbeat:Connect(tickZone)

workspace.DescendantAdded:Connect(function(inst)
	if inst.Name == ZONE_NAME then
		task.defer(tickZone)
	end
end)

task.defer(function()
	workspace:WaitForChild(ZONE_NAME, 120)
	tickZone()
end)

player.CharacterAdded:Connect(function()
	task.defer(tickZone)
end)

task.spawn(function()
	local pg = player:WaitForChild("PlayerGui")
	pg:WaitForChild("TappingGui", 120)
	updateSlowModeTitle(player:GetAttribute(Attr.IN_TAPPING_ZONE) == true)
	updateHarvestGuis(player:GetAttribute(Attr.IN_TAPPING_ZONE) == true)
end)
