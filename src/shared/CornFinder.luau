local CollectionService = game:GetService("CollectionService")

local CORN_TAG = "Corn"
local CORN_MODEL_NAMES = { "Corn", "GoldenCorn", "SilverCorn", "RubyCorn", "DiamondCorn" }

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
	for _, name in ipairs(CORN_MODEL_NAMES) do
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
