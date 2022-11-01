local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('k-cartransfer:transferinput', function(name, plate)
    local dialog = exports['qb-input']:ShowInput({
        header = "".. name .." | ".. plate .."",
        submitText = "submit",
        inputs = {
            {
                text = "Amount",
                name = "Amount",
                type = "text",
                isRequired = true
            },
            {
                text = "Buyer",
                name = "Buyer",
                type = "text",
                isRequired = true
            },
            {
                text = "Witness",
                name = "Witness",
                type = "text",
                isRequired = true
            }
        }
    })
    if dialog['Amount'] ~= nil and dialog['Buyer'] ~= nil and dialog['Witness'] ~= nil then
        price = (dialog['Amount'])
        buyer = (dialog['Buyer'])
        witness = (dialog['Witness'])
      --  if tonumber(witness) ~= tonumber(buyer) and tonumber(witness) ~= tonumber(seller) then
            TriggerServerEvent('k-cartransfer:sendbuyinfo', price, buyer, witness, name, plate)
       --else
         --   QBCore.Functions.Notify('You must set a valid Witness!', 'error', 5000)
       -- end
    else
        QBCore.Functions.Notify('You must set a valid amount!', 'error', 5000)
    end
end)


RegisterNetEvent('k-cartransfer:buyermenu', function(seller, buyer, price, witness, name, plate, sellply, buyply, Player)
    
    --local dist1 = #(GetEntityCoords(sellply) - GetEntityCoords(buyply))
    --local dist2 = #(GetEntityCoords(sellply) - GetEntityCoords(Player))
    --if dist1 < 10 and dist2 < 10 then
        local catoptions = {
        {
            header = "| ".. name .." | ".. plate .. "|",
            txt = "Price: $".. price,
            isMenuHeader = true
        }, {
            header = "Accept & Sign",
            txt = "Seller Signed",
            params = {
                event = "k-cartransfer:buyeraccept",
                args = {
                    seller = seller,
                    buyer = buyer,
                    price = price,
                    witness = witness,
                    name = name,
                    plate = plate
                    }
                }

        }, {
            header = "Decline",
            params = {
                event = "k-cartransfer:decline",
                args = {
                    seller = seller,
                    buyer = buyer,
                    witness = witness
                    }
                }

        }      
    }  
    exports['qb-menu']:openMenu(catoptions) 
    --else
    --    QBCore.Functions.Notify('Must be closer to seller', 'error', 5000)
    --end
end)

RegisterNetEvent('k-cartransfer:buyeraccept', function(data)
    local seller = data.seller
    local buyer = data.buyer
    local price = data.price
    local witness = data.witness
    local name = data.name
    local plate = data.plate
    QBCore.Functions.TriggerCallback('k-cartransfer:checkcash', function(cb)
        if cb then
            TriggerServerEvent('k-cartransfer:sendwitnessinfo', seller, buyer, witness, price, name, plate)
        else
            QBCore.Functions.Notify('You do not have enough cash.', 'error', 5000)
            TriggerServerEvent('k-cartransfer:canceltransaction', seller, buyer, witness)
        end
    end, price)
end)

RegisterNetEvent('k-cartransfer:witnessmenu', function(seller, buyer, witness, price, name, plate)
    local catoptions = {
        {
            header = "| ".. name .." | ".. plate .. "|",
            txt = "Price: $".. price,
            isMenuHeader = true
        }, {
            header = "Accept & Sign",
            txt = "Seller & Buyer Signed",
            params = {
                event = "k-cartransfer:witnessaccept",
                args = {
                    seller = seller,
                    buyer = buyer,
                    price = price,
                    witness = witness,
                    name = name,
                    plate = plate
                    }
                }

        }, {
            header = "Decline",
            params = {
                event = "k-cartransfer:decline",
                args = {
                    seller = seller,
                    buyer = buyer,
                    witness = witness
                    }
                }

        }      
    }  
    exports['qb-menu']:openMenu(catoptions) 
end)

RegisterNetEvent('k-cartransfer:decline', function(data)
    local seller = data.seller
    local buyer = data.buyer
    local witness = data.witness
    TriggerServerEvent('k-cartransfer:canceltransaction', seller, buyer, witness)
end)

RegisterNetEvent('k-cartransfer:witnessaccept', function(data)
    local seller = data.seller
    local buyer = data.buyer
    local price = data.price
    local witness = data.witness
    local name = data.name
    local plate = data.plate
    --print(buyer)
    QBCore.Functions.TriggerCallback('k-cartransfer:transfercash', function(cb)
        if cb then
            TriggerServerEvent('k-cartransfer:transfertitle', seller, buyer, witness, price, name, plate)
        end
    end, price, seller, buyer)
end)

RegisterNetEvent('k-cartransfer:givekeys', function(plate)
    TriggerEvent("vehiclekeys:client:SetOwner", plate)
end)