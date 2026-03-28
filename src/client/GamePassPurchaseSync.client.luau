-- Tras comprar un gamepass, el servidor verifica y pone OwnsGP_* (evita retrasos del marketplace en cliente)
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local syncFn = ReplicatedStorage:WaitForChild("GamePassSyncRequest")
local announce = ReplicatedStorage:WaitForChild("GamePassPurchaseAnnounce")

-- Mismo sonido de "unlock" que usan los boards / upgrades del juego
local UNLOCK_SOUND_ID = "rbxassetid://140206660137491"

local function playUnlockSound()
	local s = Instance.new("Sound")
	s.SoundId = UNLOCK_SOUND_ID
	s.Volume = 0.65
	s.Parent = SoundService
	s.Ended:Connect(function()
		s:Destroy()
	end)
	s:Play()
end

local function showGlobalChatMessage(message)
	if type(message) ~= "string" or message == "" then
		return
	end
	local showed = false
	pcall(function()
		local channels = TextChatService:FindFirstChild("TextChannels")
		local general = channels and channels:FindFirstChild("RBXGeneral")
		if general and general:IsA("TextChannel") then
			general:DisplaySystemMessage(message)
			showed = true
		end
	end)
	if showed then
		return
	end
	pcall(function()
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = message,
			Color = Color3.fromRGB(255, 210, 90),
		})
	end)
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(_, gamePassId, purchased)
	if not purchased or type(gamePassId) ~= "number" then
		return
	end
	local success = false
	pcall(function()
		success = syncFn:InvokeServer(gamePassId) == true
	end)
	if success then
		playUnlockSound()
	end
end)

announce.OnClientEvent:Connect(showGlobalChatMessage)
