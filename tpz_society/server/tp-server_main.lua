local TPZ       = exports.tpz_core:getCoreAPI()
local Societies = {}

-----------------------------------------------------------
--[[ Functions  ]]--
-----------------------------------------------------------

function UpdateSocietyLedger(job, transactionType, amount)

    transactionType = string.upper(transactionType)

    -- In case the society has not been registered in `society` database table.
    -- We don't allow any society updates.
    if Societies[job] then
        
        -- If type == `ADD`, we add the extra amount on the ledger.
        if transactionType == 'ADD' then
            Societies[job].ledger = Societies[job].ledger + amount
    
        -- If type == `REMOVE`, we remove the amount from the ledger and if it
        -- equals to or below 0, we set it to 0 (Not allowing negative values for preventing bugs).
        -- Removing is used for the salaries.
        elseif transactionType == 'REMOVE' then

            Societies[job].ledger = Societies[job].ledger - amount
    
            if Societies[job].ledger <= 0 then 
                Societies[job].ledger = 0 
            end
    
        end
        
    else
        print('(!) There was an attempt updating the following society ( ' .. job .. ' ) ledger while does not exist in the `society` database table.')
    end

end

function GetSocieties()
    return Societies
end

-----------------------------------------------------------
--[[ Local Functions  ]]--
-----------------------------------------------------------

local function GetPlayerData(source)
	local _source = source
    local xPlayer = TPZ.GetPlayer(_source)

	return {
        steamName      = GetPlayerName(_source),
        username       = xPlayer.getFirstName() .. ' ' .. xPlayer.getLastName(),
        identifier     = xPlayer.getIdentifier(),
        charIdentifier = xPlayer.getCharacterIdentifier(),
        job            = xPlayer.getJob(),
        jobGrade       = xPlayer.getJobGrade(),
	}

end

-----------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    Societies = nil
end)

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end

    exports["ghmattimysql"]:execute("SELECT * FROM society", {}, function(result)
        local tableLength = TPZ.GetTableLength(result)

        if tableLength > 0 then
            for _, res in pairs (result) do Societies[res.job] = {} Societies[res.job] = res end

            print("Successfully registered (" .. tableLength .. ') societies.')
        end
    end)

end)

