// nav_pass is a packed int on /turf. null means "unbaked / dirty". Cardinal dir values (1/2/4/8)
// are used directly as bit groups so we can index by dir with no lookup.

/// bits 0-3: a baseline GROUND mover can traverse the outgoing edge in this dir
#define NAV_GROUND(dir)  (dir)
/// bits 4-7: a baseline FLYING mover can traverse the outgoing edge in this dir
#define NAV_FLIGHT(dir)  ((dir) << 4)
/// bits 8-11: this outgoing edge has per-mover conditional blockers (walk nav_blockers["[dir]"])
#define NAV_COND(dir)    ((dir) << 8)
/// set once a turf has been baked, so "baked but every edge blocked" (value could be 0) is
/// distinguishable from null (unbaked). Always OR'd in by nav_bake().
#define NAV_BAKED        (1 << 12)

/// pass_flags bits that are NOT passability grants and must be stripped when we build a blocker mask
#define NAV_NON_PASS_FLAGS (LETPASSTHROW | LETPASSCLICKS)

///returns TRUE if this movable should affect the turfs navigatable status
#define NAV_RELEVANT(AM) (!((AM).flags_1 & NAV_IRRELEVANT_1) && ((AM).density || (AM).can_astar_pass != CANASTARPASS_DENSITY))

/// Movement class selector for a baked bit given a can_pass_info's movement_type.
#define NAV_CLASS_BIT(pass_info, dir) (((pass_info).movement_type & MOVETYPES_NOT_TOUCHING_GROUND) ? NAV_FLIGHT(dir) : NAV_GROUND(dir))

// --- hot-path query macros ----------------------------------------------------------------------
// Pathfinding touches these once per neighbour per expanded node, so they (including the rare
// conditional-entry walk, formerly the nav_edge_cond proc) are inlined to dodge proc call overhead.

/// TRUE if the mover is in a movement class that reads the flight bits. Compute ONCE per search.
#define NAV_IS_FLYING(pass_info) (((pass_info).movement_type & MOVETYPES_NOT_TOUCHING_GROUND) ? TRUE : FALSE)
/// The class bit for a dir given a precomputed is_flying flag (no movement_type re-read).
#define NAV_CLASS_BIT_FAST(dir, is_flying) ((is_flying) ? NAV_FLIGHT(dir) : NAV_GROUND(dir))

/// Statement macro: ensure a turf's edges are baked before its bits are read.
#define NAV_ENSURE_BAKED(T) if(isnull((T).nav_pass)) { (T).nav_bake(); }

/// Statement macro: sets `result` TRUE iff a mover can step from an ALREADY-BAKED turf T in cardinal
/// `dir`. An edge is open iff its movement-class bit is set and, when the edge is conditional, every
/// blocker entry on it permits the mover (numeric entries are a pass_flags bit-test; atom entries are
/// evaluated live via CanAStarPass, source-side with the forward dir and dest-side with the reverse
/// dir, mirroring LinkBlockedWithAccess in code/__HELPERS/paths/path.dm). `is_flying` is the
/// precomputed NAV_IS_FLYING(pass_info).
#define NAV_EDGE_OPEN_BAKED(T, dir, is_flying, pass_info, result) \
	do { \
		result = ((T).nav_pass & NAV_CLASS_BIT_FAST((dir), (is_flying))) ? TRUE : FALSE; \
		if(result && ((T).nav_pass & NAV_COND(dir))) { \
			for(var/_navec_entry in (T).nav_blockers?["[(dir)]"]) { \
				if(isnum(_navec_entry)) { \
					if(!((pass_info).pass_flags & _navec_entry)) { \
						result = FALSE; \
						break; \
					} \
				} else { \
					var/atom/movable/_navec_blocker = _navec_entry; \
					var/_navec_eval_dir = (_navec_blocker.loc == (T)) ? (dir) : REVERSE_DIR(dir); \
					if(!_navec_blocker.CanAStarPass(_navec_eval_dir, (pass_info))) { \
						result = FALSE; \
						break; \
					} \
				} \
			} \
		} \
	} while(FALSE)

/// Integer octile heuristic scaled to step costs (cardinal 10, diagonal 14).
#define NAV_HEURISTIC(a, b) (10 * (abs((a).x - (b).x) + abs((a).y - (b).y)) - 6 * min(abs((a).x - (b).x), abs((a).y - (b).y)))

