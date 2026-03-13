local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local LeaderboardBans = require(ReplicatedStorage:WaitForChild("LeaderboardBans"))

local template = ServerStorage:WaitForChild("BillBoardGui")

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
	billboard.Parent = player:WaitForChild("PlayerGui")

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

Players.PlayerAdded:Connect(setupBillboardForPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(setupBillboardForPlayer, player)
end
