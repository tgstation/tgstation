/**
 * A simple-ish component that reflects the icons of movables on the parent like a mirror.
 * Sadly, there's no easy way to make the SOUTH dir reflection flip the visual so that you can see
 * the back NORTH dir of a target while it's facing SOUTH beside adding the VIS_INHERIT_DIR flag
 * to the target movable, which I'm not doing to spare eventual issues with other vis overlays in the future.
 */
/datum/component/reflection
	/**
	 * The direction from which the component gets its visual overlays.
	 * The visuals are also flipped horizontally or vertically based on it.
	 */
	var/reflected_dir
	/// the movable which the reflected movables are attached to, in turn added to the vis contents of the parent.
	var/atom/movable/reflection_holder
	/// A lazy assoc list that keeps track of which movables are being reflected and the associated reflections.
	var/list/reflected_movables
	/// A callback used check to know which movables should be reflected and which not.
	var/datum/callback/can_reflect
	///the base matrix used by reflections
	var/matrix/reflection_matrix
	///the filter data added to reflection holder.
	var/list/reflection_filter
	///the transparency channel value of the reflection holder.
	var/alpha
	///A list of signals that when sent to the parent, will force the comp to recalculate the reflected movables.
	var/list/update_signals

/datum/component/reflection/Initialize(reflected_dir = NORTH, list/reflection_filter, matrix/reflection_matrix, datum/callback/can_reflect, alpha = 150, list/update_signals)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_movable_entered_or_initialized),
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = PROC_REF(on_movable_entered_or_initialized),
		COMSIG_ATOM_EXITED = PROC_REF(on_movable_exited)
	)
	var/atom/movable/mov_parent = parent
	AddComponent(/datum/component/connect_range, parent, connections, 1, works_in_containers = FALSE)
	src.reflected_dir = reflected_dir
	src.reflection_matrix = reflection_matrix
	src.reflection_filter = reflection_filter
	src.can_reflect = can_reflect
	reflection_holder = new
	reflection_holder.alpha = alpha
	reflection_holder.appearance_flags = KEEP_TOGETHER
	reflection_holder.vis_flags = VIS_INHERIT_ID
	reflection_holder.alpha = alpha
	reflection_holder.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	if(reflection_filter)
		reflection_holder.add_filter("reflection", 1, reflection_filter)
	mov_parent.vis_contents += reflection_holder

	set_reflection(new_dir = mov_parent.dir)

	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))
	var/list/reflect_update_signals = list(COMSIG_MOVABLE_MOVED) + update_signals
	RegisterSignals(parent, reflect_update_signals, PROC_REF(get_reflection_targets))

/datum/component/reflection/Destroy()
	QDEL_LIST_ASSOC_VAL(reflected_movables)
	QDEL_NULL(reflection_holder)
	return ..()

///Called when the parent changes its direction.
/datum/component/reflection/proc/on_dir_change(atom/movable/source, old_dir, new_dir)
	SIGNAL_HANDLER
	set_reflection(old_dir, new_dir)

///Turns the allowed reflected direction alongside the parent's dir. then calls get_reflection_targets.
/datum/component/reflection/proc/set_reflection(old_dir = SOUTH, new_dir = SOUTH)
	if(old_dir == new_dir)
		return

	reflected_dir = turn(reflected_dir, dir2angle(new_dir) - dir2angle(old_dir))
	get_reflection_targets()

///Unsets the old reflected movables and sets it with new ones.
/datum/component/reflection/proc/get_reflection_targets(atom/movable/source)
	SIGNAL_HANDLER
	QDEL_LIST_ASSOC_VAL(reflected_movables)
	for(var/atom/movable/target in view(1, source))
		if(check_can_reflect(target, FALSE))
			set_reflected(target)

///Checks if the target movable can be reflected or not.
/datum/component/reflection/proc/check_can_reflect(atom/movable/target, check_view = TRUE)
	if(target == parent || (check_view && !(target in view(1, parent))))
		return FALSE
	var/atom/movable/mov_parent = parent
	if(target.loc != mov_parent.loc && get_dir(mov_parent, target) != reflected_dir)
		return FALSE
	if(can_reflect && !can_reflect.Invoke(target))
		return FALSE
	return TRUE

///Called when a movable enters a turf within the connected range
/datum/component/reflection/proc/on_movable_entered_or_initialized(atom/movable/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(LAZYACCESS(reflected_movables, arrived) || !check_can_reflect(arrived))
		return
	set_reflected(arrived)

///Called when a movable exits a turf within the connected range
/datum/component/reflection/proc/on_movable_exited(atom/movable/source, atom/movable/gone)
	SIGNAL_HANDLER
	var/atom/movable/reflection = LAZYACCESS(reflected_movables, gone)
	if(!reflection || check_can_reflect(gone))
		return
	qdel(reflection)
	LAZYREMOVE(reflected_movables, gone)

///Sets up a visual overlay of the target movables, which is added to the parent's vis contents.
/datum/component/reflection/proc/set_reflected(atom/movable/target)
	SIGNAL_HANDLER
	var/atom/movable/reflection = new
	reflection.vis_contents += target
	///The filter is added to the reflection holder; the matrix is not, otherwise that'd go affecting the filter.
	if(reflection_matrix)
		reflection.transform = reflection_matrix
	if(reflected_dir == NORTH)
		reflection.transform = reflection.transform.Scale(1, -1)
	else if(reflected_dir != SOUTH)
		reflection.transform = reflection.transform.Scale(-1, 1)
	LAZYSET(reflected_movables, target, reflection)
	reflection_holder.vis_contents += reflection
