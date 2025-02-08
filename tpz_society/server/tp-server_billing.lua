

local TPZ = {}

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

local Billing = {}

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
--[[ Functions  ]]--
-----------------------------------------------------------

function GetBilling()
  return Billing
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
	}

end

-----------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
    return
  end

  Billing = nil

end)

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end

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

RegisterServerEvent('tpz_society:server:createNewBill')
AddEventHandler('tpz_society:server:createNewBill', function(targetId, isJob, account, cost, reason, issuer)
  local _source         = source
  local _tsource        = tonumber(targetId)

  if GetPlayerName(_tsource) == nil or GetPlayerName(_tsource) and not TPZ.GetPlayer(_tsource).loaded() then
    SendNotification(_source, Locales['PLAYER_NO_LONGER_AVAILABLE'], "error")
    return
  end

  local PlayerData       = GetPlayerData(_source)
  local PlayerTargetData = GetPlayerData(_tsource)

  local currentDate      = os.date('%d').. '/' ..os.date('%m').. '/' .. Config.Year .. " " .. os.date('%H') .. ":" .. os.date('%M') .. ":" .. os.date('%S')

  local Parameters = {
      ['identifier']      = PlayerTargetData.identifier,
      ['charidentifier']  = PlayerTargetData.charIdentifier,
      ['username']        = PlayerTargetData.username,
      ['account']         = account,
      ['cost']            = cost,
      ['date']            = currentDate,
  }

  if isJob or isJob == 1 then
    Parameters['job']    = 1
    Parameters['reason'] = PlayerData.job
    Parameters['issuer'] = PlayerData.username

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
  
  -- webhook???????????

end)

RegisterServerEvent('tpz_society:server:createNewBillTo')
AddEventHandler('tpz_society:server:createNewBillTo', function(identifier, charidentifier, account, cost, reason, issuer)

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

RegisterServerEvent('tpz_society:server:payBill')
AddEventHandler('tpz_society:server:payBill', function(billingId, bankName)
    local _source     = source
    local xPlayer     = TPZ.GetPlayer(_source)

    -- If billing id is null for some reason, we don't run the rest of the code.
    if Billing[billingId] == nil then
      return
    end

    local Societies   = GetSocieties()

    local billingData = Billing[billingId]
    local money       = xPlayer.getAccount(billingData.account)

    if money < billingData.cost then

      if Config.tpz_banking then 
        TriggerClientEvent("tpz_banking:client:sendNotification", _source, Locales['NOT_ENOUGH_TO_PAY_BILL'], 'error')
      
      else
        SendNotification(_source, Locales['NOT_ENOUGH_TO_PAY_BILL'], "error")
      end

      return

    end

    xPlayer.removeAccount(billingData.account, billingData.cost)

    if billingData.job == 1 and Societies[billingData.job] then
      UpdateSocietyLedger(billingData.job, 'ADD', billingData.cost)
    end

    TriggerEvent("tpz_society:server:onPaidBill", billingData)

    Billing[billingId] = nil

    exports.ghmattimysql:execute( "DELETE FROM `billing` WHERE `id` = @id", {["@id"] = billingData.id})

    -- TPZ Banking Support (Creating history records) & notification system.
    if Config.tpz_banking then

      TriggerEvent('tpz_banking:server:registerHistoryRecord', _source, bankName, billingData.identifier, billingData.charidentifier, billingData.reason, billingData.account, billingData.cost)

      TriggerClientEvent("tpz_banking:client:sendNotification", _source, Locales['PAID_BILL'], 'success')
      TriggerClientEvent("tpz_banking:client:refreshPlayerBills", _source)

    else
      SendNotification(_source, Locales['PAID_BILL'], "success")
    end

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
RegisterServerEvent('tpz_society:server:onPaidBill')
AddEventHandler('tpz_society:server:onPaidBill', function(data)
  -- todo nothing, we only register it here.
end)