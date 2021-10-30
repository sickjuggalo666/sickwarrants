ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(1)
    end
end)

--RegisterNetEvent('sickwarrants:warrantMenu')
--AddEventHandler('sickwarrants:warrantMenu', function()
RegisterCommand('warrant', function()
    ESX.UI.Menu.CloseAll()

    local WarrantMenu = {
        {
            id = 0,
            header = 'N.C.I .C. Check'
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

    exports['zf_context']:openMenu(WarrantMenu)
end)

RegisterNetEvent('SickWarrantsMenu:optionList')
AddEventHandler('SickWarrantsMenu:optionList', function(args)
    if args.selection == 'delete' then
        DeleteWarrant()
    elseif args.selection == 'list_warrants' then
        WarrantList()
    elseif args.selection == 'create_warrants' then
        ShowCreateWarrantMenu()
    end
end)

function ShowCreateWarrantMenu()
    local dialog = exports['zf_dialog']:DialogInput({
        header = "Create Warrant",
        rows = {
            id = 0,
            txt = "First Name",
        },
        {
            id = 1,
            txt = "Last Name"
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
            txt = "Reason"
        }
    })

    if dialog ~= nil then
        if dialog[1].input == nil or dialog[2].input == nil then
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
            TriggerServerEvent('sickwarrants:createWarrant', firtsname, lastname, case, bday, reason)
        end
    end
end

function WarrantList()
    ESX.TriggerServerCallback('sickwarrants:getActive', function(data)
        if data ~= nil then
            local number = Config.Dispatch
            local msg = string.format('[WARRANTS]:',data.name..' '..data.lastname..':' ..data.case..':'..data.reason)
            WarrantMessage(msg,number)
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

function WarrantMessage(msg, number)
    PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Default", true)
    if Config.Notifications == "esx" then
        ESX.ShowNotification(string.format('New Message From:',number))
    elseif Config.Notifications == "mythic" then
        exports['mythic_notify']:DoHudText('inform',string.format('New Message:',number))
    elseif Config.Notifications == "custom" then
        -- Enter custom Notifications here
    end
    TriggerServerEvent('gcPhone:sendMessage', number, msg)
end

function DeleteWarrant()
    local dialog = exports['zf_dialog']:DialogInput({
        header = "Delete Active Warrant?",
        rows =
        {
            id = 0,
            txt = "Enter Case #"
        }
    })

    if dialog[1].input == nil then
        if Config.Notifications == "esx" then
            ESX.ShowNotification(Config.InvalidName)
        elseif Config.Notifications == "mythic" then
            exports['mythic_notify']:DoHudText('error', Config.InvalidName)
        elseif Config.Notifications == "custom" then
            -- Enter custom Notifications here
        end
    else
        local case = dialog[1].input
        ESX.TriggerServerCallback('sickwarrant:CheckBeforeDelete',function(case)
            if case ~= nil then
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
