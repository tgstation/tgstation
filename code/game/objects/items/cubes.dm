/obj/effect/spawner/random/cube_all
	name = "cube spawner (All Rarities)"
	desc = "Roll the small cubes to see if you get the good cubes or the bad cubes."
	icon_state = "loot"
	remove_if_cant_spawn = FALSE //don't remove stuff from the global list, which other can use.
	// see code/_globalvars/lists/objects.dm for loot table

/obj/effect/spawner/random/cube_all/Initialize(mapload)
	loot = GLOB.all_cubes
	return ..()

/obj/effect/spawner/random/cube_all/skew_loot_weights(list/loot_list, exponent)
	///We only need to skew the weights once, since it's a global list used by all maint spawners.
	var/static/already_cubed = FALSE
	if(loot_list == GLOB.all_cubes && already_cubed)
		return
	already_cubed = TRUE
	return ..()

/obj/effect/spawner/random/cube
	name = "cube spawner (Common)"
	desc = "Used to roll for those delicious cubes."
	icon_state = "loot"
	remove_if_cant_spawn = FALSE

	/// The rarity of the cube we're going to get. Just use this as an index instead of manually inputting an Initialize() proc in all the others.
	var/cube_rarity = COMMON_CUBE
	/// The list of the lists of all cubes
	var/static/list/all_cubelists = list(
		GLOB.common_cubes,
		GLOB.uncommon_cubes,
		GLOB.rare_cubes,
		GLOB.epic_cubes,
		GLOB.legendary_cubes,
		GLOB.mythical_cubes,
		)

/obj/effect/spawner/random/cube/Initialize(mapload)
	loot = all_cubelists[cube_rarity]
	return ..()

/obj/effect/spawner/random/cube/uncommon
	name = "cube spawner (Uncommon)"
	cube_rarity = UNCOMMON_CUBE

/obj/effect/spawner/random/cube/rare
	name = "cube spawner (Rare)"
	cube_rarity = RARE_CUBE

/obj/effect/spawner/random/cube/epic
	name = "cube spawner (Epic)"
	cube_rarity = EPIC_CUBE

/obj/effect/spawner/random/cube/legendary
	name = "cube spawner (Legendary)"
	cube_rarity = LEGENDARY_CUBE

/obj/effect/spawner/random/cube/mythical
	name = "cube spawner (Mythical)"
	cube_rarity = MYTHICAL_CUBE

/obj/item/cube
	name = "dev cube"
	desc = "You shouldn't be seeing this cube!"
	icon = 'icons/obj/cubes.dmi'
	icon_state = "cube"
	w_class = WEIGHT_CLASS_NORMAL
	reagents

	/// The rarity of this cube
	var/rarity = COMMON_CUBE

/obj/item/cube/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = rarity)

/// Random cubes ///

/obj/item/cube/random
	name = "Random Common Cube"
	desc = "A cube that's full of surprises!"
	/// I'm like 90% sure trying to reference the bitflags as a list was the reason my computer was crashing 4 times so I'm just putting it here instead
	var/static/foodtype_list = list(
		MEAT,
		VEGETABLES,
		RAW,
		JUNKFOOD,
		GRAIN,
		FRUIT,
		DAIRY,
		FRIED,
		ALCOHOL,
		SUGAR,
		GROSS,
		TOXIC,
		PINEAPPLE,
		BREAKFAST,
		CLOTH,
		NUTS,
		SEAFOOD,
		ORANGES,
		BUGS,
		GORE,
		STONE,
	)

/obj/item/cube/random/Initialize(mapload)
	give_random_icon()
	apply_rand_size()
	randcolor()
	create_random_name()
	. = ..()
	give_random_effects()

/// Randomize the color for the cube
/obj/item/cube/proc/randcolor()
	add_filter("cubecolor", 1, color_matrix_filter(ready_random_color()))

/// Randomize icons (once I make more generic ones)
/obj/item/cube/proc/give_random_icon()
	if(!prob(10*rarity))
		return
	icon_state = pick(
		"small",
	)

