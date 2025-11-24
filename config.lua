Config = {}

Config.SpawnZombie = 10
Config.MinSpawnDistance = 80
Config.MaxSpawnDistance = 100
Config.DespawnDistance = 120
Config.ZombieChaseRange = 35.0
Config.ZombieChaseSpeed = 2.0

Config.UseOxTarget = true

Config.ZombieDropLoot = true
Config.LootNothingChance = 20 -- percentage chance to find nothing after searching a zombie
Config.LootItems = {
    { item = 'bandage', min = 1, max = 2, chance = 35 },
    { item = 'medikit', min = 1, max = 1, chance = 20 },
    { item = 'water', min = 1, max = 3, chance = 25 },
    { item = 'bread', min = 1, max = 3, chance = 20 }
}



Config.ObjectDropLoot = true --false if you experience low performance of server
Config.ObjectsLoot = {
    'prop_box_ammo03a'
}

-- cooldown in seconds before a lootable object can be searched again
Config.ObjectLootCooldown = 30

Config.LootNothingChanceObject = 25 -- percentage chance to find nothing in lootable objects
Config.ObjectLootItems = {
    { item = 'bread', min = 1, max = 3, chance = 40 },
    { item = 'water', min = 1, max = 3, chance = 40 },
    { item = 'bandage', min = 1, max = 2, chance = 20 }
}



Config.NoPeds = true
Config.Blackout = true
Config.MuteAmbience = true
Config.NotHealthRecharge = true
Config.SafeZone = true
Config.SafeZoneRadioBlip = true
Config.SafeZoneCoords = {
	{ x = 4438.95, y = -4457.70, z = 4.33 , radio = 30.0}
}

Config.Debug = false
