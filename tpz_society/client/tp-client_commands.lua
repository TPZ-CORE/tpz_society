

--[[ ------------------------------------------------
   Commands Registration
]]---------------------------------------------------

RegisterCommand(Config.CreateBillCommand, function(source, args, rawCommand)
    local target, inputAccount, inputAmount = tonumber(args[1]), tonumber(args[2]),  tonumber(args[3])

    local society  = Config.Societies[ClientData.Job]

    if (society == nil) or (society and not society.Billing) then
        SendNotification(nil, Locales['SOCIETY_CANNOT_CREATE_BILLS'], "error")
        return
    end

    if target == nil and target <= 0 or inputAccount == nil and inputAccount < 0 or inputAmount == nil and inputAmount <= 0 then
        SendNotification(nil, Locales['INVALID_INPUT'], "error")
        return
    end

    -- Not allowing higher currency types but only dollars and cents.
    if inputAccount > 1 then
        SendNotification(nil, Locales['NOT_AVAILABLE_ACCOUNT'], "error")
        return
    end

    local nearestPlayers = GetNearestPlayers(3.0)
    local foundPlayer    = false

    if target == GetPlayerServerId(PlayerId()) then
        SendNotification(nil, Locales['CANNOT_BILL_YOURSELF'], "error")
        return
    end

    for _, targetPlayer in pairs(nearestPlayers) do

        if target == GetPlayerServerId(targetPlayer) then
           foundPlayer = true
        end
    end

    if foundPlayer then
        TriggerServerEvent('tpz_society:createNewBill', target, 1, inputAccount, inputAmount, ClientData.Job, ClientData.Job)
    else
        SendNotification(nil, Locales['PLAYER_NOT_FOUND'], "error")
    end

end, false)

--[[ ------------------------------------------------
   Chat Suggestions Registration
]]---------------------------------------------------

TriggerEvent("chat:addSuggestion", "/" .. Config.CreateBillCommand, 'Create a bill on the selected player id.', {
    { name = "Id", help = 'Player ID' },
    { name = "Account Type", help = 'Types : ( [0]: Cash | [1]: Cents)' },
    { name = "Amount", help = 'Bill Amount' },
})