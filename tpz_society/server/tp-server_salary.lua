local TPZ = exports.tpz_core:getCoreAPI()

local ConnectedPlayers = {}

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

-- When first joining the game, we request the player to be added into the list
-- The following list handles the players and their data correctly.
local RegisterConnectedPlayer = function(source, identifier, charidentifier, job, jobGrade, username)
  local _source         = source

  ConnectedPlayers[_source]                = {}
  ConnectedPlayers[_source].source         = _source

  ConnectedPlayers[_source].identifier     = identifier
  ConnectedPlayers[_source].charidentifier = charidentifier
  ConnectedPlayers[_source].job            = job
  ConnectedPlayers[_source].jobGrade       = jobGrade
  ConnectedPlayers[_source].username       = username

  ConnectedPlayers[_source].timeInDuty     = 0
end

local GetConnectedPlayers = function()
  local data = { list = {}, players = 0 }

  local connectedPlayersLength = GetTableLength(ConnectedPlayers)

  if connectedPlayersLength > 0 then

    for index, player in pairs (ConnectedPlayers) do

      data.players = data.players + 1

      table.insert(data.list, player)
    end

  end

  return data
end

-----------------------------------------------------------
--[[ General Events  ]]--
-----------------------------------------------------------

-- When script stops, we remove all the data from ConnectedPlayers list.
AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end

  ConnectedPlayers = nil

end)

-- When player quits the game, we remove him from ConnectedPlayers list.
AddEventHandler('playerDropped', function (reason)
  ConnectedPlayers[source] = nil
end)

-- The following event is triggered after selecting a character or using devmode,
-- in order to load and register the player as connected.
RegisterServerEvent('tpz_society:server:registerConnectedPlayer')
AddEventHandler('tpz_society:server:registerConnectedPlayer', function()
  local _source = source
  local xPlayer = TPZ.GetPlayer(_source)

  -- This is mostly required for DevMode, to avoid any kind of errors when player's join the server.
  -- It will only load the following data, after a character is selected.
  if not xPlayer.loaded() then
    Wait(1000)
  end

  local identifier      = xPlayer.getIdentifier()
  local charidentifier  = xPlayer.getCharacterIdentifier()
  local jobName         = xPlayer.getJob()
  local jobGrade        = xPlayer.getJobGrade()
  local usename         = xPlayer.getFirstName() .. ' ' .. xPlayer.getLastName()

  RegisterConnectedPlayer(_source, identifier, charidentifier, jobName, jobGrade, usename)
end)

-----------------------------------------------------------
--[[ Threads ]]--
-----------------------------------------------------------

Citizen.CreateThread(function ()
  while true do
    Citizen.Wait(60000)

    local connectedPlayersList = GetConnectedPlayers()
    local Societies = GetSocieties()

    -- Checking if there are connected players and Societies Table not empty.
    if connectedPlayersList.players > 0 and GetTableLength(Societies) > 0 then

      for index, player in pairs (connectedPlayersList.list) do
        player.source   = tonumber(player.source)
        
        local xPlayer   = TPZ.GetPlayer(player.source)
        local jobName  = xPlayer.getJob()
        local jobGrade = xPlayer.getJobGrade()

        -- If previous job is not the same as current one, we reset the time.
        -- and we update the previous job to the current one.
        if player.job ~= jobName then
          player.job        = jobName
          player.jobGrade   = jobGrade
          player.timeInDuty = 0
        end

        -- Checking if society exists in configuration file and also exists in Societies Table.
        if jobName and Societies[jobName] and Config.Societies[jobName] and Config.Societies[jobName].Salary.Enabled then

          local societyConfig = Config.Societies[jobName]
          local society       = Societies[jobName]

          player.timeInDuty = player.timeInDuty + 1

          if player.timeInDuty >= Config.SalaryTime then

            player.timeInDuty = 0

            -- In case player grade is not in the salaries, we replace the player's grade
            -- As `0` which is the default payments from a job / society.
            local newPlayerGrade = jobGrade

            if societyConfig.Salary.Grades[newPlayerGrade] == nil then
              newPlayerGrade = 0
            end

            local salaryAmount = societyConfig.Salary.Grades[newPlayerGrade].Salary

            -- If the ledger does not have any money, we don't give anything.
            if salaryAmount > 0 and salaryAmount <= society.ledger then

              xPlayer.addAccount(0, salaryAmount)
              UpdateSocietyLedger(jobName, 'REMOVE', salaryAmount)

            end

          end

        end

      end

    end

  end

end)
