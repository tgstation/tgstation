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
/// set when this turf is simulated (atmos)
#define NAV_SIMULATED    (1 << 13)

/// pass_flags bits that are NOT passability grants and must be stripped when we build a blocker mask
#define NAV_NON_PASS_FLAGS (LETPASSTHROW | LETPASSCLICKS)

///returns TRUE if this movable should affect the turfs navigatable status
#define NAV_RELEVANT(AM) (!((AM).flags_1 & NAV_IRRELEVANT_1) && ((AM).density || (AM).can_astar_pass != CANASTARPASS_DENSITY))

/// Movement class selector for a baked bit given a can_pass_info's movement_type.
#define NAV_CLASS_BIT(pass_info, dir) (((pass_info).movement_type & MOVETYPES_NOT_TOUCHING_GROUND) ? NAV_FLIGHT(dir) : NAV_GROUND(dir))



// Pathfinding touches these once per neighbour per expanded node, so they (including the rarer
// conditional-entry walk) are inlined to dodge proc call overhead.

/// TRUE if the mover is in a movement class that reads the flight bits. Compute ONCE per search.
#define NAV_IS_FLYING(pass_info) (((pass_info).movement_type & MOVETYPES_NOT_TOUCHING_GROUND) ? TRUE : FALSE)
/// The class bit for a dir given a precomputed is_flying flag (no movement_type re-read).
#define NAV_CLASS_BIT_FAST(dir, is_flying) ((is_flying) ? NAV_FLIGHT(dir) : NAV_GROUND(dir))

/// Statement macro: ensure a turf's edges are baked before its bits are read.
#define NAV_ENSURE_BAKED(T) if(isnull((T).nav_pass)) { (T).nav_bake(); }
/// Sets result when a baked cardinal edge admits this mover.
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
/// Octile distance scaled to cardinal and diagonal movement costs.
#define NAV_HEURISTIC(a, b) (10 * (abs((a).x - (b).x) + abs((a).y - (b).y)) - 6 * min(abs((a).x - (b).x), abs((a).y - (b).y)))
/// Sets result when either cardinal route around a diagonal corner is open.
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


/// Sets result when a cardinal or diagonal step is passable.
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

/// Sets result when the first step is blocked and the second is open.
#define NAV_STEP_NOT_HERE_BUT_THERE_TO(cur_turf, dirA, destA, dirB, result) \
	do { \
		NAV_CAN_STEP_TO((cur_turf), (dirA), (destA), result); \
		if(!result) { \
			NAV_CAN_STEP_TO((cur_turf), (dirB), get_step((cur_turf), (dirB)), result); \
		} else { \
			result = FALSE; \
		} \
	} while(FALSE)

/// Sets result when the parent cannot reach a tile that the current turf can.
#define NAV_TURF_CANT_WE_CAN_TO(parent_turf, dir_parent, cur_turf, dir_cur, dest_cur, result) \
	do { \
		NAV_CAN_STEP_TO((parent_turf), (dir_parent), get_step((parent_turf), (dir_parent)), result); \
		if(!result) { \
			NAV_CAN_STEP_TO((cur_turf), (dir_cur), (dest_cur), result); \
		} else { \
			result = FALSE; \
		} \
	} while(FALSE)
