-- Tras comprar un gamepass, el servidor verifica y pone OwnsGP_* (evita retrasos del marketplace en cliente)
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local syncFn = ReplicatedStorage:WaitForChild("GamePassSyncRequest")

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(_, gamePassId, purchased)
	if purchased and type(gamePassId) == "number" then
		pcall(function()
			syncFn:InvokeServer(gamePassId)
		end)
	end
end)
