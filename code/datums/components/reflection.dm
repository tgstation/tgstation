/**
 * A simple-ish component that reflects the icons of movables on the parent like if it were a mirror.
 * It has a few limitations due to the engine and the fact it's a 2D game (ambidextrous sprite trope)
 */
/datum/component/reflection
	can_transfer = TRUE
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/**
	 * A list of directions the component is allowed to reflect from if use_parent_dir is FALSE.
	 * Not a bitfield so the component can we avoid reflecting from diagonal directions unless specified.
	 */
	var/list/reflected_dirs
	/// If TRUE, the parent will reflect the direction it's facing and not reflected_dirs.
	var/use_parent_dir = FALSE
	/// The typepath of the movables the component will reflect.
	var/reflected_type
	/// A movable added to the parent vis content and that holds the visual overlays of the reflected atoms.
	var/atom/movable/reflection_effect
	/// A lazy list that keeps track of which movables are being reflected.
	var/list/atom/movable/reflected_movables

/datum/component/reflection/Initialize(list/reflected_dirs, use_parent_dir = FALSE, list/reflection_filter, matrix/reflection_matrix, reflected_type = /mob/living)
	if(!ismovable(parent) && (use_parent_dir || !isturf(parent)))
		return COMPONENT_INCOMPATIBLE

	src.reflected_dirs = reflected_dirs
	src.use_parent_dir = use_parent_dir
	src.reflected_type = reflected_type

	reflection_effect = new
	reflection_effect.appearance_flags = KEEP_TOGETHER
	reflection_effect.alpha = 150
	reflection_effect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	if(reflection_filter)
		reflection_effect.add_filter("reflection_filter", 1, reflection_filter)
	if(reflection_matrix)
		reflection_effect.transform = reflection_matrix

/datum/component/reflection/Destroy()
	QDEL_NULL(reflection_effect)
	return ..()

/datum/component/reflection/RegisterWithParent()
	var/atom/atom_parent = parent
	if(ismovable(parent)) //Alas, the base atoms and areas don't have the vis_contents variable so this has to be done.
		var/atom/movable/movable_parent = parent
		movable_parent.vis_contents += reflection_effect
	else if(isturf(parent))
		var/turf/turf_parent = parent
		turf_parent.vis_contents += reflection_effect

	set_reflection_dir(new_dir = atom_parent.dir)
	set_reflection_targets()

	RegisterSignal(atom_parent, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	if(use_parent_dir)
		RegisterSignal(atom_parent, COMSIG_ATOM_DIR_CHANGE, .proc/set_reflection_dir)

/datum/component/reflection/UnregisterFromParent()
	var/atom/atom_parent = parent
	UnregisterSignal(atom_parent, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))
	if(ismovable(parent))
		var/atom/movable/movable_parent = parent
		movable_parent.vis_contents -= reflection_effect
	else if(isturf(parent))
		var/turf/turf_parent = parent
		turf_parent.vis_contents -= reflection_effect
	if(!isturf(atom_parent.loc) && !isturf(atom_parent))
		return
	for(var/turf/target_turf as anything in orange(1, atom_parent.loc))
		UnregisterSignal(target_turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
	reflection_effect?.vis_contents -= reflected_movables
	LAZYNULL(reflected_movables)

/datum/component/reflection/PostTransfer()
	if(!ismovable(parent) && (use_parent_dir || !isturf(parent)))
		return COMPONENT_INCOMPATIBLE

/datum/component/reflection/proc/on_moved(atom/movable/source, old_loc)
	SIGNAL_HANDLER
	if(source.loc == old_loc)
		return
	if(old_loc)
		for(var/turf/target_turf as anything in range(1, old_loc))
			UnregisterSignal(target_turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
	reflection_effect.vis_contents -= reflected_movables
	LAZYNULL(reflected_movables)
	if(isturf(source.loc))
		set_reflection_targets()

/// The component will call register_reflection_turf() on turfs that pass certain conditions.
/datum/component/reflection/proc/set_reflection_targets()
	var/atom/atom_parent = parent
	if(use_parent_dir)
		register_reflection_turf(get_turf(atom_parent))
		register_reflection_turf(get_step(atom_parent, atom_parent.dir))
		return

	for(var/turf/target_turf as anything in range(1, atom_parent))
		if(get_dir(atom_parent, target_turf) in reflected_dirs)
			continue
		register_reflection_turf(target_turf)

/// The component will start listening to adjacent turf and reflect any movable of the reflected type.
/datum/component/reflection/proc/register_reflection_turf(turf/target_turf)
	if(!target_turf)
		return
	RegisterSignal(target_turf, COMSIG_ATOM_ENTERED, .proc/on_turf_entered)
	RegisterSignal(target_turf, COMSIG_ATOM_EXITED, .proc/on_turf_exited)
	for(var/atom/movable/target as anything in target_turf)
		if(istype(target, reflected_type))
			reflection_effect.vis_contents += target
			LAZYSET(reflected_movables, target, TRUE)

/datum/component/reflection/proc/on_turf_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(istype(arrived, reflected_type))
		reflection_effect.vis_contents += arrived
		LAZYSET(reflected_movables, arrived, TRUE)

/datum/component/reflection/proc/on_turf_exited(datum/source, atom/movable/gone)
	SIGNAL_HANDLER
	if(LAZYACCESS(reflected_movables, gone))
		reflection_effect.vis_contents -= gone
		LAZYREMOVE(reflected_movables, gone)

/datum/component/reflection/proc/set_reflection_dir(atom/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(old_dir == new_dir)
		return

	var/common_dirs = old_dir & new_dir
	if((old_dir & NORTH || new_dir & NORTH) && !(common_dirs & NORTH))
		reflection_effect.transform = reflection_effect.transform.Invert()

	if(old_dir && use_parent_dir && get_turf(source) == source.loc)
		var/turf/target_turf = get_step(source, old_dir)
		if(target_turf)
			UnregisterSignal(target_turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
			reflection_effect.vis_contents -= target_turf.contents
			LAZYREMOVE(reflected_movables, target_turf.contents)
		register_reflection_turf(get_step(source, new_dir))
