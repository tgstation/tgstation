/*
 * Why have simple atom generation when you can have complex atom generation ?
 * Instead of placing individual items at random, we have a much smaller chance of placing "generation seeds"
 * Once that's down, tiles in a certain radius follow complex seeding rules
 * Can be used to make anything. Small forest zones, lakes, murder zones, debris, generic clutter, mob groups, etc
 * Supports objects and mobs (under movable) and turfs. Only one at a time, though (mobs and objects can be mixed, but should be mixed, carefully)
 * Note that it only supports random and radial generation. Anything more complex will need an even more complex and specific generator
 * While this generator supports all three types at once, it will try to spawn all three types at once
 */

//Base instance to define variables
//This will not spawn anything, so we need to go down one tier
/obj/structure/radial_gen

	name = "generator"
	desc = "The randomly generated seed of all things."
	icon = 'icons/obj/universal_generator/generators.dmi'
	icon_state = "gen_null"

	var/gen_min_radius = 0 //Radius from center before generation starts, 1 is equivalent to orange
	var/gen_soft_radius = 0 //Soft generator radius, different rules beyond this point. Starts after minimum but ends relative to center
	var/gen_hard_radius = 0 //Hard generator radius, nothing will generate past this, ever
	var/gen_prob_base = 0 //Base probability to plant something on a tile
	var/gen_prob_soft_fall = 0 //Probability reduction per tile after center
	var/gen_prob_hard_fall = 0	//Probability reduction per tile after last soft radius, overrides the former
	var/gen_empty_only = 0 //Generator will only work on tiles that are completely empty (!contents.len)
	var/gen_no_dense_only = 0 //Generator will only work on tiles without dense contents
	var/gen_clear_tiles = 0 //Generator will clear up the contents of all the tiles it is working on before spawning stuff
	var/list/expected_turfs = list() //Will return if turf type is different from any in the list, good to avoid generator collision with other terrain features

/obj/structure/radial_gen/New()

	..()

	deploy_generator()
	qdel(src) //This is exclusively used to generate other things, delete it once we're done

//Uses modular code structure, so you can define different behaviour
//We start by initializing shared behavior between all three generator sub-types, then we fire a spawn proc that they will modify
/obj/structure/radial_gen/proc/deploy_generator()

	for(var/turf/T in spiral_block(get_turf(src), gen_hard_radius, 0))

		if(expected_turfs.len && !is_type_in_list(T, expected_turfs)) //We are expecting a specific turf type, and it is not this one
			continue

		if(gen_empty_only && T.has_contents()) //We are looking for empty turfs, this turf isn't empty
			continue

		if(gen_no_dense_only && T.has_dense_content()) //We are looking for turfs without dense contents, this turf has some
			continue

		var/dist = cheap_pythag(T.x - x, T.y - y)

		if(dist < gen_min_radius) //Distance is below the minimum radius, forget this one

			continue

		if(dist < gen_hard_radius) //Inside the soft radius, minimum falloff

			var/soft_prob = max(0, gen_prob_base - gen_prob_soft_fall * (dist - gen_min_radius))

			if(prob(soft_prob)) //If the prob roll happens, continue onto generation

				if(gen_clear_tiles) //We attempt to clear the tile's contents. Hopefully this does not fail, because we won't dabble on it
					T.clear_contents(list(type))

				var/picked = perform_pick("soft", T)

				perform_spawn("soft", T, picked)

			continue

		if(dist > gen_hard_radius) //Inside the soft to hard radius, maximum falloff

			var/hard_prob = max(0, gen_prob_base - gen_prob_soft_fall * (gen_soft_radius - gen_min_radius) - gen_prob_hard_fall * (dist - gen_soft_radius))

			if(prob(hard_prob)) //If the prob roll happens, continue onto generation

				if(gen_clear_tiles) //We attempt to clear the tile's contents. Hopefully this does not fail, because we won't dabble on it
					T.clear_contents(list(type))

				var/picked = perform_pick("soft", T)

				perform_spawn("hard", T, picked)

			continue

//We pick the thing we will possibly spawn, because we need that to roll out adjacency rules
/obj/structure/radial_gen/proc/perform_pick(var/gen_type = "soft", var/turf/T)

	return 0

