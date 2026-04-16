local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local function cloneChildrenOfFolder(folderName)
	local folder = ReplicatedStorage:WaitForChild(folderName)
	if folder then
		for _, child in ipairs(folder:GetChildren()) do
			local clone = child:Clone()
			clone.Parent = Workspace
		end
	end
end

cloneChildrenOfFolder("CloneFolder")

require(ReplicatedStorage.Shared:WaitForChild("AutoPlacementHideHelper")).start()
