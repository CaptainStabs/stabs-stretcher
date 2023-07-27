local QBCore = exports['qb-core']:GetCoreObject()

Citizen.CreateThread(function()
    -- Stretcher related events 
    exports['qb-target']:AddTargetModel(Config.StretcherModel, {
        options = {
            {
                num = 1,
                type = "client",
                event = "stretcher:pushstretcher",
                label = "Push Stretcher",
                job = 'ambulance'
            },
            {
                num = 2,
                type = "client",
                event = "stretcher:getonstretcher",
                label = "Lay on stretcher",
            }
        },
        distance = 10,
    })
    -- Functions for spawning and inserting/removing stretcher from vehicles
    exports['qb-target']:AddTargetModel(Config.Vehicles, {
        options = {
            {
                num = 1,
                type = "command",
                event = "spawnstr",
                label = "Get new stretcher from vehicle",
                job = 'ambulance'
            },
            {
                num = 2,
                type = "client",
                event = "stretcher:togglestrincar",
                label = "Put/Remove stretcher in/from car",
                job = 'ambulance'
            },
        },
        distance = 2.5,
    })
    

end)