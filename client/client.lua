local QBCore = exports['qb-core']:GetCoreObject()
local stretcher = nil
local isEscorted = false

local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
end

local function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end
end

local function GetClosestPlayer()
    local players = QBCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(PlayerPedId())

    for i = 1, #players do
        local playerId = players[i]
        if playerId ~= PlayerId() then
            local playerPed = GetPlayerPed(playerId)
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - coords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

local function ShowNotification(msg)
    SetNotificationTextEntry('STRING')
    AddTextComponentSubstringWebsite(msg)
    DrawNotification(false, true)
end

local function PickUpStretcher(stretcherObject)
    local playerPed = PlayerPedId()
    local dict = "anim@heists@box_carry@"

    LoadAnimDict(dict)

    NetworkRequestControlOfEntity(strObject)
    AttachEntityToEntity(stretcherObject, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, -0.6, -1.43, 180.0, 164.0, 90.0, 0.0, false, false, true, false, 2, true)

    while IsEntityAttachedToEntity(stretcherObject, playerPed) do
        Citizen.Wait(0)
        DisableControlAction(1, 140, true)  -- Disable punching while carrying the stretcher
        DisableControlAction(1, 141, true)
        DisableControlAction(1, 142, true)

        if not IsEntityPlayingAnim(playerPed, dict, 'idle', 3) then
            TaskPlayAnim(playerPed, dict, 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
        end

        if IsPedDeadOrDying(playerPed) or IsControlJustPressed(0, 73) then
            DetachEntity(stretcherObject, true, true)
            ClearPedTasks(playerPed)
            StopAnimTask(playerPed, dict, 'idle', 1.0)
            EnableControlAction(1, 140, true)  -- Re-enable punching
            EnableControlAction(1, 141, true)
            EnableControlAction(1, 142, true)
        end
    end
end

local function PlaceStretcher()
    local playerPed = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.0, 0.0)
    local heading = GetEntityHeading(playerPed)

    stretcher = CreateObject(GetHashKey(Config.StretcherModel), coords.x, coords.y, coords.z, true, true, true)
    SetEntityHeading(stretcher, heading)
    PlaceObjectOnGroundProperly(stretcher)
    
    TriggerEvent('stretcher:pushstretcher')
    print("Stretcher placed.")
end

local function RemoveStretcher()
    if stretcher ~= nil then
        DeleteEntity(stretcher)
        stretcher = nil
        print("Stretcher removed.")
    else
        print("There is no stretcher placed.")
    end
end

local function ToggleStretcherInCar()
    local playerPed = PlayerPedId()
    local veh = VehicleInFront()
    local closestObject = GetClosestObjectOfType(GetEntityCoords(playerPed), 3.0, GetHashKey(Config.StretcherModel), false)
    local isAttachedToVehicle = IsEntityAttachedToAnyVehicle(closestObject) or IsEntityAttachedToEntity(closestObject, veh)

    if isAttachedToVehicle then
        StretcherOutCar(closestObject, playerPed)
    else
        StretcherToCar(closestObject, veh)
    end

    StopAnimTask(playerPed, "anim@heists@box_carry@", 'idle', 1.0)
end

local function StretcherToCar(stretcherObject, vehicle)
    local playerPed = PlayerPedId()

    if GetVehiclePedIsIn(playerPed, false) == 0 and DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        AttachEntityToEntity(stretcherObject, vehicle, 0.0, 0.0, -2.0, 0.0, 0.0, 0.0, 90.0, false, false, true, false, 2, true)
        FreezeEntityPosition(stretcherObject, true)
    else
        print("Car does not exist.")
    end
end

local function StretcherOutCar(stretcherObject)
    local playerPed = PlayerPedId()

    if DoesEntityExist(stretcherObject) then
        DetachEntity(stretcherObject, true, true)
        FreezeEntityPosition(stretcherObject, false)
        SetEntityCoords(stretcherObject, GetEntityCoords(playerPed))
        PlaceObjectOnGroundProperly(stretcherObject)
        TriggerEvent('stretcher:pushstretcher')
    else
        print("Stretcher does not exist.")
    end
end

