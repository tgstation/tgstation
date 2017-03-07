var/datum/subsystem/gravity/SSgravity

/datum/subsystem/gravity
	name = "Gravity"
	priority = 75
	wait = 1
	init_order = -100
	flags = SS_KEEP_TIMING | SS_BACKGROUND

	var/mob_base_gravity_slip_chance = 10
	var/mob_base_gravity_fall_chance = 5
	var/mob_handhold_gravity_slip_chance = 10
	var/mob_handhold_gravity_fall_chance = 3
	var/mob_gravity_strength_slip_mod = 3
	var/mob_gravity_strength_fall_mod = 1.5
	var/mob_slip_chance = 70
	var/legacy_gravity = FALSE
	var/list/currentrun = list()
	var/list/currentrun_manual = list()
	var/recalculation_cost = 0
	var/do_purge = FALSE
	var/purge_interval = 600
	var/purge_tick = 0
	var/purging = FALSE
	var/error_no_atom = 0
	var/error_mismatched_area = 0
	var/error_mismatched_turf = 0
	var/error_no_area = 0
	var/error_no_turf = 0
	var/list/gravgens
	var/list/purging_atoms
	var/list/atoms_forced_gravity_processing
	var/static/list/area_blacklist_typecache = typecacheof(list(/area/lavaland, /area/mine, /area/centcom))
	var/inited_atoms = 0
	var/inited_areas = 0
	var/init_state = 0

/datum/subsystem/gravity/New()
	NEW_SS_GLOBAL(SSgravity)

/datum/subsystem/gravity/proc/init_lists()
	gravgens = list()
	purging_atoms = list()
	atoms_forced_gravity_processing = list()

/datum/subsystem/gravity/Initialize()
	init_state = 1
	init_lists()
	inited_atoms = 0
	for(var/atom/movable/A in world)
		A.init_gravity()
		inited_atoms++
		CHECK_TICK
	for(var/area/A in world)
		A.init_gravity()
		inited_areas++
		CHECK_TICK
	testing("Initialized gravity for [inited_atoms] movable atoms and [inited_areas] areas!")
	. = ..()

/datum/subsystem/gravity/Recover()
	init_lists()
	do_purge = SSgravity.do_purge
	purge_interval = SSgravity.purge_interval
	error_no_atom = SSgravity.error_no_atom
	error_mismatched_area = SSgravity.error_mismatched_area
	error_mismatched_turf = SSgravity.error_mismatched_turf
	error_no_area = SSgravity.error_no_area
	error_no_turf = SSgravity.error_no_turf

/datum/subsystem/gravity/proc/reset_gravity_processing()
	var/count = 0
	var/can_fire_old = can_fire
	can_fire = FALSE
	while(atoms_forced_gravity_processing.len)
		var/atom/movable/AM = atoms_forced_gravity_processing[atoms_forced_gravity_processing.len]
		atoms_forced_gravity_processing.len--
		if(!istype(AM))
			SSgravity.error_no_atom++
			continue
		else
			AM.force_gravity_processing = FALSE
			count++
		CHECK_TICK
	LAZYCLEARLIST(atoms_forced_gravity_processing)
	var/atoms_not_found = "ERROR: NO SUBSYSTEM!"
	if(SSgravity)
		atoms_not_found = SSgravity.error_no_atom
	can_fire = can_fire_old
	return "[count] atoms purged from forced processing! [atoms_not_found] things found so far that were not atoms!"

/datum/subsystem/gravity/proc/recalculate_atoms()
	currentrun = list()
	currentrun_manual = list()
	var/tempcost = REALTIMEOFDAY
	for(var/I in sortedAreas)
		var/area/A = I
		if(!A.has_gravity && !A.gravity_generator && !A.gravity_overriding)
			continue
		if(!A.gravity_direction)	//Right now we don't need this.
			continue
		if(is_type_in_typecache(A, area_blacklist_typecache))
			continue
		currentrun += A.contents_affected_by_gravity
	currentrun_manual = atoms_forced_gravity_processing.Copy()
	recalculation_cost = REALTIMEOFDAY - tempcost

/datum/subsystem/gravity/fire(resumed = FALSE)
	if(!resumed)
		if(legacy_gravity)
			can_fire = FALSE
			return FALSE
		recalculate_atoms()
		if(do_purge)
			purging = FALSE
			purge_tick++
			if(purge_tick >= purge_interval)
				LAZYCLEARLIST(src.purging_atoms)
				purging = TRUE
				purge_tick = 0
	var/list/currentrun_manual = src.currentrun_manual
	var/list/purging_atoms = src.purging_atoms
	var/list/currentrun = src.currentrun
	while(currentrun_manual.len)
		var/atom/movable/AM = currentrun_manual[currentrun_manual.len]
		currentrun_manual.len--
		if(istype(AM))
			AM.gravity_tick += wait
			if(AM.gravity_tick >= AM.gravity_speed)
				AM.manual_gravity_process()
				AM.gravity_tick = 0
		else
			error_no_atom++
		if(purging && do_purge)
			purging_atoms += AM
		if(MC_TICK_CHECK)
			return
	while(currentrun.len)
		var/atom/movable/AM = currentrun[currentrun.len]
		currentrun.len--
		if(AM && !AM.force_gravity_processing)
			AM.gravity_tick += wait
			if(AM.gravity_tick >= AM.gravity_speed)
				AM.gravity_act()
				AM.gravity_tick = 0
		if(purging && do_purge)	//Only do laggy shit occasionally.
			purging_atoms += AM
		if(MC_TICK_CHECK)
			return
	if(purging && do_purge)
		while(purging_atoms.len)
			var/atom/movable/AM = purging_atoms[purging_atoms.len]
			purging_atoms.len--
			if(AM.gravity_ignores_turfcheck || isturf(AM.loc))
				var/current_area = get_area(AM)
				if(AM.current_gravity_area)
					if(AM.current_gravity_area != current_area)
						error_mismatched_area++
						AM.sync_gravity()
				else
					error_no_area++
					AM.sync_gravity()
			else
				error_no_turf++
				if(AM.current_gravity_area)
					AM.current_gravity_area.update_gravity(AM, FALSE)
				AM.sync_gravity()
