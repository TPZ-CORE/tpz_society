
ClientData = { 
    HasMenuOpen         = false,
    Username            = nil,
    CharIdentifier      = 0,
    Job                 = nil,
    JobGrade            = 0,
    Loaded              = false
}

-----------------------------------------------------------
--[[ Base Events & Threads ]]--
-----------------------------------------------------------

-- Gets the player job when devmode set to false and character is selected.
AddEventHandler("tpz_core:isPlayerReady", function()

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_core:getPlayerData", function(data)
        ClientData.CharIdentifier = data.charIdentifier
        ClientData.Job            = data.job
        ClientData.JobGrade       = data.jobGrade

        ClientData.Username       = data.firstname .. ' ' .. data.lastname

        ClientData.Loaded         = true
    
        TriggerServerEvent('tpz_society:registerConnectedPlayer')
        
        TogglePlayerDutyOnJoin()
    end)
    
end)

-- Gets the player job when devmode set to true.
if Config.DevMode then
    Citizen.CreateThread(function ()

        Wait(2000)

        TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_core:getPlayerData", function(data)

            if data == nil then
                return
            end

            ClientData.CharIdentifier = data.charIdentifier
            ClientData.Job            = data.job
            ClientData.JobGrade       = data.jobGrade

            ClientData.Username       = data.firstname .. ' ' .. data.lastname

            ClientData.Loaded         = true
        
            TriggerServerEvent('tpz_society:registerConnectedPlayer')

            TogglePlayerDutyOnJoin()
        end)

    end)
end

-- Updates the player job and job grade in case if changes.
RegisterNetEvent("tpz_core:getPlayerJob")
AddEventHandler("tpz_core:getPlayerJob", function(data)
    ClientData.Job      = data.job
    ClientData.JobGrade = data.jobGrade
end)

-----------------------------------------------------------
--[[ Threads ]]--
-----------------------------------------------------------

Citizen.CreateThread(function()
    RegisterActionPrompt()

    while true do

        Citizen.Wait(0)
        
        local sleep  = true
        local player = PlayerPedId()
        local coords = GetEntityCoords(PlayerPedId())

        local isDead = IsEntityDead(player)

        if not isDead and not ClientData.HasMenuOpen and ClientData.Loaded then

            for index, locConfig in pairs(Config.Societies) do

                local playerDist  = vector3(coords.x, coords.y, coords.z)

                for _index, location in pairs (locConfig.Locations) do
                    local societyDist = vector3(location.Coords.x, location.Coords.y, location.Coords.z)
                    local distance    = #(playerDist - societyDist)

                    if ClientData.Job == index then
                        
                        -- Creating marker on the location (If enabled).
                        if locConfig.Marker.Enabled and distance <= locConfig.Marker.DisplayDistance then
                            sleep = false
                            local dr, dg, db, da = locConfig.Marker.RGBA.r, locConfig.Marker.RGBA.g, locConfig.Marker.RGBA.b, locConfig.Marker.RGBA.a
                            Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, location.Coords.x, location.Coords.y, location.Coords.z - 1.0, 0, 0, 0, 0, 0, 0, 1.7, 1.7, 0.4, dr, dg, db, da, 0, 0, 2, 0, 0, 0, 0)

                        end
    
                        if distance <= locConfig.ActionDistance then

                            sleep = false
        
                            local label = CreateVarString(10, 'LITERAL_STRING', Config.PromptKey.label)
        
                            PromptSetActiveGroupThisFrame(Prompts, label)
        
                            if PromptHasHoldModeCompleted(PromptsList) then
        
                                OpenSocietyManagementMenu(_index)
        
                                Wait(2000)
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
