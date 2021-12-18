ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('sickwarrants:getActive', function(source,cb,active)
    MySQL.Async.fetchAll('SELECT * FROM warrants WHERE active = @active',
    {
        ['@active'] = 1
    }, function(results)
        local active = {}
            for i=1, #results do
                table.insert(active,{
                    name    = results[i].firstname.." "..results[i].lastname,
                    case    = results[i].case,
                    reason  = results[i].reason,
                    bday    = results[i].bday
                })
            end
        cb(active)
    end)
end)

RegisterServerEvent('sickwarrants:createWarrant')
AddEventHandler('sickwarrants:createWarrant', function(firstname,lastname,case,bday,reason)
    MySQL.Async.execute('INSERT INTO warrants (firstname, lastname, `case`, bday, reason, active) VALUES (@firstname, @lastname, @case, @bday, @reason, @active)',
    {
        ['@firstname']  = firstname,
        ['@lastname']   = lastname,
        ['@case']       = case,
        ['@bday']       = bday,
        ['@reason']     = reason,
        ['@active']     = 1})
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
    print(data.case)
    MySQL.Async.execute('DELETE FROM warrants WHERE `case` = @case',
        {
            ['@case'] = data.case,
        },function()
    end)
end)