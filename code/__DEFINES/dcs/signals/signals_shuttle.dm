
// Shuttle signals. this file is empty because shuttle code is ancient, feel free to
// add more signals where its appropriate to have them

/// Called when the shuttle tries to move. Do not return anything to continue with default behaviour (always allow) : ()
#define COMSIG_SHUTTLE_SHOULD_MOVE "shuttle_should_move"
	/// Return this when the shuttle move should be blocked.
	#define BLOCK_SHUTTLE_MOVE (1<<0)

//from base of /proc/expand_shuttle() : (list/turfs)
#define COMSIG_SHUTTLE_EXPANDED "shuttle_expanded"

//from base of /turf/fromShuttleMove() : (turf/new_turf, move_mode)
#define COMSIG_SHUTTLE_TURF_SHOULD_MOVE_SPECIAL "shuttle_turf_should_move_special"

//from base of /obj/docking_port/mobile/proc/takeoff() : (turf/new_turf, movement_force, movement_direction, /obj/docking_port/stationary/old_dock, /obj/docking_port/mobile/shuttle)
#define COMSIG_SHUTTLE_TURF_ON_MOVE_SPECIAL "shuttle_turf_on_move_special"
