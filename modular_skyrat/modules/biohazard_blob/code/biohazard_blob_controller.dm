#define SPREAD_PROCESS 2
#define SPREAD_STALLED_PROCESS 10

#define PROGRESSION_FOR_STRUCTURE 20
#define PROGRESSION_RETALIATED 5
#define STRUCTURE_PROGRESSION_START 20

#define RESIN_CANT_SPREAD 0
#define RESIN_DID_SPREAD 1
#define RESIN_ATTACKED_DOOR 2

/datum/biohazard_blob_controller
	var/list/active_resin = list()
	var/list/all_resin = list()
	var/obj/structure/biohazard_blob/structure/core/our_core
	var/list/other_structures = list()
	var/progress_to_spread = 0
	var/structure_progression = STRUCTURE_PROGRESSION_START
	var/stalled = FALSE
	var/blob_type
	var/spread_delay = SPREAD_PROCESS

/datum/biohazard_blob_controller/New(obj/structure/biohazard_blob/structure/core/the_core, passedtype)
	if(!the_core)
		qdel(src)
		return
	our_core = the_core
	blob_type = passedtype
	our_core.our_controller = src
	SpawnExpansion()
	START_PROCESSING(SSobj, src)
	return ..()

/datum/biohazard_blob_controller/proc/SpawnExpansion()
	var/list/turfs = list()
	var/hatcheries_to_spawn = 3
	var/bulbs_to_spawn = rand(3, 5)
	var/conditioners_to_spawn = 2
	var/spread_radius = 5
	var/our_turf = get_turf(our_core)
	turfs[our_turf] = TRUE
	for(var/i in 1 to spread_radius)
		for(var/tr in turfs)
			var/turf/T = tr
			for(var/tr2 in T.atmos_adjacent_turfs)
				turfs[tr2] = TRUE
	for(var/tr in turfs)
		var/turf/T = tr
		SpawnResin(T)
		if(T == our_turf)
			continue
		if(hatcheries_to_spawn && prob(40))
			hatcheries_to_spawn--
			SpawnStructureLoc(2, T)
		else if(bulbs_to_spawn && prob(40))
			bulbs_to_spawn--
			SpawnStructureLoc(1, T)
		else if(conditioners_to_spawn && prob(40))
			conditioners_to_spawn--
			SpawnStructureLoc(3, T)

/datum/biohazard_blob_controller/proc/SpawnStructureLoc(index, location)
	var/spawn_type
	switch(index)
		if(1)
			spawn_type = /obj/structure/biohazard_blob/structure/bulb
		if(2)
			spawn_type = /obj/structure/biohazard_blob/structure/spawner
		if(3)
			spawn_type = /obj/structure/biohazard_blob/structure/conditioner

	var/struct = new spawn_type(location, blob_type)
	other_structures[struct] = TRUE
	our_core.max_integrity += 10
	our_core.repair_damage(10)
	return struct

/datum/biohazard_blob_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	all_resin = null
	active_resin = null
	our_core = null
	other_structures = null
	return ..()

/datum/biohazard_blob_controller/proc/CoreRetaliated()
	structure_progression += PROGRESSION_RETALIATED
	active_resin.Cut()
	ActivateAdjacentResinRecursive(get_turf(our_core), 4)

/datum/biohazard_blob_controller/proc/TrySpreadResin(obj/structure/biohazard_blob/resin/spreaded_resin)
	. = RESIN_CANT_SPREAD
	var/turf/ownturf = get_turf(spreaded_resin)
	if(structure_progression > PROGRESSION_FOR_STRUCTURE)
		var/forbidden = FALSE
		for(var/obj/O in ownturf)
			if(istype(O, /obj/structure/biohazard_blob/structure))
				forbidden = TRUE
				break
		if(!forbidden)
			structure_progression -= PROGRESSION_FOR_STRUCTURE
			var/random = rand(1,3)
			SpawnStructureLoc(random, ownturf)

	//Check if we can attack an airlock
	for(var/a in get_adjacent_open_turfs(spreaded_resin))
		var/turf/open/open_turf = a
		for(var/obj/O in open_turf)
			if(istype(O, /obj/machinery/door/airlock) || istype(O, /obj/machinery/door/firedoor) || istype(O, /obj/machinery/door/window) || istype(O, /obj/structure/door_assembly) || istype(O, /obj/machinery/door/window))
				spreaded_resin.do_attack_animation(O, ATTACK_EFFECT_PUNCH)
				playsound(O, 'sound/effects/attackblob.ogg', 50, TRUE)
				O.take_damage(40, BRUTE, MELEE, 1, get_dir(O, spreaded_resin))
				. = RESIN_ATTACKED_DOOR
				break
		if(.)
			break

	var/list/possible_locs = list(ownturf) //Ownturf, because it could spread into the same turf, but on the wall
	for(var/T in ownturf.get_atmos_adjacent_turfs())
		//We encounter a space turf? Make a thick wall to block of that nasty vacuum
		if(isspaceturf(T))
			if(!locate(/obj/structure/biohazard_blob/structure/wall, ownturf))
				var/the_wall = new /obj/structure/biohazard_blob/structure/wall(ownturf, blob_type)
				other_structures[the_wall] = TRUE
				CALCULATE_ADJACENT_TURFS(T, NORMAL_TURF)
		else
			possible_locs += T

	for(var/T in possible_locs)
		var/turf/iterated_turf = T
		var/resinCount = 0
		var/placeCount = 1
		for(var/obj/structure/biohazard_blob/resin/potato in iterated_turf)
			resinCount++
		for(var/wallDir in GLOB.cardinals)
			var/turf/isWall = get_step(iterated_turf,wallDir)
			if(isWall.density)
				placeCount++
		if(resinCount >= placeCount)
			continue
		SpawnResin(iterated_turf)
		return RESIN_DID_SPREAD

	active_resin -= spreaded_resin
	return RESIN_CANT_SPREAD

