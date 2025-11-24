ESX  = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

players = {}
local scoreboard = {}
local killsData = {}
local killsFile = 'kills.json'

local function loadKillData()
    local rawFile = LoadResourceFile(GetCurrentResourceName(), killsFile)

    if rawFile then
        local decoded = json.decode(rawFile)

        if type(decoded) == 'table' then
            killsData = decoded
        end
    end
end

local function saveKillData()
    SaveResourceFile(GetCurrentResourceName(), killsFile, json.encode(killsData), -1)
end

loadKillData()

local function getIdentifier(xPlayer)
    if not xPlayer then
        return nil
    end

    if xPlayer.identifier then
        return xPlayer.identifier
    end

    if xPlayer.getIdentifier then
        return xPlayer.getIdentifier()
    end

    return nil
end

local function ensureScoreboardEntry(source, xPlayer)
    if scoreboard[source] then
        return scoreboard[source]
    end

    local player = xPlayer or ESX.GetPlayerFromId(source)
    local identifier = getIdentifier(player)
    local savedStats = (identifier and killsData[identifier]) or { zombies = 0, players = 0 }

    scoreboard[source] = {
        name = player and player.getName() or ('ID ' .. tostring(source)),
        zombies = savedStats.zombies or 0,
        players = savedStats.players or 0,
        identifier = identifier
    }

    return scoreboard[source]
end

local function updateSavedKills(entry)
    if not entry or not entry.identifier then
        return
    end

    killsData[entry.identifier] = {
        zombies = entry.zombies or 0,
        players = entry.players or 0
    }

    saveKillData()
end

local function sendScoreboard(target, openMenu)
    TriggerClientEvent('esx_zombiesystem:updateScoreboard', target, scoreboard, openMenu)
end

RegisterServerEvent("esx_zombiesystem:newplayer")
AddEventHandler("esx_zombiesystem:newplayer", function(id)
    local xPlayer = ESX.GetPlayerFromId(source)

    players[source] = id
    local entry = ensureScoreboardEntry(source, xPlayer)
    entry.name = xPlayer and xPlayer.getName() or ('ID ' .. tostring(source))

    TriggerClientEvent("esx_zombiesystem:playerupdate", -1, players)
    sendScoreboard(-1, false)
end)

AddEventHandler("playerDropped", function(reason)
    players[source] = nil
    scoreboard[source] = nil
    TriggerClientEvent("esx_zombiesystem:clear", source)
    TriggerClientEvent("esx_zombiesystem:playerupdate", -1, players)
    sendScoreboard(-1, false)
end)

AddEventHandler("onResourceStop", function()
         TriggerClientEvent("esx_zombiesystem:clear", -1)
end)

RegisterNetEvent('esx_zombiesystem:registerKill')
AddEventHandler('esx_zombiesystem:registerKill', function(killType)
    local entry = ensureScoreboardEntry(source)

    if killType == 'zombie' then
        entry.zombies = (entry.zombies or 0) + 1
    elseif killType == 'player' then
        entry.players = (entry.players or 0) + 1
    end

    updateSavedKills(entry)
    sendScoreboard(-1, false)
end)

RegisterNetEvent('esx_zombiesystem:getScoreboard')
AddEventHandler('esx_zombiesystem:getScoreboard', function()
    sendScoreboard(source, true)
end)

RegisterServerEvent('esx_zombiesystem:moneyloot')
AddEventHandler('esx_zombiesystem:moneyloot', function()
    local xPlayer = ESX.GetPlayerFromId(source)
	local random = math.random(1, 20)
    xPlayer.addMoney(random)
    TriggerClientEvent("esx:showNotification", xPlayer.source, ('You found ~g~$' .. random .. ' dolars'))
end)

RegisterServerEvent('esx_zombiesystem:itemloot')
AddEventHandler('esx_zombiesystem:itemloot', function(item, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    local quantity = tonumber(count) or 1

    if quantity < 1 then
        quantity = 1
    end

    if xPlayer.canCarryItem(item, quantity) then
        xPlayer.addInventoryItem(item, quantity)
        TriggerClientEvent("esx:showNotification", xPlayer.source, ('You found ~y~' .. quantity .. 'x ~b~' .. item))
    else
        xPlayer.showNotification('You cannot pickup that because your inventory is full!')
    end
end)

entitys = {}

RegisterServerEvent("RegisterNewZombie")
AddEventHandler("RegisterNewZombie", function(entity)
	TriggerClientEvent("ZombieSync", -1, entity)
	table.insert(entitys, entity)
end)
