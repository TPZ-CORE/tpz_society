local TPZ = exports.tpz_core:getCoreAPI()

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local function DoesTargetExistNearby(targetSource, coords, radius)
    targetSource  = tonumber(targetSource)

    local players = TPZ.GetPlayers()

    for _, playerId in ipairs(players) do

        playerId = tonumber(playerId)

        local playerCoords = GetEntityCoords(GetPlayerPed(playerId)) -- Get the player's coordinates
        local distance     = #(coords - playerCoords)

        if distance <= radius and targetSource == playerId then
            return true
        end

    end

    return false
end

--[[ ------------------------------------------------
   Commands Registration
]]---------------------------------------------------

RegisterCommand(Config.CreateBill.Command, function(source, args, rawCommand)
    local _source = source

    local xPlayer = TPZ.GetPlayer(_source)
    local job     = xPlayer.getJob()

    local target, inputAmount = tonumber(args[1]), tonumber(args[2])

    local society = Config.Societies[job]

    if (society == nil) or (society and not society.Billing) then
        SendNotification(_source, Locales['SOCIETY_CANNOT_CREATE_BILLS'], "error")
        return
    end

    if target == nil and target <= 0 or inputAmount == nil and inputAmount <= 0 then
        SendNotification(_source, Locales['INVALID_INPUT'], "error")
        return
    end

    if target == _source then
        SendNotification(_source, Locales['CANNOT_BILL_YOURSELF'], "error")
        return
    end

    local ped            = GetPlayerPed(_source)
    local playerCoords   = GetEntityCoords(ped)

    local doesTargetExistNearby = DoesTargetExistNearby(target, playerCoords, Config.CreateBill.MaximumNearestDistanceFromTarget)

    if doesTargetExistNearby then
        CreateNewBill(_source, target, 1, inputAmount)
    else
        SendNotification(_source, Locales['PLAYER_NOT_FOUND'], "error")
    end

end, false)

RegisterCommand(Config.RegisterSociety.Command, function(source, args, rawCommand)
    local _source = source
    local xPlayer = TPZ.GetPlayer(_source)

    local hasAcePermissions           = xPlayer.hasPermissionsByAce("tpzcore.society.register_society")
    local hasAdministratorPermissions = hasAcePermissions

    if not hasAcePermissions then
        hasAdministratorPermissions = xPlayer.hasAdministratorPermissions(Config.RegisterSociety.Groups, Config.RegisterSociety.DiscordRoles)
    end

    if hasAcePermissions or hasAdministratorPermissions then

        local targetSocietyJob = string.lower(args[1])

        local Societies        = GetSocieties()

        if (Societies[targetSocietyJob]) then
            SendNotification(_source, Locales['SOCIETY_ALREADY_REGISTERED'], "error")
            return
        end

        Societies[targetSocietyJob] = { job = targetSocietyJob, ledger = 0 }
    
        exports.ghmattimysql:execute("INSERT INTO `society` ( `job`, `ledger`) VALUES ( @job, @ledger)", { ['job'] = targetSocietyJob, ['ledger'] = 0 })

        SendNotification(_source, Locales['SOCIETY_REGISTERED'], "success")
        
    else
        SendNotification(_source, Locales['NO_PERMISSIONS'], "error")
    end

end, false)

-----------------------------------------------------------
--[[ Chat Suggestion Registrations ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_society:server:addChatSuggestions")
AddEventHandler("tpz_society:server:addChatSuggestions", function()
    local _source = source
    local xPlayer = TPZ.GetPlayer(source)

    if not xPlayer.loaded() then
        return
    end

    TriggerClientEvent("chat:addSuggestion", _source, "/" .. Config.CreateBill.Command, Config.CreateBill.Description, {
        { name = "Id", help = 'Player ID' },
        { name = "Amount", help = 'Bill Amount' },
    })

    TriggerClientEvent("chat:addSuggestion", _source, "/" .. Config.RegisterSociety.Command, Config.RegisterSociety.Description, {
        { name = "Job", help = 'Job Society Name' },
    })

end)
