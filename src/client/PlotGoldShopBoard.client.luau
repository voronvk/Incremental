--[[
	Plot.GoldShopBoard.Display.SurfaceGui.FrameList.RebirthFrame:
	botones 5Gold, 10Gold, 20Gold, 50Gold → Developer Products; sonido al comprar (mismo que rebirth).
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local ButtonScaleEffect = require(ReplicatedStorage.Shared:WaitForChild("ButtonScaleEffect"))

local BUTTON_PRODUCTS: { [string]: number } = {
	["5Gold"] = 3569370365,
	["10Gold"] = 3569372988,
	["20Gold"] = 3569373149,
	["50Gold"] = 3569373371,
}

local productSet: { [number]: boolean } = {}
for _, id in BUTTON_PRODUCTS do
	productSet[id] = true
end

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://140206660137491"
sound.Parent = SoundService

local function isSfxMuted(): boolean
	local settings = player:FindFirstChild("Settings")
	local sfx = settings and settings:FindFirstChild("SfxMuted")
	return sfx ~= nil and sfx:IsA("IntValue") and sfx.Value >= 1
end

local function playPurchaseSound()
	if isSfxMuted() then
		return
	end
	sound.Volume = 1
	sound:Play()
end

local function connectGoldButton(btn: GuiButton, productId: number)
	if btn:GetAttribute("GoldShopBound") then
		return
	end
	btn:SetAttribute("GoldShopBound", true)

	local img = btn:FindFirstChild("ImageLabel")
	ButtonScaleEffect.applyScaleEffect(btn, img or btn)

	local function prompt()
		MarketplaceService:PromptProductPurchase(player, productId)
	end

	if btn:IsA("TextButton") or btn:IsA("ImageButton") then
		btn.Activated:Connect(prompt)
	else
		btn.MouseButton1Click:Connect(prompt)
	end
end

local function bindGoldShopBoard(goldShopBoard: Instance)
	if goldShopBoard:GetAttribute("PlotGoldShopBound") then
		return
	end

	local display = goldShopBoard:FindFirstChild("Display")
	if not display then
		return
	end

	local surfaceGui = display:FindFirstChild("SurfaceGui")
	if not surfaceGui or not surfaceGui:IsA("SurfaceGui") then
		return
	end

	local frameList = surfaceGui:FindFirstChild("FrameList")
	if not frameList then
		return
	end

	local rebirthFrame = frameList:FindFirstChild("RebirthFrame")
	if not rebirthFrame then
		return
	end

	goldShopBoard:SetAttribute("PlotGoldShopBound", true)

	for buttonName, productId in BUTTON_PRODUCTS do
		local btn = rebirthFrame:FindFirstChild(buttonName, true)
		if btn and btn:IsA("GuiButton") then
			connectGoldButton(btn, productId)
		end
	end
end

MarketplaceService.PromptProductPurchaseFinished:Connect(function(plr, productId, purchased)
	local isLocal = false
	if type(plr) == "number" then
		isLocal = plr == player.UserId
	else
		isLocal = plr == player
	end
	if isLocal and purchased and type(productId) == "number" and productSet[productId] then
		playPurchaseSound()
	end
end)

local function tryBindUnderPlot(plot: Instance)
	local board = plot:FindFirstChild("GoldShopBoard")
	if board then
		bindGoldShopBoard(board)
	end
end

local function watchTappingRoot(tappingRoot: Instance)
	local plot = tappingRoot:FindFirstChild("Plot")
	if plot then
		tryBindUnderPlot(plot)
		plot.ChildAdded:Connect(function(ch)
			if ch.Name == "GoldShopBoard" then
				bindGoldShopBoard(ch)
			end
		end)
	end
	tappingRoot.DescendantAdded:Connect(function(desc)
		if desc.Name == "GoldShopBoard" and desc.Parent and desc.Parent.Name == "Plot" then
			bindGoldShopBoard(desc)
		end
	end)
end

local clientTapping = workspace:WaitForChild("ClientTapping")

for _, ch in clientTapping:GetChildren() do
	watchTappingRoot(ch)
end
clientTapping.ChildAdded:Connect(watchTappingRoot)
