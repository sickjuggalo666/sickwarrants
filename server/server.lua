ESX = nil


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('sickwarrants:getActive', function(cb,name)
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
AddEventHandler('sickwarrant:createWarrant', function(name,bday,reason)
    CreateWarrant(name,bday,reason)
end)

function CreateWarrant(name,bday,reason)
    MySQL.Async.execute('INSERT INTO warrants (name,bday,reason) VALUES (@name,@bday,@reason)',
        {
            ['@name']      = name,
            ['@bday']      = bday,
            ['@reason']    = reason,

        },function()
    end)
end

RegisterServerEvent('sickwarrants:DeleteWarrant')
AddEventHandler('sickwarrants:DeleteWarrant', function(name)
    DeleteWarrant(name)
end)

function DeleteWarrant(name)
    MySQL.Async.execute('DELETE * FROM warrants WHERE name = @name',
        {
            ['@name'] = name

        },function()
    end)
end

ESX.RegisterServerCallback('sickwarrant:CheckBeforeDelete', function(cb,name)
    MySQL.Async.fetchAll('SELECT name FROM warrants WHERE name = @name',
        {
            ['@name'] = name

        }, function(results)
        if results[1] then
            local check =
                {
                    name = results[1].name
                }
            cb(check)
        else
            cb(nil)
        end
    end)
end)