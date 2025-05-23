
local TPZ = exports.tpz_core:getCoreAPI()

-----------------------------------------------------------
--[[ Callbacks  ]]--
-----------------------------------------------------------

exports.tpz_core:getCoreAPI().addNewCallBack("tpz_society:callbacks:getBills", function(source, cb)
	local _source      = source
	local playerBills  = GetPlayerBills(_source)

	return cb(playerBills)
end)

-- @parameter job : Required parameter for the following callback to check if Society is null or exists.
exports.tpz_core:getCoreAPI().addNewCallBack("tpz_society:callbacks:isAllowedToCreateBill", function(source, cb, data)
	local Societies = GetSocieties()
	return cb(Societies[data.job] == nil)
end)

exports.tpz_core:getCoreAPI().addNewCallBack("tpz_society:callbacks:getSocietyData", function(source, cb)
	local _source   = source
	local xPlayer   = TPZ.GetPlayer(_source)
	local job       = xPlayer.getJob()

	local Societies = GetSocieties()

	if not Societies[job] then
		return nil
	end

	return cb(Societies[job])
end)

exports.tpz_core:getCoreAPI().addNewCallBack("tpz_society:callbacks:getEmployees", function(source, cb, data)

	local jobPlayerList = TPZ.GetJobPlayers(data.job)

	if jobPlayerList.count <= 0 then
		return cb( {} )
	end

	local elements = {}

	for _i, allowedPlayer in pairs (jobPlayerList.players) do

		local xPlayer                = TPZ.GetPlayer(tonumber(allowedPlayer.source))

		allowedPlayer.charidentifier = xPlayer.getCharacterIdentifier()
		allowedPlayer.username       = xPlayer.getFirstName() .. " " .. xPlayer.getLastName()
		allowedPlayer.grade          = xPlayer.getJobGrade()
		
		table.insert(elements, allowedPlayer)
	end

	return cb(elements)
end)
