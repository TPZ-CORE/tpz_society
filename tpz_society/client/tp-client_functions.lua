local Prompts, DutyPrompts         = GetRandomIntInRange(0, 0xffffff), GetRandomIntInRange(0, 0xffffff)
local PromptsList, DutyPromptsList = {}, {}

--[[-------------------------------------------------------
 Base Events
]]---------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    Citizen.InvokeNative(0x00EDE88D4D13CF59, Prompts) -- UiPromptDelete
    Citizen.InvokeNative(0x00EDE88D4D13CF59, DutyPrompts) -- UiPromptDelete

    for i, society in pairs (Config.Societies) do
        for index, location in pairs (society.Locations) do

            if location.BlipHandle then
                RemoveBlip(location.BlipHandle)
            end
        end
    end

end)

--[[-------------------------------------------------------
 Prompts
]]---------------------------------------------------------

RegisterActionPrompt = function()

    local str      = Locales['PROMPT_ACTION']
    local keyPress = Config.PromptKey.key

    local dPrompt = PromptRegisterBegin()
    PromptSetControlAction(dPrompt, keyPress)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(dPrompt, str)
    PromptSetEnabled(dPrompt, 1)
    PromptSetVisible(dPrompt, 1)
    PromptSetStandardMode(dPrompt, 1)
    PromptSetHoldMode(dPrompt, 1000)
    PromptSetGroup(dPrompt, Prompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, dPrompt, true)
    PromptRegisterEnd(dPrompt)

    PromptsList = dPrompt
end

function GetPromptData()
    return Prompts, PromptsList
end

RegisterDutyActionPrompt = function()

    local str      = Locales['PROMPT_DUTY_ACTION']
    local keyPress = Config.DutyPromptKey.key

    local dPrompt = PromptRegisterBegin()
    PromptSetControlAction(dPrompt, keyPress)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(dPrompt, str)
    PromptSetEnabled(dPrompt, 1)
    PromptSetVisible(dPrompt, 1)
    PromptSetStandardMode(dPrompt, 1)
    PromptSetHoldMode(dPrompt, 1000)
    PromptSetGroup(dPrompt, DutyPrompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, dPrompt, true)
    PromptRegisterEnd(dPrompt)

    DutyPromptsList = dPrompt
end

function GetDutyPromptData()
    return DutyPrompts, DutyPromptsList
end

--[[-------------------------------------------------------
 Blips Management
]]---------------------------------------------------------

Citizen.CreateThread(function ()

    for i, society in pairs (Config.Societies) do

        if society.BlipData and society.BlipData.Enabled then

            for index, location in pairs (society.Locations) do
                
                local blipHandle = N_0x554d9d53f696d002(1664425300, location.Coords.x, location.Coords.y, location.Coords.z)
    
                SetBlipSprite(blipHandle, society.BlipData.Sprite, 1)
                SetBlipScale(blipHandle, 0.1)
                Citizen.InvokeNative(0x9CB1A1623062F402, blipHandle, society.BlipData.Title)
        
                Config.Societies[i].Locations[index].BlipHandle = blipHandle

            end

        end

    end
end)


--[[-------------------------------------------------------
 General Functions
]]---------------------------------------------------------

function GetNearestPlayers(distance)
	local closestDistance = distance
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed, true, true)
	local closestPlayers = {}

	for _, player in pairs(GetActivePlayers()) do
		local target = GetPlayerPed(player)

		if target ~= playerPed then
			local targetCoords = GetEntityCoords(target, true, true)
			local distance = #(targetCoords - coords)

			if distance < closestDistance then
				table.insert(closestPlayers, player)
			end
		end
	end
	return closestPlayers
end