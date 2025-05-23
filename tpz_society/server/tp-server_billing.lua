

local TPZ           = exports.tpz_core:getCoreAPI()

local Billing       = {}
local LoadedResults = false

-----------------------------------------------------------
--[[ Local Functions  ]]--
-----------------------------------------------------------

local LoadBilling = function()

  exports["ghmattimysql"]:execute("SELECT * FROM billing ORDER BY id", {}, function(result)

    local length = TPZ.GetTableLength(result)
    
    if length > 0 then

      for _, res in pairs (result) do 
        Billing[res.id] = res 
      end
    
      print("Successfully loaded (" .. length .. ') bills.')
      
    end

  end)

end

local function LoadBillDataByParameters(cost, date)
    
  exports["ghmattimysql"]:execute("SELECT * FROM billing", {}, function(result)

    for _, res in pairs (result) do 
  
      if res.cost == cost and res.date == date then

        Billing[res.id] = {} 
        Billing[res.id] = res 

      end

    end
  
  end)

end

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
--[[ Functions  ]]--
-----------------------------------------------------------

function GetBilling()
  return Billing
end 

function CreateNewBill(source, targetId, isJob, cost, reason, issuer)
  local _source   = source
  local _tsource  = tonumber(targetId)

  if TPZ.GetPlayer(_tsource).loaded() then
    SendNotification(_source, Locales['PLAYER_NOT_AVAILABLE'], "error")
    return
  end

  local PlayerData       = GetPlayerData(_source)
  local PlayerTargetData = GetPlayerData(_tsource)

  local currentDate      = os.date('%d').. '/' ..os.date('%m').. '/' .. Config.Year .. " " .. os.date('%H') .. ":" .. os.date('%M') .. ":" .. os.date('%S')

  local Parameters = {
    ['identifier']      = PlayerTargetData.identifier,
    ['charidentifier']  = PlayerTargetData.charIdentifier,
    ['username']        = PlayerTargetData.username,
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

  exports.ghmattimysql:execute("INSERT INTO `billing` ( `job`, `reason`, `identifier`, `charidentifier`, `username`, `issuer`, `cost`, `date`) VALUES ( @job, @reason, @identifier, @charidentifier, @username, @issuer, @cost, @date)", Parameters)

  Wait(2500)
  LoadBillDataByParameters(cost, currentDate)

  -- webhook
end

function GetPlayerBills(source)
  local _source     = source

  local PlayerData  = GetPlayerData(_source)
	local playerBills = {}

	local Billing     = GetBilling()

	if ( Billing == nil ) or ( Billing and TPZ.GetTableLength(Billing) <= 0 ) then
		return {}
	end

	for _, res in pairs (Billing) do 

		if tonumber(res.charidentifier) == tonumber(PlayerData.charIdentifier) then
			playerBills[res.id] = res
		end

	end

	return playerBills

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

  LoadBilling()
  LoadedResults = true

end)

-----------------------------------------------------------
--[[ General Events  ]]--
-----------------------------------------------------------

RegisterServerEvent('tpz_society:server:payBill')
AddEventHandler('tpz_society:server:payBill', function(billingId)
  local _source     = source
  local xPlayer     = TPZ.GetPlayer(_source)

  -- If billing id is null for some reason, we don't run the rest of the code.
  if Billing[billingId] == nil then
    return
  end

  local Societies   = GetSocieties()

  local billingData = Billing[billingId]
  local money       = xPlayer.getAccount(0)

  if money < billingData.cost then
    SendNotification(_source, Locales['NOT_ENOUGH_TO_PAY_BILL'], "error")
    return
  end

  xPlayer.removeAccount(0, billingData.cost)

  if billingData.job == 1 and Societies[billingData.job] then
    UpdateSocietyLedger(billingData.job, 'ADD', billingData.cost)
  end

  Billing[billingId] = nil
  exports.ghmattimysql:execute( "DELETE FROM `billing` WHERE `id` = @id", {["@id"] = billingData.id})

  SendNotification(_source, Locales['PAID_BILL'], "success")

  TriggerEvent("tpz_society:server:onPaidBill", billingData)
end)

-- @parameter id
-- @parameter job
-- @parameter reason
-- @parameter identifier
-- @parameter charidentifier
-- @parameter username
-- @parameter issuer
-- @parameter cost
-- @parameter date
RegisterServerEvent('tpz_society:server:onPaidBill')
AddEventHandler('tpz_society:server:onPaidBill', function(data)
  -- todo nothing, we only register it here.
end)
