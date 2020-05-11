/datum/map_generator/jungle_generator
	///Static number to keep track of the generator to allow us to get an ID for the perlin noise so we can keep getting unique ones.
	var/static/generator_id_counter = 0
	///Our specific generator ID.
	var/generator_id = 0
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(BIOME_LOW_HEAT = list(BIOME_LOW_HUMIDITY = /datum/biome/plains, BIOME_MEDIUM_HUMIDITY = /datum/biome/mudlands, BIOME_HIGH_HUMIDITY = /datum/biome/water), BIOME_MEDIUM_HEAT = list(BIOME_LOW_HUMIDITY = /datum/biome/plains, BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle, BIOME_HIGH_HUMIDITY = /datum/biome/jungle),BIOME_HIGH_HEAT = list(BIOME_LOW_HUMIDITY = /datum/biome/wasteland, BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle, BIOME_HIGH_HUMIDITY = /datum/biome/jungle/deep))

///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/jungle_generator/generate_terrain(var/list/turfs)
	. = ..()
	generator_id = generator_id_counter
	rustg_perlin_noise_seed_generator("[PERLIN_LAYER_HEIGHT][generator_id]", "[rand(0,5000)]")
	rustg_perlin_noise_seed_generator("[PERLIN_LAYER_HUMIDITY][generator_id]", "[rand(0,5000)]")
	rustg_perlin_noise_seed_generator("[PERLIN_LAYER_HEAT][generator_id]", "[rand(0,5000)]")
	generator_id_counter++

	for(var/turf/T in turfs) //Go through all the turfs and generate them
		var/height = get_perlin_noise("[PERLIN_LAYER_HEIGHT][generator_id]", T.x, T.y)

		var/datum/biome/selected_biome
		if(height <= 0.85) //If height is less than 0.85, we generate biomes based on the heat and humidity of the area.
			var/humidity = get_perlin_noise("[PERLIN_LAYER_HUMIDITY][generator_id]", T.x, T.y)
			var/heat = 	get_perlin_noise("[PERLIN_LAYER_HEAT][generator_id]", T.x, T.y)

			var/heat_level
			var/humidity_level

			switch(heat)
				if(0 to 0.33)
					heat_level = BIOME_LOW_HEAT
				if(0.33 to 0.66)
					heat_level = BIOME_MEDIUM_HEAT
				if(0.66 to 1)
					heat_level = BIOME_HIGH_HEAT
			switch(humidity)
				if(0 to 0.33)
					humidity_level = BIOME_LOW_HUMIDITY
				if(0.33 to 0.66)
					humidity_level = BIOME_MEDIUM_HUMIDITY
				if(0.66 to 1)
					humidity_level = BIOME_HIGH_HUMIDITY
			selected_biome = possible_biomes[heat_level][humidity_level]
		else //Over 0.85; It's a mountain
			selected_biome = /datum/biome/mountain
		selected_biome = SSmapping.biomes[selected_biome]
		T.ChangeTurf(selected_biome.turf_type)
		selected_biome.generate_flora(T)
		selected_biome.generate_fauna(T)
		CHECK_TICK

/datum/map_generator/jungle_generator/proc/get_perlin_noise(id, x, y)
	return clamp((text2num(rustg_perlin_noise_get_at_coordinates("[id]", "[x/65]", "[y/65]")) + 1) / 2, 0, 1)

/turf/open/genturf
	name = "ungenerated turf"
	desc = "If you see this, and you're not a ghost, yell at coders"
	icon = 'icons/turf/debug.dmi'
	icon_state = "genturf"

/area/mine/planetgeneration
	name = "planet generation area"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