//We now have all that shit out of the way, spawn the fucking thing
/obj/structure/radial_gen/proc/perform_spawn(var/gen_type = "soft", var/turf/T)

	return 0

/obj/structure/radial_gen/movable

	name = "movable generator"
	desc = "This generator can manifest any atom in reality. Which one it summons was not specified."
	icon_state = "gen_mov"

	var/list/gen_types_movable_soft = list() //What types do we generate from this generator, array must contain individual probabilities for each movable. Only in soft radius
	var/list/gen_types_movable_hard = list() //Ditto above, but only in hard radius. Obviously, if you want it to spawn in both, add to both lists. OBVIOUSLY

/obj/structure/radial_gen/movable/perform_pick(var/gen_type = "soft", var/turf/T)

	switch(gen_type)

		if("soft")

			if(gen_types_movable_soft.len)

				var/picked_movable = pickweight(gen_types_movable_soft)

				return picked_movable

		if("hard")

			if(gen_types_movable_hard.len)

				var/picked_movable = pickweight(gen_types_movable_hard)

				return picked_movable

/obj/structure/radial_gen/movable/perform_spawn(var/gen_type = "soft", var/turf/T, var/atom/movable/picked)

	new picked(T)

/obj/structure/radial_gen/turf

	name = "turf generator"
	desc = "This generator can change the very fabric of reality. Which one it threads was not specified."
	icon_state = "gen_turf"

	var/list/gen_types_turf_soft = list() //What types do we generate from this generator, array must contain individual probabilities for each turf. Only in soft radius
	var/list/gen_types_turf_hard = list() //Ditto above, but only in hard radius. Obviously, if you want it to spawn in both, add to both lists. OBVIOUSLY

/obj/structure/radial_gen/turf/perform_pick(var/gen_type = "soft", var/turf/T, var/turf/picked)

	switch(gen_type)

		if("soft")

			if(gen_types_turf_soft.len)

				var/picked_turf = pickweight(gen_types_turf_soft)

				return picked_turf

		if("hard")

			if(gen_types_turf_hard.len)

				var/picked_turf = pickweight(gen_types_turf_hard)

				return picked_turf

/obj/structure/radial_gen/turf/perform_spawn(var/gen_type = "soft", var/turf/T, var/turf/picked)

	T.ChangeTurf(picked)

//Children spawn snow-related atoms
/obj/structure/radial_gen/movable/snow_nature

	name = "snow biome movable generator"
	desc = "An undefined and cold-hearted generator."
	icon_state = "gen_snow"
	expected_turfs = list(/turf/unsimulated/floor/snow) //Will return if turf type is different from any in the list, good to avoid generator collision with other terrain features

//A thin snow forest, equivalent to some lightly forested terrain
/obj/structure/radial_gen/movable/snow_nature/snow_forest

	name = "snow forest generator"
	desc = "A source of wood, can be rid off given time."
	icon_state = "gen_s_forest"

	gen_soft_radius = 5 //Soft generator radius, different rules beyond this point. Starts after minimum but ends relative to center
	gen_hard_radius = 10 //Hard generator radius, nothing will generate past this, ever
	gen_prob_base = 75 //Base probability to plant something on a tile
	gen_prob_soft_fall = 5 //Probability reduction per tile after center
	gen_prob_hard_fall = 10	//Probability reduction per tile after last soft radius, overrides the former
	gen_empty_only = 1 //Generator will only work on tiles that are completely empty (!contents.len)
	gen_no_dense_only = 1 //Generator will only work on tiles without dense contents

	//What types do we generate from this generator, array must contain individual probabilities for each turf. Only in soft radius
	gen_types_movable_soft = list(/obj/structure/flora/tree/pine = 100, \
								/obj/structure/flora/rock/pile/snow = 200, \
								/obj/structure/flora/bush = 200, \
								/obj/structure/flora/grass/white = 1000)
	//Ditto above, but only in hard radius. Obviously, if you want it to spawn in both, add to both lists. OBVIOUSLY
	gen_types_movable_hard = list(/obj/structure/flora/tree/pine = 100, \
								/obj/structure/flora/bush = 100, \
								/obj/structure/flora/rock/pile/snow = 200, \
								/obj/structure/flora/grass/white = 1000)

