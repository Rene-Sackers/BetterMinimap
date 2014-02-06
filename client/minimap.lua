class "BetterMinimap"

function BetterMinimap:__init()
	self.playerPositions = {}
	self.currentPlayerId = LocalPlayer:GetId()
	
	Network:Subscribe("BetterMinimapPlayerPositions", self, self.PlayerPositions)
	Events:Subscribe("Render", self, self.Render)
end

function BetterMinimap.Clamp(value, minimum, maximum)
	if value < minimum then
		value = minimum
	elseif value > maximum then
		value = maximum
	end
	
	return value
end

function BetterMinimap:PlayerPositions(positions)
	self.playerPositions = positions
end

function Vector3:IsNaN()
	return (self.x ~= self.x) or (self.y ~= self.y) or (self.z ~= self.z)
end

function BetterMinimap:Render()
	if Game:GetState() ~= GUIState.Game or then return end

	local updatedPlayers = {}
	for player in Client:GetStreamedPlayers() do
		local position = player:GetPosition()
		if not position:IsNaN() then
			updatedPlayers[player:GetId()] = true
			
			BetterMinimap.DrawPlayer(position, player:GetColor())
		end
	end
	
	for playerId, data in pairs(self.playerPositions) do
		-- Not streamed
		if not updatedPlayers[playerId] and self.currentPlayerId ~= playerId and LocalPlayer:GetWorld():GetId() == data.worldId then
			BetterMinimap.DrawPlayer(data.position, data.color)
		end
	end
end

function BetterMinimap.DrawPlayer(position, color)
	local pos, ok = Render:WorldToMinimap(position)
	local playerPosition = LocalPlayer:GetPosition()
	local distance = Vector3.Distance(playerPosition, position)
	
	local size = BetterMinimap.Clamp(5 - (distance * 0.00025), 2, 5)
	Render:FillCircle(pos, size, color)
end

BetterMinimap()