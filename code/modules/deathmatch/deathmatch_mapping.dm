GLOBAL_LIST_EMPTY(deathmatch_points)

/area/deathmatch
	name = "Deathmatch Arena"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | UNIQUE_AREA

/area/deathmatch/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/obj/effect/landmark/deathmatch_map_spawner
	name = "Deathmatch Map Spawner"
	var/list/map_bounds

/obj/effect/landmark/deathmatch_map_spawner/Initialize(mapload)
	. = ..()
	GLOB.deathmatch_points += src

/obj/effect/landmark/deathmatch_map_spawner/Destroy()
	if(map_bounds)
		for(var/turf/to_delete in block(
			locate(
				map_bounds[MAP_MINX],
				map_bounds[MAP_MINY],
				map_bounds[MAP_MINZ],
			),
			locate(
				map_bounds[MAP_MAXX],
				map_bounds[MAP_MAXY],
				map_bounds[MAP_MAXZ],
			)
		))
			to_delete.empty()
			to_delete.baseturfs = /turf/baseturf_bottom //if you run this outside CC z-level i will kick you in the nuts
	map_bounds = null
	GLOB.deathmatch_points -= src
	return ..()

/obj/effect/landmark/deathmatch_map_spawner/proc/load_map(user, datum/map_template/current_map)
	. = FALSE
	if (map_bounds)
		return

	var/turf/spawn_area = get_turf(src)

	if(!spawn_area)
		CRASH("No spawn area detected for DM!")
	else if(!current_map)
		CRASH("No map prepared")
	map_bounds = current_map.load(spawn_area, TRUE)
	if(!map_bounds)
		CRASH("Loading DM map failed!")
	return TRUE

/obj/effect/landmark/deathmatch_player_spawn
	name = "Deathmatch Player Spawner"

/obj/effect/landmark/deathmatch_player_spawn/Initialize(mapload)
	. = ..()
	if (!GLOB.deathmatch_game)
		return INITIALIZE_HINT_QDEL
	var/datum/deathmatch_controller/deathmatch = GLOB.deathmatch_game
	deathmatch.spawnpoint_processing += src

/obj/effect/landmark/deathmatch_player_spawn/Destroy()
	. = ..()
	if(isnull(GLOB.deathmatch_game))
		return
	var/datum/deathmatch_controller/deathmatch = GLOB.deathmatch_game
	deathmatch.spawnpoint_processing -= src