/// Statement macro: sets `result` TRUE iff a diagonal step from ALREADY-BAKED `origin` in composite
/// `dir` can round the corner, i.e. at least one of the two L-routes is clear (both cardinal hops
/// traversable). Bakes the midstep turfs as needed. Mirrors the corner rule in LinkBlockedWithAccess
/// (code/__HELPERS/paths/path.dm) so generated paths are actually walkable. `_nav_mid`/`_nav_edge_ok`
/// are scratch.
#define NAV_DIAGONAL_OPEN(origin, dir, is_flying, pass_info, result) \
	do { \
		result = FALSE; \
		var/_nav_ns = (dir) & (NORTH | SOUTH); \
		var/_nav_ew = (dir) & (EAST | WEST); \
		var/turf/_nav_mid; \
		var/_nav_edge_ok; \
		NAV_EDGE_OPEN_BAKED(origin, _nav_ns, is_flying, pass_info, _nav_edge_ok); \
		if(_nav_edge_ok) { \
			_nav_mid = get_step(origin, _nav_ns); \
			if(_nav_mid) { \
				NAV_ENSURE_BAKED(_nav_mid); \
				NAV_EDGE_OPEN_BAKED(_nav_mid, _nav_ew, is_flying, pass_info, _nav_edge_ok); \
				if(_nav_edge_ok) { result = TRUE; } \
			} \
		} \
		if(!result) { \
			NAV_EDGE_OPEN_BAKED(origin, _nav_ew, is_flying, pass_info, _nav_edge_ok); \
			if(_nav_edge_ok) { \
				_nav_mid = get_step(origin, _nav_ew); \
				if(_nav_mid) { \
					NAV_ENSURE_BAKED(_nav_mid); \
					NAV_EDGE_OPEN_BAKED(_nav_mid, _nav_ns, is_flying, pass_info, _nav_edge_ok); \
					if(_nav_edge_ok) { result = TRUE; } \
				} \
			} \
		} \
	} while(FALSE)

// --- JPS-over-navmesh step macros ---------------------------------------------------------------
// These are the navmesh equivalents of jps.dm's CAN_STEP / STEP_NOT_HERE_BUT_THERE / TURF_CANT_WE_CAN.
// They are DIRECTION-based (the JPS originals pass a pre-stepped `next` turf; here we pass the dir and
// let nav_can_step read the cached bit). Used only inside /datum/nav_jps procs, which expose `is_flying`
// and `pass_info` as locals, so the macros reference those names directly like the JPS macros do.

/// Statement macro: sets `result` TRUE iff the mover can step from `cur_turf` in cardinal or diagonal
/// `dir` to the given `dest` turf, reading cached bits (bakes lazily). Handles space exclusion and
/// diagonal corner-rounding. Inlined (rather than a /turf/proc) to dodge the proc call in the JPS
/// inner loop, same reasoning as NAV_DIAGONAL_OPEN above.
#define NAV_CAN_STEP_TO(cur_turf, dir, dest, result) \
	do { \
		result = FALSE; \
		var/turf/_navcs_cur = (cur_turf); \
		var/turf/_navcs_dest = (dest); \
		if(_navcs_cur && _navcs_dest && !SSpathfinder.space_type_cache[_navcs_dest.type]) { \
			NAV_ENSURE_BAKED(_navcs_cur); \
			if((dir) & ((dir) - 1)) { \
				NAV_DIAGONAL_OPEN(_navcs_cur, (dir), is_flying, pass_info, result); \
			} else { \
				NAV_EDGE_OPEN_BAKED(_navcs_cur, (dir), is_flying, pass_info, result); \
			} \
		} \
	} while(FALSE)
/// Statement macro: sets `result` TRUE for a forced-neighbour test - we canNOT step `dirA` but we CAN
/// step `dirB` from cur_turf. `destA` is the already-known destination of `dirA` from cur_turf (e.g. a
/// cached cardinal neighbour), so that leg skips its get_step(). Short-circuits like the `&&` it replaces.
#define NAV_STEP_NOT_HERE_BUT_THERE_TO(cur_turf, dirA, destA, dirB, result) \
	do { \
		NAV_CAN_STEP_TO((cur_turf), (dirA), (destA), result); \
		if(!result) { \
			NAV_CAN_STEP_TO((cur_turf), (dirB), get_step((cur_turf), (dirB)), result); \
		} else { \
			result = FALSE; \
		} \
	} while(FALSE)
/// Statement macro: sets `result` TRUE for a forced-neighbour test - a border stops our parent reaching
/// a turf we can reach. `dest_cur` is the already-known destination of `dir_cur` from cur_turf (e.g. a
/// cached cardinal neighbour), so that leg skips its get_step(). Short-circuits like the `&&` it replaces.
#define NAV_TURF_CANT_WE_CAN_TO(parent_turf, dir_parent, cur_turf, dir_cur, dest_cur, result) \
	do { \
		NAV_CAN_STEP_TO((parent_turf), (dir_parent), get_step((parent_turf), (dir_parent)), result); \
		if(!result) { \
			NAV_CAN_STEP_TO((cur_turf), (dir_cur), (dest_cur), result); \
		} else { \
			result = FALSE; \
		} \
	} while(FALSE)
