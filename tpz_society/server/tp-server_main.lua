local TPZ     = {}

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

Societies, Billing = {}, {}


-----------------------------------------------------------
--[[ Local Functions  ]]--
-----------------------------------------------------------

local function LoadBillProperlyByParameters(account, cost, date)
    
    exports["ghmattimysql"]:execute("SELECT * FROM billing", {}, function(result)

        for _, res in pairs (result) do 
    
            if res.account == account and res.cost == cost and res.date == date then

                Billing[res.id] = {} 
                Billing[res.id] = res 

            end

        end
    
    end)
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
        local tableLength = GetTableLength(result)

        if tableLength > 0 then
            for _, res in pairs (result) do Societies[res.job] = {} Societies[res.job] = res end

            print("Successfully registered (" .. tableLength .. ') societies.')
        end
    end)

    exports["ghmattimysql"]:execute("SELECT * FROM billing ORDER BY id", {}, function(result)
        local tableLength = GetTableLength(result)
        
        if tableLength > 0 then
            for _, res in pairs (result) do Billing[res.id] = {} Billing[res.id] = res end

            print("Successfully loaded (" .. tableLength .. ') bills.')
        end
    end)


end)

-----------------------------------------------------------
--[[ General Events  ]]--
-----------------------------------------------------------

RegisterServerEvent('tpz_society:createNewBill')
AddEventHandler('tpz_society:createNewBill', function(targetId, isJob, account, cost, reason, issuer)
    local _source         = source
    local _tsource        = targetId

    local xPlayer         = TPZ.GetPlayer(_source)
    local xJob            = xPlayer.getJob()
    local xUsername       = xPlayer.getFirstName() .. ' ' .. xPlayer.getLastName()

    local tPlayer         = TPZ.GetPlayer(_tsource)
    local tIdentifier     = tPlayer.getIdentifier()
    local tCharidentifier = tPlayer.getCharacterIdentifier()
    local tUsername       = tPlayer.getFirstName() .. ' ' .. tPlayer.getLastName()

    local currentDate     = os.date('%d').. '/' ..os.date('%m').. '/' .. Config.Year .. " " .. os.date('%H') .. ":" .. os.date('%M') .. ":" .. os.date('%S')

    local Parameters = {
        ['identifier']      = tIdentifier,
        ['charidentifier']  = tCharidentifier,
        ['username']        = tUsername,
        ['account']         = account,
        ['cost']            = cost,
        ['date']            = currentDate,
    }

    if isJob or isJob == 1 then
        Parameters['job']    = 1
        Parameters['reason'] = xJob
        Parameters['issuer'] = xUsername

    elseif not isJob or isJob == 0 then
        Parameters['job']    = 0
        Parameters['reason'] = reason
        Parameters['issuer'] = issuer
    end

    SendNotification(_source, Locales['CREATED_BILL'], "success")
    SendNotification(_tsource, Locales['RECEIVED_BILL'], "info")

    exports.ghmattimysql:execute("INSERT INTO `billing` ( `job`, `reason`, `identifier`, `charidentifier`, `username`, `issuer`, `account`, `cost`, `date`) VALUES ( @job, @reason, @identifier, @charidentifier, @username, @issuer, @account, @cost, @date)", Parameters)

    Wait(2000)
    LoadBillProperlyByParameters(account, cost, currentDate)
    

end)

RegisterServerEvent('tpz_society:createNewBillTo')
AddEventHandler('tpz_society:createNewBillTo', function(identifier, charidentifier, account, cost, reason, issuer)

    local currentDate     = os.date('%d').. '/' ..os.date('%m').. '/' .. Config.Year .. " " .. os.date('%H') .. ":" .. os.date('%M') .. ":" .. os.date('%S')

    local Parameters = {
        ['job']             = 0,
        ['reason']          = reason,
        ['identifier']      = identifier,
        ['charidentifier']  = charidentifier,
        ['username']        = issuer,
        ['issuer']          = issuer,
        ['account']         = account,
        ['cost']            = cost,
        ['date']            = currentDate,
    }

    exports.ghmattimysql:execute("INSERT INTO `billing` ( `job`, `reason`, `identifier`, `charidentifier`, `username`, `issuer`, `account`, `cost`, `date`) VALUES ( @job, @reason, @identifier, @charidentifier, @username, @issuer, @account, @cost, @date)", Parameters)

    Wait(2000)
    LoadBillProperlyByParameters(account, cost, currentDate)
end)

