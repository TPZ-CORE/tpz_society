
-- local SocietyAPI = exports.tpz_society:getAPI()

-----------------------------------------------------------
--[[ Exports ]]--
-----------------------------------------------------------

exports('getAPI', function()

  local self = {}

  -- @param source   : The required source (who sends the bill).
  -- @param targetId : The required target id to create the bill to.
  -- @param isJob    : If the created bill is made from another society job (such as saloon, police, medical department).
  self.createNewBill = function(source, targetId, isJob, cost, reason, issuer)
    CreateNewBill(source, targetId, isJob, cost, reason, issuer)
  end

  -- @param source   : The required source.
  self.getPlayerBills = function(source)
    return GetPlayerBills(source)
  end

  -- @param job             : The required society job name to add or remove money.
  -- @param transactionType : The transaction type (ADD, REMOVE)
  -- @param amount          : The transaction amount to be added or removed from the ledger account.
  self.updateSocietyLedgerAccount = function(job, transactionType, amount) 
    UpdateSocietyLedger(job, transactionType, amount)
  end

end)