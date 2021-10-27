ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, Config.Keybind) and ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
            SickWarrantsMenu()
        end
    end
end)

function SickWarrantsMenu()

    ESX.UI.Menu.CloseAll()

        local SickWarrantsMenu = {
            {
                id = 1,
                header = 'N.C.I.C. Check'
            },
            {
                id = 2,
                header = 'Search Database',
                txt = 'Enter a Name To Search Warrants'
                params = {
                    event = 'SickWarrantsMenu:optionList',
                    isServer = false,
                    args = {
                        selection = 'open_search'
                    }
                }
            },
            {
                id = 3,
                header = 'List Warrants',
                txt = 'Get a List Of Warrants'
                params = {
                    event = 'SickWarrantsMenu:optionList',
                    isServer = false,
                    args = {
                        selection = 'list_warrants'
                    }
                }
            },
            {
                id = 4,
                header = 'Create Warrant',
                txt = 'Create New Warrant'
                params = {
                    event = 'SickWarrantsMenu:optionList',
                    isServer = false,
                    args = {
                        selection = 'create_warrants'
                    }
                }
            },
        }
        exports['zf_context']:openMenu(SickWarrantsMenu)
end

RegisterNetEvent('SickWarrantsMenu:optionList')
AddEventHandler('SickWarrantsMenu:optionList', function(args)
    if args.selection == 'open_search' then
        ShowSearchMenu()
    elseif args.selection == 'list_warrants' then
        ListWarrants()
    elseif args.selection == 'create_warrants' then
        ShowCreateWarrantMenu()
    end
end)

function IsPlayerJobCop()	
	if not PlayerData then return false end
	if not PlayerData.job then return false end
	for k,v in pairs(Config.Jobs) do
		if PlayerData.job.name == v then return true end
	end
	return false
end

function HasPlayerJob(jobName)	
	if not PlayerData then return false end
	if not PlayerData.job then return false end
	if PlayerData.job.name == jobName then return true end
	return false
end

RegisterNetEvent('sick-warrants:nameCallbackEvent')
AddEventHandler('sick-warrants:nameCallbackEvent', function(name)
    if name then
        ShowActiveWarrants(name)
    else 
       ShowCreateWarrantMenu(name) 
    end
end)

function ShowSearchMenu()
    local dialog = exports['zf_dialog']:DialogInput({
        header = ""
        rows = {
                id = 0,
                txt = "",
            },
        }
    })
    
    if dialog ~= nil then
        if dialog[1].input == nil then
            ESX.ShowNotification(msg)
        else
            ListWarrants()
        end
    end
end

function ListWarrants()
    ESX.TriggerServerCallback('sick-warrants:getActive', function(info)
        if data.info == 1 then
		    warrant = json.decode(info)
            local activeWarrant = {
                {
                    id = 0,
                    header = "Active Warrant"
                    txt = "Active warrant For:" ..warrant..
                },
                {
                    id = 1,
                    header = 'Active Warrants',
                    txt = "Active warrant For:" ..info..
                },
        
            }
            exports['zf_context']:openMenu(activeWarrant)
        else
            ESX.ShowNotification('No Active Warrants!')
        end
    end)
end

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
        if dialog[1].input == nil or dialog[2].input == nil then
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
            TriggerServerEvent('sick-warrants:createWarrant', name,bday,reason)
        end
    end
end