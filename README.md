# TPZ-CORE Society

## Requirements

1. TPZ-Core: https://github.com/TPZ-CORE/tpz_core
2. TPZ-Characters: https://github.com/TPZ-CORE/tpz_characters
3. TPZ-Inventory: https://github.com/TPZ-CORE/tpz_inventory
4. TPZ-Menu-Base: https://github.com/TPZ-CORE/tpz_menu_base
4. TPZ-Notify: https://github.com/TPZ-CORE/tpz_notify
5. TPZ-Inputs: https://github.com/TPZ-CORE/tpz_inputs

# Installation

1. When opening the zip file, open `tpz_society-main` directory folder and inside there will be another directory folder which is called as `tpz_society`, this directory folder is the one that should be exported to your resources (The folder which contains `fxmanifest.lua`).

2. Add `ensure tpz_society` after the **REQUIREMENTS** in the resources.cfg or server.cfg, depends where your scripts are located.

## Development API

**Getter**
The specified export below is used on the `server` to use the API properly and faster.

```lua
local SocietyAPI = exports.tpz_society:getAPI()
```

| Export                                                                    | Description                                                                 | Returned Type |
|---------------------------------------------------------------------------|-----------------------------------------------------------------------------|---------------|
| `SocietyAPI.updateSocietyLedgerAccount(job, transactionType, amount)`     | Updates a registered society ledger account through a transaction type.     | N/A           |
| `SocietyAPI.createNewBill(source, targetId, isJob, cost, reason, issuer)` | Creates a bill on the selected player source.                               | N/A           |
| `SocietyAPI.getPlayerBills(source)`                                       | Returns all the available player bills.                                     | Table         |

## Parameters Explanation

| Parameter                                                                          | Description                                                                                                                                          |
|------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| `source`                                                                           | Requires an online player id source target                                                                                                           | 
| `transactionType`                                                                  | The available transaction types are `ADD` and `REMOVE`                                                                                               | 
| `isJob`                                                                            | It requires a number input `0` - `1` (0 = false, 1 = true) in case the bill that has been created is from a society job (such as saloon, police).    | 
| `reason`                                                                           | It requires a reason for a bill, the reason length must be very short such as (DEPOSIT, TAX, POLICE, SALOON)                                         | 
| `issuer`                                                                           | It requires an issuer for a bill, the issuer length must be very short such as (POLICE, SALOON, GOVERNMENT)                                          | 

## Information

### Ledger & Salaries

For a society to be able to be registered, the job must be inserted into `society` database table, otherwise Ledger, Salary System and Billing System, won't be functional, even if the option is enabled from the configuration file.

(!) A society will be registered only after the script is restarted and not while server is running.

When creating manually a container on `containers` database table, the `id` will be required for adding it on the Config.Societies where the job name is located! Make sure the container `name` parameter, is the same as the exact job name.

## Screenshot Displays

![image](https://github.com/user-attachments/assets/0eb6e807-c251-4a2f-95f2-ee4b012b143f)
