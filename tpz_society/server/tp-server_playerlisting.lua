
local TPZ = {}

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

local ConnectedPlayers = {}

-----------------------------------------------------------
--[[ General Events  ]]--
-----------------------------------------------------------

-- When script stops, we remove all the data from ConnectedPlayers list.
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end

    ConnectedPlayers = {}

end)

-- When player quits the game, we remove him from ConnectedPlayers list.
AddEventHandler('playerDropped', function (reason)
    local _source = source
    ConnectedPlayers[_source] = nil
end)

-- The following event is triggered after selecting a character or using devmode,
-- in order to load and register the player as connected.
RegisterServerEvent('tpz_society:registerConnectedPlayer')
AddEventHandler('tpz_society:registerConnectedPlayer', function()
    local _source         = source
    local xPlayer         = TPZ.GetPlayer(_source)

    -- This is mostly required for DevMode, to avoid any kind of errors when player's join the server.
    -- It will only load the following data, after a character is selected.
    while not xPlayer.loaded() do
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
--[[ Functions ]]--
-----------------------------------------------------------

-- When first joining the game, we request the player to be added into the list
-- The following list handles the players and their data correctly.
RegisterConnectedPlayer = function(source, identifier, charidentifier, job, jobGrade, username)
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

GetConnectedPlayers = function()
    local data = { list = {}, players = 0 }

    local finished = false

    local connectedPlayersLength = GetTableLength(ConnectedPlayers)

    if connectedPlayersLength > 0 then

        for index, player in pairs (ConnectedPlayers) do

            data.players = data.players + 1
    
            table.insert(data.list, player)
    
            if next(ConnectedPlayers, index) == nil then
                finished = true
            end
    
        end

    else
        finished = true
    end

    while not finished do
        Wait(50)
    end

    return data
end

