#define BIOME_RANDOM_SQUARE_DRIFT 2

//Mostly a copypaste of the jungle generator
/datum/map_generator/ocean_generator
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/ocean_sand,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/ocean_sand_flora,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/ocean_sand_flora,
		BIOME_HIGH_HUMIDITY = /datum/biome/ocean_sand
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/ocean_rocklight,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/ocean_sand,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/ocean_redsand,
		BIOME_HIGH_HUMIDITY = /datum/biome/ocean_sand_flora
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/ocean_rockmed,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/ocean_sand,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/ocean_redsand,
		BIOME_HIGH_HUMIDITY =/datum/biome/ocean_redsand
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/ocean_rockheavy,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/ocean_sand,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/ocean_redsand,
		BIOME_HIGH_HUMIDITY = /datum/biome/ocean_redsand
		)
	)
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 65

///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/ocean_generator/generate_terrain(list/turfs, area/generate_in)
	. = ..()
	var/height_seed = rand(0, 50000)
	var/humidity_seed = rand(0, 50000)
	var/heat_seed = rand(0, 50000)

	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t

		if(istype(gen_turf, /turf/open/openspace/ocean))
			continue

		var/drift_x = (gen_turf.x + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
		var/drift_y = (gen_turf.y + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom

		var/height = text2num(rustg_noise_get_at_coordinates("[height_seed]", "[drift_x]", "[drift_y]"))


		var/datum/biome/selected_biome
		if(height <= 0.8) //If height is less than 0.4, we generate biomes based on the heat and humidity of the area.
			var/humidity = text2num(rustg_noise_get_at_coordinates("[humidity_seed]", "[drift_x]", "[drift_y]"))
			var/heat = text2num(rustg_noise_get_at_coordinates("[heat_seed]", "[drift_x]", "[drift_y]"))
			var/heat_level //Type of heat zone we're in LOW-MEDIUM-HIGH
			var/humidity_level  //Type of humidity zone we're in LOW-MEDIUM-HIGH

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
		else //Over 0.85; It's a wall
			selected_biome = /datum/biome/ocean_wall
		selected_biome = SSmapping.biomes[selected_biome] //Get the instance of this biome from SSmapping
		selected_biome.generate_turf(gen_turf)
		CHECK_TICK

/datum/map_generator/cave_generator/trench
	name = "Trench Generator"
	closed_turf_types =  list(/turf/closed/mineral/random/ocean = 1)
	weighted_closed_turf_types = list(/turf/closed/mineral/random/ocean = 1)

	feature_spawn_list = null
	weighted_mob_spawn_list = list(
		SPAWN_MEGAFAUNA = 2,
		/obj/effect/spawner/random/lavaland_mob/goliath = 50,
		/obj/effect/spawner/random/lavaland_mob/legion = 30,
		/obj/effect/spawner/random/lavaland_mob/watcher = 40,
		/mob/living/basic/mining/bileworm = 20,
		/mob/living/basic/mining/lobstrosity/lava = 20,
		/mob/living/basic/mining/brimdemon = 20,
		/mob/living/basic/mining/goldgrub = 10,
		/obj/structure/spawner/lavaland/ocean = 2,
		/obj/structure/spawner/lavaland/ocean/goliath = 3,
		/obj/structure/spawner/lavaland/ocean/legion = 3,
		/obj/structure/spawner/lavaland/ocean/fish = 1, // a rare fish challenger approaches!
	)

	flora_spawn_list = null

	///2D list of all biomes based on heat and humidity combos.
	possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/ocean_sand/above,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/ocean_sand_flora/above,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/ocean_sand_flora/above,
		BIOME_HIGH_HUMIDITY = /datum/biome/ocean_sand/above
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/ocean_rocklight/above,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/ocean_sand/above,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/ocean_redsand/above,
		BIOME_HIGH_HUMIDITY = /datum/biome/ocean_sand_flora/above
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/ocean_rockmed/above,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/ocean_sand/above,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/ocean_redsand/above,
		BIOME_HIGH_HUMIDITY =/datum/biome/ocean_redsand/above
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/ocean_rockheavy/above,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/ocean_sand/above,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/ocean_redsand/above,
		BIOME_HIGH_HUMIDITY = /datum/biome/ocean_redsand/above
		)
	)
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	perlin_zoom = 65


