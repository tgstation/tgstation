// This element should be applied to wall-mounted machines/structures, so that if the wall it's "hanging" from is broken or deconstructed, the wall-hung structure will deconstruct.
/datum/component/wall_mounted
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// The wall our object is currently linked to.
	var/turf/closed/wall/hanging_wall_turf

/datum/component/wall_mounted/Initialize(target_wall, on_drop_callback)
	. = ..()
	if(!isobj(parent) || !iswallturf(target_wall))
		return COMPONENT_INCOMPATIBLE
	hanging_wall_turf = target_wall

/datum/component/wall_mounted/RegisterWithParent()
	ADD_TRAIT(parent, TRAIT_WALLMOUNTED, REF(src))
	RegisterSignal(hanging_wall_turf, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(hanging_wall_turf, COMSIG_TURF_CHANGE, PROC_REF(on_turf_changing))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/datum/component/wall_mounted/UnregisterFromParent()
	REMOVE_TRAIT(parent, TRAIT_WALLMOUNTED, REF(src))
	UnregisterSignal(hanging_wall_turf, list(COMSIG_ATOM_EXAMINE, COMSIG_TURF_CHANGE))
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	hanging_wall_turf = null

/**
 * When the wall is examined, explains that it's supporting the linked object.
 */
/datum/component/wall_mounted/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if (parent in view(user.client?.view || world.view, user))
		examine_list += span_notice("\The [hanging_wall_turf] is currently supporting [span_bold("[parent]")]. Deconstruction or excessive damage would cause it to [span_bold("fall to the ground")].")

/**
 * When the type of turf changes, if it is changing into a floor we should drop our contents
 */
/datum/component/wall_mounted/proc/on_turf_changing(datum/source, path, new_baseturfs, flags, post_change_callbacks)
	SIGNAL_HANDLER

	if(ispath(path, /turf/open))
		drop_wallmount()


/**
 * If we get dragged from our wall (by a singulo for instance) we should deconstruct
 */
/datum/component/wall_mounted/proc/on_move(datum/source, atom/old_loc, dir, forced, list/old_locs)
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
/datum/component/wall_mounted/proc/drop_wallmount()
	PRIVATE_PROC(TRUE)

	var/obj/hanging_parent = parent
	hanging_parent.visible_message(message = span_warning("\The [hanging_parent] falls apart!"), vision_distance = 5)
	hanging_parent.deconstruct(FALSE)


///Checks object direction and then verifies if there's a wall in that direction. Finally, applies a wall_mounted component to the object.
/obj/proc/find_and_hang_on_wall()
	if(istype(get_area(src), /area/shuttle))
		return FALSE //For now, we're going to keep the component off of shuttles to avoid the turf changing issue. We'll hit that later really;
	var/turf/attachable_wall = loc //first attempt to locate a wall in our current turf
	if(!iswallturf(attachable_wall))
		attachable_wall = get_step(src, dir) //if no then attempt to locate it in our direction
	if(!iswallturf(attachable_wall))
		return FALSE //Nothing to latch onto, or not the right thing.
	AddComponent(/datum/component/wall_mounted, attachable_wall)
	return TRUE