RegisterServerEvent('tpz_society:payBill')
AddEventHandler('tpz_society:payBill', function(billingId, bankName)
    local _source     = source
    local xPlayer     = TPZ.GetPlayer(_source)

    -- If billing id is null for some reason, we don't run the rest of the code.
    if Billing[billingId] == nil then
        return
    end

    local billingData = Billing[billingId]

    local money = xPlayer.getAccount(billingData.account)

    if money < billingData.cost then

        if Config.TPZBanking then
            TriggerClientEvent("tpz_banking:sendNotification", _source, Locales['NOT_ENOUGH_TO_PAY_BILL'], 'error')
        
        else
            -- other notification
        end

        return
    end

    xPlayer.removeAccount(billingData.account, billingData.cost)

    if billingData.job == 1 and Societies[billingData.job] then
        UpdateSocietyLedger(billingData.job, 'ADD', billingData.cost)
    end

    TriggerEvent("tpz_society:onPaidBill", billingData)

    Billing[billingId] = nil

    exports.ghmattimysql:execute( "DELETE FROM billing WHERE id = @id", {["@id"] = billingData.id})

    -- TPZ Banking Support (Creating history records) & notification system.
    if Config.TPZBanking then
        TriggerClientEvent("tpz_banking:sendNotification", _source, Locales['PAID_BILL'], 'success')

        TriggerEvent('tpz_banking:registerHistoryRecord', _source, bankName, billingData.identifier, billingData.charidentifier, billingData.reason, billingData.account, billingData.cost)
    else
        -- other notification
    end

    TriggerClientEvent("tpz_banking:refreshPlayerBills", _source)

end)

-- @parameter id
-- @parameter job
-- @parameter reason
-- @parameter identifier
-- @parameter charidentifier
-- @parameter username
-- @parameter issuer
-- @parameter account
-- @parameter cost
-- @parameter date
RegisterServerEvent('tpz_society:onPaidBill')
AddEventHandler('tpz_society:onPaidBill', function(data)
    -- todo nothing
end)


RegisterServerEvent("tpz_society:setSelectedSourceIdGrade")
AddEventHandler("tpz_society:setSelectedSourceIdGrade", function(job, username, sourceId, gradeIndex, gradeLabel)
    local _source = source
    local tsource = sourceId

    if job == nil or Societies[job] == nil then
        print('(!) There was an injection attempt "tpz_society:setSelectedSourceIdGrade" which was triggered by the following source and steam name: ' .. _source .. " " .. GetPlayerName(_source))
        return
    end

    if GetPlayerName(tsource) == nil then
        SendNotification(_source, Locales['PLAYER_NO_LONGER_AVAILABLE'], "error")
        return
    end

    local tPlayer = TPZ.GetPlayer(tsource)

    tPlayer.setJobGrade(tonumber(gradeIndex))

    TriggerClientEvent("tpz_core:getPlayerJob", tonumber(tsource), { job = job, jobGrade = tonumber(gradeIndex) })

    SendNotification(_source, string.format(Locales['GRADE_SET_TO_EMPLOYEE'], username, gradeLabel), "success")
    SendNotification(tsource, string.format(Locales['GRADE_SET_TO_EMPLOYEE_TARGET'], gradeLabel), "info")
end)

