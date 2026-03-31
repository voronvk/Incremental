-- Cuenta atrás hasta la fecha de la próxima actualización (CountDownPart en Workspace).
-- Ajusta la fecha de abajo cuando fijes la nueva salida.

local RunService = game:GetService("RunService")

local part = workspace:WaitForChild("CountDownPart")
local countGui = part:WaitForChild("CountGui")
local label = countGui:WaitForChild("CountLabel")

-- Fecha/hora objetivo: 4 de abril 2026 a las 13:00 hora España (CEST, UTC+2).
-- Para que sea igual para todos los jugadores, lo convertimos a UTC.
local TARGET_UNIX_UTC = DateTime.fromUniversalTime(2026, 4, 4, 11, 0, 0).UnixTimestamp

local function formatRemaining(totalSeconds: number): string
	totalSeconds = math.max(0, math.floor(totalSeconds))
	local days = math.floor(totalSeconds / 86400)
	totalSeconds -= days * 86400
	local hours = math.floor(totalSeconds / 3600)
	totalSeconds -= hours * 3600
	local minutes = math.floor(totalSeconds / 60)
	local seconds = math.floor(totalSeconds - minutes * 60)
	return string.format("%02dd %02dh %02dm %02ds", days, hours, minutes, seconds)
end

local acc = 0
RunService.Heartbeat:Connect(function(dt)
	acc += dt
	if acc < 0.25 then
		return
	end
	acc = 0
	local remaining = TARGET_UNIX_UTC - DateTime.now().UnixTimestamp
	label.Text = formatRemaining(remaining)
end)
