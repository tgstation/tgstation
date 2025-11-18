// This element should be applied to wall-mounted machines/structures, so that if the support structure it's "hanging" from is broken or deconstructed, the wall-hung structure will deconstruct.
/datum/component/atom_mounted
	/// The closed turf our object is currently linked to.
	var/atom/hanging_support_atom

/datum/component/atom_mounted/Initialize(target_structure, on_drop_callback)
	. = ..()
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	hanging_support_atom = target_structure

/datum/component/atom_mounted/RegisterWithParent()
	ADD_TRAIT(parent, TRAIT_WALLMOUNTED, REF(src))
	RegisterSignal(hanging_support_atom, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	if(isclosedturf(hanging_support_atom))
		RegisterSignal(hanging_support_atom, COMSIG_TURF_CHANGE, PROC_REF(on_turf_changing))
	else
		RegisterSignal(hanging_support_atom, COMSIG_QDELETING, PROC_REF(on_structure_delete))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/datum/component/atom_mounted/UnregisterFromParent()
	REMOVE_TRAIT(parent, TRAIT_WALLMOUNTED, REF(src))
	UnregisterSignal(hanging_support_atom, list(COMSIG_ATOM_EXAMINE))
	if(isclosedturf(hanging_support_atom))
		UnregisterSignal(hanging_support_atom, COMSIG_TURF_CHANGE)
	else
		UnregisterSignal(hanging_support_atom, COMSIG_QDELETING)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	hanging_support_atom = null

/**
 * When the wall is examined, explains that it's supporting the linked object.
 */
/datum/component/atom_mounted/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if (parent in view(user.client?.view || world.view, user))
		examine_list += span_notice("\The [hanging_support_atom] is currently supporting [span_bold("[parent]")]. Deconstruction or excessive damage would cause it to [span_bold("fall to the ground")].")

/// When the type of turf changes, if it is changing into a floor we should drop our contents
/datum/component/atom_mounted/proc/on_turf_changing(datum/source, path, new_baseturfs, flags, post_change_callbacks)
	SIGNAL_HANDLER

	if(ispath(path, /turf/open))
		drop_wallmount()

/datum/component/atom_mounted/proc/on_structure_delete(datum/source, force)
	SIGNAL_HANDLER

	drop_wallmount()

/// If we get dragged from our wall (by a singulo for instance) we should deconstruct
/datum/component/atom_mounted/proc/on_move(datum/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	// If we're having our lighting messed with we're likely to get dragged about
	// That shouldn't lead to a decon
	if(HAS_TRAIT(parent, TRAIT_LIGHTING_DEBUGGED))
		return
	drop_wallmount()

/**
 * Handles the dropping of the linked object. This is done via deconstruction, as that should be the most sane way to handle it for most objects.
 * Except for intercoms, which are handled by creating a new wallframe intercom, as they're apparently items.
*/
/datum/component/atom_mounted/proc/drop_wallmount()
	PRIVATE_PROC(TRUE)

	var/obj/hanging_parent = parent
	hanging_parent.visible_message(message = span_warning("\The [hanging_parent] falls apart!"), vision_distance = 5)
	hanging_parent.deconstruct(FALSE)

/**
 * Finds an support atom to hang this object on. If you need to mount the object on Late Initialize
 * then pass TRUE inside Initialize() but not in LateInitialize().
 * The flag is only applied if no support atom could be found during Initialize() as a last resort
 *
 * Arguments
 * * mark_for_late_init - if TRUE will apply the MOUNT_ON_LATE_INITIALIZE which gets cleared on every call
 * * late_init - should only be passed as TRUE from inside LateInitialize()
*/
/obj/proc/find_and_hang_on_atom(mark_for_late_init = FALSE, late_init = FALSE)
	if(obj_flags & MOUNT_ON_LATE_INITIALIZE)
		obj_flags &= ~MOUNT_ON_LATE_INITIALIZE
	else if(late_init)
		return TRUE

	var/area/location = get_area(src)
	if(!isarea(location) || istype(location, /area/shuttle))
		return FALSE

	var/msg
	if(PERFORM_ALL_TESTS(focus_only/atom_mounted) && !mark_for_late_init)
		msg = "[type] Could not find attachable object at [location.type] "

	var/list/turf/attachable_turfs = list()
	attachable_turfs += get_turf(src)
	attachable_turfs += get_step(attachable_turfs[1], dir)
	for(var/turf/target as anything in attachable_turfs)
		var/atom/attachable_atom
		if(isclosedturf(target))
			attachable_atom = target //your usual wallmount
		else
			var/static/list/attachables = list(
				/obj/structure/table,
				/obj/structure/window,
				/obj/structure/fence,
			) //list of structures to mount on
			for(var/obj/attachable in target)
				if(is_type_in_list(attachable, attachables))
					attachable_atom = attachable
					break
		if(attachable_atom)
			AddComponent(/datum/component/atom_mounted, attachable_atom)
			return TRUE
		if(msg)
			msg += "([target.x],[target.y],[target.z]) "
	if(msg)
		stack_trace(msg)

	if(mark_for_late_init)
		obj_flags |= MOUNT_ON_LATE_INITIALIZE
	return FALSE
