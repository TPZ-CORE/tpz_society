
-----------------------------------------------------------
--[[ Exports  ]]--
-----------------------------------------------------------

-- @HasActiveSocietyMenu : returns a boolean if player has active society menu (open) / not.
exports('HasActiveSocietyMenu', function()
    return GetPlayerData().HasMenuOpen
end)
