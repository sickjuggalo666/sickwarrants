ESX = nil

local playerData

Citizen.CreateThread(function()
    while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
   end

   PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

local jobsAuth = {
	['police'] = true,
	['bcso'] = true,
}

function WarrantMenu()
    local WarrantMenu = {
        {
            id = 0,
            header = 'N.C.I.C. Check',
            txt = 'Arkham Warrants'
        },
        {
            id = 1,
            header = '📲 List Warrants',
            txt = 'Get a List Of Warrants',
            params = {
                event = 'SickWarrantsMenu:optionList',
                args = {
                    selection = 'list_warrants'
                }
            }
        },
        {
            id = 2,
            header = '🔒 Create Warrant',
            txt = 'Create New Warrant',
            params = {
                event = 'SickWarrantsMenu:optionList',
                args = {
                    selection = 'create_warrants'
                }
            }
        },
        {
            id = 3,
            header = '🔎 Delete Warrant',
            txt = 'End Active Warrant',
            params = {
                event = 'SickWarrantsMenu:optionList',
                args = {
                    selection = 'delete'
                }
            }
        },
    }

    local CivWarrantMenu = {
        {
            id = 0,
            header = 'N.C.I.C. Check',
            txt = 'Do You Have a Warrant?'
        },
        {
            id = 1,
            header = '📲 List Warrants',
            txt = 'List Warrants',
            params = {
                event = 'SickWarrantsMenu:optionList',
                args = {
                    selection = 'list_civ_warrants'
                }
            }
        }
    }
    
    if jobsAuth[PlayerData.job.name] then
		exports['zf_context']:openMenu(WarrantMenu)
	else 
		exports['zf_context']:openMenu(CivWarrantMenu)
	end
end--)

RegisterNetEvent('SickWarrantsMenu:optionList')
AddEventHandler('SickWarrantsMenu:optionList', function(args)
    if args.selection == 'delete' then
        DeleteWarrant()
    elseif args.selection == 'list_civ_warrants' then
        CivWarrantList()
    elseif args.selection == 'create_warrants' then
        ShowCreateWarrantMenu()
    elseif args.selection == 'list_warrants' then
        WarrantList()
    end
end)

function ShowCreateWarrantMenu()
    local dialog = exports['zf_dialog']:DialogInput({
        header = "Create Warrant",
        rows = {
            {
                id = 0,
                txt = "First Name",
            },
            {
                id = 1,
                txt = "Last Name",
            },
            {
                id = 2,
                txt = "Case #",
            },
            {
                id = 3,
                txt = "Birth Date",
            },
            {
                id = 4,
                txt = "Reason",
            },
        }
    })

    if dialog ~= nil then
        if dialog[1].input == nil or dialog[2].input == nil or dialog[3].input == nil or dialog[4].input == nil or dialog[5].input == nil then
            ESX.ShowNotification("Dialog Bars Cannot be Empty!")
        else
            firstname = dialog[1].input
            lastname  = dialog[2].input
            case      = dialog[3].input
            bday = dialog[4].input
            reason = dialog[5].input
            TriggerServerEvent('sickwarrants:createWarrant', firstname, lastname, case, bday, reason)
        end
    end
end

function WarrantList() -- for police checking
    ESX.TriggerServerCallback('sickwarrants:getActive', function(active)
        local counter = 2
        local WL = {
                {
                    id = 1,
                    header = 'Active Warrants',
                    txt = 'N.C.I.C',
                }
            }
            for i = 1, #active do
                table.insert(WL,{
                    id = counter,
                    header = active[i].name..', DOB: '..active[i].bday..',  Case: '..active[i].case,
                    txt = "Reason: "..active[i].reason,
                    params = {   -- Remove this table if you don't want the cases to be deleted in the menu!
                        event = 'sickwarrants:DeleteWarrant1',  
                        isServer = true,
                        args = {
                            case = active[i].case,
                        }
                    }
                })
                counter = counter+1
            end
        exports['zf_context']:openMenu(WL)
    end)
end

function CivWarrantList() -- for civ Checking. realistically you could make this one function if you remove the params for deleting in the menu. 
    ESX.TriggerServerCallback('sickwarrants:getActive', function(active) -- same info is used basically police menu just has the option to quick delete
        local counter = 2                                     -- Once my Jail is ready i will work a way to make it so when police select name they are sent to Jail
        local WCL = {
                {
                    id = 1,
                    header = 'Active Warrants',
                    txt = 'N.C.I.C',
                },
            }
            for i=1, #active do
                table.insert(WCL, {
                    id = counter,
                    header = active[i].name..', DOB: '..active[i].bday..'  Case: '..active[i].case,
                    txt = "Reason: "..active[i].reason,
                })
                counter = counter+1
            end
        exports['zf_context']:openMenu(WCL)
    end)
end

function DeleteWarrant()
    local dialog = exports['zf_dialog']:DialogInput({
        header = "Delete Active Warrant?",
        rows = {
            {
                id = 0,
                txt = "Enter Case #"
            }
        }
    })

    if dialog[1].input == nil then
        ESX.ShowNotification("Please Enter Valid Case Number!")
    else
        local case = dialog[1].input
            TriggerServerEvent('sickwarrants:DeleteWarrant', case)  -- working
            ESX.ShowNotification("Successful Removal Of Warrant!")
        end)
    end
end