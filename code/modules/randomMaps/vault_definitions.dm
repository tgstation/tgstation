var/list/existing_vaults = list()

/datum/vault
	var/list/exclusive_to_maps = list() //Only spawn on these maps (accepts nameShort and nameLong, for more info see maps/_map.dm). No effect if empty
	var/list/map_blacklist = list() //Don't spawn on these maps

	var/map_directory = "maps/randomVaults/"
	var/map_name = "" //Don't include the suffix or "maps/randomVaults/". If the vault is maps/randomVaults/hell.dmm, this should be "hell"

	var/only_spawn_once = 1 //If 0, this vault can spawn multiple times on a single map

	var/turf/location //The first turf from this vault
	var/base_turf_type = /turf/space //The "default" turf type that surrounds this vault. If it differs from the z-level's base turf type (for example if this vault is loaded on a snow map), all turfs of this type will be replaced with turfs of the z-level's base turf type

/datum/vault/proc/initialize(list/objects)
	existing_vaults.Add(src)

	location = locate(/turf) in objects
	if(!location) return

	var/zlevel_base_turf_type = get_base_turf(location.z)
	if(!zlevel_base_turf_type) zlevel_base_turf_type = /turf/space

	for(var/turf/new_turf in objects)
		if(new_turf.type == base_turf_type) //New turf is vault's base turf
			if(new_turf.type != zlevel_base_turf_type) //And vault's base turf differs from zlevel's base turf
				new_turf.ChangeTurf(zlevel_base_turf_type)

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

/datum/vault/iou_vault
	map_name = "iou_fort"

/datum/vault/biodome
	map_name = "biodome"
