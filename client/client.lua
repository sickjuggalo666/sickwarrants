ESX = nil

local PlayerData = {}

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

local BountyJobs = {
      ['bondsman'] = true
}

RegisterNetEvent('sickwarrants:warrantMenu')
AddEventHandler('sickwarrants:warrantMenu',function()
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
    }

    local CivWarrantMenu = {
        {
            id = 0,
            header = 'N.C.I.C. Check',
            txt = 'Do You Have a Warrant?'
        },
        {
            id = 1,
            header = '📲 List Person Warrants',
            txt = 'List Person Warrants',
            params = {
                event = 'SickWarrantsMenu:optionList',
                args = {
                    selection = 'list_civ_warrants'
                }
            }
        },
    }
    if jobsAuth[PlayerData.job.name] then
	exports['zf_context']:openMenu(WarrantMenu)
    else 
	exports['zf_context']:openMenu(CivWarrantMenu)
    end
end)

RegisterNetEvent('SickWarrantsMenu:optionList')
AddEventHandler('SickWarrantsMenu:optionList', function(args)
    if args.selection == 'delete' then  -- Deleting i THINK works but not fully tested!
        DeleteWarrant(args.case)
    elseif args.selection == 'list_civ_warrants' then
        CivWarrantList()
    elseif args.selection == 'create_warrants' then
        ShowCreateWarrantMenu()
    elseif args.selection == 'list_warrants' then
        WarrantList()
    elseif args.selection == 'warrant_choices' then
        SetWarrantOptions(args.case)
    elseif args.selection == 'set_bounty' then
        EnterBountyAmount(args.case)
    end
end)

function EnterBountyAmount(case)
   local BountyAmount = exports['zf_dialog']:DialogInput({
        header = "Create Warrant",
        rows = {
            {
                id = 0,
                txt = "Set Bounty Amount",
            },
        }
    })

    if BountyAmount ~= nil then
        if BountyAmount[1].input == nil then
            Notify(3, "Dialog Bars Cannot be Empty!")
        else
            amount = BountyAmount[1].input,
            
            TriggerServerEvent('sickwarrants:setBounty', amount, case)
        end
    end
end

function SetWarrantOptions(case)
   local DeleteWarrant = {
        {
            id = 0,
            header = 'Delete or Set Bounty',
            txt = 'Choose an Option Below'
        },
        {
            id = 1,
            header = 'Delete Warrant?',
            txt = 'Delete Selected Warrant?',
            params = {
                event = 'SickWarrantsMenu:optionList',
                args = {
                    selection = 'delete'
                    case = case
                }
            }
        },
    }
   local SetBounty = {
        {
            id = 0,
            header = 'Delete or Set Bounty',
            txt = 'Choose an Option Below'
        },
        {
            id = 1,
            header = 'Set a Bounty?',
            txt = 'Add a Bounty for this Warrant!',
            params = {
                event = 'SickWarrantsMenu:optionList',
                args = {
                    selection = 'set_bounty'
                    case = case
                }
            }
        },
        {
            id = 2,
            header = 'Delete Warrant?',
            txt = 'Delete Selected Warrant?',
            params = {
                event = 'SickWarrantsMenu:optionList',
                args = {
                    selection = 'delete'
                    case = case
                }
            }
        },
    }
    if BountyJobs[PlayerData.job.name] then
	exports['zf_context']:openMenu(SetBounty)
    else 
	exports['zf_context']:openMenu(DeleteWarrant)
    end
end

function ShowCreateWarrantMenu() -- if using the MDT option you will not need these menus. if not using MDT option then this is how you will create warrants inside the script!
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
            Notify(3, "Dialog Bars Cannot be Empty!")
        else
            firstname = dialog[1].input,
            lastname  = dialog[2].input,
            case      = dialog[3].input,
            bday = dialog[4].input,
            reason = dialog[5].input,
            TriggerServerEvent('sickwarrants:createWarrant', firstname, lastname, case, bday, reason)
        end
    end
end

function WarrantList() --for police checking
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
                    header = active[i].name..', DOB: '..active[i].bday..',  Case: '..active[i].case, -- this is where the server side query reads the data. if you change server side
                    txt = "Reason: "..active[i].reason,                                              -- info make sure to change these to match!!
                    params = { 
                        event = 'SickWarrantsMenu:optionList',  
                        --isServer = true,
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

function CivWarrantList() 
    ESX.TriggerServerCallback('sickwarrants:getActive', function(active) 
        local counter = 2                                     
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
                    header = active[i].name..',  Date: '..active[i].bday..'  Case: '..active[i].case, -- this is where the server side query reads the data. if you change server side
                    txt = "Reason: "..active[i].reason.. "Bounty: "..active[i].bounty,                                               -- info make sure to change these to match!!
                })
                counter = counter+1
            end
        exports['zf_context']:openMenu(WCL)
    end)
end

function DeleteWarrant(case)
    local SetBounty = {
        {
            id = 0,
            header = 'Delete Selected Warrant?',
            txt = 'Case Number: '..case
        },
        {
            id = 1,
            header = 'YES',
            txt = 'Delete Warrant for Case Number: '..case,
            params = {
                event = 'SickWarrantsMenu:optionList',
                isServer = true,
                args = {
                    selection = 'delete'
                    case = case
                }
            }
        },
        {
            id = 2,
            header = 'NO',
            txt = 'Cancel Deletion of Warrant?',
            params = {
                event = 'SickWarrantsMenu:optionList',
                args = {
                    selection = 'cancel'
                }
            }
        },
    }
   exports['zf_context']:openMenu(SetBounty)
end

function Notify(noty_type, message)
    if noty_type and message then
        if Config.NotificationType.client == 'esx' then
            ESX.ShowNotification(message)

        elseif Config.NotificationType.client == 'okokNotify' then
            if notif_type == 1 then
                exports['okokNotify']:Alert("Warrants", message, 10000,'success')
            elseif notif_type == 2 then
                exports['okokNotify']:Alert("Warrants", message, 10000, 'info')
            elseif notif_type == 3 then
                exports['okokNotify']:Alert("Warrants", message, 10000, 'error')
            end

        elseif Config.NotificationType.client == 'mythic' then
            if notif_type == 1 then
                exports['mythic_notify']:SendAlert('success', message, { ['background-color'] = '#ffffff', ['color'] = '#000000' })
            elseif notif_type == 2 then
                exports['mythic_notify']:SendAlert('inform', message, { ['background-color'] = '#ffffff', ['color'] = '#000000' })
            elseif notif_type == 3 then
                exports['mythic_notify']:SendAlert('error', message, { ['background-color'] = '#ffffff', ['color'] = '#000000' })
            end

        elseif Config.NotificationType.client == 'chat' then
            TriggerEvent('chatMessage', message)
            
        elseif Config.NotificationType.client == 'other' then
            --add your own notification.
            
        end
    end
end

exports("WarrantMenu", WarrantMenu)
