Config         = {}

Config.DevMode = false
Config.Debug   = false

Config.PromptKey     = { key = 0x760A9C6F, label = 'Society Management' }
Config.DutyPromptKey = { key = 0x760A9C6F, label = 'Duty Management' }

-----------------------------------------------------------
--[[ General ]]--
-----------------------------------------------------------

-- If set to true, when a player joins the server and ActiveDuty of the player's job society exists
-- and is activated, the player's job will be toggled as off-duty automatically by the system.
Config.ToggleDutyOnPlayerJoin = true

-- The time in minutes (How often should the player should be receiving the salary).
Config.SalaryTime = 30

-- The following option is saving all data upon server restart hours (2-3 Minutes atleast before server restart is preferred).
Config.RestartHours = { "7:57" , "13:57", "19:57", "1:57"}

Config.Year = 1890

-- If TPZ Banking exists, set it to true, the following script is creating History Records directly from society billing system.
-- Also, you will be receiving salaries directly to TPZ Banking (No item given), an item will be given
-- only if TPZBanking has been set to false.
-- This item is not supported by any of our scripts, it has to be manually supported by a developer of your server.
Config.TPZBanking = true

-- What is the job that should be set when an employee gets fired / kicked out of the current job?
Config.UnemployedJob = "unemployed"

-----------------------------------------------------------
--[[ Society Locations ]]--
-----------------------------------------------------------

Config.Societies = {

    ['police'] = { -- The job name.
        
        JobLabel = "Police Department",

        InventoryContainerTitle = "Police",

        -- The following coords is where the menu, blips and inventory containers are located.
        -- All the players with this job and allowed grades will be able to open the inventory container.
        -- The container ID can be found from `containers` table from database.

        -- (!) Set containerId to false if you don't want to open any storage ( ex: containerId = false ).
        Locations = { 
            [1] = { Coords = { x = -279.21,  y = 809.9,    z = 119.3  }, InventoryContainer = { grades = {2, 3}, containerId = 1 } },
            [2] = { Coords = { x = 1361.56,  y = -1303.22, z = 77.76  }, InventoryContainer = { grades = {2, 3}, containerId = 1 } },
            [3] = { Coords = { x = 2508.43,  y = -1308.72, z = 48.95  }, InventoryContainer = { grades = {2, 3}, containerId = 1 } },
            [4] = { Coords = { x = -763.41,  y = -1271.52, z = 43.99  }, InventoryContainer = { grades = {2, 3}, containerId = 1 } },
            [5] = { Coords = { x = -3624.99, y = -2601.39, z = -13.39 }, InventoryContainer = { grades = {2, 3}, containerId = 1 } },
            [6] = { Coords = { x = 2907.72,  y = 1312.85,  z = 44.93  }, InventoryContainer = { grades = {2, 3}, containerId = 1 } },
            [7] = { Coords = { x = -1807.44, y = -348.05,  z = 164.70 }, InventoryContainer = { grades = {2, 3}, containerId = 1 } },
            [8] = { Coords = { x = -5530.88, y = -2929.16, z = -1.36  }, InventoryContainer = { grades = {2, 3}, containerId = 1 } },
            [9] = { Coords = { x = 337.7483, y = 1507.591, z = 181.87 }, InventoryContainer = { grades = {2, 3}, containerId = 1 } },
        },

        -- If ActiveDuty set to false, DutyLocations will not be activated 
        -- and Config.ToggleDutyOnPlayerJoin will also not toggle the player's job to off-duty if enabled.
        ActiveDuty = true,

        DutyLocations = {
            [1] = { Coords = { x = 2507.456, y = -1301.41, z = 48.953, h = 12.058819770813 } },
        },

        BlipData = {
            Enabled = true,
            Sprite = 778811758,
            Title = "Police",
        },
        
        Marker = { -- If this is enabled, a circular marker will be displayed when close to the warehouse actions.
            Enabled = true,
            RGBA    = {r = 240, g = 230, b = 140, a = 50},
            DisplayDistance = 5.0,
        },

        ActionDistance = 1.5,

        -- Set it to false if you don't want the players with this job to use billing by doing /bill <id> <amount> 
        -- Billing will not be functional if the society is not registered.
        Billing = true, 
    
        -- Set it to false if you don't want the players to receive any salary from the job (TPZ-Banking Support)
        -- The cost is the reward for the player after giving the document to the bank and also the amount which will take from ledger.
        -- If ledger has not enough to pay for a salary, no item will be given.
        -- (!) Time does not count for off-duty players.
        Salary = { 
            Enabled = true,

            -- Set to false if you are using TPZ-Banking.
            Item    = false, 

            -- Salary Cost based on the player's grade.
            -- If a player has a grade which is missing from below, the player will receive the same
            -- reward as [0] grade which is the default.
            -- That means, if you don't want a boss to be paid, you should add the grade with 0 cost.
            Grades = { 
                [0] = { Salary = 3 },
                [1] = { Salary = 5 },
                [2] = { Salary = 5 },
                [3] = { Salary = 0 }, -- Boss (Handles Ledger, no need for salary).
            },
        }, 
        
        Webhooking = { 
            Enabled = false, -- Set it to false if you dont use any webhook, otherwise all the society actions will be sent to the webhook url.
            Url = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", 
            Color = 10038562,
        },

        BossGrade      = 3, -- The boss grade which will be able to manage all society actions. 
        RecruitGrade   = 0, -- The recruit grade when someone is hiring a player to the job.

        GradesList      = {
            [0] = "Recruit",
            [1] = "Sheriff",
            [2] = "Marshal",
            [3] = "Boss",
        },

    },
}

-----------------------------------------------------------
--[[ Notification Functions  ]]--
-----------------------------------------------------------

-- @param source is always null when called from client.
-- @param messageType returns "success" or "error" depends when and where the message is sent.
function SendNotification(source, message, messageType)

    if not source then
        TriggerEvent('tpz_core:sendRightTipNotification', message, 3000)
    else
        TriggerClientEvent('tpz_core:sendRightTipNotification', source, message, 3000)
    end
  
end