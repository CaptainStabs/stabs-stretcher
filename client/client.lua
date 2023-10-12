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

    NetworkRequestControlOfEntity(stretcherObject)
    AttachEntityToEntity(stretcherObject, playerPed, GetPedBoneIndex(playerPed, 28422), Config.PushPos.x, Config.PushPos.y, Config.PushPos.z, Config.PushPos.xRot, Config.PushPos.yRot, Config.PushPos.zRot, 0.0, false, false, true, false, 2, true)

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
            
            
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local forwardVector = GetEntityForwardVector(playerPed)

            local distance = 1.3 -- Adjust the distance as needed

            local targetCoords = playerCoords + forwardVector * distance
            SetEntityCoordsNoOffset(stretcherObject, targetCoords.x, targetCoords.y, targetCoords.z, true, true, true)

            ClearPedTasks(playerPed)
            StopAnimTask(playerPed, dict, 'idle', 1.0)
            EnableControlAction(1, 140, true)  -- Re-enable punching
            EnableControlAction(1, 141, true)
            EnableControlAction(1, 142, true)
            PlaceObjectOnGroundProperly(stretcherObject)
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
    
    TriggerEvent('stretcher:PushStretcher')
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
        local coords = Config.VehiclesPos[GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))]
        AttachEntityToEntity(stretcherObject, vehicle, 0, coords.x, coords.y, coords.z, 0.0, 0.0, 90.0, false, false, false, false, 2, true)
    else
        print("Car does not exist.")
    end
end

local function StretcherOutCar(stretcherObject)
    local playerPed = PlayerPedId()

    if DoesEntityExist(stretcherObject) then
        DetachEntity(stretcherObject, true, true)
        SetEntityCoords(stretcherObject, GetEntityCoords(playerPed))
        PlaceObjectOnGroundProperly(stretcherObject)
        TriggerEvent('stretcher:PushStretcher')
    else
        print("Stretcher does not exist.")
    end
end

