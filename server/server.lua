local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('stretcher:server:GetPlayerStatus', function(_, cb, playerId)
	local Player = QBCore.Functions.GetPlayer(playerId)
    local inLaststand, isDead = Player.PlayerData.metadata['inlaststand'], Player.PlayerData.metadata['isdead']
    -- print("server", inLaststand, isDead)
    cb(inLaststand, isDead)
end)

QBCore.Commands.Add("setgod", "Set player's permission level to god", {}, false, function(source, args)
    local target = tonumber(args[1])

    if target then
        local player = QBCore.Functions.GetPlayer(target)

        if player then
            player.set('permission_level', 'god')
            TriggerClientEvent('QBCore:Notify', source, 'Permission level set to god for player ID ' .. target)
        else
            TriggerClientEvent('QBCore:Notify', source, 'Invalid player ID')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, 'Invalid syntax! Usage: /setgod [playerId]')
    end
end, 'admin')