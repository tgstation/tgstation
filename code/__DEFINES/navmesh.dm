/*
 * Navmesh: cached per-turf directional passability.
 *
 * Experimental, additive-only alternative to querying LinkBlockedWithAccess() per step during
 * pathfinding. Each turf caches, per cardinal direction, whether a baseline GROUND / FLYING mover
 * can leave that turf in that direction, plus a "conditional" bit meaning "there are blockers on
 * this edge that must be evaluated per-mover" (access doors, pass-flag gated statics like tables).
 *
 * Deliberate divergences from JPS, documented here and enforced in the bake:
 * - Mobs are never baked into the mesh (they move constantly and would thrash invalidation). The
 *   mover resolves live mobs at execution time (bump / wait / repath).
 * - Single-z, exactly like JPS.
 */

// --- nav_pass bit layout ------------------------------------------------------------------------
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

/// TRUE if this movable can affect the navmesh. Mobs are excluded by design. An atom matters if it
/// is dense, has pass_flags_self (border/gated statics), or forces the CanAStarPass proc to run.
#define NAV_RELEVANT(AM) (!ismob(AM) && ((AM).density || (AM).pass_flags_self || (AM).can_astar_pass != CANASTARPASS_DENSITY))

/// Movement class selector for a baked bit given a can_pass_info's movement_type.
#define NAV_CLASS_BIT(pass_info, dir) (((pass_info).movement_type & MOVETYPES_NOT_TOUCHING_GROUND) ? NAV_FLIGHT(dir) : NAV_GROUND(dir))

// --- hot-path query macros ----------------------------------------------------------------------
// Pathfinding touches these once per neighbour per expanded node, so they are inlined to dodge proc
// call overhead. The rare conditional-entry walk stays a proc (nav_edge_cond).

/// TRUE if the mover is in a movement class that reads the flight bits. Compute ONCE per search.
#define NAV_IS_FLYING(pass_info) (((pass_info).movement_type & MOVETYPES_NOT_TOUCHING_GROUND) ? TRUE : FALSE)
/// The class bit for a dir given a precomputed is_flying flag (no movement_type re-read).
#define NAV_CLASS_BIT_FAST(dir, is_flying) ((is_flying) ? NAV_FLIGHT(dir) : NAV_GROUND(dir))

/// Statement macro: ensure a turf's edges are baked before its bits are read.
#define NAV_ENSURE_BAKED(T) if(isnull((T).nav_pass)) { (T).nav_bake(); }

/// Boolean expression: can a mover step from an ALREADY-BAKED turf T in cardinal `dir`? An edge is
/// open iff its movement-class bit is set and, when the edge is conditional, the per-mover entry
/// walk permits it. `is_flying` is the precomputed NAV_IS_FLYING(pass_info).
#define NAV_EDGE_OPEN_BAKED(T, dir, is_flying, pass_info) ( \
	((T).nav_pass & NAV_CLASS_BIT_FAST(dir, is_flying)) && \
	(!((T).nav_pass & NAV_COND(dir)) || (T).nav_edge_cond((dir), (pass_info))) \
)

/// Integer octile heuristic scaled to step costs (cardinal 10, diagonal 14).
#define NAV_HEURISTIC(a, b) (10 * (abs((a).x - (b).x) + abs((a).y - (b).y)) - 6 * min(abs((a).x - (b).x), abs((a).y - (b).y)))

/// Statement macro: sets `result` TRUE iff a diagonal step from ALREADY-BAKED `origin` in composite
/// `dir` can round the corner, i.e. at least one of the two L-routes is clear (both cardinal hops
/// traversable). Bakes the midstep turfs as needed. Mirrors the corner rule in LinkBlockedWithAccess
/// (code/__HELPERS/paths/path.dm) so generated paths are actually walkable. `_nav_mid` is a scratch.
#define NAV_DIAGONAL_OPEN(origin, dir, is_flying, pass_info, result) \
	do { \
		result = FALSE; \
		var/_nav_ns = (dir) & (NORTH | SOUTH); \
		var/_nav_ew = (dir) & (EAST | WEST); \
		var/turf/_nav_mid; \
		if(NAV_EDGE_OPEN_BAKED(origin, _nav_ns, is_flying, pass_info)) { \
			_nav_mid = get_step(origin, _nav_ns); \
			if(_nav_mid) { \
				NAV_ENSURE_BAKED(_nav_mid); \
				if(NAV_EDGE_OPEN_BAKED(_nav_mid, _nav_ew, is_flying, pass_info)) { result = TRUE; } \
			} \
		} \
		if(!result && NAV_EDGE_OPEN_BAKED(origin, _nav_ew, is_flying, pass_info)) { \
			_nav_mid = get_step(origin, _nav_ew); \
			if(_nav_mid) { \
				NAV_ENSURE_BAKED(_nav_mid); \
				if(NAV_EDGE_OPEN_BAKED(_nav_mid, _nav_ns, is_flying, pass_info)) { result = TRUE; } \
			} \
		} \
	} while(FALSE)

// --- JPS-over-navmesh step macros ---------------------------------------------------------------
// These are the navmesh equivalents of jps.dm's CAN_STEP / STEP_NOT_HERE_BUT_THERE / TURF_CANT_WE_CAN.
// They are DIRECTION-based (the JPS originals pass a pre-stepped `next` turf; here we pass the dir and
// let nav_can_step read the cached bit). Used only inside /datum/nav_jps procs, which expose `is_flying`
// and `pass_info` as locals, so the macros reference those names directly like the JPS macros do.

/// TRUE if the mover can step from `cur_turf` in cardinal or diagonal `dir` to the given `dest` turf,
/// reading cached bits (bakes lazily). Handles space exclusion and diagonal corner-rounding inside
/// nav_can_step_to.
#define NAV_CAN_STEP_TO(cur_turf, dir, dest) ((cur_turf) && (cur_turf).nav_can_step_to((dir), (dest), is_flying, pass_info))
/// Forced-neighbour test: we canNOT step `dirA` but we CAN step `dirB` from cur_turf. `destA` is the
/// already-known destination of `dirA` from cur_turf (e.g. a cached cardinal neighbour), so that leg
/// skips its get_step().
#define NAV_STEP_NOT_HERE_BUT_THERE_TO(cur_turf, dirA, destA, dirB) (!NAV_CAN_STEP_TO(cur_turf, dirA, destA) && NAV_CAN_STEP_TO(cur_turf, dirB, get_step((cur_turf), (dirB))))
/// Forced-neighbour test: a border stops our parent reaching a turf we can reach. `dest_cur` is the
/// already-known destination of `dir_cur` from cur_turf (e.g. a cached cardinal neighbour), so that leg
/// skips its get_step().
#define NAV_TURF_CANT_WE_CAN_TO(parent_turf, dir_parent, cur_turf, dir_cur, dest_cur) (!NAV_CAN_STEP_TO(parent_turf, dir_parent, get_step((parent_turf), (dir_parent))) && NAV_CAN_STEP_TO(cur_turf, dir_cur, dest_cur))