//A much more dense forest, with a lot more trees
/obj/structure/radial_gen/movable/snow_nature/snow_forest/dense

	name = "dense snow forest generator"
	desc = "A source of wood, easy to get lost in."
	icon_state = "gen_s_forest"

	//What types do we generate from this generator, array must contain individual probabilities for each turf. Only in soft radius
	gen_types_movable_soft = list(/obj/structure/flora/tree/pine = 500, \
								/obj/structure/flora/rock/pile/snow = 250, \
								/obj/structure/flora/bush = 250, \
								/obj/structure/flora/grass/white = 1000)
	//Ditto above, but only in hard radius. Obviously, if you want it to spawn in both, add to both lists. OBVIOUSLY
	gen_types_movable_hard = list(/obj/structure/flora/tree/pine = 250, \
								/obj/structure/flora/bush = 100, \
								/obj/structure/flora/rock/pile/snow = 200, \
								/obj/structure/flora/grass/white = 1000)


//A larger thin forest, falls offs slowly at first and after a 15 tile radii down to 0 % chance after 30
/obj/structure/radial_gen/movable/snow_nature/snow_forest/large

	name = "large snow forest generator"
	desc = "A plentiful source of wood, sparse tree coverage, but certainly blocks construction projects."
	icon_state = "gen_s_forest_l"

	gen_soft_radius = 15 //Soft generator radius, different rules beyond this point. Starts after minimum but ends relative to center
	gen_hard_radius = 30 //Hard generator radius, nothing will generate past this, ever
	gen_prob_base = 90 //Base probability to plant something on a tile
	gen_prob_soft_fall = 2 //Probability reduction per tile after center
	gen_prob_hard_fall = 4	//Probability reduction per tile after last soft radius, overrides the former

//A much more dense forest, with a lot more trees
/obj/structure/radial_gen/movable/snow_nature/snow_forest/large/dense

	name = "dense and large snow forest generator"
	desc = "A massive source of wood, easy to get lost in."
	icon_state = "gen_s_forest"

	//What types do we generate from this generator, array must contain individual probabilities for each turf. Only in soft radius
	gen_types_movable_soft = list(/obj/structure/flora/tree/pine = 500, \
								/obj/structure/flora/rock/pile/snow = 250, \
								/obj/structure/flora/bush = 250, \
								/obj/structure/flora/grass/white = 1000)
	//Ditto above, but only in hard radius. Obviously, if you want it to spawn in both, add to both lists. OBVIOUSLY
	gen_types_movable_hard = list(/obj/structure/flora/tree/pine = 250, \
								/obj/structure/flora/bush = 100, \
								/obj/structure/flora/rock/pile/snow = 200, \
								/obj/structure/flora/grass/white = 1000)

//A patch of snowy grass, with some rocks and bushes thrown in
/obj/structure/radial_gen/movable/snow_nature/snow_grass

	name = "snow grass generator"
	desc = "A bunch of tundra plants, managing to thrive even in otherwise awful weather for plant life."
	icon_state = "gen_s_grass"

	gen_soft_radius = 10 //Soft generator radius, different rules beyond this point. Starts after minimum but ends relative to center
	gen_hard_radius = 15 //Hard generator radius, nothing will generate past this, ever
	gen_prob_base = 85 //Base probability to plant something on a tile
	gen_prob_soft_fall = 1 //Probability reduction per tile after center
	gen_prob_hard_fall = 15	//Probability reduction per tile after last soft radius, overrides the former
	gen_empty_only = 1 //Generator will only work on tiles that are completely empty (!contents.len)
	gen_no_dense_only = 1 //Generator will only work on tiles without dense contents

	//What types do we generate from this generator, array must contain individual probabilities for each turf. Only in soft radius
	gen_types_movable_soft = list(/obj/structure/flora/rock/pile/snow = 100, \
								/obj/structure/flora/bush = 400, \
								/obj/structure/flora/grass/white = 1000)
	//Ditto above, but only in hard radius. Obviously, if you want it to spawn in both, add to both lists. OBVIOUSLY
	gen_types_movable_hard = list(/obj/structure/flora/rock/pile/snow = 50, \
								/obj/structure/flora/bush = 200, \
								/obj/structure/flora/grass/white = 1000)

