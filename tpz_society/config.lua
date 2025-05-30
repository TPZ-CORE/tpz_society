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

-- As default, we save all data every 15 minutes to avoid data loss in case for server crashes.
-- @Duration = Time in minutes.
Config.SaveDataRepeatingTimer = { Enabled = true, Duration = 15 }

Config.Year = 1890

-- What is the job that should be set when an employee gets fired / kicked out of the current job?
Config.UnemployedJob = "unemployed"

Config.CreateBill   = { Command = "createbill", Description = "Create a bill on the selected player id", MaximumNearestDistanceFromTarget = 2.0 }
Config.DisplayBills = { Command = "bills", Description = "Displays all the available bills." }

Config.RegisterSociety = { 
    Command       = "registersociety", 
    Description   = "Register a non-registered society job for the ledger account.",

    Groups        = { 'admin', 'mod' },
    DiscordRoles  = { 111111111111, 22222222222222 },
}


-----------------------------------------------------------
--[[ Society Locations ]]--
-----------------------------------------------------------

Config.Societies = {

    ['police'] = { -- The job name.
        
        JobLabel = "Sheriff's Department",

        InventoryContainerTitle = "Sheriff's Contents",

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
            [1] = { Coords = { x = 2507.456, y = -1301.41, z = 48.953 }, }, -- saint denis
            [2] = { Coords = { x = -279.200, y = 805.9745, z = 119.38 }, }, -- valentine
            [3] = { Coords = { x = 2906.184, y = 1308.746, z = 44.937 }, }, -- annesburg
            [4] = { Coords = { x = 1359.206, y = -1299.75, z = 77.760 }, }, -- rhodes
            [5] = { Coords = { x = -768.029, y = -1266.34, z = 44.053 }, }, -- blackwater
            [6] = { Coords = { x = -1812.31, y = -355.388, z = 164.64 }, }, -- strawberry
        },
        
        Store = { 
            Enabled = true, -- Set it to false if you dont want to have a store included.
            StoreIndexName = "POLICE", -- tpz_stores support as default through an export call. 
            MenuTitle = "Buy Police Gear and Weaponry", 
        },

        BlipData = {
            Enabled = true,
            Sprite = 778811758,
            Title = "Police",
        },
        
        Marker = { -- If this is enabled, a circular marker will be displayed when close to the warehouse actions.
            Enabled = true,
            RGBA    = {r = 255, g = 255, b = 255, a = 50},
            DisplayDistance = 5.0,
        },

        ActionDistance = 1.5,

        -- Set it to false if you don't want the players with this job to use billing by doing /bill <id> <amount> 
        -- Billing will not be functional if the society is not registered.
        Billing = true, 
    
        -- Set it to false if you don't want the players to receive any salary from the job (TPZ-Banking Support)
        -- The cost is the reward for the player after giving the document to the bank and also the amount which will take from ledger.
        -- If ledger has not enough to pay for a salary, no money will be given.
        -- (!) Time does not count for off-duty players.
        Salary = { 
            Enabled = true,

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

        BossGrade      = 3, -- The boss grade which will be able to manage all society actions. 
        RecruitGrade   = 0, -- The recruit grade when someone is hiring a player to the job.

        GradesList      = {
            [0] = "Recruit",
            [1] = "Sheriff",
            [2] = "Marshal",
            [3] = "Boss",
        },
        
        Webhooking = { 
            Enabled = false, -- Set it to false if you dont use any webhook, otherwise all the society actions will be sent to the webhook url.
            Url = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", 
            Color = 10038562,
        },

    },

    ['medic'] = { -- The job name.
        
        JobLabel = "Medical Department",

        InventoryContainerTitle = "Medical",

        -- The following coords is where the menu, blips and inventory containers are located.
        -- All the players with this job and allowed grades will be able to open the inventory container.
        -- The container ID can be found from `containers` table from database.

        -- (!) Set containerId to false if you don't want to open any storage ( ex: containerId = false ).
        Locations = { 
            [1] = { Coords = { x = -282.282, y = 817.8605, z = 119.38 }, InventoryContainer = { grades = {0, 1}, containerId = 2 } },
            [2] = { Coords = { x = 1372.310, y = -1305.61, z = 77.970 }, InventoryContainer = { grades = {0, 1}, containerId = 2 } },
            [3] = { Coords = { x = 2730.585, y = -1229.20, z = 50.370 }, InventoryContainer = { grades = {0, 1}, containerId = 2 } },
            [4] = { Coords = { x = -1803.17, y = -432.625, z = 158.82 }, InventoryContainer = { grades = {0, 1}, containerId = 2 } },
        },

        -- If ActiveDuty set to false, DutyLocations will not be activated 
        -- and Config.ToggleDutyOnPlayerJoin will also not toggle the player's job to off-duty if enabled.
        ActiveDuty = true,

        DutyLocations = {
            [1] = { Coords = { x = -291.545, y = 816.6009, z = 119.38 } }, -- Valentine
            [2] = { Coords = { x = 1368.716, y = -1306.76, z = 76.970 } }, -- Rhodes
            [3] = { Coords = { x = 2726.695, y = -1231.99, z = 50.366 } }, -- Saint Denis
            [4] = { Coords = { x = -1806.84, y = -432.444, z = 158.83 } }, -- Strawberry
        },
        
        Store = { 
            Enabled = false, -- Set it to false if you dont want to have a store included.
            StoreIndexName = "", -- tpz_stores support as default through an export call. 
            MenuTitle = "",
        },

        BlipData = {
            Enabled = false,
            Sprite = -1739686743,
            Title = "Medical Department",
        },
        
        Marker = { -- If this is enabled, a circular marker will be displayed when close to the warehouse actions.
            Enabled = true,
            RGBA    = {r = 255, g = 255, b = 255, a = 50},
            DisplayDistance = 5.0,
        },

        ActionDistance = 1.5,

        -- Set it to false if you don't want the players with this job to use billing by doing /bill <id> <amount> 
        -- Billing will not be functional if the society is not registered.
        Billing = true, 
    
        -- Set it to false if you don't want the players to receive any salary from the job (TPZ-Banking Support)
        -- The cost is the reward for the player after giving the document to the bank and also the amount which will take from ledger.
        -- If ledger has not enough to pay for a salary, no money will be given.
        -- (!) Time does not count for off-duty players.
        Salary = { 
            Enabled = true,

            -- Salary Cost based on the player's grade.
            -- If a player has a grade which is missing from below, the player will receive the same
            -- reward as [0] grade which is the default.
            -- That means, if you don't want a boss to be paid, you should add the grade with 0 cost.
            Grades = { 
                [0] = { Salary = 3 },
                [1] = { Salary = 5 },
            },
        }, 

        BossGrade      = 1, -- The boss grade which will be able to manage all society actions. 
        RecruitGrade   = 0, -- The recruit grade when someone is hiring a player to the job.

        GradesList      = {
            [0] = "Recruit",
            [1] = "Boss",
        },
        
        Webhooking = { 
            Enabled = false, -- Set it to false if you dont use any webhook, otherwise all the society actions will be sent to the webhook url.
            Url = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", 
            Color = 10038562,
        },

    },
}

-----------------------------------------------------------
--[[ Webhooking (Only DevTools - Injection Cheat Logs) ]]--
-----------------------------------------------------------

Config.Webhooks = {
    
    ['DEVTOOLS_INJECTION_CHEAT'] = { -- Warnings and Logs about players who used or atleast tried to use devtools injection.
        Enabled = false, 
        Url = "", 
        Color = 10038562,
    },

}

-----------------------------------------------------------
--[[ Notification Functions  ]]--
-----------------------------------------------------------

-- @param source is always null when called from client.
-- @param messageType returns "success" or "error" depends when and where the message is sent.
function SendNotification(source, message, messageType)

    if not source then
        TriggerEvent('tpz_core:sendBottomTipNotification', message, 3000)
    else
        TriggerClientEvent('tpz_core:sendBottomTipNotification', source, message, 3000)
    end
  
end
