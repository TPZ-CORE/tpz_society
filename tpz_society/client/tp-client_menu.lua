local TPZ = exports.tpz_core:getCoreAPI()

local MenuData = {}

TriggerEvent('tpz_menu_base:getData',function(call)
    MenuData = call
end)

local CurrentLocationIndex = nil

--[[ ------------------------------------------------
   Local Functions
]]---------------------------------------------------

local HasStoragePermission = function()
    local PlayerData = GetPlayerData()

    local locationData = Config.Societies[PlayerData.Job].Locations[CurrentLocationIndex]

    for _, grade in pairs (locationData.InventoryContainer.grades) do

        if tonumber(PlayerData.JobGrade) == tonumber(grade) then
            return true
        end
    end

    return false

    
end

local CloseMenuProperly = function ()
    local PlayerData = GetPlayerData()

    MenuData.CloseAll()

    TaskStandStill(PlayerPedId(), 1)
    PlayerData.HasMenuOpen = false

    CurrentLocationIndex = nil
end

--[[ ------------------------------------------------
   Menu Actions
]]---------------------------------------------------

function OpenSocietyManagementMenu(index)
    MenuData.CloseAll()

    local PlayerData = GetPlayerData()
    PlayerData.HasMenuOpen = true

    if CurrentLocationIndex == nil then
        CurrentLocationIndex = index
    end

    TaskStandStill(PlayerPedId(), -1)

    local options = {
        { label = Locales['MANAGEMENT_MENU_EMPLOYEES'], value = 'employees', desc = ""},

        { label = Locales['MANAGEMENT_MENU_INVENTORY'], value = 'storage',   desc = ""},
        { label = Locales['MANAGEMENT_MENU_LEDGER'],    value = 'ledger',    desc = ""},

        { label = Locales['MANAGEMENT_MENU_EXIT'],      value = 'backup',    desc = ""},
    }

    MenuData.Open('default', GetCurrentResourceName(), 'main_menu',

    {
        title    = Locales['MANAGEMENT_MENU_TITLE'],
        subtext  = "",
        align    = "left",
        elements = options,
    },

    function(data, menu)

        if (data.current.value == "backup") then
            CloseMenuProperly()

        elseif (data.current.value == 'storage') then

            local hasPermission = HasStoragePermission()

            if hasPermission then

                local containerId = Config.Societies[PlayerData.Job].Locations[CurrentLocationIndex].InventoryContainer.containerId

                if containerId == false then
                    SendNotification(nil, Locales['STORAGE_INVALID'], "error")
                    return
                end

                CloseMenuProperly()

                Wait(500)

                TriggerEvent("tpz_inventory:openInventoryContainerById", containerId, Config.Societies[PlayerData.Job].InventoryContainerTitle, false)

            else
                SendNotification(nil, Locales['INSUFFICIENT_PERMISSIONS'], "error")
            end

        elseif (data.current.value == 'employees') then

            local bossGrade = Config.Societies[PlayerData.Job].BossGrade

            if PlayerData.JobGrade ~= bossGrade then
                SendNotification(nil, Locales['INSUFFICIENT_PERMISSIONS'], "error")
                return
            end

            OpenSocietyEmployeesList()

        elseif (data.current.value == 'ledger') then
            
            local bossGrade = Config.Societies[PlayerData.Job].BossGrade

            if PlayerData.JobGrade ~= bossGrade then
                SendNotification(nil, Locales['INSUFFICIENT_PERMISSIONS'], "error")
                return
            end

            OpenSocietyLedgerMenu()
        end


    end,

    function(data, menu)
        CloseMenuProperly()
    end)
end


function OpenSocietyEmployeesList()
    MenuData.CloseAll()

    local PlayerData = GetPlayerData()
    local elements = {}

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_society:callbacks:getEmployees", function(cb)

        local length = TPZ.GetTableLength(cb)

        if length > 0 then
    
            local count = 0 
    
            for _, player in pairs (cb) do

                if GetPlayerServerId(PlayerId()) ~= player.source then
                    count = count + 1
                    table.insert(elements, { source = player.source, username = player.username, label = string.format(Locales['MANAGEMENT_MENU_EMPLOYEE'], count, player.username, player.grade), value = player.charidentifier, desc = "" })
                end
                
            end
    
        end

    
        table.insert(elements, { label = Locales['MANAGEMENT_MENU_HIRE'], value = "hire", desc = ""})
        table.insert(elements, { label = Locales['MANAGEMENT_MENU_BACK'], value = "backup", desc = ""})

        MenuData.Open('default', GetCurrentResourceName(), 'employees_menu',

        {
            title    = Locales['MANAGEMENT_MENU_EMPLOYEES_LIST'],
            subtext  = "",
            align    = "left",
            elements = elements,
        },
    
        function(data, menu)
    
            if (data.current.value == "backup") then
                OpenSocietyManagementMenu()
    
            elseif (data.current.value == "hire") then

                local nearestPlayers = GetNearestPlayers(3.0)
                local foundPlayer    = false

                local inputData = {
                    title        = Locales['MANAGEMENT_MENU_HIRE_TITLE'],
                    desc         = Locales['MANAGEMENT_MENU_HIRE_DESCRIPTION'],
                    buttonparam1 = Locales['MENU_ACCEPT'],
                    buttonparam2 = Locales['MENU_DECLINE'],
                 }
                                            
                 TriggerEvent("tpz_inputs:getTextInput", inputData, function(cb)

                    local inputId = tonumber(cb)

                    if inputId ~= nil and inputId ~= 0 and inputId > 0 then

                        if inputId == GetPlayerServerId(PlayerId()) then
                            SendNotification(nil, Locales['CANNOT_HIRE_YOURSELF'], "error")
                            return
                        end

                        for _, targetPlayer in pairs(nearestPlayers) do

                            if inputId == GetPlayerServerId(targetPlayer) then
                               foundPlayer = true
                            end
                        end

                        if foundPlayer then
                            TriggerServerEvent("tpz_society:server:hireSelectedSourceId", PlayerData.Job, data.current.username, tonumber(data.current.source) )
                            Wait(2000)
                            OpenSocietyEmployeesList()
                        else
                            SendNotification(nil, Locales['PLAYER_NOT_FOUND'], "error")
                        end

                    else

                        if cb ~= 'DECLINE' then
                            SendNotification(nil, Locales['INVALID_INPUT'], "error")
                        end

                    end

                end) 


            else

                OpenEmployeeManagement(data.current.username, data.current.source)
            end
    
    
        end,
    
        function(data, menu)
            OpenSocietyManagementMenu()
        end)


    end, { job = PlayerData.Job })

