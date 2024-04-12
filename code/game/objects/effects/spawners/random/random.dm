/**
 * Base class for all random spawners.
 */
/obj/effect/spawner/random
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "loot"
	layer = OBJ_LAYER
	/// Stops persistent lootdrop spawns from being shoved into lockers
	anchored = TRUE
	/// A list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)
	var/list/loot
	/// The subtypes AND type to combine with the loot list
	var/loot_type_path
	/// The subtypes (this excludes the provided path) to combine with the loot list
	var/loot_subtype_path
	/// How many items will be spawned
	var/spawn_loot_count = 1
	/// If the same item can be spawned twice
	var/spawn_loot_double = TRUE
	/// Whether the items should be distributed to offsets 0,1,-1,2,-2,3,-3.. This overrides pixel_x/y on the spawner itself
	var/spawn_loot_split = FALSE
	/// The pixel x/y divider offsets for spawn_loot_split (spaced 1 pixel apart by default)
	var/spawn_loot_split_pixel_offsets = 2
	/// Whether the spawner should spawn all the loot in the list
	var/spawn_all_loot = FALSE
	/// The chance for the spawner to create loot (ignores spawn_loot_count)
	var/spawn_loot_chance = 100
	/// Determines how big of a range (in tiles) we should scatter things in.
	var/spawn_scatter_radius = 0
	/// Whether the items should have a random pixel_x/y offset (maxium offset distance is ±16 pixels for x/y)
	var/spawn_random_offset = FALSE

/obj/effect/spawner/random/Initialize(mapload)
	. = ..()
	spawn_loot()

///If the spawner has any loot defined, randomly picks some and spawns it. Does not cleanup the spawner.
/obj/effect/spawner/random/proc/spawn_loot(lootcount_override)
	if(!prob(spawn_loot_chance))
		return

	var/list/spawn_locations = get_spawn_locations(spawn_scatter_radius)
	var/spawn_loot_count = isnull(lootcount_override) ? src.spawn_loot_count : lootcount_override

	if(spawn_all_loot)
		spawn_loot_count = INFINITY
		spawn_loot_double = FALSE

	if(loot_type_path)
		loot += typesof(loot_type_path)

	if(loot_subtype_path)
		loot += subtypesof(loot_subtype_path)

	if(loot?.len)
		var/loot_spawned = 0
		var/pixel_divider = FLOOR(16 / spawn_loot_split_pixel_offsets, 1) // 16 pixels offsets is max that should be allowed in any direction
		while((spawn_loot_count-loot_spawned) && loot.len)
			var/lootspawn = pick_weight_recursive(loot)
			if(!can_spawn(lootspawn))
				loot.Remove(lootspawn)
				continue
			if(!spawn_loot_double)
				loot.Remove(lootspawn)
			if(lootspawn && (spawn_scatter_radius == 0 || spawn_locations.len))
				var/turf/spawn_loc = loc
				if(spawn_scatter_radius > 0)
					spawn_loc = pick_n_take(spawn_locations)

				var/atom/movable/spawned_loot = make_item(spawn_loc, lootspawn)
				spawned_loot.setDir(dir)

				if (!spawn_loot_split && !spawn_random_offset)
					if (pixel_x != 0)
						spawned_loot.pixel_x = pixel_x
					if (pixel_y != 0)
						spawned_loot.pixel_y = pixel_y
				else if (spawn_random_offset)
					spawned_loot.pixel_x = rand(-16, 16)
					spawned_loot.pixel_y = rand(-16, 16)
				else if (spawn_loot_split)
					if (loot_spawned)
						var/column = FLOOR(loot_spawned / pixel_divider, 1)
						spawned_loot.pixel_x = spawn_loot_split_pixel_offsets * (loot_spawned % pixel_divider) + (column * spawn_loot_split_pixel_offsets)
						spawned_loot.pixel_y = spawn_loot_split_pixel_offsets * (loot_spawned % pixel_divider)
			loot_spawned++

/**
 *  Makes the actual item related to our spawner.
 *
 * spawn_loc - where are we spawning it?
 * type_path_to_make - what are we spawning?
 **/
/obj/effect/spawner/random/proc/make_item(spawn_loc, type_path_to_make)
	return new type_path_to_make(spawn_loc)

///If the spawner has a spawn_scatter_radius set, this creates a list of nearby turfs available that are in view and have an unblocked line to them.
/obj/effect/spawner/random/proc/get_spawn_locations(radius)
	var/list/scatter_locations = list()

	if(!radius)
		return scatter_locations

	for(var/turf/turf_in_view in view(radius, get_turf(src)))
		if(isclosedturf(turf_in_view) || (isgroundlessturf(turf_in_view) && !GET_TURF_BELOW(turf_in_view)))
			continue
		if(!has_unblocked_line(turf_in_view))
			continue

		scatter_locations += turf_in_view

	return scatter_locations

/obj/effect/spawner/random/proc/has_unblocked_line(destination)
	for(var/turf/potential_blockage as anything in get_line(get_turf(src), destination))
		if(!potential_blockage.is_blocked_turf(exclude_mobs = TRUE))
			continue
		return FALSE
	return TRUE

//finds the probabilities of items spawning from a loot spawner's loot pool
/obj/item/loot_table_maker
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"
	var/spawner_to_test = /obj/effect/spawner/random/maintenance //what lootdrop spawner to use the loot pool of
	var/loot_count = 180 //180 is about how much maint loot spawns per map as of 11/14/2019
	//result outputs
	var/list/spawned_table //list of all items "spawned" and how many
	var/list/stat_table //list of all items "spawned" and their occurrance probability

/obj/item/loot_table_maker/Initialize(mapload)
	. = ..()
	make_table()

/obj/item/loot_table_maker/attack_self(mob/user)
	to_chat(user, "Loot pool re-rolled.")
	make_table()

/obj/item/loot_table_maker/proc/make_table()
	spawned_table = list()
	stat_table = list()
	var/obj/effect/spawner/random/spawner_to_table = new spawner_to_test
	var/lootpool = spawner_to_table.loot
	qdel(spawner_to_table)
	for(var/i in 1 to loot_count)
		var/loot_spawn = pick_weight_recursive(lootpool)
		if(!(loot_spawn in spawned_table))
			spawned_table[loot_spawn] = 1
		else
			spawned_table[loot_spawn] += 1
	stat_table += spawned_table
	for(var/item in stat_table)
		stat_table[item] /= loot_count
