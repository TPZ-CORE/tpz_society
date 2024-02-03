# TPZ-CORE Society

## Requirements

TPZ Menu Base : https://github.com/TPZ-CORE/tpz_menu_base

TPZ Inputs : https://github.com/TPZ-CORE/tpz_inputs

# Installation

1. When opening the zip file, open `tpz_society-main` directory folder and inside there will be another directory folder which is called as `tpz_society`, this directory folder is the one that should be exported to your resources (The folder which contains `fxmanifest.lua`).

2. Add `ensure tpz_society` after `tpz_core` and its requirements in the resources.cfg or server.cfg, depends where your scripts are located.

# Important Information

## Ledger & Salaries

For a society to be able to be registered, the job must be inserted into `society` database table, otherwise Ledger, Salary System and Billing System, won't be functional, even if the option is enabled from the configuration file.

(!) A society will be registered only after the script is restarted and not while server is running.

## Billing

A billing system is functional only with TPZ-Banking.

When a society (job), creates a bill on a player, the bills must be paid directly from the Bank and not from a Menu like other frameworks.
