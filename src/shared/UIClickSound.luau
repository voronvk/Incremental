-- Sonido "pop" reutilizable para cada click en UI
-- ID: 139009780109934

local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local POP_SOUND_ID = "rbxassetid://139009780109934"

local cachedSound = nil

local function getSound()
	if not cachedSound then
		cachedSound = Instance.new("Sound")
		cachedSound.SoundId = POP_SOUND_ID
		cachedSound.Volume = 1
		cachedSound.Parent = SoundService
	end
	return cachedSound
end

-- Reproduce el pop (respeta SfxMuted)
local function playPop()
	local player = Players.LocalPlayer
	local settings = player:FindFirstChild("Settings")
	local sfxMuted = settings and settings:FindFirstChild("SfxMuted")
	if sfxMuted and sfxMuted.Value >= 1 then
		return
	end
	local sound = getSound()
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

return {
	playPop = playPop,
	connectToButton = connectToButton,
}
