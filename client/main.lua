local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}
ESX = nil
local PlayerData = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
	end
	
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

Citizen.CreateThread(function()
    if Config.EnableBlip then
        player = GetPlayerPed(-1)
        coords = GetEntityCoords(player)
        for k, v in pairs(Crafting.Positions) do
            CreateBlip(vector3(Crafting.Positions[k].x, Crafting.Positions[k].y, Crafting.Positions[k].z ), "Crafting Item", 3.0, Config.Color, Config.BlipID)
        end
    end
end)

local CurrentCraft = nil
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        if ESX ~= nil and Crafting.Positions ~= nil then
            local pos = GetEntityCoords(GetPlayerPed(-1), true)
            for i=1, #Crafting.Positions, 1 do
                if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Crafting.Positions[i].x, Crafting.Positions[i].y, Crafting.Positions[i].z, true) < 1.5 then
                    DrawText3Ds(Crafting.Positions[i].x, Crafting.Positions[i].y, Crafting.Positions[i].z, 'Press [~g~E~w~] To Start Crafting')
                    if IsControlJustReleased(0, Keys["E"]) then
                        if PlayerData.job and (PlayerData.job.name == 'mafia' or PlayerData.job.name == 'cartel' or PlayerData.job.name == 'gang' or PlayerData.job.name == 'biker') then
                            BukaMenuCrafting()
                        else
                            exports['mythic_notify']:SendAlert('error', _U('no_allow'))
                        end
                    end
                end
            end
        end
    end
end)

function BukaMenuCrafting()
    local elements = {}
    for item, v in pairs(Crafting.Items) do
        local elementlabel = v.label .. " "
        local somecount = 1
        for k, need in pairs(v.needs) do
            if somecount == 1 then
                somecount = somecount + 1
                elementlabel = elementlabel
            else
                elementlabel = elementlabel
            end
        end
        table.insert(elements, {value = item, label = elementlabel})
    end
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'crafting_actions', {
		title    = _U('crafting_item'),
		align    = 'bottom-right',
		elements = elements
    }, function(data, menu)
        menu.close()
        CurrentCraft = data.current.value
        ESX.TriggerServerCallback('fox_simplecrafting:CekItem', function(result)
            if result then
                TriggerEvent("mythic_progbar:client:progress", {
                    name = "fox_simplecrafting",
                    duration = 35000,
                    label = 'Crafting Item',
                    useWhileDead = true,
                    canCancel = false,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    },
                    animation = {
                        animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                        anim = "machinic_loop_mechandplayer",
                        flags = 49,
                    },
                }, function(status)
                    if not status then
                        -- Do Something If Event Wasn't Cancelled
                    end
                end)
                Citizen.Wait(35000)
                TriggerServerEvent("fox_simplecrafting:CraftingItem", CurrentCraft)
            else
                exports['mythic_notify']:SendAlert('error', _U('no_enough'))
            end
        end, CurrentCraft)

    end, function(data, menu)
        menu.close()
    end)
end

RegisterNUICallback('CraftingItem', function()
    SetNuiFocus(false, false)
    ClearPedTasks(GetPlayerPed(-1))
    FreezeEntityPosition(GetPlayerPed(-1),false)
    TriggerServerEvent("fox_simplecrafting:CraftingItem", CurrentCraft)
end)

function CreateBlip(coords, text, radius, color, sprite)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, 0.7)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
end

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextDropShadow(1)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
	DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end