-----------------------------------------------------------
--[[ General Events  ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_society:server:setSelectedSourceIdGrade")
AddEventHandler("tpz_society:server:setSelectedSourceIdGrade", function(job, username, targetSourceId, gradeIndex, gradeLabel)
    local _source    = source
    local _tsource   = tonumber(targetSourceId)

    local xPlayer    = TPZ.GetPlayer(_source)
    local PlayerData = GetPlayerData(_source)

    if ( job == nil ) or ( Societies[job] == nil ) or ( Config.Societies[job] == nil ) or ( job ~= PlayerData.job ) or ( Config.Societies[job] and Config.Societies[job].BossGrade ~= PlayerData.jobGrade ) then

        if Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Enabled then
            local _w, _c      = Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Url, Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Color
            local description = 'The specified user attempted to use devtools / injection or netbug cheat on society withdraw job ledger.'
            TPZ.SendToDiscordWithPlayerParameters(_w, Locales['DEVTOOLS_INJECTION_DETECTED_TITLE_LOG'], _source, PlayerData.steamName, PlayerData.username, PlayerData.identifier, PlayerData.charIdentifier, description, _c)
        end

        xPlayer.disconnect(Locales['DEVTOOLS_INJECTION_DETECTED'])

        return
    end

    if GetPlayerName(_tsource) == nil or GetPlayerName(_tsource) and not TPZ.GetPlayer(_tsource).loaded() then
        SendNotification(_source, Locales['PLAYER_NO_LONGER_AVAILABLE'], "error")
        return
    end

    local tPlayer = TPZ.GetPlayer(_tsource)

    tPlayer.setJobGrade(tonumber(gradeIndex))

    SendNotification(_source, string.format(Locales['GRADE_SET_TO_EMPLOYEE'], username, gradeLabel), "success")
    SendNotification(tsource, string.format(Locales['GRADE_SET_TO_EMPLOYEE_TARGET'], gradeLabel), "info")
end)

-- @hireSelectedSourceId is used in society menu and is triggered only to hire a player as a new employee to the current job society.
RegisterServerEvent("tpz_society:server:server:hireSelectedSourceId")
AddEventHandler("tpz_society:server:server:hireSelectedSourceId", function(job, username, targetSourceId)
    local _source    = source
    local _tsource   = tonumber(targetSourceId)

    local xPlayer    = TPZ.GetPlayer(_source)
    local PlayerData = GetPlayerData(_source)

    if ( job == nil ) or ( Societies[job] == nil ) or ( Config.Societies[job] == nil ) or ( job ~= PlayerData.job ) or ( Config.Societies[job] and Config.Societies[job].BossGrade ~= PlayerData.jobGrade ) then

        if Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Enabled then
            local _w, _c      = Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Url, Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Color
            local description = 'The specified user attempted to use devtools / injection or netbug cheat on society withdraw job ledger.'
            TPZ.SendToDiscordWithPlayerParameters(_w, Locales['DEVTOOLS_INJECTION_DETECTED_TITLE_LOG'], _source, PlayerData.steamName, PlayerData.username, PlayerData.identifier, PlayerData.charIdentifier, description, _c)
        end

        xPlayer.disconnect(Locales['DEVTOOLS_INJECTION_DETECTED'])

        return
    end

    if GetPlayerName(_tsource) == nil or GetPlayerName(_tsource) and not TPZ.GetPlayer(_tsource).loaded() then
        SendNotification(_source, Locales['PLAYER_NO_LONGER_AVAILABLE'], "error")
        return
    end

    local tPlayer          = TPZ.GetPlayer(_tsource)
    local PlayerTargetData = GetPlayerData(_tsource)

    tPlayer.setJob(job) -- sets the job.
    tPlayer.setJobGrade(Config.Societies[job].RecruitGrade) -- always hiring as recruit grade at first.

    SendNotification(_source, string.format(Locales['HIRED_EMPLOYEE'], username), "success")
    SendNotification(_tsource, Locales['HIRED_EMPLOYEE_TARGET'], "info")

    local webhookData  = Config.Societies[job].Webhooking

    if webhookData.Enabled then
        local title       = "💼` " .. Config.Societies[job].JobLabel .. " - Hired New Employee `"
        local description = string.format('The specified user hired a new employee: `(Username: %s, Identifier: %s, Char Identifier: %s)` to the mentioned department.', PlayerTargetData.username, PlayerTargetData.identifier, PlayerTargetData.charIdentifier)

        TPZ.SendToDiscordWithPlayerParameters( webhookData.Url, title, _source, PlayerData.steamName, PlayerData.username, PlayerData.identifier, PlayerData.charIdentifier, description, webhookData.Color)

    end

end)

-- @fireSelectedSourceId is used in society menu and is triggered only to set an employee as unemployed (fired) from
-- the current job society.
RegisterServerEvent("tpz_society:server:fireSelectedSourceId")
AddEventHandler("tpz_society:server:fireSelectedSourceId", function(job, username, targetSourceId)
    local _source    = source
    local _tsource   = tonumber(targetSourceId)

    local xPlayer    = TPZ.GetPlayer(_source)
    local PlayerData = GetPlayerData(_source)

    if ( job == nil ) or ( Societies[job] == nil ) or ( Config.Societies[job] == nil ) or ( job ~= PlayerData.job ) or ( Config.Societies[job] and Config.Societies[job].BossGrade ~= PlayerData.jobGrade ) then

        if Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Enabled then
            local _w, _c      = Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Url, Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Color
            local description = 'The specified user attempted to use devtools / injection or netbug cheat on society withdraw job ledger.'
            TPZ.SendToDiscordWithPlayerParameters(_w, Locales['DEVTOOLS_INJECTION_DETECTED_TITLE_LOG'], _source, PlayerData.steamName, PlayerData.username, PlayerData.identifier, PlayerData.charIdentifier, description, _c)
        end

        xPlayer.disconnect(Locales['DEVTOOLS_INJECTION_DETECTED'])

        return
    end

    if GetPlayerName(_tsource) == nil or GetPlayerName(_tsource) and not TPZ.GetPlayer(_tsource).loaded() then
        SendNotification(_source, Locales['PLAYER_NO_LONGER_AVAILABLE'], "error")
        return
    end

    local tPlayer          = TPZ.GetPlayer(_tsource)
    local PlayerTargetData = GetPlayerData(_tsource)

    tPlayer.setJob(Config.UnemployedJob) -- reset
    tPlayer.setJobGrade(0) -- reset

    SendNotification(_source, string.format(Locales['FIRED_EMPLOYEE'], username), "success")
    SendNotification(_tsource, Locales['FIRED_EMPLOYEE_TARGET'], "info")

    local webhookData  = Config.Societies[job].Webhooking

    if webhookData.Enabled then
        local title       = "💼` " .. Config.Societies[job].JobLabel .. " - Fired Employee `"
        local description = string.format('The specified user fired an employee: `(Username: %s, Identifier: %s, Char Identifier: %s)` from the mentioned department.', PlayerTargetData.username, PlayerTargetData.identifier, PlayerTargetData.charIdentifier)

        TPZ.SendToDiscordWithPlayerParameters( webhookData.Url, title, _source, PlayerData.steamName, PlayerData.username, PlayerData.identifier, PlayerData.charIdentifier, description, webhookData.Color)
    end

end)

-- The specified event is triggered when being in the society menu to add money on the ledger account.
RegisterServerEvent("tpz_society:server:depositJobLedger")
AddEventHandler("tpz_society:server:depositJobLedger", function(job, quantity)
    local _source    = source
    local xPlayer    = TPZ.GetPlayer(_source)
    local PlayerData = GetPlayerData(_source)

    if ( job == nil ) or ( Societies[job] == nil ) or ( Config.Societies[job] == nil ) or ( job ~= PlayerData.job ) or ( Config.Societies[job] and Config.Societies[job].BossGrade ~= PlayerData.jobGrade ) then

        if Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Enabled then
            local _w, _c      = Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Url, Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Color
            local description = 'The specified user attempted to use devtools / injection or netbug cheat on society withdraw job ledger.'
            TPZ.SendToDiscordWithPlayerParameters(_w, Locales['DEVTOOLS_INJECTION_DETECTED_TITLE_LOG'], _source, PlayerData.steamName, PlayerData.username, PlayerData.identifier, PlayerData.charIdentifier, description, _c)
        end

        xPlayer.disconnect(Locales['DEVTOOLS_INJECTION_DETECTED'])

        return
    end

    local money = xPlayer.getAccount(0)

    if money < quantity then
        SendNotification(_source, Locales['NOT_ENOUGH_MONEY_TO_DEPOSIT'], "error")
        return
    end
    
    xPlayer.removeAccount(0, quantity)
    UpdateSocietyLedger(job, 'ADD', quantity)
    
    SendNotification(_source, string.format(Locales['LEDGER_DEPOSIT'], quantity), "success")

    local webhookData  = Config.Societies[job].Webhooking

    if webhookData.Enabled then
        local title       = "💼` " .. Config.Societies[job].JobLabel .. " - Ledger Deposit `"
        local description = string.format('The specified user deposited to the mentioned department %s dollars.', quantity)

        TPZ.SendToDiscordWithPlayerParameters( webhookData.Url, title, _source, PlayerData.steamName, PlayerData.username, PlayerData.identifier, PlayerData.charIdentifier, description, webhookData.Color)

    end

end)

-- The specified event is triggered when being in the society menu to withdraw money from the ledger account.
RegisterServerEvent("tpz_society:server:withdrawJobLedger")
AddEventHandler("tpz_society:server:withdrawJobLedger", function(job, quantity)
    local _source    = source

    local xPlayer    = TPZ.GetPlayer(_source)
    local PlayerData = GetPlayerData(_source)

    if ( job == nil ) or ( Societies[job] == nil ) or ( Config.Societies[job] == nil ) or ( job ~= PlayerData.job ) or ( Config.Societies[job] and Config.Societies[job].BossGrade ~= PlayerData.jobGrade ) then

        if Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Enabled then
            local _w, _c      = Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Url, Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Color
            local description = 'The specified user attempted to use devtools / injection or netbug cheat on society withdraw job ledger.'
            TPZ.SendToDiscordWithPlayerParameters(_w, Locales['DEVTOOLS_INJECTION_DETECTED_TITLE_LOG'], _source, PlayerData.steamName, PlayerData.username, PlayerData.identifier, PlayerData.charIdentifier, description, _c)
        end

        xPlayer.disconnect(Locales['DEVTOOLS_INJECTION_DETECTED'])

        return
    end

    if Societies[job].ledger < quantity then
        SendNotification(_source, Locales['NOT_ENOUGH_MONEY_TO_WITHDRAW'], "error")
        return
    end

    xPlayer.addAccount(0, quantity)
    UpdateSocietyLedger(job, 'REMOVE', quantity)

    SendNotification(_source, string.format(Locales['LEDGER_WITHDREW'], quantity), "success")

    local webhookData  = Config.Societies[job].Webhooking

    if webhookData.Enabled then

        local title       = "💼` " .. Config.Societies[job].JobLabel .. " - Ledger Withdraw `"
        local description = string.format('The specified user withdrew from the mentioned department %s dollars.', quantity)

        TPZ.SendToDiscordWithPlayerParameters( webhookData.Url, title, _source, PlayerData.steamName, PlayerData.username, PlayerData.identifier, PlayerData.charIdentifier, description, webhookData.Color)
    end

end)

-----------------------------------------------------------
--[[ Threads  ]]--
-----------------------------------------------------------

local CurrentTime  = 0

-- Saving (Updating) Societies before server restart or every x minutes.
Citizen.CreateThread(function()
	while true do
		Wait(60000)

        local time        = os.date("*t") 
        local currentTime = table.concat({time.hour, time.min}, ":")

        local finished    = false
        local shouldSave  = false

        for index, restartHour in pairs (Config.RestartHours) do

            if currentTime == restartHour then
                shouldSave = true
            end

            if next(Config.RestartHours, index) == nil then
                finished = true
            end
        end

        while not finished do
            Wait(1000)
        end

        CurrentTime = CurrentTime + 1

        if Config.SaveDataRepeatingTimer.Enabled and CurrentTime == Config.SaveDataRepeatingTimer.Duration then
          CurrentTime = 0
          shouldSave  = true
        end
    
        if shouldSave then

            if Societies and TPZ.GetTableLength(Societies) > 0 then
                
                for _, society in pairs (Societies) do

                    local Parameters = { 
                        ['job']     = society.job,
                        ['ledger']  = society.ledger
                    }

                    exports.ghmattimysql:execute("UPDATE `society` SET `ledger` = @ledger WHERE job = @job", Parameters)

                end

                if Config.Debug then
                    print( " (" .. TPZ.GetTableLength(Societies) .. ") societies have been saved.")
                end

            end
            
        end

    end

end)
