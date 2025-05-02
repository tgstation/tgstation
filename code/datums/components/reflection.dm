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
	VAR_PRIVATE/obj/effect/abstract/reflection_holder
	/**
	 * A lazy assoc list that keeps track of all movables in range that either could be reflected or are reflected.
	 *
	 * The key is the movable, and the value is the reflection object (or null - the reflection object is also lazy loaded).
	 */
	VAR_PRIVATE/list/reflected_movables
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
	///List of signals registered on reflected atoms to update their reflections.
	var/list/check_reflect_signals

/**
 * Init Args
 * * set_reflected_dir: Optional: What dir to reflect. If not provided, uses (and updates to) the parent's dir.
 * * reflection_filter: Optional: A list of filters to apply to the reflection.
 * * reflection_matrix: Optional: A matrix to apply as the transform of the reflection.
 * * can_reflect: Optional: A callback to check if a movable should be reflected.
 * * alpha: The transparency of the reflection holder.
 * * update_signals: Optional: Additional signals to provide to update_signals (to check for when to recalculate all reflections).
 * * check_reflect_signals: Optional: Additional signals to provide to check_reflect_signals (to check for when to update a single reflection).
 */
/datum/component/reflection/Initialize(set_reflected_dir, list/reflection_filter, matrix/reflection_matrix, datum/callback/can_reflect, alpha = 150, list/update_signals, list/check_reflect_signals)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_movable_entered_or_initialized),
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = PROC_REF(on_movable_entered_or_initialized),
		COMSIG_ATOM_EXITED = PROC_REF(on_movable_exited)
	)
	AddComponent(/datum/component/connect_range, parent, connections, 1, works_in_containers = FALSE)
	// Always supplied to check_reflect_signals
	var/list/default_can_reflect_signals = list(
		COMSIG_ATOM_POST_DIR_CHANGE,
		COMSIG_ATOM_UPDATED_ICON,
		COMSIG_CARBON_APPLY_OVERLAY,
		COMSIG_CARBON_REMOVE_OVERLAY,
		COMSIG_LIVING_POST_UPDATE_TRANSFORM,
	)
	// Always supplied to update_signals
	var/list/default_update_signals = list(
		COMSIG_MOVABLE_MOVED,
	)

	src.reflection_matrix = reflection_matrix
	src.reflection_filter = reflection_filter
	src.can_reflect = can_reflect
	src.check_reflect_signals = (check_reflect_signals || list()) + default_can_reflect_signals
	reflection_holder = new(parent)
	reflection_holder.alpha = alpha
	reflection_holder.appearance_flags = KEEP_TOGETHER
	reflection_holder.vis_flags = VIS_INHERIT_ID
	reflection_holder.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	if(reflection_filter)
		reflection_holder.add_filter("reflection", 1, reflection_filter)

	var/atom/movable/mov_parent = parent
	mov_parent.vis_contents += reflection_holder
	set_reflection(set_reflected_dir || REVERSE_DIR(mov_parent.dir))

	if(!set_reflected_dir)
		RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))
	RegisterSignals(parent, (update_signals || list()) + default_update_signals, PROC_REF(get_reflection_targets))

/datum/component/reflection/Destroy(force)
	for(var/atom/movable/tracked in reflected_movables)
		nuke_reflection(tracked)
	QDEL_NULL(reflection_holder)
	can_reflect = null
	return ..()

///Called when the parent changes its direction.
/datum/component/reflection/proc/on_dir_change(atom/movable/source, old_dir, new_dir)
	SIGNAL_HANDLER
	set_reflection(REVERSE_DIR(new_dir))

///Turns the allowed reflected direction alongside the parent's dir. then calls get_reflection_targets.
/datum/component/reflection/proc/set_reflection(new_dir = SOUTH)
	if(reflected_dir == new_dir)
		return

	reflected_dir = new_dir
	get_reflection_targets(parent)

///Unsets the old reflected movables and sets it with new ones.
/datum/component/reflection/proc/get_reflection_targets(atom/movable/source)
	SIGNAL_HANDLER
	// clean slate
	for(var/atom/movable/tracked in reflected_movables)
		nuke_reflection(tracked)
	// find anything adjacent, if we can't see it that's fine (we check view later)
	for(var/atom/movable/target in range(1, source))
		track_reflection(target)

