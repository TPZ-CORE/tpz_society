
local PlayerData = { 
    HasMenuOpen         = false,
    Username            = nil,
    CharIdentifier      = 0,
    Job                 = nil,
    JobGrade            = 0,
    Loaded              = false
}

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

function GetPlayerData()
    return PlayerData
end

-----------------------------------------------------------
--[[ Base Events & Threads ]]--
-----------------------------------------------------------

-- Gets the player job when devmode set to false and character is selected.
AddEventHandler("tpz_core:isPlayerReady", function()

    Wait(2000)
    
    local data = exports.tpz_core:getCoreAPI().GetPlayerClientData()

    if data == nil then
        return
    end

    PlayerData.CharIdentifier = data.charIdentifier
    PlayerData.Job            = data.job
    PlayerData.JobGrade       = data.jobGrade

    PlayerData.Username       = data.firstname .. ' ' .. data.lastname

    PlayerData.Loaded         = true
    
    TriggerServerEvent('tpz_society:server:registerConnectedPlayer')
    TriggerServerEvent("tpz_society:server:addChatSuggestions")
        
    TogglePlayerDutyOnJoin()

end)

-- Gets the player job when devmode set to true.
if Config.DevMode then

    Citizen.CreateThread(function ()

        Wait(2000)

        local data = exports.tpz_core:getCoreAPI().GetPlayerClientData()

        if data == nil then
            return
        end

        PlayerData.CharIdentifier = data.charIdentifier
        PlayerData.Job            = data.job
        PlayerData.JobGrade       = data.jobGrade

        PlayerData.Username       = data.firstname .. ' ' .. data.lastname

        PlayerData.Loaded         = true
    
        TriggerServerEvent('tpz_society:server:registerConnectedPlayer')
        TriggerServerEvent("tpz_society:server:addChatSuggestions")
        
        TogglePlayerDutyOnJoin()

    end)
end

-- Updates the player job and job grade in case if changes.
RegisterNetEvent("tpz_core:getPlayerJob")
AddEventHandler("tpz_core:getPlayerJob", function(data)
    PlayerData.Job      = data.job
    PlayerData.JobGrade = data.jobGrade
end)

-----------------------------------------------------------
--[[ Threads ]]--
-----------------------------------------------------------

Citizen.CreateThread(function()
    RegisterActionPrompt()

    while true do

        local sleep  = 1000
        local player = PlayerPedId()
        local isDead = IsEntityDead(player)

        if isDead or PlayerData.HasMenuOpen or not PlayerData.Loaded then
            goto END
        end

        if not isDead and not PlayerData.HasMenuOpen and PlayerData.Loaded then

            local coords = GetEntityCoords(player)
            local isSecondaryInventoryActive = exports.tpz_inventory:getInventoryAPI().isSecondaryInventoryActive()

            if not isSecondaryInventoryActive then

                for index, locConfig in pairs(Config.Societies) do

                    local playerDist  = vector3(coords.x, coords.y, coords.z)
    
                    for _index, location in pairs (locConfig.Locations) do
                        local societyDist = vector3(location.Coords.x, location.Coords.y, location.Coords.z)
                        local distance    = #(playerDist - societyDist)
    
                        if PlayerData.Job == index then
                            
                            -- Creating marker on the location (If enabled).
                            if locConfig.Marker.Enabled and distance <= locConfig.Marker.DisplayDistance then
                                sleep = 0
                                local dr, dg, db, da = locConfig.Marker.RGBA.r, locConfig.Marker.RGBA.g, locConfig.Marker.RGBA.b, locConfig.Marker.RGBA.a
                                Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, location.Coords.x, location.Coords.y, location.Coords.z - 1.0, 0, 0, 0, 0, 0, 0, 1.7, 1.7, 0.4, dr, dg, db, da, 0, 0, 2, 0, 0, 0, 0)
    
                            end
        
                            if distance <= locConfig.ActionDistance then
    
                                sleep = 0
            
                                local promptGroup, promptList = GetPromptData()
    
                                local label = CreateVarString(10, 'LITERAL_STRING', Config.PromptKey.label)
                                PromptSetActiveGroupThisFrame(promptGroup, label)
            
                                if PromptHasHoldModeCompleted(promptList) then
            
                                    OpenSocietyManagementMenu(_index)
            
                                    Wait(2000)
                                end
                            end
    
                        end
    
                    end
    
                end

            end

        end

        ::END::
        Wait(sleep)
    end
end)
