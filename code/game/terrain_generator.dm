/obj/effect/landmark/terrain_generator
	name = "terrain generator"
	var/static/generator_id = 0
	var/list/biomes = list()
	var/iteration_count = 0

/obj/effect/landmark/terrain_generator/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/terrain_generator/LateInitialize()
	. = ..()
	generator_id++
	rustg_perlin_noise_seed_generator("[generator_id]", "3")
	generate_turfs()

/obj/effect/landmark/terrain_generator/proc/generate_turfs()
	var/area/our_area = get_area(src)

	for(var/turf/T in our_area)
		var/height = (text2num(rustg_perlin_noise_get_at_coordinates("[generator_id]", "[T.x/100]", "[T.y/100]")) * sqrt(2) + 1) / 2
		var/datum/biome/selected_biome
		switch(height)
			if(0 to 0.05)
				selected_biome = /datum/biome/water
			if(0.05 to 0.08)
				selected_biome = /datum/biome/beach
			if(0.08 to 0.3)
				selected_biome = /datum/biome/plains
			if(0.3 to 0.8)
				selected_biome = /datum/biome/jungle
			if(0.8 to 1)
				selected_biome = /datum/biome/mountain
		selected_biome = SSmapping.biomes[selected_biome]
		T.ChangeTurf(selected_biome.turf_type)
		generate_flora(selected_biome, T)
		CHECK_TICK

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
