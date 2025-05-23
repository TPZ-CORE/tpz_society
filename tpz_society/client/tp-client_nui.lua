local TPZ = exports.tpz_core:getCoreAPI()

local HasMenuActive = false

local PAGES_LIST = {
    {min = 1,     max = 6,     page = 1},
    {min = 7,     max = 12,    page = 2},
    {min = 13,    max = 18,    page = 3},
    {min = 19,    max = 24,    page = 4},
    {min = 25,    max = 30,    page = 5}, -- MAXIMUM 5 PAGES.
}

--[[ ------------------------------------------------
   Base Events
]]---------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    if HasMenuActive then
        ClearPedTasks(PlayerPedId())
    end

end)

--[[ ------------------------------------------------
   Local Functions
]]---------------------------------------------------

local function IterateRange (Table, Min, Max)
  
    local ClosureIndex = Min - 1
    local ClosureMax   = math.min(Max, #Table)
    
    local function Closure ()
      if (ClosureIndex < ClosureMax) then
        ClosureIndex = ClosureIndex + 1
        return Table[ClosureIndex]
      end
    end
  
    return Closure
end

local function IterateLastEntries (Table, Count)
    local TableSize  = #Table
    local StartIndex = (TableSize - Count)
    return IterateRange(Table, StartIndex, TableSize)
end


local function GetPageByIndex(index)

    if index >= 20 then
        return 5
    end

    if index > 0 then

        for _, value in pairs (PAGES_LIST) do

            if index == value.min or index == value.max then
                return value.page
            end

            if index >= value.min and index <= value.max then
                return value.page
            end
        end

    end

    return 0
end


local function RefreshPageResults(selectedPageIndex)

    SendNUIMessage({ action = 'resetPages' } )

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_society:callbacks:getBills", function(result)

        if TPZ.GetTableLength(result) > 0 then

            local count, addedCount = 0, 0
            local elements = {}

            -- Step 1: Extract values into a list
            for _, entry in pairs(result) do
                table.insert(elements, entry)
            end

            -- Step 2: Sort the list by id descending
            table.sort(elements, function(a, b)
                return a.id > b.id
            end)
            
            for _, res in ipairs(elements) do

                count = count + 1

                local currentPage = GetPageByIndex(count)

                if currentPage == selectedPageIndex then

                    addedCount = addedCount + 1

                    SendNUIMessage({ 
                        action      = 'insetElement', 
                        option_det  = res
                    })

                    if addedCount == 6 then
                        break
                    end

                end

            end
        end

        local totalPages = GetPageByIndex(TPZ.GetTableLength(result))
        SendNUIMessage({ action = 'setTotalPages', total = totalPages, selected = selectedPageIndex } )

    end)
    
end


local ToggleNUI = function(display)
	SetNuiFocus(display,display)

	HasMenuActive = display

    if not display then
        ClearPedTasks(PlayerPedId())
    end

    SendNUIMessage({ type = "enable", enable = display })
end

local CloseNUI = function()
    if HasMenuActive then SendNUIMessage({action = 'close'}) end
end

local OpenSelectableMenu = function()

    if HasMenuActive then
        return
    end

    ClearPedTasksImmediately(PlayerPedId())
    TaskStartScenarioInPlace(PlayerPedId(), joaat('WORLD_HUMAN_WRITE_NOTEBOOK'), -1)

    SendNUIMessage({ action = 'updateMainTitle', cb = Locales['BILLS_COMMAND_TITLE']})
    RefreshPageResults(1)

    ToggleNUI(true)

end

--[[ ------------------------------------------------
   NUI Callback Functions
]]---------------------------------------------------

RegisterNUICallback('close', function()
	ToggleNUI(false)
end)

RegisterNUICallback('selectPage', function(data)
    RefreshPageResults(tonumber(data.page))
end)


-- @param billIndex
-- @param date
RegisterNUICallback('performAction', function(data)
    Wait(500)
    TriggerServerEvent("tpz_society:server:payBill", tonumber(data.billIndex))
end)


-----------------------------------------------------------
--[[ Commands ]]--
-----------------------------------------------------------

RegisterCommand(Config.DisplayBills.Command, function(source, args, rawCommand)
    OpenSelectableMenu()
end)
