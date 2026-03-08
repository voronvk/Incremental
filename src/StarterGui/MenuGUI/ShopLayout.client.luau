local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local menuGui = script.Parent
local shop = menuGui:FindFirstChild("Shop")
if not shop then return end

local ButtonScaleEffect = require(ReplicatedStorage.Shared:WaitForChild("ButtonScaleEffect"))
local scroll = shop:WaitForChild("ScrollingFrame", 5)
if not scroll then return end

-- Ejecutar tras un frame para que la GUI esté lista
task.defer(function()
	-- Búsqueda recursiva por si están dentro de un contenedor
	local firstLayout = scroll:FindFirstChild("FirstLayout", true)
		or scroll:FindFirstChild("First Layout", true)
	local secondLayout = scroll:FindFirstChild("SecondLayout", true)
		or scroll:FindFirstChild("Second Layout", true)

-- BuyAll
local BUNDLE_GAMEPASS_ID = 1740820575
local buyAll = nil

if firstLayout then
	buyAll = firstLayout:FindFirstChild("BuyAll")
	local deco = firstLayout:FindFirstChild("Deco")
	if buyAll then
		ButtonScaleEffect.applyScaleEffect(buyAll, deco or buyAll)
		buyAll.Activated:Connect(function()
			MarketplaceService:PromptGamePassPurchase(game.Players.LocalPlayer, BUNDLE_GAMEPASS_ID)
		end)
	end
end

-- IDs de gamepasses por nombre (fallback si no tiene atributo)
local GAMEPASS_BY_NAME = {
	["+100% Luck!"] = 1740916450,
	["Luck"] = 1740916450,
	["Melon X2"] = 1740686732,
	["Melon"] = 1740686732,
	["Ascensión x2"] = 1740630375,
	["Ascension x2"] = 1740630375,
	["Ascension"] = 1740630375,
	["x2 Walkspeed!"] = 1740406688,
	["Walkspeed"] = 1740406688,
}

local function getGamePassId(gui)
	local id = gui:GetAttribute("GamePassId")
		or gui:GetAttribute("GamePassID")
		or gui:GetAttribute("gamePassId")
	if not id and gui.Parent then
		id = gui.Parent:GetAttribute("GamePassId")
			or gui.Parent:GetAttribute("GamePassID")
			or gui.Parent:GetAttribute("gamePassId")
	end
	local numId = type(id) == "number" and id or (type(id) == "string" and tonumber(id))
	if numId then return numId end
	-- Fallback: buscar por nombre del botón o del padre
	return GAMEPASS_BY_NAME[gui.Name] or (gui.Parent and GAMEPASS_BY_NAME[gui.Parent.Name])
end

local function onGamePassButtonClick(btn)
	local numId = getGamePassId(btn)
	if numId then
		MarketplaceService:PromptGamePassPurchase(game.Players.LocalPlayer, numId)
	end
end

local function setupButton(btn)
	ButtonScaleEffect.applyScaleEffect(btn, btn:FindFirstChild("ImageLabel") or btn)
	btn.Activated:Connect(function()
		onGamePassButtonClick(btn)
	end)
end

local function setupLayoutButtons(layout, excludeButton)
	if not layout then return end
	local processed = {}
	for _, desc in ipairs(layout:GetDescendants()) do
		if desc:IsA("GuiButton") and desc ~= excludeButton and not processed[desc] then
			processed[desc] = true
			setupButton(desc)
		end
	end
end

setupLayoutButtons(firstLayout, buyAll)
setupLayoutButtons(secondLayout)

end) -- task.defer
