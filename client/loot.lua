ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

objects = {}
local usingOxTarget = Config.UseOxTarget and GetResourceState('ox_target') == 'started'
local GetRandomLoot

local function performObjectLoot(obj)
        if objects[obj] then
                return
        end

        SetCurrentPedWeapon(GetPlayerPed(-1), 0xA2719263, true)
        RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
        while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do
                Citizen.Wait(10)
        end

        TaskPlayAnim(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 2.0, 2.0, 4000, 30, 0, 0, 0, 0)
        Citizen.Wait(4000)
        local lootItem, lootCount = GetRandomLoot(Config.ObjectLootItems, Config.LootNothingChanceObject)

        if lootItem and lootCount then
                TriggerServerEvent('esx_zombiesystem:itemloot', lootItem, lootCount)
        else
                ESX.ShowNotification('You not found nothing')
        end

        objects[obj] = true
end

GetRandomLoot = function(lootTable, nothingChance)
        if math.random(1, 100) <= nothingChance then
                return nil
        end

        local totalWeight = 0

        for _, loot in ipairs(lootTable) do
                totalWeight = totalWeight + (loot.chance or 0)
        end

        if totalWeight <= 0 then
                return nil
        end

        local roll = math.random(1, totalWeight)

        for _, loot in ipairs(lootTable) do
                roll = roll - (loot.chance or 0)

                if roll <= 0 then
                        local minCount = loot.min or 1
                        local maxCount = loot.max or minCount

                        if maxCount < minCount then
                                maxCount = minCount
                        end

                        return loot.item, math.random(minCount, maxCount)
                end
        end
end

if Config.ObjectDropLoot then
	if usingOxTarget then
		exports.ox_target:addModel(Config.ObjectsLoot, {
			{
				name = 'zombie_object_loot',
				label = 'Search loot',
				icon = 'fa-solid fa-box-open',
				distance = 2.2,
				canInteract = function(entity)
					return not objects[entity]
				end,
				onSelect = function(data)
					performObjectLoot(data.entity)
				end
			}
		})
	else
		Citizen.CreateThread(function()
			while true do
				Wait(0)
				for k,v in pairs(Config.ObjectsLoot) do
					local player = GetPlayerPed(-1)
					local distanceobject = 2.2
					local obj = GetClosestObjectOfType(GetEntityCoords(player).x, GetEntityCoords(player).y, GetEntityCoords(player).z, distanceobject, v, false, true ,true)
					local distance = GetDistanceBetweenCoords(GetEntityCoords(player), GetEntityCoords(obj), true)
					if distance <= distanceobject then
						local ObjectCoords = GetEntityCoords(obj)
						if not objects[obj] then
							ESX.Game.Utils.DrawText3D(ObjectCoords + vector3(0.0, 0.0, 0.5), '~c~PRESS ~b~[E]~c~ TO SEARCH', 1, 4)
						end
						if IsControlJustReleased(0, 38) then
							performObjectLoot(obj)
						end
					end
				end
			end
		end)
	end
end
