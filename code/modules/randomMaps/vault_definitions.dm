/datum/vault
	var/list/exclusive_to_maps = list() //Only spawn on these maps (accepts nameShort and nameLong, for more info see maps/_map.dm). No effect if empty
	var/list/map_blacklist = list() //Don't spawn on these maps

	var/map_directory = "maps/randomVaults/"
	var/map_name = "" //Don't include the preffix or "maps/randomVaults/". If the vault is maps/randomVaults/hell.dmm, this should be "hell"

	var/only_spawn_once = 1 //If 0, this vault can spawn multiple times on a single map

/datum/vault/proc/initialize(list/objects)
	for(var/turf/new_turf in objects)
		new_turf.flags |= NO_MINIMAP //Makes the spawned turfs invisible on minimaps

//How to create a new vault:
//1) create a map in maps/randomVaults/
//2) create a new subtype of /datum/vault/ (look below for an example) and set its map_name to your map's filename (don't include the "dmm" part)
//3) if you're an advanced user, feel free to play around with other variables

/datum/vault/icetruck_crash
	map_name = "icetruck_crash"

/datum/vault/asteroid_temple
	map_name = "asteroid_temple"

/datum/vault/tommyboyasteroid
	map_name = "tommyboyasteroid"

/datum/vault/hivebot_factory
	map_name = "hivebot_factory"

/datum/vault/clown_base
	map_name = "clown_base"

/datum/vault/rust
	map_name = "rust"

/datum/vault/dance_revolution
	map_name = "dance_revolution"

/datum/vault/spacegym
	map_name = "spacegym"
	
/datum/vault/oldarmory
	map_name = "oldarmory"

/datum/vault/spacepond
	map_name = "spacepond"
