local QBCore = exports['qb-core']:GetCoreObject()

Citizen.CreateThread(function()
    -- Stretcher related events 
    exports['qb-target']:AddTargetModel(Config.StretcherModel, {
        options = {
            {
                num = 1,
                type = "client",
                event = "stretcher:PushStretcher",
                label = "Push Stretcher",
                job = Config.Job
            },
            {
                num = 2,
                type = "client",
                event = "stretcher:GetOnStretcher",
                label = "Lay on stretcher",
                icon = "fas fa-stretcher",
            },
        },
    },
        distance = 10,
    })
    -- Functions for spawning and inserting/removing stretcher from vehicles
    exports['qb-target']:AddTargetModel(Config.Vehicles, {
        options = {
            {
                num = 1,
                type = "command",
                event = Config.SpawnCommand,
                label = "Get new stretcher from vehicle",
                job = Config.Job
            },
            {
                num = 2,
                type = "client",
                event = "stretcher:ToggleStrInCar",
                label = "Put/Remove stretcher in/from vehicle",
                job = Config.Job
            },
        },
        distance = 2.5,
    })

    exports['qb-target']:AddGlobalPlayer({
        options = { 
            {
            num = 3,
            type = "client", 
            event = "stretcher:client:PlaceOnStretcher", 
            icon = 'fas fa-stretcher',
            label = 'Place on stretcher', 
            job = Config.Job, 
            },
        distance = 2.5,
        })
end)