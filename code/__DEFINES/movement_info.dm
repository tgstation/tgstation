#define ACTIVE_MOVEMENT_OLDLOC 1
#define ACTIVE_MOVEMENT_DIRECTION 2
#define ACTIVE_MOVEMENT_FORCED 3
#define ACTIVE_MOVEMENT_OLDLOCS 4

/// The arguments of this macro correspond directly to the argument order of /atom/movable/proc/Moved
#define SET_ACTIVE_MOVEMENT(_old_loc, _direction, _forced, _oldlocs) \
	active_movement = list( \
		_old_loc, \
		_direction, \
		_forced, \
		_oldlocs, \
	)

/// Finish any active movements
#define RESOLVE_ACTIVE_MOVEMENT \
	if(active_movement) { \
		var/__move_args = active_movement; \
		active_movement = null; \
		Moved(arglist(__move_args)); \
	}

/// Finish an active movement between areas, which enters the new area right before its Moved()
#define RESOLVE_ACTIVE_AREA_MOVEMENT(_new_area, _entered_arg) \
	if(active_movement) { \
		var/__move_args = active_movement; \
		active_movement = null; \
		_new_area.Entered(src, _entered_arg); \
		Moved(arglist(__move_args)); \
	}

/// A movement started from inside our last one's callbacks finishes that one first, area entry included
#define RESOLVE_INTERRUPTED_MOVEMENT \
	if(active_movement) { \
		finish_interrupted_movement(); \
	}
