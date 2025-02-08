
local TPZ         = {}

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

-----------------------------------------------------------
--[[ Callbacks  ]]--
-----------------------------------------------------------

exports.tpz_core:server().addNewCallBack("tpz_society:getBills", function(source, cb)
	local _source         = source
	local xPlayer         = TPZ.GetPlayer(_source)

	local charidentifier  = xPlayer.getCharacterIdentifier()

	local playerBills     = {}
	local Billing          = GetBilling()

	if Billing == nil then
		return cb({})
	end

	if GetTableLength(Billing) > 0 then

		for _, res in pairs (Billing) do 

			if tonumber(res.charidentifier) == tonumber(charidentifier) then
				playerBills[res.id] = {}
				playerBills[res.id] = res

			end

		end

	end

	return cb(playerBills)
end)

-- @parameter job : Required parameter for the following callback to check if Society is null or exists.
exports.tpz_core:server().addNewCallBack("tpz_society:isAllowedToCreateBill", function(source, cb, data)
	cb(Societies[data.job] == nil)
end)


exports.tpz_core:server().addNewCallBack("tpz_society:getEmployees", function(source, cb, data)

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
