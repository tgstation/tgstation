/**
 * Holds the shared state for the experimental turf navmesh: the baseline "representative" pass_infos
 * used to bake static passability bits, the typecaches the bake consults, and stats counters for
 * benchmarking against JPS. Station z-levels are eagerly baked in full at Initialize(); every other
 * turf (plus anything /turf/proc/nav_dirty() marks stale afterwards) goes into a FIFO bake_queue that
 * fire() drains within the per-tick budget.
 */
SUBSYSTEM_DEF(navmesh)
	name = "Navmesh"
	ss_flags = SS_BACKGROUND
	dependencies = list(
		/datum/controller/subsystem/mapping,
	)

	/// Representative GROUND mover: no pass_flags, no access, no id. Used to bake the static ground bit.
	var/datum/can_pass_info/ground_rep
	/// Representative FLYING mover. Used to bake the static flight bit.
	var/datum/can_pass_info/flying_rep

	/// FIFO queue of turfs awaiting nav_bake(): non-station turfs queued at init, plus anything
	/// nav_dirty() marks stale afterwards. Appended to at the tail; drained via currentrun below.
	var/list/bake_queue = list()
	/// Working batch popped off the front of bake_queue, walked by index rather than Cut() so draining
	/// a batch is O(1) per turf instead of O(n). Refilled from bake_queue once exhausted.
	var/list/currentrun
	/// Index into currentrun of the next turf to bake.
	var/currentrun_index = 1

	/// Border/directional blocker types. Mirrors path.dm's directional_blocker_cache. On the SOURCE
	/// turf we only consider these types (a wall on our north edge is one of these); everything else
	/// on our own tile doesn't block leaving.
	var/list/border_blocker_cache
	/// Types whose CanAStarPass gate is a single pass_flag, representable as a plain bitmask entry
	/// (fast path, no proc call at query time). Assoc: type -> the exact pass_flag the atom honours.
	/// Note this is NOT pass_flags_self (e.g. a grille's pass_flags_self includes PASSWINDOW but its
	/// CanAStarPass only honours PASSGRILLE), so the masks are stated explicitly.
	var/list/mask_whitelist_cache
	/// Escape hatch: types whose CanAStarPass depends on the mover but which the conditional heuristic
	/// (pass_flags_self / door / ALWAYS_PROC) would miss, so must be stored as live atom entries.
	var/list/force_conditional_cache

	// --- stats (for benchmarking / debugging) ---
	/// How many turf edge-sets we have baked total.
	var/bakes = 0
	/// How many nav_dirty() calls have happened.
	var/dirties = 0
	/// How many live conditional-entry evaluations A* has performed.
	var/cond_evaluations = 0

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

	// Station z-levels matter immediately (mobs pathing at roundstart), so bake them in full up front.
	var/list/station_zs = SSmapping.levels_by_trait(ZTRAIT_STATION)
	for(var/z in station_zs)
		prebake_z(z)

	// Everything else (lavaland, mining outposts, space, ruins, ...) is baked lazily in the background:
	// queue every turf that wasn't just covered above and let fire() drain it within budget.
	for(var/z in 1 to world.maxz)
		if(z in station_zs)
			continue
		for(var/turf/queued_turf as anything in Z_TURFS(z))
			queue_turf_bake(queued_turf)
		CHECK_TICK

	return SS_INIT_SUCCESS

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

/**
 * Appends a turf to the FIFO bake queue if it isn't already pending. Safe to call repeatedly (e.g.
 * from nav_dirty()); duplicate enqueues are no-ops until the turf is actually baked.
 */
/datum/controller/subsystem/navmesh/proc/queue_turf_bake(turf/queued_turf)
	if(queued_turf.turf_flags & NAV_QUEUED)
		return
	queued_turf.turf_flags |= NAV_QUEUED
	bake_queue += queued_turf
	if(!can_fire)
		can_fire = TRUE

/**
 * Eagerly bake every turf on the given z-level, warming the cache. Invalidation stays lazy; this
 * just lets us compare cold-query vs warm-query cost. Returns the number of turfs baked.
 */
/datum/controller/subsystem/navmesh/proc/prebake_z(z_level)
	var/count = 0
	for(var/turf/baking_turf as anything in Z_TURFS(z_level))
		baking_turf.nav_bake()
		count++
		CHECK_TICK
	return count
