local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('stretcher:server:GetPlayerStatus', function(_, cb, playerId)
	local Player = QBCore.Functions.GetPlayer(playerId)
    local inLaststand, isDead = Player.PlayerData.metadata['inlaststand'], Player.PlayerData.metadata['isdead']
    -- print("server", inLaststand, isDead)
    cb(inLaststand, isDead)
end)

RegisterServerEvent("stretcher:server:PlaceOnStretcher")
AddEventHandler("stretcher:server:PlaceOnStretcher", function(playerServerId, stretcher)
    print('placeonstretcher', playerServerId)
    TriggerClientEvent('stretcher:client:GetPlacedOnStretcher', playerServerId, stretcher)
end)


RegisterServerEvent("stretcher:server:RemoveFromStretcher")
AddEventHandler("stretcher:server:RemoveFromStretcher", function(playerServerId, stretcher)
    print('RemoveFromStretcher', playerServerId)
    TriggerClientEvent('stretcher:client:GetRemovedFromStretcher', playerServerId, stretcher)
end)
