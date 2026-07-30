SUBSYSTEM_DEF(navmesh)
	name = "Navmesh"
	ss_flags = SS_BACKGROUND
	dependencies = list(
		/datum/controller/subsystem/mapping,
	)
	/// Baseline movers used to bake static ground and flying edges.
	var/datum/can_pass_info/ground_rep
	var/datum/can_pass_info/flying_rep
	var/list/bake_queue = list()
	var/list/currentrun
	var/currentrun_index = 1
	var/list/border_blocker_cache
	var/list/mask_whitelist_cache
	var/list/force_conditional_cache
	var/list/auto_dirty_ztraits = list(ZTRAIT_STATION, ZTRAIT_MINING)
	var/list/auto_dirty_zlevels = list()
	var/list/space_type_cache

/// Initializes bake representatives, blocker caches, and existing z-level data.
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
	mask_whitelist_cache = list()
	for(var/table_type in typesof(/obj/structure/table))
		mask_whitelist_cache[table_type] = PASSTABLE
	for(var/grille_type in typesof(/obj/structure/grille))
		mask_whitelist_cache[grille_type] = PASSGRILLE
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
/// Enables automatic dirtying for a newly relevant z-level.
/datum/controller/subsystem/navmesh/proc/on_new_zlevel(datum/source, datum/space_level/new_level)
	SIGNAL_HANDLER
	for(var/trait in auto_dirty_ztraits)
		if(new_level.traits[trait])
			auto_dirty_zlevels["[new_level.z_value]"] = TRUE
			return

/// Reports the number of turfs waiting to bake.
/datum/controller/subsystem/navmesh/stat_entry(msg)
	var/pending = length(bake_queue) + max(length(currentrun) - currentrun_index + 1, 0)
	msg = "Dirty:[pending]"
	return ..()

/// Bakes queued turfs until the tick budget is exhausted.
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

/// Queues a dirty turf once for asynchronous baking.
/datum/controller/subsystem/navmesh/proc/queue_turf_bake(turf/queued_turf)
	if(queued_turf.turf_flags & NAV_QUEUED)
		return
	queued_turf.turf_flags |= NAV_QUEUED
	bake_queue += queued_turf
	if(!can_fire)
		can_fire = TRUE

/// Bakes and bulk-publishes every non-space turf on a z-level.
/datum/controller/subsystem/navmesh/proc/prebake_z(z_level)
	var/count = 0
	var/list/rust_batch = list()
	for(var/turf/baking_turf as anything in Z_TURFS(z_level))
		baking_turf.nav_bake(skip_rust_push = TRUE)
		rust_batch += list(baking_turf.x, baking_turf.y, baking_turf.z, baking_turf.nav_pass)
		count++
		CHECK_TICK
	if(length(rust_batch))
		rustg_turfmap_bulk_update(rust_batch)
	return count
