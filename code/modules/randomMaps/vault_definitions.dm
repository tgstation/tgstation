var/list/existing_vaults = list()

/datum/map_element/vault
	type_abbreviation = "V"

	var/list/exclusive_to_maps = list() //Only spawn on these maps (accepts nameShort and nameLong, for more info see maps/_map.dm). No effect if empty
	var/list/map_blacklist = list() //Don't spawn on these maps

	var/only_spawn_once = 1 //If 0, this vault can spawn multiple times on a single map

	var/base_turf_type = /turf/space //The "default" turf type that surrounds this vault. If it differs from the z-level's base turf type (for example if this vault is loaded on a snow map), all turfs of this type will be replaced with turfs of the z-level's base turf type

/datum/map_element/vault/initialize(list/objects)
	..(objects)
	existing_vaults.Add(src)

	var/zlevel_base_turf_type = get_base_turf(location.z)
	if(!zlevel_base_turf_type) zlevel_base_turf_type = /turf/space

	for(var/turf/new_turf in objects)
		if(new_turf.type == base_turf_type) //New turf is vault's base turf
			if(new_turf.type != zlevel_base_turf_type) //And vault's base turf differs from zlevel's base turf
				new_turf.ChangeTurf(zlevel_base_turf_type)

		new_turf.flags |= NO_MINIMAP //Makes the spawned turfs invisible on minimaps

//How to create a new vault:
//1) create a map in maps/randomVaults/
//2) create a new subtype of /datum/map_element/vault/ (look below for an example) and set its file_path to your map's file path (including the file extension, which is most likely ".dmm")
//3) if you're an advanced user, feel free to play around with other variables

/datum/map_element/vault/icetruck_crash
	file_path = "maps/randomvaults/icetruck_crash.dmm"

/datum/map_element/vault/asteroid_temple
	file_path = "maps/randomvaults/asteroid_temple.dmm"

/datum/map_element/vault/tommyboyasteroid
	file_path = "maps/randomvaults/tommyboyasteroid.dmm"

/datum/map_element/vault/hivebot_factory
	file_path = "maps/randomvaults/hivebot_factory.dmm"

/datum/map_element/vault/clown_base
	file_path = "maps/randomvaults/clown_base.dmm"

/datum/map_element/vault/rust
	file_path = "maps/randomvaults/rust.dmm"

/datum/map_element/vault/dance_revolution
	file_path = "maps/randomvaults/dance_revolution.dmm"

/datum/map_element/vault/spacegym
	file_path = "maps/randomvaults/spacegym.dmm"

/datum/map_element/vault/oldarmory
	file_path = "maps/randomvaults/oldarmory.dmm"

/datum/map_element/vault/spacepond
	file_path = "maps/randomvaults/spacepond.dmm"

/datum/map_element/vault/iou_vault
	file_path = "maps/randomvaults/iou_fort.dmm"

/datum/map_element/vault/biodome
	file_path = "maps/randomvaults/biodome.dmm"

/datum/map_element/vault/iou_vault
	file_path = "maps/randomvaults/iou_fort.dmm"

/datum/map_element/vault/asteroids
	file_path = "maps/randomvaults/asteroids.dmm"

/datum/map_element/vault/listening
	file_path = "maps/randomvaults/listening.dmm"

/datum/map_element/vault/hivebot_crash
	file_path = "maps/randomvaults/hivebot_crash.dmm"

/datum/map_element/vault/brokeufo
	file_path = "maps/randomvaults/brokeufo.dmm"
