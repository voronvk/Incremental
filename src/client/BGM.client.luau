local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Attr = require(ReplicatedStorage.Shared:WaitForChild("PlayerClientAttributes"))

local songs = {
	"rbxassetid://140722099430139",
	"rbxassetid://5410086218",
	"rbxassetid://140009716850576",
	"rbxassetid://140695633562281",
	"rbxassetid://140683966043041",
}

local currentIndex = 1
local bgm = Instance.new("Sound")
bgm.Name = "ClientBackgroundMusic"
local BASE_BGM_VOLUME = 0.4
local RUNE_UI_VOLUME_MULT = 0.18
bgm.Volume = BASE_BGM_VOLUME
bgm.Parent = SoundService

local player = Players.LocalPlayer
local volTween: Tween? = nil

local function tweenBgmVolume(target: number)
	if volTween then
		volTween:Cancel()
		volTween = nil
	end
	if math.abs(bgm.Volume - target) < 0.001 then
		return
	end
	volTween = TweenService:Create(
		bgm,
		TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Volume = target }
	)
	volTween.Completed:Connect(function()
		volTween = nil
	end)
	volTween:Play()
end

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

-- Mute por ajustes + bajar volumen mientras la tienda de runas (pedestal) está abierta
local settings = player:WaitForChild("Settings")
local musicMuted = settings:WaitForChild("MusicMuted")

local function updateMute()
	if musicMuted.Value >= 1 or player.UserId == 1912996551 then
		if volTween then
			volTween:Cancel()
			volTween = nil
		end
		bgm.Volume = 0
		return
	end
	local runeShop = player:GetAttribute(Attr.RUNE_TOUCH_SHOP_OPEN) == true
	local target = runeShop and (BASE_BGM_VOLUME * RUNE_UI_VOLUME_MULT) or BASE_BGM_VOLUME
	tweenBgmVolume(target)
end

updateMute()
musicMuted.Changed:Connect(updateMute)
player:GetAttributeChangedSignal(Attr.RUNE_TOUCH_SHOP_OPEN):Connect(updateMute)
