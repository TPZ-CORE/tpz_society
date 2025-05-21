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


## Information

### Ledger & Salaries

For a society to be able to be registered, the job must be inserted into `society` database table, otherwise Ledger, Salary System and Billing System, won't be functional, even if the option is enabled from the configuration file.

(!) A society will be registered only after the script is restarted and not while server is running.

When creating manually a container on `containers` database table, the `id` will be required for adding it on the Config.Societies where the job name is located! Make sure the container `name` parameter, is the same as the exact job name.
