/**
 * Holds the shared state for the experimental turf navmesh: the baseline "representative" pass_infos
 * used to bake static passability bits, the typecaches the bake consults, and stats counters for
 * benchmarking against JPS. It does not fire; invalidation is lazy (see /turf/proc/nav_dirty). The
 * subsystem is the natural home for an eventual eager pre-bake / rebuild queue.
 */
SUBSYSTEM_DEF(navmesh)
	name = "Navmesh"
	ss_flags = SS_NO_FIRE

	/// Representative GROUND mover: no pass_flags, no access, no id. Used to bake the static ground bit.
	var/datum/can_pass_info/ground_rep
	/// Representative FLYING mover. Used to bake the static flight bit.
	var/datum/can_pass_info/flying_rep

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

	return SS_INIT_SUCCESS

/datum/controller/subsystem/navmesh/stat_entry(msg)
	msg = "B:[bakes] D:[dirties] C:[cond_evaluations]"
	return ..()

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