/// Randomize size
/obj/item/cube/proc/apply_rand_size()
	if(!prob(10*rarity))
		return
	var/randscale = rand(0.5, 2.0)
	transform.Scale(randscale,randscale)

/// Create a random name for the cube with a complexity based off its rarity
/obj/item/cube/proc/create_random_name()
	var/adjective_string = ""
	if(rarity > 2)
		for(var/i in 1 to (rarity-2))
			adjective_string += " [pick(GLOB.adjectives)]"

	switch(rarity)
		if(1)
			name = "[pick(GLOB.adjectives)] Cube"
		if(2)
			switch(rand(1,2))
				if(1)
					name = "[pick(GLOB.adjectives)] Cube of the [pick(GLOB.station_suffixes)]"
				if(2)
					name = "[pick(GLOB.adjectives)] Cube of [pick(GLOB.ing_verbs)]"
		else
			switch(rand(1,2))
				if(1)
					name = "[pick(GLOB.adjectives)] Cube of the[adjective_string] [pick(GLOB.station_suffixes)]"
				if(2)
					name = "[pick(GLOB.adjectives)] Cube of[adjective_string] [pick(GLOB.ing_verbs)]"

/// Random cube effects
/obj/item/cube/proc/give_random_effects()

//! Continue random effects
	var/list/possible_cube_effects = list(
	"Edible",
	"Chemical",
	"Circuit",
	"Boomerang",
	"Tool",
	"Instrument",
	"Laser Gun",
	"Melee",
	"Storage",
	"Paperweight"
	)
	for(var/i in 1 to rarity)
		var/rand_swap = pick(possible_cube_effects)
		switch(rand_swap)

			if("Edible")
				if(!reagents)
					create_reagents(50, INJECTABLE)
				var/list/cube_reagents
				var/cube_foodtypes
				var/list/cube_tastes
				for(var/r in 1 to rarity)
					cube_reagents += list(subtypesof(/datum/reagent/consumable) = rand(2,5*rarity))
					cube_foodtypes |= pick(foodtype_list)
					cube_tastes += list("[pick(GLOB.adjectives)]" = rand(1,rarity))

				AddComponentFrom(
					SOURCE_EDIBLE_INNATE,\
					/datum/component/edible,\
					initial_reagents = cube_reagents,\
					food_flags = pick(NONE, FOOD_FINGER_FOOD),\
					foodtypes = cube_foodtypes,\
					eat_time = round(3 SECONDS/rarity),\
					tastes = cube_tastes,\
				)

			if("Chemical")
				if(!reagents)
					create_reagents(50, INJECTABLE)
				if(prob(15*rarity))
					reagents.flags |= pick(NO_REACT, REAGENT_HOLDER_INSTANT_REACT)
				reagents.flags |= pick(SEALED_CONTAINER, OPENCONTAINER)
				reagents.maximum_volume = rand(50, 50*rarity)
				for(var/c in 1 to rarity)
					reagents.add_reagent(get_random_reagent_id(), rand(5,10*rarity))
				/// Try to make it less likely to explode you by normalizing the temp
				var/temp_raw = rand(0, rarity*150)
				reagents.set_temperature(round((temp_raw/(rarity*150))**2*(rarity*150)))


		possible_cube_effects -= rand_swap

/obj/item/cube/random/uncommon
	name = "Random Uncommon Cube"
	rarity = UNCOMMON_CUBE

/obj/item/cube/random/rare
	name = "Random Rare Cube"
	rarity = RARE_CUBE

/obj/item/cube/random/epic
	name = "Random Epic Cube"
	rarity = EPIC_CUBE

/obj/item/cube/random/legendary
	name = "Random Legendary Cube"
	rarity = LEGENDARY_CUBE

/obj/item/cube/random/mythical
	name = "Random Mythical Cube"
	rarity = MYTHICAL_CUBE
