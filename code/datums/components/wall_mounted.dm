// This element should be applied to wall-mounted machines/structures, so that if the wall it's "hanging" from is broken or deconstructed, the wall-hung structure will deconstruct.
/datum/component/wall_mounted
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// The object that is currently linked to the wall.
	var/obj/linked_object

/datum/component/wall_mounted/Initialize(target_hung_object, target_wall)
	. = ..()
	if(!isturf(parent))
		return COMPONENT_INCOMPATIBLE
	if(!isobj(target_hung_object))
		return COMPONENT_INCOMPATIBLE
	linked_object = target_hung_object

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
	if(ismachinery(linked_object))
		var/obj/machinery/machine_mount = linked_object
		machine_mount.deconstruct()
		return
	if(isstructure(linked_object))
		var/obj/structure/structure_mount = linked_object
		structure_mount.deconstruct()
		return
	if(istype(linked_object, /obj/item/radio/intercom)) //This is probably awful practice
		new /obj/item/wallframe/intercom(get_turf(linked_object))
		qdel(linked_object)
		return

/// Checks object direction and then verifies if there's a wall in that direction. Finally, applies a wall_mounted component to the object.
/obj/proc/find_and_hang_on_wall(directional = TRUE)
	if(istype(get_area(src), /area/shuttle))
		return FALSE //For now, we're going to keep the component off of shuttles to avoid the turf changing issue. We'll hit that later really;
	var/turf/attachable_wall
	if(directional)
		attachable_wall = get_step(src, dir)
	else
		attachable_wall = loc ///Pull from the curent object loc
	if(!iswallturf(attachable_wall))
		return FALSE//Nothing to latch onto, or not the right thing.
	attachable_wall.AddComponent(/datum/component/wall_mounted, src)
	return TRUE
