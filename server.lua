ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

ESX.RegisterServerCallback('sick-warrants:getActive', function(src,cb)
    MySQL.Async.fetchAll('SELECT * FROM warrants WHERE name = @name',
    { 
        ['@name'] = name
    },function(results)
        if results[1] then
            local data = {
                name    = results[1].name, 
                reason  = results[1].reason,
                bday    = results[1].bday
            }
            cb(data)
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('sickwarrant:createWarrant')
AddEventHandler('sickwarrant:createWarrant', function(src,name,bday,reason)
    MySQL.Async.insert('INSERT INTO warrants (name,bday,reason) VALUES (@name,@bday,@reason)',
        {
            ['@name']      = name,
            ['@bday']      = bday, 
            ['@reason']    = reason,
        },function()
    end)
end)

RegisterServerEvent('sickwarrants:DeleteWarrant')
AddEventHandler('sickwarrants:DeleteWarrant', function(srcname)
    MySQL.Async.execute('DELETE * FROM warrants WHERE name = @name', 
        {
            ['@name'] = name
        },function()
    end)
end)

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