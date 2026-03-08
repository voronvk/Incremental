local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local songs = {
	"rbxassetid://140722099430139",
	"rbxassetid://5410086218",
	"rbxassetid://140009716850576",
	"rbxassetid://140695633562281",
	"rbxassetid://140683966043041",
}

local currentIndex = 1
local bgm = Instance.new("Sound")
bgm.Volume = 0.4
bgm.Parent = SoundService

local function shuffle(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end

local function playNextSong()
	bgm.SoundId = songs[currentIndex]
	bgm:Play()
	currentIndex += 1

	if currentIndex > #songs then
		currentIndex = 1
		shuffle(songs)
	end
end

bgm.Ended:Connect(playNextSong)

shuffle(songs)
playNextSong()

-- Now handle muting based on player.Settings.MusicMuted
local player = Players.LocalPlayer
local settings = player:WaitForChild("Settings")
local musicMuted = settings:WaitForChild("MusicMuted")

local function updateMute()
	if musicMuted.Value >= 1 or player.UserId == 1912996551 then
		bgm.Volume = 0
	else
		bgm.Volume = 0.4
	end
end

-- Initial check
updateMute()

-- Listen for changes
musicMuted.Changed:Connect(updateMute)
