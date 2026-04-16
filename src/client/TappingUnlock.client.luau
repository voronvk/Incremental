--[[
	Clona ReplicatedStorage.Tapping al Workspace solo para este cliente cuando Level >= MIN_LEVEL (25).
	El clon es local (no se replica al servidor ni a otros jugadores).
	Si añades mecánicas con RemoteEvents, valida el mismo umbral en el servidor.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local MIN_LEVEL = 25

local player = Players.LocalPlayer
local template = ReplicatedStorage:WaitForChild("Tapping")
local events = player:WaitForChild("Events")
local level = events:WaitForChild("Level")

local holder = Instance.new("Folder")
holder.Name = "ClientTapping"
holder.Parent = workspace

local clone: Instance? = nil

local function setVisible(visible: boolean)
	if visible then
		if clone == nil or clone.Parent == nil then
			clone = template:Clone()
			clone.Name = "Tapping"
			clone.Parent = holder
		end
	else
		if clone then
			clone:Destroy()
			clone = nil
		end
	end
end

local function refresh()
	setVisible(level.Value >= MIN_LEVEL)
end

refresh()
level:GetPropertyChangedSignal("Value"):Connect(refresh)
