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
      ['bondsman'] = true,
      ['police'] = true
}

RegisterNetEvent('sickwarrants:warrantMenu')
AddEventHandler('sickwarrants:warrantMenu',function()
    lib.registerContext({
        id = 'WarrantMenu',
        title = 'N.C.I.C. Check',
        options = {
            {
                title = '📲 List Warrants',
                description = 'Get a List Of Warrants',
                arrow = true,
                event = 'SickWarrantsMenu:optionList',
                args = {selection = 'list_warrants'}
            },
            {
                title = '🔒 Create Warrant',
                description = 'Create New Warrant',
                arrow = true,
                event = 'SickWarrantsMenu:optionList',
                args = {selection = 'create_warrants'}
            },
        },
    })


    lib.registerContext({
        id = 'CivWarrantMenu',
        title = 'N.C.I.C. Check',
        options = {
            {
                title = '📲 List Person Warrants',
                description = 'List Person Warrants',
                arrow = true,
                event = 'SickWarrantsMenu:optionList',
                args = {selection = 'list_civ_warrants'}
            }
        },
    })
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
    if Config.jobsAuth[PlayerData.job.name] then
        if Config.MenuType == 'ox_libs' then
            lib.showContext('WarrantMenu')
        elseif Config.MenuType =='zf_context' then
	        exports['zf_context']:openMenu(WarrantMenu)
        end
    else 
        if Config.MenuType == 'ox_libs' then
            lib.showContext('CivWarrantMenu')
        elseif Config.MenuType =='zf_context' then
	        exports['zf_context']:openMenu(CivWarrantMenu)
        end
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
    elseif args.selection == 'cancel' then
        if Config.MenuType == 'ox_libs' then
            lib.hideContext(false)
        elseif Config.MenuType == 'zf_context' then

        end
    end
end)

function EnterBountyAmount(case)
    if Config.MenuType == 'ox_libs' then
        local input = lib.inputDialog('Set Bounty Amount', {'Amount'})

        if not input then
            lib.hideContext(false) 
            return
        end
        local amount = input[1]
        local case = case
        print('Client: ', amount, case)
        TriggerServerEvent('sickwarrants:setBounty', amount, case)
    elseif Config.MenuType == 'zf_context' then
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
                amount = BountyAmount[1].input
                case = case
                print('Amount: '..amount.. ', Case: '..case)
                TriggerServerEvent('sickwarrants:setBounty', amount, case)
            end
        end
    end
end

function SetWarrantOptions(case)
    lib.registerContext({
        id = 'deleteBounty',
        title = 'Delete or Set Bounty',
        options = {
            {
                title = 'Delete Warrant?',
                description = 'Delete Selected Warrant?',
                arrow = true,
                event = 'SickWarrantsMenu:optionList',
                args = {selection = 'delete', case = case},
                metadata = {
                    {label = 'Case #', value = case}
                }
            }
        },
    })
    
    
    lib.registerContext({
        id = 'SetBounty',
        title = 'Choose an Option Below',
        options = {
            {
                title = 'Set a Bounty?',
                description = 'Add a Bounty for this Warrant!',
                arrow = true,
                event = 'SickWarrantsMenu:optionList',
                args = {selection = 'set_bounty', case = case},
                metadata = {
                    {label = 'Case #', value = case}
                }
            },
            {
                title = 'Delete Warrant?',
                description = 'Delete Selected Warrant?',
                arrow = true,
                event = 'SickWarrantsMenu:optionList',
                args = {selection = 'delete', case = case},
                metadata = {
                    {label = 'Case #', value = case}
                }
            }
        },
    })


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
                    selection = 'delete',
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
                        selection = 'set_bounty',
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
                        selection = 'delete',
                        case = case
                    }
                }
            },
        }
    if Config.BountyJobs[PlayerData.job.name] then
        if Config.MenuType == 'ox_libs' then
            lib.showContext('SetBounty')
        elseif Config.MenuType =='zf_context' then
	        exports['zf_context']:openMenu(SetBounty)
        end
    else 
        if Config.MenuType == 'ox_libs' then
            lib.showContext('DeleteWarrant')
        elseif Config.MenuType =='zf_context' then
	        exports['zf_context']:openMenu(DeleteWarrant)
        end
    end
end