//A large patch of snowy grass, with some rocks and bushes thrown in
/obj/structure/radial_gen/movable/snow_nature/snow_grass/large

	name = "large snow grass generator"
	desc = "A large bunch of tundra plants, managing to thrive even in otherwise awful weather for plant life."
	icon_state = "gen_s_grass_l"

	gen_soft_radius = 15 //Soft generator radius, different rules beyond this point. Starts after minimum but ends relative to center
	gen_hard_radius = 30 //Hard generator radius, nothing will generate past this, ever
	gen_prob_base = 95 //Base probability to plant something on a tile
	gen_prob_soft_fall = 1 //Probability reduction per tile after center
	gen_prob_hard_fall = 5	//Probability reduction per tile after last soft radius, overrides the former

//Children spawn snow-related turfs
/obj/structure/radial_gen/turf/snow_nature

	name = "snow biome turf generator"
	desc = "An undefined and cold-hearted generator."
	icon_state = "gen_s_turf"

//A patch of snow
/obj/structure/radial_gen/turf/snow_nature/snow_patch

	name = "snow generator"
	desc = "A patch of frozen water particles."
	icon_state = "gen_snow"

	gen_soft_radius = 5 //Soft generator radius, different rules beyond this point. Starts after minimum but ends relative to center
	gen_hard_radius = 10 //Hard generator radius, nothing will generate past this, ever
	gen_prob_base = 100 //Base probability to plant something on a tile
	gen_prob_soft_fall = 0 //Probability reduction per tile after center
	gen_prob_hard_fall = 10	//Probability reduction per tile after last soft radius, overrides the former

	//What types do we generate from this generator, array must contain individual probabilities for each turf. Only in soft radius
	gen_types_turf_soft = list(/turf/unsimulated/floor/snow = 100)
	//Ditto above, but only in hard radius. Obviously, if you want it to spawn in both, add to both lists. OBVIOUSLY
	gen_types_turf_hard = list(/turf/unsimulated/floor/snow = 100)

//A very large patch of snow
/obj/structure/radial_gen/turf/snow_nature/snow_patch/large

	name = "large snow generator"
	desc = "A large patch of frozen water particles."
	icon_state = "gen_snow_l"

	gen_soft_radius = 15 //Soft generator radius, different rules beyond this point. Starts after minimum but ends relative to center
	gen_hard_radius = 30 //Hard generator radius, nothing will generate past this, ever
	gen_prob_hard_fall = 5	//Probability reduction per tile after last soft radius, overrides the former

//A patch of permafrost
/obj/structure/radial_gen/turf/snow_nature/permafrost

	name = "permafrost generator"
	desc = "A patch of frozen dirt."
	icon_state = "gen_pfrost"

	gen_soft_radius = 5 //Soft generator radius, different rules beyond this point. Starts after minimum but ends relative to center
	gen_hard_radius = 10 //Hard generator radius, nothing will generate past this, ever
	gen_prob_base = 100 //Base probability to plant something on a tile
	gen_prob_soft_fall = 0 //Probability reduction per tile after center
	gen_prob_hard_fall = 10	//Probability reduction per tile after last soft radius, overrides the former
	gen_clear_tiles = 1 //FOR TESTING ONLY

	//What types do we generate from this generator, array must contain individual probabilities for each turf. Only in soft radius
	gen_types_turf_soft = list(/turf/unsimulated/floor/snow/permafrost = 100)
	//Ditto above, but only in hard radius. Obviously, if you want it to spawn in both, add to both lists. OBVIOUSLY
	gen_types_turf_hard = list(/turf/unsimulated/floor/snow/permafrost = 100)

//A very large patch of permafrost
/obj/structure/radial_gen/turf/snow_nature/permafrost/large

	name = "large permafrost generator"
	desc = "A large patch of frozen dirt."
	icon_state = "gen_pfrost_l"

	gen_soft_radius = 15 //Soft generator radius, different rules beyond this point. Starts after minimum but ends relative to center
	gen_hard_radius = 30 //Hard generator radius, nothing will generate past this, ever
	gen_prob_hard_fall = 5	//Probability reduction per tile after last soft radius, overrides the former
