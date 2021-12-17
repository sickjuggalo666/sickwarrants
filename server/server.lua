ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('sickwarrants:getActive', function(source,cb,active)
    MySQL.Async.fetchAll('SELECT * FROM warrants WHERE active = @active',
    {
        ['@active'] = 1

    }, function(results)
        if #results > 0 then
            for i = 1, #results do
                local data = {
                    firstname    = results[i].firstname,
                    lastname     = results[i].lastname,
                    case         = results[i].case,
                    reason       = results[i].reason,
                    bday         = results[i].bday
                }
                cb(data)
            end
        end
    end)
end)

RegisterServerEvent('sickwarrants:createWarrant')
AddEventHandler('sickwarrants:createWarrant', function(firstname,lastname,case,bday,reason)
    MySQL.Async.execute('INSERT INTO warrants (firstname, lastname, `case`, bday, reason, active) VALUES (@firstname, @lastname, @case, @bday, @reason, @active)',{   
        ['@firstname']      = firstname,
        ['@lastname']       = lastname,
        ['@case']           = case,
        ['@bday']           = bday,
        ['@reason']         = reason,
        ['@active']         = 1,
    })
end)

RegisterServerEvent('sickwarrants:DeleteWarrant')
AddEventHandler('sickwarrants:DeleteWarrant', function(case)
    MySQL.Async.execute('DELETE FROM warrants WHERE `case` = @case',
        {
            ['@case'] = case,
        },function()
    end)
end)

ESX.RegisterServerCallback('sickwarrants:CheckBeforeDelete', function(cb,case)
    MySQL.Async.fetchAll('SELECT * FROM warrants WHERE `case` = @case',{
        ['@case'] = case
    }, function(case)
        if case then
            cb(true)
        else
            cb(false)
        end
    end)
end)