SUBSYSTEM_DEF(navmesh)
	name = "Navmesh"
	ss_flags = SS_BACKGROUND
	dependencies = list(
		/datum/controller/subsystem/mapping,
	)

	/// GROUND mover representative: no pass_flags, no access, no id. Used to bake the static ground bit.
	var/datum/can_pass_info/ground_rep
	/// FLYING mover representative. Used to bake the static flight bit.
	var/datum/can_pass_info/flying_rep

	/// FIFO queue of turfs awaiting nav_bake()
	var/list/bake_queue = list()
	/// Working batch to run through
	var/list/currentrun
	/// Index into currentrun of the next turf to bake.
	var/currentrun_index = 1

	/// Border/directional blocker types we care about
	var/list/border_blocker_cache
	/// Types whose CanAStarPass gate is a single pass_flag, representable as a plain bitmask entry
	var/list/mask_whitelist_cache
	/// Types whose CanAStarPass depends on the mover but arent simple, so they need actual atom refs to process
	var/list/force_conditional_cache

	///Z-traits we care about and automatically update
	var/list/auto_dirty_ztraits = list(ZTRAIT_STATION, ZTRAIT_MINING)
	///All zlevels we care about (filled with previous vars)
	var/list/auto_dirty_zlevels = list()

	///Space turfs are never prebaked - nothing meaningfully paths through open space
	var/list/space_type_cache

	/// If TRUE, A* cross-checks every cached edge verdict against LinkBlockedWithAccess and CRASHes
	/// on mismatch. Expensive; for catching stale-cache / classification bugs during testing.
	var/validate_against_jps = FALSE

/datum/controller/subsystem/navmesh/Initialize()
	ground_rep = new /datum/can_pass_info(null, null, no_id = TRUE)
	ground_rep.movement_type = GROUND

	flying_rep = new /datum/can_pass_info(null, null, no_id = TRUE)
	flying_rep.movement_type = FLYING

	border_blocker_cache = typecacheof(list(
		/obj/structure/window,
		/obj/machinery/door/window,
		/obj/structure/railing,
		/obj/machinery/door/firedoor/border_only,
	))
	// type -> exact honoured pass_flag, expanded over subtypes.
	mask_whitelist_cache = list()
	for(var/table_type in typesof(/obj/structure/table))
		mask_whitelist_cache[table_type] = PASSTABLE
	for(var/grille_type in typesof(/obj/structure/grille))
		mask_whitelist_cache[grille_type] = PASSGRILLE

	// Dense, mover-dependent, but no pass_flags_self / not a door: the heuristic would bake them as
	// plain walls. girder honours PASSGRILLE; thing_boss_spike checks requester type.
	force_conditional_cache = typecacheof(list(
		/obj/structure/girder,
		/obj/structure/thing_boss_spike,
	))

	space_type_cache = typecacheof(/turf/open/space)

	for(var/z in 1 to world.maxz)
		prebake_z(z)

	for(var/z in SSmapping.levels_by_any_trait(auto_dirty_ztraits))
		auto_dirty_zlevels["[z]"] = TRUE
	RegisterSignal(SSdcs, COMSIG_GLOB_NEW_Z, PROC_REF(on_new_zlevel))

	return SS_INIT_SUCCESS

///Mark new z-levels as potentially auto-dirty
/datum/controller/subsystem/navmesh/proc/on_new_zlevel(datum/source, datum/space_level/new_level)
	SIGNAL_HANDLER
	for(var/trait in auto_dirty_ztraits)
		if(new_level.traits[trait])
			auto_dirty_zlevels["[new_level.z_value]"] = TRUE
			return

/datum/controller/subsystem/navmesh/stat_entry(msg)
	var/pending = length(bake_queue) + max(length(currentrun) - currentrun_index + 1, 0)
	msg = "Dirty:[pending]"
	return ..()

/datum/controller/subsystem/navmesh/fire(resumed)
	if(currentrun_index > length(currentrun))
		if(!length(bake_queue))
			can_fire = FALSE
			return
		currentrun = bake_queue
		bake_queue = list()
		currentrun_index = 1

	while(currentrun_index <= length(currentrun))
		var/turf/baking_turf = currentrun[currentrun_index]
		currentrun_index++
		if(!QDELETED(baking_turf))
			baking_turf.turf_flags &= ~NAV_QUEUED
			baking_turf.nav_bake()
		if(MC_TICK_CHECK)
			return

///Queue up a turf to be baked since its dirty!
/datum/controller/subsystem/navmesh/proc/queue_turf_bake(turf/queued_turf)
	if(queued_turf.turf_flags & NAV_QUEUED)
		return
	queued_turf.turf_flags |= NAV_QUEUED
	bake_queue += queued_turf
	if(!can_fire)
		can_fire = TRUE

///Bake every non-space turf on a z-level. NOT queued so dont just run this please.
/datum/controller/subsystem/navmesh/proc/prebake_z(z_level)
	var/count = 0
	for(var/turf/baking_turf as anything in Z_TURFS(z_level))
		if(space_type_cache[baking_turf.type])
			continue
		baking_turf.nav_bake()
		count++
		CHECK_TICK
	return count