local function LayOnStretcher(stretcherObject, playerPed)
    if playerPed == nil then -- if called by another person
        local playerPed = PlayerPedId()
    end
    local closestPlayer, closestPlayerDist = GetClosestPlayer()

    if closestPlayer ~= nil and closestPlayerDist <= 1.5 then
        if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), 'anim@gangops@morgue@table@', 'ko_front', 3) then
            ShowNotification("Somebody is already using the stretcher!")
            return
        end
    end

    LoadAnimDict('anim@gangops@morgue@table@')

    isEscorted = true
    TriggerEvent('hospital:client:isEscorted', isEscorted)
    DetachEntity(playerPed, true, true)
    AttachEntityToEntity(playerPed, stretcherObject, 0, -0.09, 0.02, 1.9, 0.0, 0.0, 266.0, 0.0, false, false, false, false, 2, true)

    local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(playerPed))
    local stillSitting = true
    local playerDied = false
    local playerNotDead = false

    Citizen.CreateThread(function()
        -- This needs to be repeated in order to detect when the player has
        -- transistioned from inLaststand to isDead
        repeat
            -- Citizen.Wait(0)
            QBCore.Functions.TriggerCallback('stretcher:server:GetPlayerStatus', function(inLaststand, isDead)
                if not isDead and not IsEntityPlayingAnim(playerPed, 'anim@gangops@morgue@table@', 'ko_front', 3) then
                    TaskPlayAnim(playerPed, 'anim@gangops@morgue@table@', 'ko_front', 8.0, 8.0, -1, 69, 1, false, false, false)
                end

                if IsControlPressed(0, 32) then
                    PlaceObjectOnGroundProperly(stretcherObject)
                end

                if IsControlJustPressed(0, 73) then
                    TriggerEvent("unsit", stretcherObject, playerPed)
                    stillSitting = false
                end

                if isDead then
                    playerDied = true
                    return
                end

                if not isDead and not inLaststand then
                    playerNotDead = true
                end
            end, playerId)

            Citizen.Wait(0)

        until playerNotDead or playerDied or not stillSitting

        if playerNotDead or playerDied then
            AttachEntityToEntity(playerPed, stretcherObject, 0, -0.09, 0.02, 1.9, 0.0, 0.0, 266.0, 0.0, false, false, false, false, 2, true)
            stillSitting = true

            while stillSitting do
                Citizen.Wait(5)

                if not IsEntityAttachedToEntity(playerPed, stretcherObject) then
                    TriggerEvent('unsit', stretcherObject)
                    stillSitting = false
                    print("No longer attached.")
                end

                if IsControlPressed(0, 32) then
                    PlaceObjectOnGroundProperly(stretcherObject)
                end

                if IsControlJustPressed(0, 73) then
                    TriggerEvent("unsit", stretcherObject, playerPed)
                    stillSitting = false
                end
            end
        end
    end)
end

local function UnsitFromStretcher(stretcherObject, playerPed)
    isEscorted = false
    TriggerEvent('hospital:client:isEscorted', isEscorted)
    ClearPedTasks(playerPed)

    DetachEntity(playerPed, true, true)
    SetEntityCoords(playerPed, table.unpack(GetEntityCoords(stretcherObject) + GetEntityForwardVector(stretcherObject) * -0.7))
end

RegisterNetEvent("stretcher:pushstretcher")
AddEventHandler("stretcher:pushstretcher", function()
    local playerPed = PlayerPedId()
    local pedCoords = GetEntityCoords(playerPed)
    local closestObject = GetClosestObjectOfType(pedCoords, 3.0, GetHashKey(Config.StretcherModel), false)

    if DoesEntityExist(closestObject) then
        local strCoords = GetEntityCoords(closestObject)
        local strVecForward = GetEntityForwardVector(closestObject)
        local sitCoords = strCoords + strVecForward * -0.5
        local pickupCoords = strCoords + strVecForward * 0.3

        if GetDistanceBetweenCoords(pedCoords, pickupCoords, true) <= 2.0 then
            PickUpStretcher(closestObject)
        end
    end 
end)

RegisterCommand("push", function()
    TriggerEvent('stretcher:pushstretcher')
end)

RegisterCommand("lay", function()
    TriggerEvent('stretcher:getonstretcher')
end)

