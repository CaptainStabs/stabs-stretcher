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
                icon = "fas fa-stretcher",
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
                label = "Put/Remove stretcher in/from vehicle",
                job = 'ambulance'
            },
        },
        distance = 2.5,
    })

    exports['qb-target']:AddGlobalPlayer({
        options = { -- This is your options table, in this table all the options will be specified for the target to accept
            { -- This is the first table with options, you can make as many options inside the options table as you want
            num = 3, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
            type = "client", -- This specifies the type of event the target has to trigger on click, this can be "client", "server", "command" or "qbcommand", this is OPTIONAL and will only work if the event is also specified
            event = "stretcher:client:PlaceOnStretcher", -- This is the event it will trigger on click, this can be a client event, server event, command or qbcore registered command, NOTICE: Normal command can't have arguments passed through, QBCore registered ones can have arguments passed through
            icon = 'fas fa-stretcher', -- This is the icon that will display next to this trigger option
            label = 'Place on stretcher', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
            -- item = 'handcuffs', -- This is the item it has to check for, this option will only show up if the player has this item, this is OPTIONA
            job = 'ambulance', -- This is the job, this option won't show up if the player doesn't have this job, this can also be done with multiple jobs and grades, if you want multiple jobs you always need a grade with it: job = {["police"] = 0, ["ambulance"] = 2},
            }
        },
        distance = 2.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
        })
    

end)