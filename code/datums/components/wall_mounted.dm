// This element should be applied to wall-mounted machines/structures, so that if the wall it's "hanging" from is broken or deconstructed, the wall-hung structure will deconstruct.
/datum/component/wall_mounted
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// The object that is currently linked to the wall.
	var/obj/linked_object
	/// Callback to the parent's proc to call on the linked object when the wall disappear's or changes.
	var/datum/callback/on_drop

/datum/component/wall_mounted/Initialize(target_hung_object, target_wall, on_drop_callback)
	. = ..()
	if(!isturf(parent))
		return COMPONENT_INCOMPATIBLE
	if(!isobj(target_hung_object))
		return COMPONENT_INCOMPATIBLE
	if(!on_drop_callback)
		return COMPONENT_INCOMPATIBLE //We need to have a callback to call when the wall is destroyed for sanity.
	linked_object = target_hung_object
	on_drop = on_drop_callback

/datum/component/wall_mounted/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_TURF_CHANGE, PROC_REF(drop_wallmount))
	RegisterSignal(linked_object, COMSIG_QDELETING, PROC_REF(on_linked_destroyed))

/datum/component/wall_mounted/UnregisterFromParent()
	linked_object = null
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_TURF_CHANGE))

/**
 * Basic reference handling if the hanging/linked object is destroyed first.
 */
/datum/component/wall_mounted/proc/on_linked_destroyed()
	SIGNAL_HANDLER
	linked_object = null

/**
 * When the wall is examined, explains that it's supporting the linked object.
 */
/datum/component/wall_mounted/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("\The [parent] is currently supporting [span_bold("[linked_object]")]. Deconstruction or excessive damage would cause it to [span_bold("fall to the ground")].")

/**
 * Handles the dropping of the linked object. This is done via deconstruction, as that should be the most sane way to handle it for most objects.
 * Except for intercoms, which are handled by creating a new wallframe intercom, as they're apparently items.
 */
/datum/component/wall_mounted/proc/drop_wallmount()
	SIGNAL_HANDLER
	linked_object.visible_message(message = span_notice("\The [linked_object] falls off the wall!"), vision_distance = 5)
	on_drop?.Invoke(parent)

/**
 *	Checks object direction and then verifies if there's a wall in that direction. Finally, applies a wall_mounted component to the object.
 *
 * 	@param directional If TRUE, will use the direction of the object to determine the wall to attach to. If FALSE, will use the object's loc.
 *	@param custom_drop_callback If set, will use this callback instead of the default deconstruct callback.
 */
/obj/proc/find_and_hang_on_wall(directional = TRUE, custom_drop_callback)
	if(istype(get_area(src), /area/shuttle))
		return FALSE //For now, we're going to keep the component off of shuttles to avoid the turf changing issue. We'll hit that later really;
	var/turf/attachable_wall
	if(directional)
		attachable_wall = get_step(src, dir)
	else
		attachable_wall = loc ///Pull from the curent object loc
	if(!iswallturf(attachable_wall))
		return FALSE//Nothing to latch onto, or not the right thing.
	var/datum/callback/drop_callback = CALLBACK(src, PROC_REF(deconstruct))
	if(custom_drop_callback)
		drop_callback = custom_drop_callback
	attachable_wall.AddComponent(/datum/component/wall_mounted, src, drop_callback)
	return TRUE
