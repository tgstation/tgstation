/obj/structure/overmap/dynamic
	name = "weak energy signature"
	desc = "A very weak energy signal. It may not still be here if you leave it."
	icon_state = "strange_event"
	///The active turf reservation, if there is one
	var/datum/map_zone/mapzone
	///The preset ruin template to load, if/when it is loaded.
	var/datum/map_template/template
	///The docking port in the reserve
	var/obj/docking_port/stationary/reserve_dock
	///The docking port in the reserve
	var/obj/docking_port/stationary/reserve_dock_secondary
	///If the level should be preserved. Useful for if you want to build an autismfort or something.
	var/preserve_level = FALSE
	///What kind of planet the level is, if it's a planet at all.
	var/datum/overmap/planet/planet
	///Keep track of whether or not the docks have been reserved by a ship. This is required to prevent issues where two ships will attempt to dock in the same place due to unfortunate timing
	var/first_dock_taken = FALSE
	var/second_dock_taken = FALSE

/obj/structure/overmap/dynamic/attack_ghost(mob/user)
	if(reserve_dock)
		user.forceMove(get_turf(reserve_dock))
		return TRUE
	else
		return

/obj/structure/overmap/planet/Initialize(mapload)
	. = ..()
	if(planet)
		var/datum/overmap/planet/planet_info = new planet
		name = planet_info.name
		desc = planet_info.desc
		icon_state = planet_info.icon_state
		color = planet_info.color
		qdel(planet_info)

/obj/structure/overmap/planet/lava
	planet = /datum/overmap/planet/lava

/obj/structure/overmap/planet/ice
	planet = /datum/overmap/planet/ice

/obj/structure/overmap/planet/beach
	planet = /datum/overmap/planet/beach

/obj/structure/overmap/planet/jungle
	planet = /datum/overmap/planet/jungle

/obj/structure/overmap/planet/reebe
	planet = /datum/overmap/planet/reebe

/obj/structure/overmap/planet/asteroid
	planet = /datum/overmap/planet/asteroid

/obj/structure/overmap/planet/energy_signal
	planet = /datum/overmap/planet/space

/obj/structure/overmap/planet/wasteland
	planet = /datum/overmap/planet/wasteland

/obj/structure/overmap/planet/empty
	planet = /datum/overmap/planet/empty

/obj/structure/overmap/planet/empty/unload_level()
	if(preserve_level)
		return

	// Duplicate code grrr
	if(length(mapzone.get_mind_mobs()))
		return //Dont fuck over stranded people? tbh this shouldn't be called on this condition, instead of bandaiding it inside

	remove_mapzone()
	qdel(src)


/area/overmap_encounter
	name = "\improper Overmap Encounter"
	icon_state = "away"
	area_flags = HIDDEN_AREA | UNIQUE_AREA | CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED | NOTELEPORT
	flags_1 = CAN_BE_DIRTY_1
	always_unpowered = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	requires_power = TRUE
	static_lighting = TRUE
	luminosity = 0
	sound_environment = SOUND_ENVIRONMENT_STONEROOM
	ambientsounds = RUINS
	outdoors = TRUE

/area/overmap_encounter/planetoid
	name = "\improper Unknown Planetoid"
	sound_environment = SOUND_ENVIRONMENT_MOUNTAINS
	has_gravity = STANDARD_GRAVITY
	always_unpowered = TRUE

/area/overmap_encounter/planetoid/cave
	name = "\improper Mysterious Cave"
	sound_environment = SOUND_ENVIRONMENT_CAVE
	ambientsounds = SPOOKY
	outdoors = FALSE

/area/overmap_encounter/planetoid/lava
	name = "\improper Volcanic Planetoid"
	ambientsounds = MINING

/area/overmap_encounter/planetoid/ice
	name = "\improper Frozen Planetoid"
	sound_environment = SOUND_ENVIRONMENT_CAVE
	ambientsounds = SPOOKY

/area/overmap_encounter/planetoid/beach
	name = "\improper Beach Planetoid"
	sound_environment = SOUND_ENVIRONMENT_FOREST
	ambientsounds = BEACH

/area/overmap_encounter/planetoid/jungle
	name = "\improper Jungle Planetoid"
	sound_environment = SOUND_ENVIRONMENT_FOREST
	ambientsounds = AWAY_MISSION

/area/overmap_encounter/planetoid/dynamic
	name = "\improper Dynamic Planetoid"
	sound_environment = SOUND_ENVIRONMENT_FOREST
	ambientsounds = AWAY_MISSION

/area/overmap_encounter/planetoid/wasteland
	name = "\improper Apocalyptic Planetoid"
	sound_environment = SOUND_ENVIRONMENT_HANGAR
	ambientsounds = MINING

/area/overmap_encounter/planetoid/reebe
	name = "\improper Yellow Space"
	sound_environment = SOUND_ENVIRONMENT_MOUNTAINS
	ambientsounds = REEBE
