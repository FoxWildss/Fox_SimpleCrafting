ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('fox_simplecrafting:CraftingItem')
AddEventHandler('fox_simplecrafting:CraftingItem', function(CraftItem)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local item = Crafting.Items[CraftItem]
    local xItem = xPlayer.getInventoryItem('clip')

    if xItem.limit ~= -1 and (xItem.count + 1) > xItem.limit then
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'No Enough Space'})
    else
        for itemname, v in pairs(item.needs) do
            xPlayer.removeInventoryItem(itemname, v.count)
        end
        xPlayer.addInventoryItem(CraftItem, 1)
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = ('Success Crafted 1x ' ..item.label..'')})
    end
end)

-- Cek apakah memiliki item
ESX.RegisterServerCallback('fox_simplecrafting:CekItem', function(source, cb, CraftItem)
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = Crafting.Items[CraftItem]
    for itemname, v in pairs(item.needs) do
        if xPlayer.getInventoryItem(itemname).count < v.count then
            cb(false)
        end
    end
    cb(true)
end)