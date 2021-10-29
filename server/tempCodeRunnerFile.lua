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