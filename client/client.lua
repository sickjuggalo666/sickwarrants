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

function WarrantMenu()
    ESX.UI.Menu.CloseAll()

        local WarrantMenu = {
            {
                id = 1,
                header = 'N.C.I.C. Check',
            },
            {
                id = 2,
                header = '📲 List Warrants',
                txt = 'Get a List Of Warrants',
                params = {
                    event = 'SickWarrantsMenu:optionList',
                    args = {
                        selection = 'list_warrants',
                    }
                }
            },
            {
                id = 3,
                header = '🔒 Create Warrant',
                txt = 'Create New Warrant',
                params = {
                    event = 'SickWarrantsMenu:optionList',
                    args = {
                        selection = 'create_warrants',
                    }
                }
            },
            {
                id = 4,
                header = '🔎 Delete Warrant',
                txt = 'End Active Warrant',
                params = {
                    event = 'SickWarrantsMenu:optionList',
                    args = {
                        selection = 'delete',
                    }
                }
            },
        }

        exports['zf_context']:openMenu(WarrantMenu)
end

RegisterNetEvent('SickWarrantsMenu:optionList')
AddEventHandler('SickWarrantsMenu:optionList', function(args)
    if args.selection == 'delete' then
        DeleteWarrant()
    elseif args.selection == 'list_warrants' then
        SickWarrantList()
    elseif args.selection == 'create_warrants' then
        ShowCreateWarrantMenu()
    end
end)

function ShowCreateWarrantMenu()
    local dialog = exports['zf_dialog']:DialogInput({
        header = "Create Warrant",
        rows = {
            id = 0,
            txt = "Enter Name",
        },
        {
            id = 1,
            txt = "Birth Date",
        },
        {
            id = 2,
            txt = "Reason"
        }
    })

    if dialog ~= nil then
        if dialog[1].input == nil or dialog[2].input == nil or dialog[3].input == nil then
            if Config.Notifications == "esx" then
                ESX.ShowNotification(Config.Invalid)
            elseif Config.Notifications == "mythic" then
                exports['mythic_notify']:DoHudText('error', Config.Invalid)
            elseif Config.Notifications == "custom" then
                -- Enter custom Notifications here
            end
        else        
            name   = dialog[1].input
            bday   = dialog[2].input
            reason = dialog[3].input
            TriggerServerEvent('sick-warrants:createWarrant',name,bday,reason)
        end
    end
end

function SickWarrantList()
    ESX.TriggerServerCallback('sick-warrants:getActive', function(data)
        if data ~= nil then
            local number = Config.Dispatch
                SickWarrantMessage('[ACTIVE WARRANTS]:',sting.format(data.name..':'..data.reason))
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

function SickWarrantMessage(msg, number)
    PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Default", true)
    if Config.Notifications == "esx" then
        ESX.ShowNotification('New Message:',format(number))
    elseif Config.Notifications == "mythic" then
        exports['mythic_notify']:DoHudText('inform', 'New Message:',format(number))
    elseif Config.Notifications == "custom" then
        -- Enter custom Notifications here
    end
	TriggerServerEvent('gcPhone:sendMessage', number, msg)
end


function DeleteWarrant()
    local dialog = exports['zf_dialog']:DialogInput({
        header = "Delete Active Warrant?",
        rows = {
            id = 0,
            txt = "Enter [EXACT] Name",
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
        local name = dialog[1].input
        ESX.TriggerServerCallback('sickwarrant:CheckBeforeDelete', function(name) 
            if name ~= nil then
                TriggerServerEvent('sickwarrants:DeleteWarrant', name)
                    if Config.Notifications == "esx" then
                        ESX.ShowNotification(Config.DeletedWarrant)
                    elseif Config.Notifications == "mythic" then
                        exports['mythic_notify']:DoHudText('error', Config.DeletedWarrant)
                    elseif Config.Notifications == "custom" then
                        -- Enter custom Notifications here
                end
            else
                if Config.Notifications == "esx" then
                    ESX.ShowNotification(Config.NoWarrantWithName)
                elseif Config.Notifications == "mythic" then
                    exports['mythic_notify']:DoHudText('error', Config.NoWarrantWithName)
                elseif Config.Notifications == "custom" then
                    -- Enter custom Notifications here
                end
            end
        end)
    end
end