///Checks if the target movable can be reflected or not.
/datum/component/reflection/proc/check_can_reflect(atom/movable/target)
	if(target == parent || !(target in view(1, parent)))
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
	track_reflection(arrived)

/datum/component/reflection/proc/track_reflection(atom/movable/target, check_view = TRUE)
	// this stuff really shouldn't be tracked
	if(QDELETED(target) || target == parent || target.loc == parent)
		return
	// i don't really want to do this but there's a bunch of abstract effects we should ignore...
	// we can revisit this later when we actually have an object that wants to reflect this stuff
	if(iseffect(target))
		return
	if(!LAZYFIND(reflected_movables, target)) // not lazyaccess - value may be null
		LAZYSET(reflected_movables, target, null)
		RegisterSignals(target, check_reflect_signals, PROC_REF(update_reflection))
		RegisterSignals(target, COMSIG_QDELETING, PROC_REF(nuke_reflection))
	update_reflection(target)

/datum/component/reflection/proc/nuke_reflection(atom/movable/target)
	SIGNAL_HANDLER

	var/atom/movable/reflection = LAZYACCESS(reflected_movables, target)
	if(reflection)
		qdel(reflection)
	LAZYREMOVE(reflected_movables, target)
	UnregisterSignal(target, check_reflect_signals)
	UnregisterSignal(target, COMSIG_QDELETING)

///Called when a movable exits a turf within the connected range
/datum/component/reflection/proc/on_movable_exited(atom/movable/source, atom/movable/gone)
	SIGNAL_HANDLER

	if(!LAZYFIND(reflected_movables, gone)) // not lazyaccess - value may be null
		return
	if(check_can_reflect(gone))
		return
	nuke_reflection(gone)

/// Handles updating the appearance of the reflection to match the target movable.
/datum/component/reflection/proc/copy_appearance_to_reflection(obj/effect/abstract/reflection, atom/movable/target)
	reflection.appearance = copy_appearance_filter_overlays(target.appearance)
	reflection.vis_flags = VIS_INHERIT_ID
	reflection.transform = reflection_matrix || matrix()
	// updating the dir so facing towards / away from it correctly faces the reflection away / towards it,
	// while facing left / right will correctly face the reflection left / right
	// there's probably a more intelligent way to tackle this but this is more readable, i guess
	if(reflected_dir & EAST)
		if(target.dir & NORTH)
			reflection.dir = WEST
		else if(target.dir & SOUTH)
			reflection.dir = EAST
		else
			reflection.dir = REVERSE_DIR(target.dir)

	else if(reflected_dir & WEST)
		if(target.dir & NORTH)
			reflection.dir = EAST
		else if(target.dir & SOUTH)
			reflection.dir = WEST
		else
			reflection.dir = REVERSE_DIR(target.dir)

	else if(reflected_dir & SOUTH)
		// east/west is the same, makes it easy on us
		reflection.dir = (target.dir & (EAST|WEST)) ? target.dir : REVERSE_DIR(target.dir)

	else if(reflected_dir & NORTH)
		reflection.dir = (target.dir & (NORTH|SOUTH)) ? target.dir : REVERSE_DIR(target.dir)
		// north needs snowflake handling to make a more... "understandable" reflection
		reflection.transform = reflection.transform.Turn(180)
		reflection.pixel_y += 5

	// purely for vv
	reflection.name = "[target.name]'s reflection"

///Called when the target movable changes its appearance or dir.
/datum/component/reflection/proc/update_reflection(atom/movable/source)
	SIGNAL_HANDLER

	var/obj/effect/abstract/reflection = LAZYACCESS(reflected_movables, source)
	if(!check_can_reflect(source))
		// temporarily hide any reflection
		reflection?.vis_flags |= VIS_HIDE
		return
	// Lazy init the reflection
	if(!reflection)
		// If the loc is null, only a black (or grey depending on alpha) silhouette of the target will be rendered
		// Just putting this information here in case you want something like that in the future.
		reflection = new(parent)
		reflection_holder.vis_contents += reflection
		LAZYSET(reflected_movables, source, reflection)

	// technically redundant (...because copying appearance copies vis flags), but good to be explicit
	reflection.vis_flags &= ~VIS_HIDE
	copy_appearance_to_reflection(reflection, source)
