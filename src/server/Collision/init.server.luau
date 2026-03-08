local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local GroupName = "Players"
PhysicsService:RegisterCollisionGroup(GroupName)
PhysicsService:CollisionGroupSetCollidable(GroupName, GroupName, false)

local function setCollisions(char)
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.CollisionGroup == GroupName then continue end

			part.CollisionGroup = GroupName
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAppearanceLoaded:Connect(function(char)
		setCollisions(char)
	end)
end)
