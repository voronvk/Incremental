-- Sonido "pop" reutilizable para cada click en UI
-- ID: 139009780109934

local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local POP_SOUND_ID = "rbxassetid://139009780109934"

local cachedSound = nil
local cachedByAssetId: { [string]: Sound } = {}

local function getSound()
	if not cachedSound then
		cachedSound = Instance.new("Sound")
		cachedSound.SoundId = POP_SOUND_ID
		cachedSound.Volume = 1
		cachedSound.Parent = SoundService
	end
	return cachedSound
end

local function isSfxMuted(): boolean
	local player = Players.LocalPlayer
	local settings = player:FindFirstChild("Settings")
	local sfxMuted = settings and settings:FindFirstChild("SfxMuted")
	return sfxMuted ~= nil and sfxMuted.Value >= 1
end

-- Reproduce el pop (respeta SfxMuted)
local function playPop()
	if isSfxMuted() then
		return
	end
	local sound = getSound()
	sound:Play()
end

local function getOrCreateSoundForAssetId(assetId: string): Sound
	local existing = cachedByAssetId[assetId]
	if existing then
		return existing
	end
	local sound = Instance.new("Sound")
	sound.SoundId = assetId
	sound.Volume = 1
	sound.Parent = SoundService
	cachedByAssetId[assetId] = sound
	return sound
end

-- rbxassetid numérico o string completo; respeta SfxMuted
local function playSoundId(soundId: number | string)
	if isSfxMuted() then
		return
	end
	local assetId = if type(soundId) == "number" then string.format("rbxassetid://%d", soundId) else soundId
	local sound = getOrCreateSoundForAssetId(assetId)
	sound:Play()
end

-- Conecta el pop a un botón (GuiButton o Frame/ImageButton con MouseButton1Click)
local function connectToButton(button)
	if not button then return end
	if button:IsA("GuiButton") then
		button.Activated:Connect(playPop)
	else
		button.MouseButton1Click:Connect(playPop)
	end
end

local function connectToButtonWithSoundId(button, soundId: number | string)
	if not button then return end
	local function play()
		playSoundId(soundId)
	end
	if button:IsA("GuiButton") then
		button.Activated:Connect(play)
	else
		button.MouseButton1Click:Connect(play)
	end
end

return {
	playPop = playPop,
	playSoundId = playSoundId,
	connectToButton = connectToButton,
	connectToButtonWithSoundId = connectToButtonWithSoundId,
}