RegisterCommand("spawnstr", function()
    if QBCore.Functions.GetPlayerData().job.name == 'ambulance' then
        if stretcher == nil then
            PlaceStretcher()
        else
            print("The stretcher is already placed.")
        end
    else
        TriggerEvent("QBCore:Notify", "You must be NHS to do this!", "error")
    end
end, false)

RegisterCommand("removestr", function()
    if QBCore.Functions.GetPlayerData().job.name == 'ambulance' then
        RemoveStretcher()
    else
        TriggerEvent("QBCore:Notify", "You must be NHS to do this!", "error")
    end
end, false)

RegisterNetEvent("stretcher:getonstretcher")
AddEventHandler("stretcher:getonstretcher", function()
    local playerPed = PlayerPedId()
    local pedCoords = GetEntityCoords(playerPed)
    local closestObject = GetClosestObjectOfType(pedCoords, 3.0, GetHashKey(Config.StretcherModel), false)

    if DoesEntityExist(closestObject) then
        local strCoords = GetEntityCoords(closestObject)
        local strVecForward = GetEntityForwardVector(closestObject)
        local sitCoords = strCoords + strVecForward * -0.5
        local pickupCoords = strCoords + strVecForward * 0.3

        if GetDistanceBetweenCoords(pedCoords, sitCoords, true) <= 2.0 then
            LayOnStretcher(closestObject, playerPed)
        end
    end
end)

-- This is an attempt to allow another player to trigger the clientside events
RegisterNetEvent('stretcher:test')
AddEventHandler('stretcher:test', function()
    local playerPed, distance = GetClosestPlayer()
    
    if playerPed ~= -1 and distance < 5 then
        local pedCoords = GetEntityCoords(playerPed)
        local closestObject = GetClosestObjectOfType(pedCoords, 3.0, GetHashKey(Config.StretcherModel), false)
    
        if DoesEntityExist(closestObject) then
            local strCoords = GetEntityCoords(closestObject)
            local strVecForward = GetEntityForwardVector(closestObject)
            local sitCoords = strCoords + strVecForward * -0.5
            local pickupCoords = strCoords + strVecForward * 0.3
            
            if GetDistanceBetweenCoords(pedCoords, sitCoords, true) <= 2.0 then
                LayOnStretcher(closestObject, playerPed)
            end
        end
    end
end)

RegisterNetEvent("stretcher:togglestrincar")
AddEventHandler("stretcher:togglestrincar", function()
    local veh = VehicleInFront()
    local playerPed = PlayerPedId()
    local pedCoords = GetEntityCoords(playerPed)
    local closestObject = GetClosestObjectOfType(pedCoords, 3.0, GetHashKey(Config.StretcherModel), false)
    local isAttachedToVehicle = IsEntityAttachedToAnyVehicle(closestObject) or IsEntityAttachedToEntity(closestObject, veh)

    if not isAttachedToVehicle then
        StretcherToCar(closestObject, veh)
    else
        StretcherOutCar(closestObject, playerPed)
    end

    StopAnimTask(playerPed, "anim@heists@box_carry@", 'idle', 1.0)
end)

RegisterNetEvent('unsit')
AddEventHandler('unsit', function(stretcherObject, playerPed)
    if playerPed == nil then
        playerPed = PlayerPedId()
    end

    isEscorted = false
    TriggerEvent('hospital:client:isEscorted', isEscorted)
    ClearPedTasks(playerPed)

    DetachEntity(playerPed, true, true)
    local x, y, z = table.unpack(GetEntityCoords(stretcherObject) + GetEntityForwardVector(stretcherObject) * -0.7)
    SetEntityCoords(playerPed, x, y, z)
end)

-- RegisterCommand("test", function()
--     local playerPed = PlayerPedId()
--     local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(playerPed))

--     QBCore.Functions.TriggerCallback('stretcher:server:GetPlayerStatus', function(inLaststand, isDead)
--         print("inlaststand in loop", isDead, inLaststand)
--     end, playerId)
-- end)


function VehicleInFront()
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)
    local entityWorld = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.0, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 30, playerPed, 0)
    local _, _, _, _, result = GetRaycastResult(rayHandle)
    return result
end
