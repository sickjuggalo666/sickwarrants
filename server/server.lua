ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

ESX.RegisterServerCallback('sickwarrants:getActive', function(source,cb,active)
        MySQL.Async.fetchAll('SELECT * FROM warrants WHERE active = @active',
        {
            ['@active'] = 1,
        }, function(results)
            local active = {}
                for i=1, #results do
                    table.insert(active,{
                        name    = string.format(results[i].firstname..' '..results[i].lastname),
                        case    = results[i].case,
                        reason  = results[i].reason,
                        bday    = results[i].bday,
                        bounty  = results[i].bounty
                    })
                end
            cb(active)
       end)
end)

RegisterServerEvent('sickwarrants:createWarrant')
AddEventHandler('sickwarrants:createWarrant', function(firstname,lastname,case,bday,reason)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.Async.execute('INSERT INTO warrants (firstname, lastname, `case`, bday, reason, active) VALUES (@firstname, @lastname, @case, @bday, @reason, @active)',
    {
        ['@firstname']  = firstname,
        ['@lastname']   = lastname,
        ['@case']       = case,
        ['@bday']       = bday,
        ['@reason']     = reason,
        ['@active']     = 1
    },function(result)
      if result then
        Notify(1, src, "Warrant has been Set for Case: "..case)
      else
        Notify(3, src, "Warrant wasn\'t able to be set Please try again!")
      end
    end)
end)

RegisterServerEvent('sickwarrants:setBounty')
AddEventHandler('sickwarrants:setBounty', function(case,amount)
    print("serverbounty",amount,case)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.Async.execute('UPDATE warrants SET bounty =@bounty WHERE `case` =@case',
    {
        ['@case']       = case,
        ['@bounty']       = tonumber(amount),
    },function(result)
      if result then
        Notify(1, src, "Bounty has been Set for Case: "..case.. "Amount $"..amount)
      else
        Notify(3, src, "Bounty wasn\'t able to be set Please try again!")
      end
    end)
end)

RegisterServerEvent('sickwarrants:DeleteWarrant')  -- Used to Delete when a Case # is entered!
AddEventHandler('sickwarrants:DeleteWarrant', function(case)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.Async.execute('DELETE FROM warrants WHERE `case` = @case',
    {
        ['@case'] = case
    },function(result)
       if result then
         Notify(1, src, "Warrant was deleted Successfully!")
       else
         Notify(3, src, "Warrant wasn\'t Deleted please try again!")
       end
    end)
end)

RegisterServerEvent('sickwarrants:DeleteWarrant1')  -- only cause the menu sends different data then the dialog menu 
AddEventHandler('sickwarrants:DeleteWarrant1', function(data)  -- don't need this if you take out the delete through menus
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.Async.execute('DELETE FROM warrants WHERE `case` = @case',
    {
        ['@case'] = data.case
    },function(result)
       if result then
         Notify(1, src, "Warrant was deleted Successfully!")
       else
         Notify(3, src, "Warrant wasn\'t Deleted please try again!")
       end
    end)
end)

function Notify(source, noty_type, message)
    if source and noty_type and message then
        if Config.NotificationType.server == 'esx' then
            TriggerClientEvent('esx:showNotification', source, message)
        
        elseif Config.NotificationType.server == 'okokNotify' then
            if noty_type == 1 then
                TriggerClientEvent('okokNotify:Alert', source, 'Warrants', message, 10000, 'success')
            elseif noty_type == 2 then
                TriggerClientEvent('okokNotify:Alert', source, 'Warrants', message, 10000, 'info')
            elseif noty_type == 3 then
                TriggerClientEvent('okokNotify:Alert', source, 'Warrants', message, 10000, 'error')
            end

        elseif Config.NotificationType.server == 'mythic' then
            if noty_type == 1 then
                TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = message, style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
            elseif noty_type == 2 then
                TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = message, style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
            elseif noty_type == 3 then
                TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = message, style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
            end

        elseif Config.NotificationType.server == 'other' then
            --add your own notification.

        end
    end
end
