ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

ESX.RegisterServerCallback('sickwarrants:getActiveVeh', function(source,cb,active)
    if not Config.UseMDT then
        MySQL.Async.fetchAll('SELECT * FROM warrants WHERE active = @active',
        {
            ['@active'] = 1,
        }, function(results)
            local active = {}
                for i=1, #results do
                    table.insert(active,{
                        name    = string.format(results[i].firstname..' '..results[i].lastname) 
                        case    = results[i].case,
                        reason  = results[i].reason,
                        bday    = results[i].bday
                    })
                end
            cb(active)
        end)
    else
        MySQL.Async.fetchAll('SELECT * FROM drx_mdt_warrants WHERE type = @type', -- could prolly set it to your MDT system but some edits might be needed. this is ONLY MDT i will
            {                                                                     -- support at this time! 
                ['@type'] = 'person'
            }, function(results)
            local active = {}
                for i=1, #results do
                    table.insert(active,{
                        name    = results[i].victim,  -- if you do change your MDT query make sure to leave the first variable as is so its easier to read client side
                        case    = results[i].title,   -- ex: name(stays the same) = results[i].(what your column name would be)
                        reason  = results[i].incident, -- this is cause client reads the (name) part and feeds the data. you CAN change these as long as you change them 
                        bday    = results[i].date       -- client side as well!!!
                    })
                end
            cb(active)
        end)
    end
end)

if Config.UseMDT then -- if you use Deltarix MDT and are going to use the warrants there this is for vehicles! 
    ESX.RegisterServerCallback('sickwarrants:getActiveVeh', function(source,cb,active)
        MySQL.Async.fetchAll('SELECT * FROM drx_mdt_warrants WHERE type = @type',
        {
            ['@type'] = 'veh'
        }, function(results)
            local active = {}
                for i=1, #results do
                    table.insert(active,{
                        name    = results[i].victim,
                        case    = results[i].title,
                        reason  = results[i].incident,
                        plate    = results[i].plate
                    })
                end
            cb(active)
        end)
    end)
end

RegisterServerEvent('sickwarrants:createWarrant')
AddEventHandler('sickwarrants:createWarrant', function(firstname,lastname,case,bday,reason)
    MySQL.Async.execute('INSERT INTO warrants (firstname, lastname, `case`, bday, reason, active) VALUES (@firstname, @lastname, @case, @bday, @reason, @active)',
    {
        ['@firstname']  = firstname,
        ['@lastname']   = lastname,
        ['@case']       = case,
        ['@bday']       = bday,
        ['@reason']     = reason,
        ['@active']     = 1
    })
end)

RegisterServerEvent('sickwarrants:DeleteWarrant')  -- Used to Delete when a Case # is entered!
AddEventHandler('sickwarrants:DeleteWarrant', function(case)
    MySQL.Async.execute('DELETE FROM warrants WHERE `case` = @case',
    {
        ['@case'] = case
    },function()
    end)
end)

RegisterServerEvent('sickwarrants:DeleteWarrant1')  -- only cause the menu sends different data then the dialog menu 
AddEventHandler('sickwarrants:DeleteWarrant1', function(data)  -- don't need this if you take out the delete through menus
    MySQL.Async.execute('DELETE FROM warrants WHERE `case` = @case',
        {
            ['@case'] = data.case,
        },function()
    end)
end)

if Config.CheckVersion then 
    Citizen.CreateThread(function()
        Citizen.Wait(5000)
        local resource_name = GetCurrentResourceName()
        local current_version = GetResourceMetadata(resource_name, "version")
        PerformHttpRequest('https://raw.githubusercontent.com/sickjuggalo666/sickVersions/master/'..resource_name..'.txt',function(error, result, headers)
            if not result then 
                return 
            end
            local new_version = result:sub(1, -2)
            if new_version ~= current_version then
                print('^2['..resource_name..'] - New Update Available.^0\nCurrent Version: ^5'..current_version..'^0\nNew Version: ^5'..new_version..'^0')
            elseif current_version == current_version then 
                print('^2['..resource_name..'] - All Up To Date Using Version: ^5'..current_version..'^0')
            end
        end,'GET')
        Citizen.Wait(5000)
    end)
end