-- @fireSelectedSourceId is used in society menu and is triggered only to set an employee as unemployed (fired) from
-- the current job society.
RegisterServerEvent("tpz_society:fireSelectedSourceId")
AddEventHandler("tpz_society:fireSelectedSourceId", function(job, username, sourceId)
    local _source = source
    local tsource = sourceId

    if job == nil or Societies[job] == nil then
        print('(!) There was an injection attempt "tpz_society:fireSelectedSourceId" which was triggered by the following source and steam name: ' .. _source .. " " .. GetPlayerName(_source))
        return
    end

    if GetPlayerName(tsource) == nil then
        SendNotification(_source, Locales['PLAYER_NO_LONGER_AVAILABLE'], "error")
        return
    end

    local tPlayer        = TPZ.GetPlayer(tsource)
    local charidentifier = tPlayer.getCharacterIdentifier()

    tPlayer.setJob(Config.UnemployedJob)
    tPlayer.setJobGrade(0)

    TriggerClientEvent("tpz_core:getPlayerJob", tonumber(tsource), { job = Config.UnemployedJob, jobGrade = 0 })

    SendNotification(_source, string.format(Locales['FIRED_EMPLOYEE'], username), "success")
    SendNotification(tsource, Locales['FIRED_EMPLOYEE_TARGET'], "info")

    local webhookData  = Config.Societies[job].Webhooking

    if webhookData.Enabled then
        local title   = "💼` " .. job .. " (Fired) `"
        local message = "The player with the following character id: **`( " .. charidentifier .. ")`** has been fired.`"
        TriggerEvent("tpz_core:sendToDiscord", webhookData.Url, title, message, webhookData.Color)
    end

end)

-- @hireSelectedSourceId is used in society menu and is triggered only to hire a player as a new employee to
-- the current job society.
RegisterServerEvent("tpz_society:hireSelectedSourceId")
AddEventHandler("tpz_society:hireSelectedSourceId", function(job, username, sourceId)
    local _source = source
    local tsource = sourceId

    if job == nil or Societies[job] == nil then
        print('(!) There was an injection attempt "tpz_society:hireSelectedSourceId" which was triggered by the following source and steam name: ' .. _source .. " " .. GetPlayerName(_source))
        return
    end

    if GetPlayerName(tsource) == nil then
        SendNotification(_source, Locales['PLAYER_NO_LONGER_AVAILABLE'], "error")
        return
    end

    local tPlayer        = TPZ.GetPlayer(tsource)
    local charidentifier = tPlayer.getCharacterIdentifier()

    tPlayer.setJob(job)
    tPlayer.setJobGrade(Config.Societies[job].RecruitGrade)

    TriggerClientEvent("tpz_core:getPlayerJob", tonumber(tsource), { job = job, jobGrade = Config.Societies[job].RecruitGrade })

    SendNotification(_source, string.format(Locales['HIRED_EMPLOYEE'], username), "success")
    SendNotification(tsource, Locales['HIRED_EMPLOYEE_TARGET'], "info")

    local webhookData  = Config.Societies[job].Webhooking

    if webhookData.Enabled then
        local title   = "💼` " .. job .. " (Hired) `"
        local message = "The player with the following character id: **`( " .. charidentifier .. ")`** has been hired to the mentioned job as an employee.`"
        TriggerEvent("tpz_core:sendToDiscord", webhookData.Url, title, message, webhookData.Color)
    end

end)


RegisterServerEvent("tpz_society:depositJobLedger")
AddEventHandler("tpz_society:depositJobLedger", function(job, amount)
    local _source = source
    local xPlayer = TPZ.GetPlayer(_source)
    local charidentifier = xPlayer.getCharacterIdentifier()

    if job == nil or Societies[job] == nil then
        print('(!) There was an injection attempt "tpz_society:depositJobLedger" which was triggered by the following source and steam name: ' .. _source .. " " .. GetPlayerName(_source))
        return
    end

    local money = xPlayer.getAccount(0)

    if money < amount then
        SendNotification(_source, Locales['NOT_ENOUGH_MONEY_TO_DEPOSIT'], "error")
        return
    end

    UpdateSocietyLedger(job, 'ADD', amount)

    xPlayer.removeAccount(0, amount)
    
    SendNotification(_source, string.format(Locales['LEDGER_DEPOSIT'], amount), "success")

    local webhookData  = Config.Societies[job].Webhooking

    if webhookData.Enabled then
        local title   = "💼` " .. job .. " (Deposit) `"
        local message = "The player with the following character id: **`( " .. charidentifier .. ")`** deposited $" .. amount .. " dollars in the society ledger.`"
        TriggerEvent("tpz_core:sendToDiscord", webhookData.Url, title, message, webhookData.Color)
    end

end)


