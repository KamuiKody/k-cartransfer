local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('k-cartransfer:sendbuyinfo', function(price, buyer, witness, name, plate)
    if tonumber(witness) ~= tonumber(buyer) and tonumber(witness) ~= tonumber(seller) then
        local buyply = QBCore.Functions.GetPlayer(tonumber(buyer))
        local Player = QBCore.Functions.GetPlayer(tonumber(witness))
        local sellply = QBCore.Functions.GetPlayer(source)
        TriggerClientEvent('k-cartransfer:buyermenu', buyer, source, buyer, price, witness, name, plate, sellply, buyply, Player)
   else
    TriggerClientEvent('QBCore:Notify', source, 'You must set a valid Witness!', 'error', 5000)
    end

    --[[local buyply = QBCore.Functions.GetPlayer(tonumber(buyer))
    local Player = QBCore.Functions.GetPlayer(tonumber(witness))
    local sellply = QBCore.Functions.GetPlayer(source)
    local dist1 = #(GetEntityCoords(sellply) - GetEntityCoords(buyply))
    local dist2 = #(GetEntityCoords(sellply) - GetEntityCoords(Player))
    print(dist1,dist2)
    if dist1 < 10 and dist2 < 10 then]]
        
    --[[else
        TriggerClientEvent('QBCore:Notify', source, 'Buyer and Witness must be closer.', 'error', 5000)
    end]]
end)

RegisterServerEvent('k-cartransfer:sendwitnessinfo', function(seller, buyer, witness, price, name, plate)
    TriggerClientEvent('k-cartransfer:witnessmenu', witness, seller, buyer, witness, price, name, plate)
    --print(buyer)
end)

RegisterServerEvent('k-cartransfer:canceltransaction', function(seller, buyer, witness)
    TriggerClientEvent('QBCore:Notify', seller, 'Transaction was canceled.', 'error', 5000)
    TriggerClientEvent('QBCore:Notify', buyer, 'Transaction was canceled.', 'error', 5000)
    TriggerClientEvent('QBCore:Notify', witness, 'Transaction was canceled.', 'error', 5000)
end)

RegisterServerEvent('k-cartransfer:transfertitle', function(seller, buyer, witness, price, name, plate)
    local citizenid = QBCore.Functions.GetPlayer(tonumber(buyer)).PlayerData.citizenid
    MySQL.query('UPDATE player_vehicles SET citizenid = ? WHERE plate = ?', {citizenid, plate})   
    --print(citizenid,plate)  
    TriggerClientEvent('k-cartransfer:givekeys', buyer, plate)
    TriggerClientEvent('QBCore:Notify', seller, 'Title was transfered.', 'success', 5000)
    TriggerClientEvent('QBCore:Notify', buyer, 'Title was transfered.', 'success', 5000)
    TriggerClientEvent('QBCore:Notify', witness, 'Title was transfered.', 'success', 5000)
end)

QBCore.Functions.CreateCallback('k-cartransfer:checkcash', function(source, cb, price)
    local Player = QBCore.Functions.GetPlayer(source)
    local cashBalance = Player.PlayerData.money["cash"]
    if tonumber(cashBalance) >= tonumber(price) then
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('k-cartransfer:transfercash', function(source, cb, price, seller, buyer)
    --local buyply = QBCore.Functions.GetPlayer(buyer)    
   -- print(buyer,source)
   -- print(buyply)
    local Player = QBCore.Functions.GetPlayer(tonumber(buyer))
    local sellply = QBCore.Functions.GetPlayer(seller)
    if sellply.Functions.RemoveItem(Config.Item, 1) then
        if Player.Functions.RemoveMoney('cash', price) then
            sellply.Functions.AddMoney('cash', price)
            cb(true)
        else
            cb(false)
            TriggerEvent('k-cartransfer:canceltransaction', seller, buyer, source, seller)
        end
    else
        cb(false)
        TriggerEvent('k-cartransfer:canceltransaction', seller, buyer, source, seller)
    end
end)


QBCore.Functions.CreateUseableItem(Config.Item, function(source, item) 
    local Player = QBCore.Functions.GetPlayer(source)
    local car = GetVehiclePedIsIn(GetPlayerPed(source), false)
   -- print(car)
    if car == 0 then
        TriggerClientEvent('QBCore:Notify', source, 'You Must be in a car.', 'error', 5000)
    else
        local plate = GetVehicleNumberPlateText(car)
        local info = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = ?', {plate})
        local owner = table.unpack(info).citizenid
        local citizenid = Player.PlayerData.citizenid
        local name = table.unpack(info).vehicle
        local plate = table.unpack(info).plate
        --print(plate)
        if citizenid == owner then
            TriggerClientEvent('k-cartransfer:transferinput', source, name, plate)
        else
            TriggerClientEvent('QBCore:Notify', source, 'You do not own this car.', 'error', 5000)
        end
    end
end)