/area/deathmatch
	name = "Deathmatch Arena"
	requires_power = FALSE
	has_gravity = TRUE
	area_flags = UNIQUE_AREA

/area/deathmatch/fullbright

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
	var/turf/location
	var/x_offset
	var/y_offset
	var/width
	var/height

/datum/deathmatch_map_loc/New(loc, x, y, w, h)
	. = ..()
	location = loc
	x_offset = x
	y_offset = y
	width = w
	height = h

/obj/effect/landmark/deathmatch_map_spawn
	name = "Deathmatch Location"
	var/datum/deathmatch_map_loc/compiled_location
	// Variables used for map size checks.
	var/x_offset = 0
	var/y_offset = 0
	var/width = 0
	var/height = 0

/obj/effect/landmark/deathmatch_map_spawn/Initialize()
	. = ..()
	compiled_location = new(get_turf(loc), x_offset, y_offset, width, height)

/obj/effect/landmark/deathmatch_player_spawn
	name = "Deathmatch Player Spawner"

/obj/effect/landmark/deathmatch_player_spawn/Initialize()
	. = ..()
	if (!GLOB.deathmatch_game)
		return INITIALIZE_HINT_QDEL
	// fuck off linter.
	var/datum/deathmatch_controller/G = GLOB.deathmatch_game
	G.spawnpoint_processing += src
