local hasThreadActive = false

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

function TogglePlayerDutyOnJoin()
    local PlayerData = GetPlayerData()

    if not Config.ToggleDutyOnPlayerJoin or Config.Societies[PlayerData.Job] == nil then
        return
    end

    if not Config.Societies[PlayerData.Job].ActiveDuty then
        return
    end

    TriggerServerEvent('tpz_society:server:togglePlayerDutyOnJoin')

end

-----------------------------------------------------------
--[[ Threads ]]--
-----------------------------------------------------------

Citizen.CreateThread(function()
    RegisterDutyActionPrompt()
end)

AddEventHandler('tpz_society:client:start_duty_thread', function()
    local currentJobName = GetPlayerData().Job
    if string.match(currentJobName, "off") then currentJobName = currentJobName:gsub("%off", "") end

    if (Config.Societies[currentJobName] == nil) or (Config.Societies[currentJobName] and not Config.Societies[currentJobName].ActiveDuty) or hasThreadActive then
        return
    end

    hasThreadActive = true

    Citizen.CreateThread(function()

        while true do

            local sleep      = 1000
            local player     = PlayerPedId()

            local isDead     = IsEntityDead(player)
            local PlayerData = GetPlayerData()

            local currentJobName = PlayerData.Job
            if string.match(currentJobName, "off") then currentJobName = currentJobName:gsub("%off", "") end
        
            if (Config.Societies[currentJobName] == nil) or (Config.Societies[currentJobName] and not Config.Societies[currentJobName].ActiveDuty) then
                hasThreadActive = false 
                break 
            end
    
            if isDead or PlayerData.HasMenuOpen then
                goto END
            end

            if not isDead and not PlayerData.HasMenuOpen then

                local coords    = GetEntityCoords(player)
                local locConfig = Config.Societies[currentJobName]
    
                for _index, location in pairs (locConfig.DutyLocations) do

                    local distance = #(coords - vector3(location.Coords.x, location.Coords.y, location.Coords.z))

                    -- Creating marker on the location (If enabled).
                    if locConfig.Marker.Enabled and distance <= locConfig.Marker.DisplayDistance then
                        sleep = 0
                        local dr, dg, db, da = locConfig.Marker.RGBA.r, locConfig.Marker.RGBA.g, locConfig.Marker.RGBA.b, locConfig.Marker.RGBA.a
                        Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, location.Coords.x, location.Coords.y, location.Coords.z - 1.0, 0, 0, 0, 0, 0, 0, 1.7, 1.7, 0.4, dr, dg, db, da, 0, 0, 2, 0, 0, 0, 0)
                    end

                    if distance <= locConfig.ActionDistance then

                        sleep = 0
    
                        local promptGroup, promptList = GetDutyPromptData()

                        local label = CreateVarString(10, 'LITERAL_STRING', Config.DutyPromptKey.label)
                        PromptSetActiveGroupThisFrame(promptGroup, label)
    
                        if PromptHasHoldModeCompleted(promptList) then
    
                            TriggerServerEvent('tpz_society:server:toggleDutyStatus')
    
                            Wait(2000)
                        end
                    end

                end
    
            end
    
            ::END::
            Wait(sleep)
        end

    end)

end)
