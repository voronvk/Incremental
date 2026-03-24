--[[
	SpawnHelper - Utilidad para spawn flexible basado en el mapa.
	Coloca "SpawnPoints" (Attachments o Parts) o usa un Part "SpawnArea" en tu mapa
	para definir dónde pueden aparecer objetos. Si no existen, usa el Part de fallback.
]]

local function getRandomSpawnPosition(spawnRoot)
	if not spawnRoot then return nil end

	-- Opción 1: Carpeta SpawnPoints (en spawnRoot o en su parent)
	local pointsFolder = spawnRoot:FindFirstChild("SpawnPoints") or (spawnRoot.Parent and spawnRoot.Parent:FindFirstChild("SpawnPoints"))
	if pointsFolder and #pointsFolder:GetChildren() > 0 then
		local children = pointsFolder:GetChildren()
		local valid = {}
		for _, child in ipairs(children) do
			if child:IsA("Attachment") then
				table.insert(valid, child.WorldPosition)
			elseif child:IsA("BasePart") then
				table.insert(valid, child.Position)
			end
		end
		if #valid > 0 then
			return valid[math.random(1, #valid)]
		end
	end

	-- Opción 2: Part SpawnArea o el propio spawnRoot como Part
	local part = spawnRoot:IsA("BasePart") and spawnRoot or spawnRoot:FindFirstChild("SpawnArea")
	if not part or not part:IsA("BasePart") then
		return nil
	end

	-- Punto aleatorio dentro del Part (respeta CFrame/rotación)
	local size = part.Size
	local edgeBuffer = 1
	local halfX = math.max(0, (size.X - 2 * edgeBuffer) / 2)
	local halfZ = math.max(0, (size.Z - 2 * edgeBuffer) / 2)
	local rx = (math.random() * 2 - 1) * halfX
	local rz = (math.random() * 2 - 1) * halfZ
	local ry = size.Y / 2 + 0.75 + math.random() * 0.5
	local localPos = Vector3.new(rx, ry, rz)
	return part.CFrame:PointToWorldSpace(localPos)
end

return {
	getRandomSpawnPosition = getRandomSpawnPosition,
}