local function LayOnStretcher(stretcherObject)

    local stretcherObject =  NetworkGetEntityFromNetworkId(stretcherObject)
    -- Used only to check if someone is already using the stretcher
    local closestPlayer, closestPlayerDist = GetClosestPlayer()
    
    if closestPlayer ~= nil and closestPlayerDist <= 1.5 then
        if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), Config.StretcherAnimationDict, Config.StretcherAnimation, 3) then
            ShowNotification("Somebody is already using the stretcher!")
            return
        end
    end
    
    LoadAnimDict(Config.StretcherAnimationDict)
    
    local playerPed = PlayerPedId()
    local playerServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(playerPed))
    
    isEscorted = true
    TriggerEvent('hospital:client:isEscorted', isEscorted)
    DetachEntity(playerPed, true, true)
    AttachEntityToEntity(playerPed, stretcherObject, 0, Config.LayPos.x, Config.LayPos.y, Config.LayPos.z, Config.LayPos.xRot, Config.LayPos.yRot, Config.LayPos.zRot, 0.0, false, false, false, false, 2, true)

    local stillSitting = true
    local playerDied = false
    local playerNotDead = false

    Citizen.CreateThread(function()
        -- This needs to be repeated in order to detect when the player has
        -- transistioned from inLaststand to isDead
        repeat
            Citizen.Wait(0)
            QBCore.Functions.TriggerCallback('stretcher:server:GetPlayerStatus', function(inLaststand, isDead)
                -- Overwriting the qb-ambulancejob dead animation causes player to detach
                if not isDead and not IsEntityPlayingAnim(playerPed, Config.StretcherAnimationDict, Config.StretcherAnimation, 3) then
                    TaskPlayAnim(playerPed, Config.StretcherAnimationDict, Config.StretcherAnimation, 8.0, 8.0, -1, 69, 1, false, false, false)
                end

                -- if X is pressed
                if IsControlJustPressed(0, 73) then 
                    TriggerEvent("stretcher:unsit", stretcherObject, playerPed)
                    stillSitting = false
                end

                if isDead then
                    playerDied = true
                    return
                end

                -- Immediately leave the expensive server callback after one attempt if the player is neither dead nor dying
                if not isDead and not inLaststand then
                    playerNotDead = true
                end
            end, playerServerId)

        until playerNotDead or playerDied or not stillSitting

        if playerNotDead or playerDied then
            -- Cannot play the animation while the player is dead
            if not isDead and not IsEntityPlayingAnim(playerPed, Config.StretcherAnimationDict, Config.StretcherAnimation, 3) then
                TaskPlayAnim(playerPed, Config.StretcherAnimationDict, Config.StretcherAnimation, 8.0, 8.0, -1, 69, 1, false, false, false)
            end

            AttachEntityToEntity(playerPed, stretcherObject, 0, Config.LayPos.x, Config.LayPos.y, Config.LayPos.z, Config.LayPos.xRot, Config.LayPos.yRot, Config.LayPos.zRot, 0.0, false, false, false, false, 2, true)
            stillSitting = true

            while stillSitting do
                Citizen.Wait(0)

                if not IsEntityAttachedToEntity(playerPed, stretcherObject) then
                    AttachEntityToEntity(playerPed, stretcherObject, 0, Config.LayPos.x, Config.LayPos.y, Config.LayPos.z, Config.LayPos.xRot, Config.LayPos.yRot, Config.LayPos.zRot, 0.0, false, false, false, false, 2, true)
                end

                if IsControlPressed(0, 32) then
                    PlaceObjectOnGroundProperly(stretcherObject)
                end

                if IsControlJustPressed(0, 73) then
                    TriggerEvent("stretcher:unsit", stretcherObject, playerPed)
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

RegisterNetEvent("stretcher:PushStretcher")
AddEventHandler("stretcher:PushStretcher", function()
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


RegisterNetEvent("stretcher:GetOnStretcher")
AddEventHandler("stretcher:GetOnStretcher", function()
    local playerPed = PlayerPedId()
    local pedCoords = GetEntityCoords(playerPed)
    local stretcher = GetClosestObjectOfType(pedCoords, 3.0, GetHashKey(Config.StretcherModel), false)

    if DoesEntityExist(stretcher) then
        local strCoords = GetEntityCoords(stretcher)
        local strVecForward = GetEntityForwardVector(stretcher)
        local sitCoords = strCoords + strVecForward * -0.5
        local pickupCoords = strCoords + strVecForward * 0.3

        if GetDistanceBetweenCoords(pedCoords, sitCoords, true) <= 2.0 then
            local playerServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(playerPed))
            LayOnStretcher(NetworkGetNetworkIdFromEntity(stretcher))
        end
    end
end)


-- Place another player on the stretcher
RegisterNetEvent('stretcher:client:PlaceOnStretcher')
AddEventHandler('stretcher:client:PlaceOnStretcher', function()
    local playerId, distance = GetClosestPlayer()
    local playerPed = GetPlayerPed(playerId)
    local pedCoords = GetEntityCoords(playerPed)
    if playerPed ~= -1 and distance < 5 then
        local stretcher = GetClosestObjectOfType(pedCoords, 3.0, GetHashKey(Config.StretcherModel), false)
        if DoesEntityExist(stretcher) then
            local playerServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(playerPed))
            TriggerServerEvent('stretcher:server:PlaceOnStretcher', playerServerId, NetworkGetNetworkIdFromEntity(stretcher))
        end
    end
end)

-- called from server on specified client
RegisterNetEvent('stretcher:client:GetPlacedOnStretcher')
AddEventHandler('stretcher:client:GetPlacedOnStretcher', function(stretcher, playerServerId)
    LayOnStretcher(stretcher)
end)

RegisterNetEvent("stretcher:ToggleStrInCar")
AddEventHandler("stretcher:ToggleStrInCar", function()
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

RegisterNetEvent('stretcher:unsit')
AddEventHandler('stretcher:unsit', function(stretcherObject, playerPed)
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

function VehicleInFront()
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)
    local entityWorld = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.0, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 30, playerPed, 0)
    local _, _, _, _, result = GetRaycastResult(rayHandle)
    return result
end

RegisterCommand(Config.PushCommand, function()
    TriggerEvent('stretcher:PushStretcher')
end)

RegisterCommand(Config.LayCommand, function()
    TriggerEvent('stretcher:GetOnStretcher')
end)

RegisterCommand(Config.SpawnCommand, function()
    if QBCore.Functions.GetPlayerData().job.name == Config.Job then
    -- if true then
        if stretcher == nil then
            PlaceStretcher()
        else
            print("The stretcher is already placed.")
        end
    else
        TriggerEvent("QBCore:Notify", Config.JobMessage, "error")
    end
end, false)

RegisterCommand(Config.RemoveCommand, function()
    if QBCore.Functions.GetPlayerData().job.name == Config.Job then
    -- if true then
        RemoveStretcher()
    else
        TriggerEvent("QBCore:Notify", Config.JobMessage, "error")
    end
end, false)