RegisterServerEvent("tpz_society:withdrawJobLedger")
AddEventHandler("tpz_society:withdrawJobLedger", function(job, amount)
    local _source = source
    local xPlayer = TPZ.GetPlayer(_source)
    local charidentifier = xPlayer.getCharacterIdentifier()

    if job == nil or Societies[job] == nil then
        print('(!) There was an injection attempt "tpz_society:withdrawJobLedger" which was triggered by the following source and steam name: ' .. _source .. " " .. GetPlayerName(_source))
        return
    end

    if not DoesSocietyLedgerHasEnough(job, amount) then
        SendNotification(_source, Locales['NOT_ENOUGH_MONEY_TO_WITHDRAW'], "error")
        return
    end

    UpdateSocietyLedger(job, 'REMOVE', amount)
    xPlayer.addAccount(0, amount)

    SendNotification(_source, string.format(Locales['LEDGER_WITHDREW'], amount), "success")

    local webhookData  = Config.Societies[job].Webhooking

    if webhookData.Enabled then
        local title   = "💼` " .. job .. " (Withdraw) `"
        local message = "The player with the following character id: **`( " .. charidentifier .. ")`** withdrew $" .. amount .. " dollars from the society ledger.`"
        TriggerEvent("tpz_core:sendToDiscord", webhookData.Url, title, message, webhookData.Color)
    end

end)

--------------------------------------------------------- --
--[[ Functions  ]]--
-----------------------------------------------------------

function UpdateSocietyLedger(job, type, amount)
    -- In case the society has not been registered in `society` database table.
    -- We don't allow any society updates.
    if Societies[job] then
        
        -- If type == `ADD`, we add the extra amount on the ledger.
        if type == 'ADD' then
            Societies[job].ledger = Societies[job].ledger + amount
    
        -- If type == `REMOVE`, we remove the amount from the ledger and if it
        -- equals to or below 0, we set it to 0 (Not allowing negative values for preventing bugs).
        -- Removing is used for the salaries.
        elseif type == 'REMOVE' then
            Societies[job].ledger = Societies[job].ledger - amount
    
            if Societies[job].ledger <= 0 then 
                Societies[job].ledger = 0 
            end
    
        end
        
    else
        print('(!) There was an attempt updating the following society ( ' .. job .. ' ) ledger while does not exist in the `society` database table.')
    end

end

function DoesSocietyLedgerHasEnough(job, amount)

    -- In case the society has not been registered in `society` database table.
    -- We don't allow any society updates.
    if Societies[job] then
        return amount <= Societies[job].ledger
    end

    -- If society does not exist, it will always return as false so it won't 
    -- give any salary mistaken.
    return false
end

-- @GetTableLength returns the length of a table.
function GetTableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end


-----------------------------------------------------------
--[[ Threads  ]]--
-----------------------------------------------------------

-- Saving (Updating) Societies before server restart.
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
    
        if shouldSave then

            if GetTableLength(Societies) > 0 then
                
                for _, society in pairs (Societies) do

                    local Parameters = { 
                        ['job']     = society.job,
                        ['ledger']  = society.ledger
                    }

                    exports.ghmattimysql:execute("UPDATE `society` SET `ledger` = @ledger WHERE job = @job", Parameters)

                    if Config.Debug then
                        print("The following Society: " .. society.job .. " has been saved.")
                    end

                end

            end
            
        end

    end

end)