function ShowCreateWarrantMenu() -- if using the MDT option you will not need these menus. if not using MDT option then this is how you will create warrants inside the script!
    if Config.MenuType == 'ox_libs' then
        local input = lib.inputDialog('Create Warrant', {'First Name','Last Name', 'Case #','Birth Date','Reason'})

        if not input then 
            lib.hideContext(false) 
            return
        end
        firstname = input[1]
        lastname  = input[2]
        case      = input[3]
        bday = input[4]
        reason = input[5]
        TriggerServerEvent('sickwarrants:createWarrant', firstname, lastname, case, bday, reason)
    elseif Config.MenuType == 'zf_context' then
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
                firstname = dialog[1].input
                lastname  = dialog[2].input
                case      = dialog[3].input
                bday = dialog[4].input
                reason = dialog[5].input
                TriggerServerEvent('sickwarrants:createWarrant', firstname, lastname, case, bday, reason)
            end
        end
    end
end

function WarrantList() --for police checking
    ESX.TriggerServerCallback('sickwarrants:getActive', function(active)
        if Config.MenuType == 'ox_libs' then
            local option = {}
            for i = 1, #active do
                local BountyAmount = active[i].bounty
                option[#option+1] = {
                    id = active[i].name,
                    title = active[i].name..', DOB: '..active[i].bday..',  Case: '..active[i].case,
                    description = "Reason: "..active[i].reason,
                    arrow = true,
                    event = 'SickWarrantsMenu:optionList',
                    args = {selection = 'warrant_choices', case = active[i].case},
                    metadata = {
                        {label = 'Bounty Amount', value = BountyAmount}
                    }
                }
            end
            lib.registerContext({
                id = 'active_warrants',
                title = 'Active Warrants',
                options = option
            })
            lib.showContext('active_warrants')
        elseif Config.MenuType == 'zf_context' then
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
                                selection = 'warrant_choices',
                                case = active[i].case,
                            }
                        }
                    })
                    counter = counter+1
                end
            exports['zf_context']:openMenu(WL)
        end
    end)
end

function CivWarrantList() 
    ESX.TriggerServerCallback('sickwarrants:getActive', function(active) 
        if Config.MenuType == 'ox_libs' then
            local option = {}
            for i = 1, #active do
                local BountyAmount = active[i].bounty
                option[#option+1] = {
                    id = active[i].name,
                    title = active[i].name..', DOB: '..active[i].bday..',  Case: '..active[i].case,
                    description = "Reason: "..active[i].reason,
                    arrow = true,
                    event = 'SickWarrantsMenu:optionList',
                    args = {selection = 'warrant_choices', case = active[i].case},
                    metadata = {
                        {label = 'Bounty Amount', value = BountyAmount}
                    }
                }
            end
            lib.registerContext({
                id = 'active_civ_warrants',
                title = 'Active Warrants',
                options = option
            })
            lib.showContext('active_civ_warrants')
        elseif Config.MenuType == 'zf_context' then
            local counter = 2                                     
            local WCL = {
                    {
                        id = 1,
                        header = 'Active Warrants',
                        txt = 'N.C.I.C',
                    },
                }
                for i=1, #active do
                    local BountyAmount = ('%s <span style="color:MediumSeaGreen;">, Bounty: $[%s]</span>'):format(active[i].name,active[i].bounty)
                    local caseNumber = ('Case Number: <span style="color:MediumSeaGreen;">[ %s ]</span>'):format(active[i].case)
                    table.insert(WCL, {
                        id = counter,
                        header = BountyAmount..',  Date: '..active[i].bday, -- this is where the server side query reads the data. if you change server side
                        txt = caseNumber.. " Reason: "..active[i].reason,                                               -- info make sure to change these to match!!
                    })
                end
            exports['zf_context']:openMenu(WCL)
        end
    end)
end

function DeleteWarrant(case)
    if Config.MenuType == 'ox_libs' then
        lib.registerContext({
            id = 'deleteMenu',
            title = 'Delete Selected Warrant?',
            options = {
                {
                    title = 'YES',
                    description = 'Delete Warrant for Case Number: '..case,
                    arrow = true,
                    serverEvent = 'sickwarrants:DeleteWarrant1',
                    args = {
                        case = case
                    }
                },
                {
                    title = 'NO',
                    description = 'Cancel Deletion?',
                    arrow = true,
                    event = 'SickWarrantsMenu:optionList',
                    args = {selection = 'cancel'}
                },
            },
        })
        lib.showContext('deleteMenu')
    elseif Config.MenuType == 'zf_context' then
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
                        selection = 'delete',
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

exports("WarrantMenu", function()
    TriggerEvent('sickwarrants:warrantMenu')
end)