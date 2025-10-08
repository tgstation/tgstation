/// This is the main proc. Despite what the name suggests,
/// it instantly moves our mobile port to stationary port `new_dock`.
/obj/docking_port/mobile/proc/initiate_docking(obj/docking_port/stationary/new_dock, movement_direction, force=FALSE)
	// Crashing this ship with NO SURVIVORS

	if(new_dock.get_docked() == src)
		remove_ripples()
		return DOCKING_SUCCESS

	if(!force)
		if(!check_dock(new_dock))
			remove_ripples()
			return DOCKING_BLOCKED
		if(!canMove())
			remove_ripples()
			return DOCKING_IMMOBILIZED

	var/obj/docking_port/stationary/old_dock = get_docked()

	// The area that gets placed under shuttle turfs that do not have their own area to place down
	var/fallback_area_type = SHUTTLE_DEFAULT_UNDERLYING_AREA

	if(old_dock) //Dock overwrites
		fallback_area_type = old_dock.area_type

	/**************************************************************************************************************
		Both lists are associative with a turf:bitflag structure. (new_turfs bitflag space unused currently)
		The bitflag contains the data for what inhabitants of that coordinate should be moved to the new location
		The bitflags can be found in __DEFINES/shuttles.dm
	*/
	var/list/old_turfs = return_ordered_turfs(x, y, z, dir)
	var/list/new_turfs = return_ordered_turfs(new_dock.x, new_dock.y, new_dock.z, new_dock.dir)
	CHECK_TICK
	/**************************************************************************************************************/

	// The fallback area is the area for shuttle turfs that have no area underneath them
	// If it no longer/has never existed it will be created
	var/area/fallback_area = GLOB.areas_by_type[fallback_area_type]
	if(!fallback_area)
		fallback_area = new fallback_area_type(null)

	var/rotation = 0
	if(new_dock.dir != dir) //Even when the dirs are the same rotation is coming out as not 0 for some reason
		rotation = dir2angle(new_dock.dir)-dir2angle(dir)
		if ((rotation % 90) != 0)
			rotation += (rotation % 90) //diagonal rotations not allowed, round up
		rotation = SIMPLIFY_DEGREES(rotation)

	if(!movement_direction)
		movement_direction = REVERSE_DIR(preferred_direction)

	var/list/moved_atoms = list() //Everything not a turf that gets moved in the shuttle
	var/list/areas_to_move = list() //unique assoc list of areas on turfs being moved
	var/list/underlying_areas = list() //unique assoc list of areas beneath turfs being moved

	. = preflight_check(old_turfs, new_turfs, areas_to_move, underlying_areas, rotation)
	if(.)
		remove_ripples()
		return

	/*******************************************Hiding turfs if necessary*******************************************/
	// TODO: Move this somewhere sane
	var/list/new_hidden_turfs
	if(hidden)
		new_hidden_turfs = list()
		for(var/i in 1 to old_turfs.len)
			CHECK_TICK
			var/turf/oldT = old_turfs[i]
			if(old_turfs[oldT] & MOVE_TURF)
				new_hidden_turfs += new_turfs[i]
		SSshuttle.update_hidden_docking_ports(null, new_hidden_turfs)
	/***************************************************************************************************************/

	if(!force)
		if(!check_dock(new_dock))
			remove_ripples()
			return DOCKING_BLOCKED
		if(!canMove())
			remove_ripples()
			return DOCKING_IMMOBILIZED

	// Moving to the new location will trample the ripples there at the exact
	// same time any mobs there are trampled, to avoid any discrepancy where
	// the ripples go away before it is safe.
	takeoff(old_turfs, new_turfs, moved_atoms, rotation, movement_direction, old_dock, fallback_area)

	CHECK_TICK

	cleanup_runway(new_dock, old_turfs, new_turfs, areas_to_move, underlying_areas, moved_atoms, rotation, movement_direction, fallback_area)

	CHECK_TICK

	/*******************************************Unhiding turfs if necessary******************************************/
	if(new_hidden_turfs)
		SSshuttle.update_hidden_docking_ports(hidden_turfs, null)
		hidden_turfs = new_hidden_turfs
	/****************************************************************************************************************/

	check_poddoors()
	new_dock.last_dock_time = world.time
	setDir(new_dock.dir)

	// remove any stragglers just in case, and clear the list
	remove_ripples()
	return DOCKING_SUCCESS

/obj/docking_port/mobile/proc/preflight_check(list/old_turfs, list/new_turfs, list/areas_to_move, list/underlying_areas, rotation)
	for(var/i in 1 to length(old_turfs))
		CHECK_TICK
		var/turf/oldT = old_turfs[i]
		var/turf/newT = new_turfs[i]
		if(!newT)
			return DOCKING_NULL_DESTINATION
		if(!oldT)
			return DOCKING_NULL_SOURCE

		var/area/old_area = oldT.loc
		var/move_mode = old_area.beforeShuttleMove(shuttle_areas) //areas

		for(var/atom/movable/moving_atom as anything in oldT.contents)
			CHECK_TICK
			if(moving_atom.loc != oldT) //fix for multi-tile objects
				continue
			move_mode = moving_atom.beforeShuttleMove(newT, rotation, move_mode, src) //atoms

		move_mode = oldT.fromShuttleMove(newT, move_mode) //turfs
		move_mode = newT.toShuttleMove(oldT, move_mode, src) //turfs

		if(move_mode & MOVE_AREA)
			var/area/underlying_area = underlying_areas_by_turf[oldT]
			if(underlying_area)
				underlying_areas[underlying_area] = TRUE
			areas_to_move[old_area] = TRUE

		old_turfs[oldT] = move_mode

