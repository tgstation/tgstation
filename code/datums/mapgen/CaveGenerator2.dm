/datum/map_generator/cave_generator2
	///Weighted list of the types that spawns if the turf is open
	var/weighted_open_turf_types = list(/turf/open/misc/asteroid/basalt/lava_land_surface = 1)
	///Expanded list of the types that spawns if the turf is open
	var/open_turf_types
	///Weighted list of the types that spawns if the turf is closed
	var/weighted_closed_turf_types = list(/turf/closed/mineral/random/volcanic = 1)
	///Expanded list of the types that spawns if the turf is closed
	var/closed_turf_types


	var/temp_prefabs
	/// Minimum dimension of a BSP leaf in the generator. Raising this creates larger pockets but can end up making for big corridors
	var/min_bsp_size = 35
	/// Maximum aspect ratio for BSP splits for lavaland generator
	var/max_ratio = 1.5
	/// Room edge padding within BSP leaf for lavaland generator
	var/padding = 1
	/// How much of each BSP leaf is considered untouchable by the cellular automata. Raising this generally means bigger pockets
	var/room_fill_percent = 30
	/// Width of corridors between rooms for lavaland generator. Raising this just means corridors are AT LEAST this wide. but cellular automata can make them bigger
	var/corridor_width = 1
	/// Chance to add extra MST edges for loops for lavaland generator. This basically results in more corridors / mazier generation
	var/loop_percent = 5
	/// Initial random floor density for lavaland generator
	var/noise_percent = 50
	/// Cellular Automata smoothing iterations for lavaland generator
	var/ca_steps = 8
	/// Neighbors to create floor (>=) for lavaland generator
	var/birth_limit = 6
	/// Neighbors to survive as floor (>=) for lavaland generator
	var/survival_limit = 4

	///Unique ID for this spawner
	var/string_gen

/datum/map_generator/cave_generator2/New()
	. = ..()
	open_turf_types = expand_weights(weighted_open_turf_types)
	closed_turf_types = expand_weights(weighted_closed_turf_types)

/datum/map_generator/cave_generator2/generate_terrain(list/turfs, area/generate_in)
	. = ..()
	if(!(generate_in.area_flags_mapping & CAVES_ALLOWED))
		return


	var/start_time = REALTIMEOFDAY

	var/list/active_ruins_list = list()

	for(var/turf/center_turf in SSmapping.active_ruins)
		var/datum/map_template/ruin/active_ruin = SSmapping.active_ruins[center_turf]
		if(center_turf.z != generate_in.z)
			continue
		active_ruins_list += list(list(
			"cx" = center_turf.x,
			"cy" = center_turf.y,
			"w" = active_ruin.width + active_ruin.terrain_padding * 2,
			"h" = active_ruin.height + active_ruin.terrain_padding * 2,
			"isEnclosed" = active_ruin.enclosed_for_terrain,
		))


	var/active_ruin_string = json_encode(active_ruins_list)

	temp_prefabs = active_ruin_string

	string_gen = rustg_lavaland_generator_generate("[world.maxx]", "[world.maxy]",active_ruin_string, "[min_bsp_size]","[max_ratio]", "[padding]", "[room_fill_percent]", "[corridor_width]","[loop_percent]", "[noise_percent]", "[ca_steps]", "[birth_limit]", "[survival_limit]")

	for(var/turf/gen_turf as anything in turfs) //Go through all the turfs and generate them
		var/closed = string_gen[world.maxx * (gen_turf.y - 1) + gen_turf.x] != "1"
		var/turf/new_turf = pick(closed ? closed_turf_types : open_turf_types)

		// The assumption is this will be faster then changeturf, and changeturf isn't required since by this point
		// The old tile hasn't got the chance to init yet
		new_turf = new new_turf(gen_turf)

		if(gen_turf.turf_flags & NO_RUINS)
			new_turf.turf_flags |= NO_RUINS

	var/message = "new terrain generation finished in [(REALTIMEOFDAY - start_time)/10]s!"
	to_chat(world, span_boldannounce("[message]"), MESSAGE_TYPE_DEBUG)
	log_world(message)
