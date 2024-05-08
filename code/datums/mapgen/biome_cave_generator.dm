/// The random offset applied to square coordinates, causes intermingling at biome borders
#define BIOME_RANDOM_SQUARE_DRIFT 2


/datum/map_generator/cave_generator/biome
	name = "Cave Biome Generator"

	/// The turf types to replace with a biome-related turf, as an associative list of type = TRUE. Leave empty for all open turfs (but not closed turfs) to be hijacked.
	var/list/turf/open/turfs_affected_by_biome = list()
	/// 2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(
		BIOME_LOW_HEAT = list(
			BIOME_LOW_HUMIDITY = /datum/biome/plains,
			BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mudlands,
			BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mudlands,
			BIOME_HIGH_HUMIDITY = /datum/biome/water
		),
		BIOME_LOWMEDIUM_HEAT = list(
			BIOME_LOW_HUMIDITY = /datum/biome/plains,
			BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/jungle,
			BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/jungle,
			BIOME_HIGH_HUMIDITY = /datum/biome/mudlands
		),
		BIOME_HIGHMEDIUM_HEAT = list(
			BIOME_LOW_HUMIDITY = /datum/biome/plains,
			BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/plains,
			BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/jungle/deep,
			BIOME_HIGH_HUMIDITY = /datum/biome/jungle
		),
		BIOME_HIGH_HEAT = list(
			BIOME_LOW_HUMIDITY = /datum/biome/wasteland,
			BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/plains,
			BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/jungle,
			BIOME_HIGH_HUMIDITY = /datum/biome/jungle/deep
		)
	)
	/// Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 65


/datum/map_generator/cave_generator/biome/generate_terrain(list/turfs, area/generate_in)
	if(!(generate_in.area_flags & CAVES_ALLOWED))
		return

	var/humidity_seed = rand(0, 50000)
	var/heat_seed = rand(0, 50000)

	var/start_time = REALTIMEOFDAY
	string_gen = rustg_cnoise_generate("[initial_closed_chance]", "[smoothing_iterations]", "[birth_limit]", "[death_limit]", "[world.maxx]", "[world.maxy]") //Generate the raw CA data

	var/list/open_turfs_used = list()

	for(var/turf/gen_turf as anything in turfs) //Go through all the turfs and generate them
		var/closed = string_gen[world.maxx * (gen_turf.y - 1) + gen_turf.x] != "0"
		var/turf/new_turf = pick(closed ? closed_turf_types : open_turf_types)

		var/datum/biome/selected_biome

		// Here comes the meat of the biome code.
		var/drift_x = (gen_turf.x + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
		var/drift_y = (gen_turf.y + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom

		var/humidity = text2num(rustg_noise_get_at_coordinates("[humidity_seed]", "[drift_x]", "[drift_y]"))
		var/heat = text2num(rustg_noise_get_at_coordinates("[heat_seed]", "[drift_x]", "[drift_y]"))
		var/heat_level //Type of heat zone we're in (LOW-LOWMEDIUM-HIGHMEDIUM-HIGH)
		var/humidity_level  //Type of humidity zone we're in (LOW-LOWMEDIUM-HIGHMEDIUM-HIGH)

		switch(heat)
			if(0 to 0.25)
				heat_level = BIOME_LOW_HEAT
			if(0.25 to 0.5)
				heat_level = BIOME_LOWMEDIUM_HEAT
			if(0.5 to 0.75)
				heat_level = BIOME_HIGHMEDIUM_HEAT
			if(0.75 to 1)
				heat_level = BIOME_HIGH_HEAT

		switch(humidity)
			if(0 to 0.25)
				humidity_level = BIOME_LOW_HUMIDITY
			if(0.25 to 0.5)
				humidity_level = BIOME_LOWMEDIUM_HUMIDITY
			if(0.5 to 0.75)
				humidity_level = BIOME_HIGHMEDIUM_HUMIDITY
			if(0.75 to 1)
				humidity_level = BIOME_HIGH_HUMIDITY

		selected_biome = possible_biomes[heat_level][humidity_level]
		selected_biome = SSmapping.biomes[selected_biome] //Get the instance of this biome from SSmapping

		if((!length(turfs_affected_by_biome) && !closed) || turfs_affected_by_biome[new_turf])
			new_turf = selected_biome.generate_turf_for_terrain(gen_turf)

		else
			// The assumption is this will be faster then changeturf, and changeturf isn't required since by this point
			// The old tile hasn't got the chance to init yet
			new_turf = new new_turf(gen_turf)

		if(!closed)
			open_turfs_used[new_turf.type] = TRUE

		new_turf.biome = selected_biome

		if(gen_turf.turf_flags & NO_RUINS)
			new_turf.turf_flags |= NO_RUINS

		CHECK_TICK

	open_turf_types = assoc_to_keys(open_turfs_used)

	var/message = "[name] terrain generation finished in [(REALTIMEOFDAY - start_time)/10]s!"
	to_chat(world, span_boldannounce("[message]"))
	log_world(message)


/datum/map_generator/cave_generator/biome/populate_terrain(list/turfs, area/generate_in)
	// Area var pullouts to make accessing in the loop faster
	var/flora_allowed = (generate_in.area_flags & FLORA_ALLOWED)
	var/features_allowed = (generate_in.area_flags & FLORA_ALLOWED)
	var/fauna_allowed = (generate_in.area_flags & MOB_SPAWN_ALLOWED)

	var/start_time = REALTIMEOFDAY

	// No sense in doing anything here if nothing is allowed anyway.
	if(!flora_allowed && !features_allowed && !fauna_allowed)
		var/message = "[name] terrain population finished in [(REALTIMEOFDAY - start_time)/10]s!"
		to_chat(world, span_boldannounce("[message]"))
		log_world(message)
		return

	for(var/turf/target_turf as anything in turfs)
		if(!(target_turf.type in open_turf_types)) //only put stuff on open turfs we generated, so closed walls and rivers and stuff are skipped
			continue

		target_turf.biome?.populate_turf(target_turf, flora_allowed, features_allowed, fauna_allowed)
		CHECK_TICK

	var/message = "[name] terrain population finished in [(REALTIMEOFDAY - start_time)/10]s!"
	to_chat(world, span_boldannounce("[message]"))
	log_world(message)


#undef BIOME_RANDOM_SQUARE_DRIFT
