RegisterCommand("push", function()
    TriggerEvent('stretcher:pushstretcher')
end)

RegisterCommand("lay", function()
    TriggerEvent('stretcher:GetOnStretcher')
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