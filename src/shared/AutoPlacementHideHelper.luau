local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

type PartState = {
	baseCFrame: CFrame,
	baseTransparency: number,
	baseCanCollide: boolean,
	baseCanQuery: boolean,
	baseCanTouch: boolean,
	baseY: number,
}

local M = {}

local cache: {[Instance]: PartState} = {}
local captured = false

local function findWorkspaceInstanceByPath(pathParts: {string})
	local cur: Instance = Workspace
	for _, name in ipairs(pathParts) do
		cur = cur:FindFirstChild(name)
		if not cur then
			return nil
		end
	end
	return cur
end

local function captureFromTemplate(templateObj: Instance, pathParts: {string})
	for _, child in ipairs(templateObj:GetChildren()) do
		local newPath = {}
		for i, name in ipairs(pathParts) do
			newPath[i] = name
		end
		newPath[#pathParts + 1] = child.Name
		captureFromTemplate(child, newPath)
	end

	if templateObj:IsA("BasePart") then
		local wsInst = findWorkspaceInstanceByPath(pathParts)
		if wsInst and wsInst:IsA("BasePart") then
			local base = templateObj
			cache[wsInst] = {
				baseCFrame = base.CFrame,
				baseTransparency = base.Transparency,
				baseCanCollide = base.CanCollide,
				baseCanQuery = base.CanQuery,
				baseCanTouch = base.CanTouch,
				baseY = base.CFrame.Position.Y,
			}
		end
	end
end

local function capture()
	if captured then return end
	captured = true

	local cloneFolder = ReplicatedStorage:WaitForChild("CloneFolder")
	for _, child in ipairs(cloneFolder:GetChildren()) do
		captureFromTemplate(child, { child.Name })
	end
end

function M.start(opts)
	opts = opts or {}
	local hiddenDeltaY = opts.hiddenDeltaY or 60
	local interval = opts.interval or 0.25

	capture()

	task.spawn(function()
		while true do
			for inst, st in pairs(cache) do
				if inst and inst.Parent then
					local hidden = inst.Position.Y < (st.baseY - hiddenDeltaY)
					if hidden then
						inst.Transparency = 1
						inst.CanCollide = false
						inst.CanQuery = false
						inst.CanTouch = false
					else
						-- Restaurar exactamente la posición del template clonado.
						inst.CFrame = st.baseCFrame
						inst.Transparency = st.baseTransparency
						inst.CanCollide = st.baseCanCollide
						inst.CanQuery = st.baseCanQuery
						inst.CanTouch = st.baseCanTouch
					end
				end
			end
			task.wait(interval)
		end
	end)
end

return M

