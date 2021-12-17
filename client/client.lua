ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
   end

   ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('sickwarrants:warrantMenu')
AddEventHandler('sickwarrants:warrantMenu', function()
    ESX.UI.Menu.CloseAll()

    refreshjob()

    local WarrantMenu = {
        {
            id = 0,
            header = 'N.C.I.C. Check'
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
            txt = 'Do You Have One?'
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
    
    if PlayerData.job.name == 'police' then
		exports['zf_context']:openMenu(WarrantMenu)
	else 
		exports['zf_context']:openMenu(CivWarrantMenu)
	end
end)

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
            if Config.Notifications == "esx" then
                ESX.ShowNotification(Config.InvalidInputs)
            elseif Config.Notifications == "mythic" then
                exports['mythic_notify']:DoHudText('error', Config.InvalidInputs)
            elseif Config.Notifications == "custom" then
                -- Enter custom Notifications here
            end
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

function WarrantList()
    ESX.TriggerServerCallback('sickwarrants:getActive', function(data)
        if data then
            if Config.UsePhone == true then
                local number = Config.Dispatch
                local msg = string.format('[WARRANTS]:' ..data.firstname..' '..data.lastname..': ' ..data.case..': '..data.reason)
                WarrantMessage(msg,number)
            else
                local msg = string.format('[WARRANTS]:' ..data.firstname..' '..data.lastname..': ' ..data.case..': '..data.reason)
                if Config.Notifications == "esx" then
                    ESX.ShowNotification(msg)
                elseif Config.Notifications == "mythic" then
                    exports['mythic_notify']:DoHudText('inform',msg)
                elseif Config.Notifications == "custom" then
                    -- Enter custom Notifications here
                end
            end
        else
            if Config.Notifications == "esx" then
                ESX.ShowNotification(Config.NoWarrants)
            elseif Config.Notifications == "mythic" then
                exports['mythic_notify']:DoHudText('error', Config.NoWarrants)
            elseif Config.Notifications == "custom" then
                -- Enter custom Notifications here
            end
        end
    end)
end

function CivWarrantList()
    local WarrantListing = {}
    ESX.TriggerServerCallback('sickwarrants:getActive', function(data)
        if data then
            table.insert(WarrantListing,{
                id = 0,
                header = data.firstname.." "..data.lastname..", DOB: "..data.bday,
                txt = "Reason: "..data.reason,
            })
        end
        exports['zf_context']:openMenu(WarrantListing)
    end)
end

function WarrantMessage(msg, number)
    PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Default", true)
    --TriggerServerEvent('gcPhone:sendMessage', number, msg)
    TriggerServerEvent('gksphone:NewMail', ESX.GetPlayerData().identifier, {
        sender = "N.C.I.C",
        subject = "Criminal Check",
        image = '/html/static/img/icons/mail.png',
        message = msg,
      })
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
        if Config.Notifications == "esx" then
            ESX.ShowNotification(Config.InvalidCase)
        elseif Config.Notifications == "mythic" then
            exports['mythic_notify']:DoHudText('error', Config.InvalidCase)
        elseif Config.Notifications == "custom" then
            -- Enter custom Notifications here
        end
    else
        local case = dialog[1].input
        ESX.TriggerServerCallback('sickwarrants:CheckBeforeDelete',function(case)
            if case then
                TriggerServerEvent('sickwarrants:DeleteWarrant', case)
                if Config.Notifications == "esx" then
                    ESX.ShowNotification(Config.DeletedWarrant)
                elseif Config.Notifications == "mythic" then
                    exports['mythic_notify']:DoHudText('error',Config.DeletedWarrant)
                elseif Config.Notifications == "custom" then
                    -- Enter custom Notifications here
                end
            else
                if Config.Notifications == "esx" then
                    ESX.ShowNotification(Config.NoWarrantWithName)
                elseif Config.Notifications == "mythic" then
                    exports['mythic_notify']:DoHudText('error',Config.NoWarrantWithName)
                elseif Config.Notifications == "custom" then
                    -- Enter custom Notifications here
                end
            end
        end)
    end
end

function refreshjob()
    Citizen.Wait(1)
    PlayerData = ESX.GetPlayerData()
end