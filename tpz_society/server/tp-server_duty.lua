

local TPZ    = {}

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

-- The following event is triggered when player selects a character and Config.ToggleDutyOnPlayerJoin is true 
-- and its society `ActiveDuty` is also true which toggles the player's job to off-duty automatically.
RegisterServerEvent('tpz_society:server:togglePlayerDutyOnJoin')
AddEventHandler('tpz_society:server:togglePlayerDutyOnJoin', function()
  local _source  = source
  local xPlayer  = TPZ.GetPlayer(_source)

  local jobName  = xPlayer.getJob()
  local jobGrade = xPlayer.getJobGrade()

  xPlayer.setJob('off' .. jobName)
  xPlayer.setJobGrade(jobGrade)

end)

-- The following event is triggered when a player toggles the duty status to become off-duty or on-duty.
RegisterServerEvent('tpz_society:server:toggleDutyStatus')
AddEventHandler('tpz_society:server:toggleDutyStatus', function()
  local _source  = source
  local xPlayer  = TPZ.GetPlayer(_source)

  local jobName = xPlayer.getJob()
  local jobGrade = xPlayer.getJobGrade()

  local NotifyData = nil

  if string.match(jobName, "off") then 

    jobName   = jobName:gsub("%off", "")
    NotifyData = Locales['DUTY_TOGGLE_ON']
  else

    jobName    = "off" .. jobName
    NotifyData = Locales['DUTY_TOGGLE_OFF']
  end

  xPlayer.setJob(jobName)
  xPlayer.setJobGrade(jobGrade)

  TriggerClientEvent("tpz_notify:sendNotification", _source, NotifyData.title, NotifyData.message, NotifyData.icon, "info", NotifyData.duration)
end)