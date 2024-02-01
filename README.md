# TPZ-CORE Society

## Requirements

TPZ Menu Base : https://github.com/TPZ-CORE/tpz_menu_base

# Important Information

## Ledger & Salaries

For a society to be able to be registered, the job must be inserted into `society` database table, otherwise Ledger, Salary System and Billing System, won't be functional, even if the option is enabled from the configuration file.

(!) A society will be registered only after the script is restarted and not while server is running.

## Billing

A billing system is functional only with TPZ-Banking.

When a society (job), creates a bill on a player, the bills must be paid directly from the Bank and not from a Menu like other frameworks.
