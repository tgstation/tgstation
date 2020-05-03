/obj/effect/landmark/terrain_generator
	name = "terrain generator"
	var/static/generator_id = 0
	var/list/biomes = list()

/obj/effect/landmark/terrain_generator/Initialize()
	. = ..()
	rustg_perlin_noise_seed_generator(generator_id, world.time)
	generator_id++
	generate_turfs()

/obj/effect/landmark/terrain_generator/proc/generate_turfs()
	var/area/our_area = get_area(src)

	for(var/turf/T in our_area.contents)
		var/height = rustg_perlin_noise_get_at_coordinates(generator_id, T.x, T.y)
		var/datum/biome/selected_biome
		switch(height)
			if(0 to 0.15)
				selected_biome = /datum/biome/water
			if(0.15 to 0.2)
				selected_biome = /datum/biome/beach
			if(0.2 to 0.5)
				selected_biome = /datum/biome/plains
			if(0.5 to 0.8)
				selected_biome = /datum/biome/jungle
			if(0.8 to 1)
				selected_biome = /datum/biome/mountain
		T.ChangeTurf(selected_biome.turf_type)

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
