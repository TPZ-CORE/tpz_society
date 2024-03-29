

local TPZ    = {}

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

-- The following event is triggered when player selects a character and Config.ToggleDutyOnPlayerJoin is true 
-- and its society `ActiveDuty` is also true which toggles the player's job to off-duty automatically.
RegisterServerEvent('tpz_society:togglePlayerDutyOnJoin')
AddEventHandler('tpz_society:togglePlayerDutyOnJoin', function()
  local _source  = source
  local xPlayer  = TPZ.GetPlayer(_source)

  local jobName  = xPlayer.getJob()
  local jobGrade = xPlayer.getJobGrade()

  xPlayer.setJob('off' .. jobName)
  xPlayer.setJobGrade(jobGrade)

  TriggerClientEvent("tpz_core:getPlayerJob", _source, { job = 'off' .. jobName, jobGrade = jobGrade })

end)

-- The following event is triggered when a player toggles the duty status to become off-duty or on-duty.
RegisterServerEvent('tpz_society:toggleDutyStatus')
AddEventHandler('tpz_society:toggleDutyStatus', function()
  local _source  = source
  local xPlayer  = TPZ.GetPlayer(_source)

  local jobName  = xPlayer.getJob()
  local jobGrade = xPlayer.getJobGrade()

  local NotifyData = nil
  local NotifyType = nil

  if string.match(jobName, "off") then 

    jobName = jobName:gsub("%off", "")

    xPlayer.setJob(jobName)
    xPlayer.setJobGrade(jobGrade)

    TriggerClientEvent("tpz_core:getPlayerJob", _source, { job = jobName, jobGrade = jobGrade })

    NotifyData = Locales['DUTY_TOGGLE_ON']
    NotifyType = "success"
  else
    xPlayer.setJob('off' .. jobName)
    xPlayer.setJobGrade(jobGrade)

    TriggerClientEvent("tpz_core:getPlayerJob", _source, { job = 'off' .. jobName, jobGrade = jobGrade })
  
    NotifyData = Locales['DUTY_TOGGLE_OFF']
    NotifyType = "error"
  end

  TriggerClientEvent("tpz_notify:sendNotification", _source, NotifyData.title, NotifyData.message, NotifyData.icon, NotifyType, NotifyData.duration)
  
  
end)