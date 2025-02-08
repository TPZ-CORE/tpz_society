

local TPZ    = {}
local TPZInv = exports.tpz_inventory:getInventoryAPI()

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

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

        local xPlayer  = TPZ.GetPlayer(player.source)
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

            if society.ledger > salaryAmount then

              if salaryAmount > 0 then

                if Config.TPZBanking then
                  
                  TriggerEvent('tpz_banking:depositDefaultBankingAccount', tonumber(player.source), salaryAmount, Locales['BANKING_SALARY_REASON'], true)

                else

                  if societyConfig.Salary.Item ~= nil then
                    local canCarryItem = TPZInv.canCarryItem(player.source, societyConfig.Salary.Item, 1)

                    if canCarryItem then
                    
                      local metadata = { salary = salaryAmount, description = player.username, durability = -1 }
                      TPZInv.addItem(player.source, societyConfig.Salary.Item, 1, metadata)
                    
                      UpdateSocietyLedger(jobName, 'REMOVE', salaryAmount)
  
                    else
  
                    end

                 else
                     --money
                  end

                end

              end

            else

            end

          end

        end

      end

    end

  end
end)