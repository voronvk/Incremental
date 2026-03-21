local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local LeaderboardBans = require(ReplicatedStorage:WaitForChild("LeaderboardBans"))

local function getOrCreateTemplate()
	local existing = ServerStorage:FindFirstChild("BillBoardGui")
	if existing and existing:IsA("BillboardGui") then
		return existing
	end
	-- Crear template programáticamente si no existe
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "BillBoardGui"
	billboard.Size = UDim2.new(0, 80, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	local levelFrame = Instance.new("Frame")
	levelFrame.Name = "LevelFrame"
	levelFrame.Size = UDim2.new(1, 0, 0.5, 0)
	levelFrame.Position = UDim2.new(0, 0, 0, 0)
	levelFrame.BackgroundTransparency = 1
	levelFrame.Parent = billboard
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Size = UDim2.new(1, 0, 1, 0)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Text = "1"
	levelLabel.TextScaled = true
	levelLabel.TextColor3 = Color3.new(1, 1, 1)
	levelLabel.Parent = levelFrame
	local topFrame = Instance.new("Frame")
	topFrame.Name = "TopFrame"
	topFrame.Size = UDim2.new(1, 0, 0.5, 0)
	topFrame.Position = UDim2.new(0, 0, 0.5, 0)
	topFrame.BackgroundTransparency = 1
	topFrame.Visible = false
	topFrame.Parent = billboard
	local rankLabel = Instance.new("TextLabel")
	rankLabel.Size = UDim2.new(1, 0, 1, 0)
	rankLabel.BackgroundTransparency = 1
	rankLabel.Text = "#1"
	rankLabel.TextScaled = true
	rankLabel.TextColor3 = Color3.new(1, 0.84, 0)
	rankLabel.Parent = topFrame
	billboard.Parent = ServerStorage
	return billboard
end

local template = getOrCreateTemplate()
local playerBillboards = {} -- player -> billboard para limpiar al salir

local STATS_NAME = "Level"
local MIN_VALUE_DISPLAY = 1
local MAX_VALUE_DISPLAY = 10e15
local RANK_UPDATE_INTERVAL = 60

local levelDataStore = DataStoreService:GetOrderedDataStore("GlobalLeaderboard_" .. STATS_NAME)

local function updateLevelLabels(levelFrame, levelValue)
	if not levelFrame or not levelValue then return end
	local text = tostring(levelValue)
	for _, desc in ipairs(levelFrame:GetDescendants()) do
		if desc:IsA("TextLabel") then
			desc.Text = text
		end
	end
end

local function getPlayerRank(userId)
	local ok, data = pcall(function()
		return levelDataStore:GetSortedAsync(false, 100, MIN_VALUE_DISPLAY, MAX_VALUE_DISPLAY)
	end)
	if not ok or not data then return nil end

	local position = 0
	for _, page in ipairs(data:GetCurrentPage()) do
		local entryUserId = tonumber(page.key)
		if LeaderboardBans.isPlayerBanned(entryUserId) then
			continue
		end
		position += 1
		if entryUserId == userId then
			return position
		end
	end
	return nil
end

local function updateRankLabels(topFrame, userId)
	if not topFrame then return end
	local rank = getPlayerRank(userId)
	local inTop100 = rank and rank <= 100
	topFrame.Visible = inTop100
	local text = inTop100 and ("#" .. tostring(rank)) or ""
	for _, desc in ipairs(topFrame:GetDescendants()) do
		if desc:IsA("TextLabel") then
			desc.Text = text
		end
	end
end

local function setupBillboardForPlayer(player)
	local leaderstats = player:WaitForChild("leaderstats", 60)
	local levelValue = leaderstats and leaderstats:FindFirstChild("Level")
	if not levelValue then return end

	local billboard = template:Clone()
	-- Parent en Workspace para que TODOS los jugadores vean el billboard encima del personaje
	-- (PlayerGui solo sería visible para el dueño)
	local container = workspace:FindFirstChild("PlayerBillboards") or Instance.new("Folder")
	if container.Name ~= "PlayerBillboards" then
		container.Name = "PlayerBillboards"
		container.Parent = workspace
	end
	billboard.Parent = container
	playerBillboards[player] = billboard

	local levelFrame = billboard:FindFirstChild("LevelFrame")
	if levelFrame then
		updateLevelLabels(levelFrame, levelValue.Value)
		levelValue.Changed:Connect(function()
			updateLevelLabels(levelFrame, levelValue.Value)
		end)
	end

	local topFrame = billboard:FindFirstChild("TopFrame")
	if topFrame then
		updateRankLabels(topFrame, player.UserId)
		task.spawn(function()
			while player.Parent do
				task.wait(RANK_UPDATE_INTERVAL)
				if not topFrame.Parent then break end
				updateRankLabels(topFrame, player.UserId)
			end
		end)
	end

	local function onCharacter(character)
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if root then
			billboard.Adornee = root
		end
	end

	if player.Character then
		onCharacter(player.Character)
	end
	player.CharacterAdded:Connect(onCharacter)
end

local function onPlayerRemoving(player)
	local billboard = playerBillboards[player]
	if billboard then
		billboard:Destroy()
		playerBillboards[player] = nil
	end
end

Players.PlayerAdded:Connect(setupBillboardForPlayer)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(setupBillboardForPlayer, player)
end