/obj/docking_port/mobile/proc/takeoff(list/old_turfs, list/new_turfs, list/moved_atoms, rotation, movement_direction, old_dock, area/fallback_area)
	for(var/i in 1 to old_turfs.len)
		var/turf/oldT = old_turfs[i]
		var/turf/newT = new_turfs[i]
		var/move_mode = old_turfs[oldT]

		if(move_mode & MOVE_TURF)
			oldT.onShuttleMove(newT, movement_force, movement_direction, move_mode & MOVE_AREA) //turfs

		if(move_mode & MOVE_AREA)
			var/area/shuttle_area = oldT.loc
			shuttle_area.onShuttleMove(oldT, newT, src, fallback_area) //areas

		if(move_mode & MOVE_CONTENTS)
			for(var/k in oldT)
				var/atom/movable/moving_atom = k
				if(moving_atom.loc != oldT) //fix for multi-tile objects
					continue
				moving_atom.onShuttleMove(newT, oldT, movement_force, movement_direction, old_dock, src) //atoms
				moved_atoms[moving_atom] = oldT


/obj/docking_port/mobile/proc/cleanup_runway(obj/docking_port/stationary/new_dock, list/old_turfs, list/new_turfs, list/areas_to_move, list/underlying_areas, list/moved_atoms, rotation, movement_direction, area/fallback_area)
	fallback_area.afterShuttleMove(0)
	for(var/i in 1 to underlying_areas.len)
		CHECK_TICK
		var/area/underlying_area = underlying_areas[i]
		underlying_area.afterShuttleMove(0)

	// Parallax handling
	// This needs to be done before the atom after move
	var/new_parallax_dir = FALSE
	if(istype(new_dock, /obj/docking_port/stationary/transit))
		new_parallax_dir = preferred_direction
	for(var/i in 1 to areas_to_move.len)
		CHECK_TICK
		var/area/internal_area = areas_to_move[i]
		internal_area.afterShuttleMove(new_parallax_dir) //areas

	for(var/i in 1 to old_turfs.len)
		CHECK_TICK
		var/turf/old_turf = old_turfs[i]
		var/old_move_mode = old_turfs[old_turf]
		var/turf/old_ceiling = get_step_multiz(old_turf, UP)
		if(old_ceiling) // check if a ceiling was generated previously
			// remove old ceiling
			if(istype(old_ceiling, /turf/open/floor/engine/hull/ceiling))
				old_ceiling.ScrapeAway()
			else
				old_ceiling.remove_baseturfs_from_typecache(list(/turf/open/floor/engine/hull/ceiling = TRUE))
		if(!(old_move_mode & MOVE_TURF))
			continue
		var/turf/new_turf = new_turfs[i]
		new_turf.afterShuttleMove(old_turf, rotation) //turfs
		var/turf/new_ceiling = get_step_multiz(new_turf, UP) // check if a ceiling is needed
		if(new_ceiling)
			// generate ceiling
			if(!(istype(new_ceiling, /turf/open/floor/engine/hull/ceiling) || new_ceiling.depth_to_find_baseturf(/turf/open/floor/engine/hull/ceiling)))
				if(istype(new_ceiling, /turf/open/openspace) || istype(new_ceiling, /turf/open/space/openspace))
					new_ceiling.place_on_top(/turf/open/floor/engine/hull/ceiling)
				else
					new_ceiling.stack_ontop_of_baseturf(/turf/open/openspace, /turf/open/floor/engine/hull/ceiling)
					new_ceiling.stack_ontop_of_baseturf(/turf/open/space/openspace, /turf/open/floor/engine/hull/ceiling)
	for(var/i in 1 to moved_atoms.len)
		CHECK_TICK
		var/atom/movable/moved_object = moved_atoms[i]
		if(QDELETED(moved_object))
			continue
		var/turf/oldT = moved_atoms[moved_object]
		moved_object.afterShuttleMove(oldT, movement_force, dir, preferred_direction, movement_direction, rotation)//atoms

	// lateShuttleMove (There had better be a really good reason for additional stages beyond this)

	fallback_area.lateShuttleMove()

	for(var/i in 1 to areas_to_move.len)
		CHECK_TICK
		var/area/internal_area = areas_to_move[i]
		internal_area.lateShuttleMove()

	for(var/i in 1 to underlying_areas.len)
		CHECK_TICK
		var/area/underlying_area = underlying_areas[i]
		underlying_area.lateShuttleMove()

	for(var/i in 1 to old_turfs.len)
		CHECK_TICK
		if(!(old_turfs[old_turfs[i]] & (MOVE_CONTENTS|MOVE_TURF)))
			continue
		var/turf/oldT = old_turfs[i]
		var/turf/newT = new_turfs[i]
		newT.lateShuttleMove(oldT)

	for(var/i in 1 to moved_atoms.len)
		CHECK_TICK
		var/atom/movable/moved_object = moved_atoms[i]
		if(QDELETED(moved_object))
			continue
		var/turf/oldT = moved_atoms[moved_object]
		moved_object.lateShuttleMove(oldT, movement_force, movement_direction)
