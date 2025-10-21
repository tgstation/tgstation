// This element should be applied to mounted machines/structures, so that if the structure it's "hanging" from is broken or deconstructed, the hung structure will deconstruct.
/datum/component/wall_mounted
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// The thing our object is currently attached to.
	var/atom/supporting_object
	/// Callback to the parent's proc to call on the linked object when the wall disappear's or changes.
	var/datum/callback/on_drop

/datum/component/wall_mounted/Initialize(target, on_drop_callback)
	. = ..()
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	if(!isturf(target) && !istype(target, /obj/structure/table))
		return COMPONENT_INCOMPATIBLE
	supporting_object = target
	on_drop = on_drop_callback

/datum/component/wall_mounted/RegisterWithParent()
	ADD_TRAIT(parent, TRAIT_WALLMOUNTED, REF(src))
	RegisterSignal(supporting_object, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	if(isturf(supporting_object))
		RegisterSignal(supporting_object, COMSIG_TURF_CHANGE, PROC_REF(on_turf_changing))
	else
		RegisterSignal(supporting_object, COMSIG_OBJ_DECONSTRUCT, PROC_REF(drop_wallmount))
		RegisterSignal(supporting_object, COMSIG_MOVABLE_MOVED, PROC_REF(drop_wallmount))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_linked_destroyed))

/datum/component/wall_mounted/UnregisterFromParent()
	REMOVE_TRAIT(parent, TRAIT_WALLMOUNTED, REF(src))
	UnregisterSignal(supporting_object, list(COMSIG_ATOM_EXAMINE, COMSIG_TURF_CHANGE, COMSIG_OBJ_DECONSTRUCT, COMSIG_MOVABLE_MOVED))
	UnregisterSignal(parent, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	supporting_object = null

/**
 * Basic reference handling if the hanging/linked object is destroyed first.
 */
/datum/component/wall_mounted/proc/on_linked_destroyed()
	SIGNAL_HANDLER
	if(!QDELING(src))
		qdel(src)

/**
 * When the wall is examined, explains that it's supporting the linked object.
 */
/datum/component/wall_mounted/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if (parent in view(user.client?.view || world.view, user))
		examine_list += span_notice("\The [supporting_object] is currently supporting \the [span_bold("[parent]")]. Deconstruction or excessive damage would cause it to [span_bold("fall to the ground")].")

/**
 * When the type of turf changes, if it is changing into a floor we should drop our contents
 */
/datum/component/wall_mounted/proc/on_turf_changing(datum/source, path, new_baseturfs, flags, post_change_callbacks)
	SIGNAL_HANDLER
	if (ispath(path, /turf/open))
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
	SIGNAL_HANDLER
	var/obj/hanging_parent = parent

	if(on_drop)
		hanging_parent.visible_message(message = span_warning("\The [hanging_parent] falls off \the [supporting_object]!"), vision_distance = 5)
		on_drop.Invoke(hanging_parent)
	else
		hanging_parent.visible_message(message = span_warning("\The [hanging_parent] falls apart!"), vision_distance = 5)
		hanging_parent.deconstruct()

	if(!QDELING(src))
		qdel(src) //Well, we fell off the wall, so we're done here.

/**
 *	Checks object direction and then verifies if there's a wall in that direction. Finally, applies a wall_mounted component to the object.
 *
 * 	@param directional If TRUE, will use the direction of the object to determine the wall to attach to. If FALSE, will use the object's loc.
 *	@param custom_drop_callback If set, will use this callback instead of the default deconstruct callback.
 */
/obj/proc/find_and_hang_on_wall(directional = TRUE, custom_drop_callback)
	if(istype(get_area(src), /area/shuttle))
		return FALSE //For now, we're going to keep the component off of shuttles to avoid the turf changing issue. We'll hit that later really;
	var/turf/targeted_turf
	var/target
	if(directional)
		targeted_turf = get_step(src, dir)
	else
		targeted_turf = loc ///Pull from the curent object loc
	if(iswallturf(targeted_turf))
		target = targeted_turf
	else
		for(var/obj/structure/table/potential in targeted_turf?.contents)
			target = potential
			break
		if(!target)
			return FALSE
	src.AddComponent(/datum/component/wall_mounted, target, custom_drop_callback)
	return TRUE