/datum/biohazard_blob_controller/proc/SpawnResin(loc)
	//Each spawned resin gives us progression for a structure
	structure_progression++
	//On spawning effects
	for(var/obj/machinery/light/potato in loc)
		potato.break_light_tube()
	//Spawn the resin
	var/obj/structure/biohazard_blob/resin/new_resin = new /obj/structure/biohazard_blob/resin(loc, blob_type)
	new_resin.our_controller = src
	all_resin[new_resin] = TRUE
	active_resin[new_resin] = TRUE
	new_resin.CalcDir()
	our_core.max_integrity += 2
	our_core.repair_damage(2)
	return new_resin

/datum/biohazard_blob_controller/proc/ActivateAdjacentResinRecursive(turf/centrum_turf, iterations = 1)
	var/list/turfs = list()
	turfs[centrum_turf] = TRUE
	for(var/i in 1 to iterations)
		for(var/t in turfs)
			var/turf/open = t
			for(var/atmoadj in open.get_atmos_adjacent_turfs())
				turfs[atmoadj] = TRUE
	for(var/t in turfs)
		var/turf/ite_turf = t
		for(var/obj/structure/biohazard_blob/resin/potato in ite_turf)
			if(potato && potato.our_controller && potato.our_controller == src)
				active_resin[potato] = TRUE
				return

/datum/biohazard_blob_controller/proc/ActivateAdjacentResin(turf/centrum_turf)
	if(!our_core)
		//We're dead, no point in doing this
		return
	var/list/turfs = list(centrum_turf)
	for(var/t in centrum_turf.get_atmos_adjacent_turfs())
		turfs += t
	for(var/t in turfs)
		var/turf/ite_turf = t
		for(var/obj/structure/biohazard_blob/resin/potato in ite_turf)
			if(potato && potato.our_controller && potato.our_controller == src)
				active_resin[potato] = TRUE
				return

/datum/biohazard_blob_controller/process(delta_time)
	progress_to_spread++
	if(stalled && progress_to_spread < SPREAD_STALLED_PROCESS)
		return
	if(progress_to_spread < spread_delay)
		return
	stalled = FALSE
	progress_to_spread = 0

	if(!our_core)
		if(length(all_resin))
			var/obj/structure/biohazard_blob/resin/iterated_resin = pick(all_resin)
			qdel(iterated_resin)
			return
		//No structures, no core, no resin
		qdel(src)

	//No resin, but we've got a core
	if(!length(all_resin))
		SpawnResin(get_turf(our_core))
		return

	if(!length(active_resin))
		var/did_anything = FALSE
		for(var/t in all_resin)
			var/obj/structure/biohazard_blob/resin/iterated_resin = t
			var/attempt = TrySpreadResin(iterated_resin)
			switch(attempt)
				if(RESIN_DID_SPREAD, RESIN_ATTACKED_DOOR)
					active_resin[iterated_resin] = TRUE
					did_anything = TRUE
					break
		//If we didnt manage to do anything even though we iterated over all resin, stall us
		if(!did_anything)
			stalled = TRUE
		return

	for(var/t in active_resin)
		var/obj/structure/biohazard_blob/resin/active_resin = t
		var/attempt = TrySpreadResin(active_resin)
		switch(attempt)
			if(RESIN_DID_SPREAD)
				return

#undef SPREAD_PROCESS
#undef SPREAD_STALLED_PROCESS

#undef PROGRESSION_FOR_STRUCTURE
#undef PROGRESSION_RETALIATED
#undef STRUCTURE_PROGRESSION_START

#undef RESIN_CANT_SPREAD
#undef RESIN_DID_SPREAD
#undef RESIN_ATTACKED_DOOR
