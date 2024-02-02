
-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

function TogglePlayerDutyOnJoin()
    if not Config.ToggleDutyOnPlayerJoin or Config.Societies[ClientData.Job] == nil then
        return
    end

    if not Config.Societies[ClientData.Job].ActiveDuty then
        return
    end

    TriggerServerEvent('tpz_society:togglePlayerDutyOnJoin')

end

-----------------------------------------------------------
--[[ Threads ]]--
-----------------------------------------------------------

Citizen.CreateThread(function()
    RegisterDutyActionPrompt()

    while true do
        Citizen.Wait(0)
        
        local sleep   = true
        local player  = PlayerPedId()
        local coords  = GetEntityCoords(PlayerPedId())

        local isDead  = IsEntityDead(player)

        if not isDead and not ClientData.HasMenuOpen and ClientData.Loaded then

            local currentJobName = ClientData.Job
            if string.match(currentJobName, "off") then currentJobName = currentJobName:gsub("%off", "") end

            for index, locConfig in pairs(Config.Societies) do

                if locConfig.ActiveDuty then

                    local playerDist  = vector3(coords.x, coords.y, coords.z)

                    for _index, location in pairs (locConfig.DutyLocations) do
                        local societyDist = vector3(location.Coords.x, location.Coords.y, location.Coords.z)
                        local distance    = #(playerDist - societyDist)
    
                        if index == currentJobName then
                            
                            -- Creating marker on the location (If enabled).
                            if locConfig.Marker.Enabled and distance <= locConfig.Marker.DisplayDistance then
                                sleep = false
                                local dr, dg, db, da = locConfig.Marker.RGBA.r, locConfig.Marker.RGBA.g, locConfig.Marker.RGBA.b, locConfig.Marker.RGBA.a
                                Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, location.Coords.x, location.Coords.y, location.Coords.z - 1.0, 0, 0, 0, 0, 0, 0, 1.7, 1.7, 0.4, dr, dg, db, da, 0, 0, 2, 0, 0, 0, 0)
    
                            end
        
                            if distance <= locConfig.ActionDistance then
    
                                sleep = false
            
                                local label = CreateVarString(10, 'LITERAL_STRING', Config.DutyPromptKey.label)
            
                                PromptSetActiveGroupThisFrame(DutyPrompts, label)
            
                                if PromptHasHoldModeCompleted(DutyPromptsList) then
            
                                    TriggerServerEvent('tpz_society:toggleDutyStatus')
            
                                    Wait(2000)
                                end
                            end
    
                        end

                    end

                end

            end

        end

        if sleep then
            Citizen.Wait(1000)
        end
    end
end)