/datum/map_generator/cave_generator/trench/generate_terrain(list/turfs, area/generate_in)

	var/humidity_seed = rand(0, 50000)
	var/heat_seed = rand(0, 50000)

	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t

		if(istype(gen_turf, /turf/open/openspace/ocean))
			continue

		var/drift_x = (gen_turf.x + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
		var/drift_y = (gen_turf.y + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
		var/datum/biome/selected_biome

		var/humidity = text2num(rustg_noise_get_at_coordinates("[humidity_seed]", "[drift_x]", "[drift_y]"))
		var/heat = text2num(rustg_noise_get_at_coordinates("[heat_seed]", "[drift_x]", "[drift_y]"))
		var/heat_level //Type of heat zone we're in LOW-MEDIUM-HIGH
		var/humidity_level  //Type of humidity zone we're in LOW-MEDIUM-HIGH

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
		selected_biome.generate_turf(gen_turf)
		CHECK_TICK


	string_gen = rustg_cnoise_generate("[initial_closed_chance]", "[smoothing_iterations]", "[birth_limit]", "[death_limit]", "[world.maxx]", "[world.maxy]") //Generate the raw CA data

	// Area var pullouts to make accessing in the loop faster
	var/mobs_allowed = (generate_in.area_flags & MOB_SPAWN_ALLOWED) && length(mob_spawn_list)
	var/megas_allowed = (generate_in.area_flags & MEGAFAUNA_SPAWN_ALLOWED) && length(megafauna_spawn_list)

	for(var/i in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = i

		var/closed = string_gen[world.maxx * (gen_turf.y - 1) + gen_turf.x] != "0"
		var/turf/new_turf = pick(closed ? closed_turf_types : open_turf_types)

		if(closed)
			// The assumption is this will be faster then changeturf, and changeturf isn't required since by this point
			// The old tile hasn't got the chance to init yet
			new_turf = new new_turf(gen_turf)

			if(gen_turf.turf_flags & NO_RUINS)
				new_turf.turf_flags |= NO_RUINS

		if(closed)//Open turfs have some special behavior related to spawning flora and mobs.
			CHECK_TICK
			continue

		// If we've spawned something yet
		var/spawned_something = FALSE

		///Spawning isn't done in procs to save on overhead on the 60k turfs we're going through.

		//MOB SPAWNING HERE
		if(mobs_allowed && !spawned_something && prob(mob_spawn_chance))
			var/atom/picked_mob = pick(mob_spawn_list)

			if(picked_mob == SPAWN_MEGAFAUNA)
				if(megas_allowed) //this is danger. it's boss time.
					picked_mob = pick(megafauna_spawn_list)
				else //this is not danger, don't spawn a boss, spawn something else
					picked_mob = pick(mob_spawn_no_mega_list) //What if we used 100% of the brain...and did something (slightly) less shit than a while loop?

			var/can_spawn = TRUE

			// prevents tendrils spawning in each other's collapse range
			if(ispath(picked_mob, /obj/structure/spawner/lavaland))
				for(var/obj/structure/spawner/lavaland/spawn_blocker in range(2, gen_turf))
					can_spawn = FALSE
					break
			// if the random is not a tendril (hopefully meaning it is a mob), avoid spawning if there's another one within 12 tiles
			else
				var/list/things_in_range = range(12, gen_turf)
				for(var/mob/living/mob_blocker in things_in_range)
					if(ismining(mob_blocker))
						can_spawn = FALSE
						break
			//if there's a megafauna within standard view don't spawn anything at all (This isn't really consistent, I don't know why we do this. you do you tho)
			if(can_spawn)
				for(var/mob/living/simple_animal/hostile/megafauna/found_fauna in range(7, gen_turf))
					can_spawn = FALSE
					break

			if(can_spawn)
				if(ispath(picked_mob, /mob/living/simple_animal/hostile/megafauna/bubblegum)) //there can be only one bubblegum, so don't waste spawns on it
					weighted_megafauna_spawn_list.Remove(picked_mob)
					megafauna_spawn_list = expand_weights(weighted_megafauna_spawn_list)
					megas_allowed = megas_allowed && length(megafauna_spawn_list)
				new picked_mob(gen_turf)
				spawned_something = TRUE

		CHECK_TICK

#undef BIOME_RANDOM_SQUARE_DRIFT
