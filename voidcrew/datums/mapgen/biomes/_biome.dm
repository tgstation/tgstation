
/proc/pickweight(list/L)
	var/total = 0
	var/item
	for (item in L)
		if (!L[item])
			L[item] = 1
		total += L[item]

	total = rand(1, total)
	for (item in L)
		total -=L [item]
		if (total <= 0)
			return item

	return null


/datum/biome
	var/open_turf_types = list(/turf/open/misc/asteroid = 1)
	var/list/feature_spawn_list
	var/list/mob_spawn_list
	var/list/flora_spawn_list
	var/mob_spawn_chance = 6
	var/flora_spawn_chance = 2
	var/feature_spawn_chance = 0.1

/datum/biome/cave
	var/closed_turf_types =  list(/turf/closed/mineral/random/volcanic = 1)
	open_turf_types = list(/turf/open/misc/asteroid = 1)

/datum/biome/proc/generate_overworld(var/turf/gen_turf)
	//TURF SPAWNING
	var/turf/picked_turf = pickweight(open_turf_types)
	var/turf/open/new_turf = gen_turf.ChangeTurf(picked_turf, initial(picked_turf.baseturfs), CHANGETURF_IGNORE_AIR|CHANGETURF_RECALC_ADJACENT|CHANGETURF_DEFER_CHANGE)
	CHECK_TICK
	gen_turf.AfterChange(CHANGETURF_IGNORE_AIR|CHANGETURF_RECALC_ADJACENT)
	CHECK_TICK

	generate_features(new_turf)

	CHECK_TICK

/datum/biome/cave/proc/generate_caves(turf/gen_turf, string_gen)
	var/area/A = gen_turf.loc
	if(!(A.area_flags & CAVES_ALLOWED))
		return

	var/closed = text2num(string_gen[world.maxx * (gen_turf.y - 1) + gen_turf.x])

	var/stored_flags
	if(gen_turf.flags_1 & NO_RUINS)
		stored_flags |= NO_RUINS

	var/turf/new_turf = pickweight(closed ? closed_turf_types : open_turf_types)
	new_turf = gen_turf.ChangeTurf(new_turf, initial(new_turf.baseturfs), CHANGETURF_IGNORE_AIR|CHANGETURF_DEFER_CHANGE)
	new_turf.flags_1 |= stored_flags
	CHECK_TICK
	gen_turf.AfterChange(CHANGETURF_IGNORE_AIR|CHANGETURF_RECALC_ADJACENT)

	CHECK_TICK

	//Overwrite turf areas with cave areas to combat weather
	var/area/overmap_encounter/planetoid/cave/new_area = GLOB.areas_by_type[/area/overmap_encounter/planetoid/cave] || new
	var/area/old_area = get_area(new_turf)
	new_area.contents += new_turf
	new_turf.change_area(old_area, new_area)
	CHECK_TICK

	if(!closed)
		generate_features(new_turf)
	CHECK_TICK

/datum/biome/proc/generate_features(turf/new_turf)
	//FLORA SPAWNING
	var/atom/spawned_flora
	var/area/A = new_turf.loc
	if(flora_spawn_list && prob(flora_spawn_chance))
		var/can_spawn = TRUE
		if(!(A.area_flags & FLORA_ALLOWED))
			can_spawn = FALSE
		if(can_spawn)
			spawned_flora = pickweight(flora_spawn_list)
			spawned_flora = new spawned_flora(new_turf)
			new_turf.flags_1 |= NO_LAVA_GEN

	//FEATURE SPAWNING HERE
	var/atom/spawned_feature
	if(feature_spawn_list && prob(feature_spawn_chance) && !spawned_flora)
		var/can_spawn = TRUE

		if(!(A.area_flags & FLORA_ALLOWED))
			can_spawn = FALSE

		var/atom/picked_feature = pickweight(feature_spawn_list)

		for(var/obj/F in range(7, new_turf))
			if(istype(F, picked_feature))
				can_spawn = FALSE

		if(can_spawn)
			spawned_feature = new picked_feature(new_turf)
			new_turf.flags_1 |= NO_LAVA_GEN

	//MOB SPAWNING
	if(mob_spawn_list && !spawned_flora && !spawned_feature && prob(mob_spawn_chance))
		var/can_spawn = TRUE

		if(!(A.area_flags & MOB_SPAWN_ALLOWED))
			can_spawn = FALSE

		var/atom/picked_mob = pickweight(mob_spawn_list)

		for(var/thing in urange(12, new_turf)) //prevents mob clumps
			if(!ishostile(thing) && !istype(thing, /obj/structure/spawner))
				continue
			if(ispath(picked_mob, /mob/living) || istype(thing, /mob/living/))
				can_spawn = FALSE //if the random is a standard mob, avoid spawning if there's another one within 12 tiles
				break
			if((ispath(picked_mob, /obj/structure/spawner) || istype(thing, /obj/structure/spawner)) && get_dist(new_turf, thing) <= 2)
				can_spawn = FALSE //prevents tendrils spawning in each other's collapse range
				break

		if(can_spawn)
			new picked_mob(new_turf)
			new_turf.flags_1 |= NO_LAVA_GEN


	CHECK_TICK
