-- FarmCirce (alias for FarmCircle - same content)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local farmPlot = Workspace:WaitForChild("FarmPlot")
local guiTemplate = ReplicatedStorage:WaitForChild("FarmCircleGui")
local upgrades = player:WaitForChild("Upgrades")
local collectradius = upgrades:WaitForChild("CollectRadiusUpg1")
local upgtree10 = upgrades:WaitForChild("UpgTree10")

local character = nil
local rootPart = nil
local circlePart = nil
local gui = nil
local renderConnection = nil

local radius = 2

local function isOnFarmPlot()
	if not rootPart then return false end
	local pos = rootPart.Position
	local plotSize = farmPlot.Size
	local plotPos = farmPlot.Position

	local dx = math.abs(pos.X - plotPos.X)
	local dz = math.abs(pos.Z - plotPos.Z)
	local insideX = dx <= (plotSize.X / 2)
	local insideZ = dz <= (plotSize.Z / 2)
	local nearY = math.abs(pos.Y - plotPos.Y) < 7

	return insideX and insideZ and nearY
end

local function calculateDiameter(radius, collectRadiusValue)
	return (radius + (collectRadiusValue * 0.5) + upgtree10.Value) * 2 * 10
end

local function createCircle()
	local diameter = calculateDiameter(radius, collectradius.Value)

	if circlePart then
		circlePart.Size = Vector3.new(diameter, 0.1, diameter)
		return
	end

	circlePart = Instance.new("Part")
	circlePart.Name = "CircleIndicator"
	circlePart.Anchored = true -- important for manual positioning
	circlePart.CanCollide = false
	circlePart.Size = Vector3.new(diameter, 0.1, diameter)
	circlePart.Transparency = 1
	circlePart.Parent = Workspace

	gui = guiTemplate:Clone()
	gui.Adornee = circlePart
	gui.Parent = player:WaitForChild("PlayerGui")
end

local function removeCircle()
	if gui then
		gui:Destroy()
		gui = nil
	end
	if circlePart then
		circlePart:Destroy()
		circlePart = nil
	end
end

local function onCharacter(char)
	character = char
	rootPart = char:WaitForChild("HumanoidRootPart")

	if renderConnection then
		renderConnection:Disconnect()
	end

	renderConnection = RunService.RenderStepped:Connect(function()
		if isOnFarmPlot() then
			createCircle()
			if circlePart and rootPart then
				-- Snap circle right below player, flat on world axis
				local rootPos = rootPart.Position
				circlePart.CFrame = CFrame.new(rootPos.X, rootPos.Y - 3, rootPos.Z)
			end
		else
			removeCircle()
		end
	end)
end

player.CharacterAdded:Connect(onCharacter)
if player.Character then onCharacter(player.Character) end

collectradius:GetPropertyChangedSignal("Value"):Connect(function()
	removeCircle()
	task.wait()
	createCircle()
end)
