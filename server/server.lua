ESX = nil
local data 
local check

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('sick-warrants:getActive', function(src,cb)
    MySQL.Async.fetchAll('SELECT * FROM warrants WHERE name = @name',
    { 
        ['@name'] = name
        
    }, function(results)
        if results[1] then
            local data = {
                name    = results[1].name, 
                reason  = results[1].reason,
                bday    = results[1].bday
            }
            cb(data)
        end
    end)
end)

RegisterServerEvent('sickwarrant:createWarrant')
AddEventHandler('sickwarrant:createWarrant', function(src,name,bday,reason)
    createWarrant(name,bday,reason)
end)

function createWarrant(name,bday,reason)
    MySQL.Sync.execute('INSERT INTO warrants (name,bday,reason) VALUES (@name,@bday,@reason)',
        {
            ['@name']      = name,
            ['@bday']      = bday, 
            ['@reason']    = reason,

        },function(name,bday,reason)
    end)
end

RegisterServerEvent('sickwarrants:DeleteWarrant')
AddEventHandler('sickwarrants:DeleteWarrant', function(name)
    DeleteWarrant(name)
end)

function DeleteWarrant(name)
    local source = ESX.GetPlayerFromId(src)
    MySQL.Async.execute('DELETE * FROM warrants WHERE name = @name', 
        {
            ['@name'] = name

        },function(name)
    end)
end

ESX.RegisterServerCallback('sickwarrant:CheckBeforeDelete', function(src,cb)
    MySQL.Async.fetchAll('SELECT name FROM warrants WHERE name = @name',
        {
            ['@name'] = name

        }, function(results)
        if results[1] then
            local check = 
                {
                    name = result[1].name
                }
            cb(check)
        end
    end)
end)