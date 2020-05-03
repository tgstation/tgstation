/obj/effect/landmark/terrain_generator
	name = "terrain generator"
	var/static/generator_id = 0
	var/list/biomes = list()
	var/iteration_count = 0

	var/list/possible_biomes = list(BIOME_LOW_HEAT = list(BIOME_LOW_HUMIDITY = /datum/biome/plains, BIOME_MEDIUM_HUMIDITY = /datum/biome/mudlands, BIOME_HIGH_HUMIDITY = /datum/biome/water), BIOME_MEDIUM_HEAT = list(BIOME_LOW_HUMIDITY = /datum/biome/plains, BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle, BIOME_HIGH_HUMIDITY = /datum/biome/jungle),BIOME_HIGH_HEAT = list(BIOME_LOW_HUMIDITY = /datum/biome/wasteland, BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle, BIOME_HIGH_HUMIDITY = /datum/biome/jungle/deep))

/obj/effect/landmark/terrain_generator/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/terrain_generator/LateInitialize()
	. = ..()
	generator_id++
	rustg_perlin_noise_seed_generator("[PERLIN_LAYER_HEIGHT][generator_id]", "[rand(0,5000)]")
	rustg_perlin_noise_seed_generator("[PERLIN_LAYER_HUMIDITY][generator_id]", "[rand(0,5000)]")
	rustg_perlin_noise_seed_generator("[PERLIN_LAYER_HEAT][generator_id]", "[rand(0,5000)]")
	generate_turfs()

/obj/effect/landmark/terrain_generator/proc/generate_turfs()
	var/area/our_area = get_area(src)

	for(var/turf/T in our_area)
		var/height = get_perlin_noise("[PERLIN_LAYER_HEIGHT][generator_id]", T.x, T.y)

		var/datum/biome/selected_biome
		switch(height)
			if(0 to 0.85)
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
			if(0.85 to 1)
				selected_biome = /datum/biome/mountain
		selected_biome = SSmapping.biomes[selected_biome]
		T.ChangeTurf(selected_biome.turf_type)
		generate_flora(selected_biome, T)
		generate_fauna(selected_biome, T)
		CHECK_TICK

/obj/effect/landmark/terrain_generator/proc/get_perlin_noise(id, x, y)
	return clamp((text2num(rustg_perlin_noise_get_at_coordinates("[id]", "[x/65]", "[y/65]")) + 1) / 2, 0, 1)

/obj/effect/landmark/terrain_generator/proc/generate_flora(var/datum/biome/B, var/turf/T)
	if(prob(B.flora_density))
		var/obj/structure/flora = pick(B.flora_types)
		new flora(T)

/obj/effect/landmark/terrain_generator/proc/generate_fauna(var/datum/biome/B, var/turf/T)
	if(prob(B.fauna_density))
		var/mob/fauna = pick(B.fauna_types)
		new fauna(T)

/turf/open/genturf
	name = "ungenerated turf"
	desc = "If you see this, and you're not a ghost, yell at coders"
	icon = 'icons/turf/debug.dmi'
	icon_state = "genturf"

/area/mine/planetgeneration
	name = "planet generation area"