end


function OpenEmployeeManagement(username, sourceId)
    MenuData.CloseAll()

    local PlayerData = GetPlayerData()

    local options = {
        { label = Locales['MANAGEMENT_MENU_EMPLOYEE_GRADE'], value = 'grade',  desc = ""},

        { label = Locales['MANAGEMENT_MENU_EMPLOYEE_FIRE'],  value = 'fire',   desc = ""},
        { label = Locales['MANAGEMENT_MENU_BACK'],           value = 'backup', desc = ""},
    }

    MenuData.Open('default', GetCurrentResourceName(), 'employees_menu_manage',

    {
        title    = username,
        subtext  = "",
        align    = "left",
        elements = options,
    },

    function(data, menu)

        if (data.current.value == "backup") then
            OpenSocietyEmployeesList()

        elseif (data.current.value == "grade") then
            OpenEmployeeGradeManagement(username, tonumber(sourceId) )

        elseif (data.current.value == "fire") then
            TriggerServerEvent("tpz_society:server:fireSelectedSourceId", PlayerData.Job, username, tonumber(sourceId) )
            OpenSocietyEmployeesList()
        end


    end,

    function(data, menu)
        OpenSocietyEmployeesList()
    end)

end

function OpenEmployeeGradeManagement(username, sourceId)
    MenuData.CloseAll()

    local PlayerData = GetPlayerData()

    local elements = {}

    local society  = Config.Societies[PlayerData.Job]
    local length   = GetTableLength(society.GradesList)

    if length > 0 then

        for grade, label in pairs (society.GradesList) do
            table.insert(elements, { label = label, value = grade, desc = "" })
        end

    end

    table.insert(elements, { label = Locales['MANAGEMENT_MENU_BACK'], value = "backup", desc = ""})
    
    MenuData.Open('default', GetCurrentResourceName(), 'employees_menu_manage_grade',

    {
        title    = username,
        subtext  = "",
        align    = "left",
        elements = elements,
    },

    function(data, menu)

        if (data.current.value == "backup") then
            OpenEmployeeManagement(username, sourceId)

        else
            TriggerServerEvent("tpz_society:server:setSelectedSourceIdGrade", PlayerData.Job, username, tonumber(sourceId), tonumber(data.current.value), data.current.label)
            OpenSocietyEmployeesList()
        end

    end,

    function(data, menu)
        OpenEmployeeManagement(username, sourceId)
    end)

end


function OpenSocietyLedgerMenu()

    local PlayerData = GetPlayerData()

    MenuData.CloseAll()

    local options = {
        { label = Locales['MANAGEMENT_MENU_LEDGER_DEPOSIT'],  value = 'deposit',  desc = ""},

        { label = Locales['MANAGEMENT_MENU_LEDGER_WITHDRAW'], value = 'withdraw', desc = ""},
        { label = Locales['MANAGEMENT_MENU_BACK'],            value = 'backup',   desc = ""},
    }

    MenuData.Open('default', GetCurrentResourceName(), 'ledger_menu',

    {
        title    = Locales['MANAGEMENT_MENU_LEDGER'],
        subtext  = "",
        align    = "left",
        elements = options,
    },

    function(data, menu)

        if (data.current.value == "backup") then
            OpenSocietyManagementMenu()

        elseif (data.current.value == "withdraw") or (data.current.value == "deposit") then

            local inputData = {
                title        = Locales['MANAGEMENT_MENU_' .. string.upper(data.current.value) .. '_TITLE'],
                desc         = Locales['MANAGEMENT_MENU_' .. string.upper(data.current.value) .. '_DESCRIPTION'],
                buttonparam1 = Locales['MENU_ACCEPT'],
                buttonparam2 = Locales['MENU_DECLINE'],
             }
                                        
             TriggerEvent("tpz_inputs:getTextInput", inputData, function(cb)

                local inputId = tonumber(cb)

                if inputId ~= nil and inputId ~= 0 and inputId > 0 then

                    if data.current.value == 'deposit' then
                        TriggerServerEvent("tpz_society:server:depositJobLedger", PlayerData.Job, inputId )

                    elseif data.current.value == 'withdraw' then
                        TriggerServerEvent("tpz_society:server:withdrawJobLedger", PlayerData.Job, inputId )
                    end

                    Wait(500)
                    OpenSocietyLedgerMenu()
                    
                else

                    if cb ~= 'DECLINE' then
                        SendNotification(nil, Locales['INVALID_INPUT'], "error")
                    end

                end

            end) 

        end


    end,

    function(data, menu)
        OpenSocietyManagementMenu()
    end)

end
