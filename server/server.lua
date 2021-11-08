ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('sickwarrants:getActive', function(cb,case)
    MySQL.Async.fetchAll('SELECT * FROM warrants WHERE case = @case',
    {
        ['@case'] = case

    }, function(results)
        if results[1] then
            local data = {
                firstname    = results[1].firstname,
                lastname     = results[1].lastname,
                case         = results[1].case,
                reason       = results[1].reason,
                bday         = results[1].bday
            }
            cb(data)
        end
    end)
end)

RegisterServerEvent('sickwarrant:createWarrant')
AddEventHandler('sickwarrant:createWarrant', function(firstname,lastname,case,bday,reason)
    CreateWarrant(firstname,lastname,case,bday,reason)
end)

function CreateWarrant(firstname,lastname,case,bday,reason)
    local query =
    {
        'INSERT INTO warrants (case,firstname,lastname,bday,reason) VALUES (@case,@firstname,@lastname,@bday,@reason)'
    }
    MySQL.Async.execute(query,
        {
            ['@case']           = case,
            ['@firstname']      = firstname,
            ['@lastname']       = lastname,
            ['@bday']           = bday,
            ['@reason']         = reason,

        },function()
    end)
end

RegisterServerEvent('sickwarrants:DeleteWarrant')
AddEventHandler('sickwarrants:DeleteWarrant', function(case)
    DeleteWarrant(case)
end)

function DeleteWarrant(case)
    MySQL.Sync.execute('DELETE FROM warrants WHERE case = @case',
        {
            ['@case'] = case,
        },function()
    end)
end

ESX.RegisterServerCallback('sickwarrant:CheckBeforeDelete', function(cb,case)
    MySQL.Async.fetchAll('SELECT * FROM warrants WHERE case = @case',
        {
            ['@case'] = case

        }, function(results)
        if results[1] then
            local check =
                {
                    case = results[1].case
                }
            cb(check)
        else
            cb(nil)
        end
    end)
end)