/area/deathmatch
	name = "Deathmatch Arena"
	requires_power = FALSE
	has_gravity = TRUE
	area_flags = UNIQUE_AREA | NO_ALERTS
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/deathmatch/fullbright
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/turf/open/indestructible/deathmatch
	name = "Deathmatch border"
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	blocks_air = TRUE

// This just deletes everything that enters it.
/turf/open/indestructible/deathmatch/Enter(atom/movable/mover)
	if (!QDELETED(mover))
		if (isliving(mover))
			var/mob/living/L = mover
			L.dust(TRUE, FALSE, TRUE)
		else
			qdel(mover)

/datum/deathmatch_map_loc
	var/turf/centre
	// width and height are used to check map size.
	var/width
	var/height
	var/z
	// rectangle
	var/x1
	var/y1
	var/x2
	var/y2

/obj/effect/landmark/deathmatch_map_corner
	name = "Deathmatch Map Corner"
	var/location_id = ""

/obj/effect/landmark/deathmatch_map_corner/Initialize()
	. = ..()
	if (!location_id)
		stack_trace("Deathmatch map location at [x] [y] [z] doesn't have an ID.")
		return INITIALIZE_HINT_QDEL

/obj/effect/landmark/deathmatch_player_spawn
	name = "Deathmatch Player Spawner"

/obj/effect/landmark/deathmatch_player_spawn/Initialize()
	. = ..()
	if (!GLOB.deathmatch_game)
		return INITIALIZE_HINT_QDEL
	// fuck off linter.
	var/datum/deathmatch_controller/G = GLOB.deathmatch_game
	G.spawnpoint_processing += src
