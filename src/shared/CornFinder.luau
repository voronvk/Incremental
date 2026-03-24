local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CORN_TAG = "Corn"
-- Nombres por defecto; si existe ReplicatedStorage.CornTemplates, se usan sus hijos
local DEFAULT_NAMES = { "Corn", "GoldenCorn", "SilverCorn", "RubyCorn", "DiamondCorn" }
local function getCornNames()
	local folder = ReplicatedStorage:FindFirstChild("CornTemplates")
	if folder then
		local names = {}
		for _, child in ipairs(folder:GetChildren()) do
			if child:IsA("Model") or child:IsA("BasePart") then
				table.insert(names, child.Name)
			end
		end
		if #names > 0 then return names end
	end
	return DEFAULT_NAMES
end

local function getPosition(instance)
	if instance:IsA("BasePart") then
		return instance.Position
	elseif instance:IsA("Model") then
		if instance.PrimaryPart then
			return instance.PrimaryPart.Position
		end
		local ok, pivot = pcall(function()
			return instance:GetPivot()
		end)
		if ok and pivot then
			return pivot.Position
		end
		local part = instance:FindFirstChildWhichIsA("BasePart", true)
		if part then
			return part.Position
		end
	end
	return nil
end

local function findClosestCornInWorkspace(fromPosition, exclude)
	local closest = nil
	local closestDist = math.huge
	local nameSet = {}
	for _, name in ipairs(getCornNames()) do
		nameSet[name] = true
	end

	local function isCornModel(model)
		return nameSet[model.Name] or model:FindFirstChild("Base")
	end

	for _, desc in workspace:GetDescendants() do
		if desc ~= exclude and desc:IsA("Model") and isCornModel(desc) then
			local pos = getPosition(desc)
			if pos then
				local dist = (fromPosition - pos).Magnitude
				if dist < closestDist then
					closestDist = dist
					closest = desc
				end
			end
		end
	end

	return closest
end

local function findClosestByTag(fromPosition, exclude)
	local closest = nil
	local closestDist = math.huge
	for _, corn in pairs(CollectionService:GetTagged(CORN_TAG)) do
		if corn ~= exclude and corn.Parent and corn:IsDescendantOf(workspace) then
			local pos = getPosition(corn)
			if pos then
				local dist = (fromPosition - pos).Magnitude
				if dist < closestDist then
					closestDist = dist
					closest = corn
				end
			end
		end
	end
	return closest
end

return {
	findClosest = function(fromPosition, exclude)
		local corn = findClosestByTag(fromPosition, exclude)
		if not corn then
			corn = findClosestCornInWorkspace(fromPosition, exclude)
		end
		return corn
	end,
	getPosition = getPosition,
}
