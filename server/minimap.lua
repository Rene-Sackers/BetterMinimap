class "BetterMinimap"

function BetterMinimap:__init()
	self.timeoutTimer = Timer()
	self.timeout = 5
	
	self.invisiblePlayers = {}
	
	Events:Subscribe("PostTick", self, self.PostTick)
	Events:Subscribe("PlayerChat", self, self.PlayerChat)
end

function BetterMinimap:PostTick()
	if self.timeoutTimer:GetSeconds() < self.timeout then return end
	self.timeoutTimer:Restart()

	local playerPositions = {}
	
	for player in Server:GetPlayers() do
		local playerId = player:GetId()
		if self.invisiblePlayers[playerId] == nil then
			playerPositions[playerId] = {position = player:GetPosition(), color = player:GetColor(), worldId = player:GetWorld():GetId()}
		end
	end
	
	Network:Broadcast("BetterMinimapPlayerPositions", playerPositions)
end

function BetterMinimap:PlayerChat(args)
	local text = args.text
	local playerId = args.player:GetId()
	
	if text ~= "/minimap" then return end
	
	if self.invisiblePlayers[playerId] == nil then
		self.invisiblePlayers[playerId] = true
		Chat:Send(args.player, "You are now invisible on the minimap.", Color(255, 0, 0))
	else
		self.invisiblePlayers[playerId] = nil
		Chat:Send(args.player, "You are now visible on the minimap.", Color(255, 0, 0))
	end
end

BetterMinimap()