ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

ESX.RegisterServerCallback('sick-warrants:getActive', function(source,cb,warrant)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer ~= nil then
        MySQL.Async.fetchAll("SELECT * FROM `users` WHERE identifer = @identifer AND warrant = @warrant", { 
            [@identifer] = xPlayer.identifer, 
            [@warrant] = 1 
        }, function(result)
            if result[1] then
                cb(result[1].warrant)
            else
                cb(nil)
            end
        end)
    end
end)