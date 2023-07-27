local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('stretcher:server:GetPlayerStatus', function(_, cb, playerId)
	local Player = QBCore.Functions.GetPlayer(playerId)
    local inLaststand, isDead = Player.PlayerData.metadata['inlaststand'], Player.PlayerData.metadata['isdead']
    -- print("server", inLaststand, isDead)
    cb(inLaststand, isDead)
end)