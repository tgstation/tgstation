/**
 * This element should be applied to machines/structures that are mounted to a turf (likely a wall),
 * so that if the turf it's mounted to is broken or deconstructed,
 * the structure will deconstruct.
 */

/datum/component/turf_mounted
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// The turf our object is currently linked to.
	var/turf/hanging_turf
	/// Callback to the parent's proc to call on the linked object when the turf disappear's or changes.
	var/datum/callback/on_drop

/datum/component/turf_mounted/Initialize(target_turf, on_drop_callback)
	. = ..()
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	if(!isturf(target_turf))
		return COMPONENT_INCOMPATIBLE
	hanging_turf = target_turf
	on_drop = on_drop_callback

/datum/component/turf_mounted/RegisterWithParent()
	ADD_TRAIT(parent, TRAIT_TURFMOUNTED, REF(src))
	RegisterSignal(hanging_turf, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(hanging_turf, COMSIG_TURF_CHANGE, PROC_REF(on_turf_changing))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_linked_destroyed))

/datum/component/turf_mounted/UnregisterFromParent()
	REMOVE_TRAIT(parent, TRAIT_TURFMOUNTED, REF(src))
	UnregisterSignal(hanging_turf, list(COMSIG_ATOM_EXAMINE, COMSIG_TURF_CHANGE))
	UnregisterSignal(parent, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	hanging_turf = null

/**
 * Basic reference handling if the hanging/linked object is destroyed first.
 */
/datum/component/turf_mounted/proc/on_linked_destroyed()
	SIGNAL_HANDLER
	if(!QDELING(src))
		qdel(src)

/**
 * When the turf is examined, explains that it's supporting the linked object.
 */
/datum/component/turf_mounted/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("\The [hanging_turf] is currently supporting [span_bold("[parent]")]. Deconstruction or excessive damage would cause it to [span_bold("fall to the ground")].")

/**
 * When the type of turf changes, if it is changing into a floor we should drop our contents
 */
/datum/component/turf_mounted/proc/on_turf_changing(datum/source, path, new_baseturfs, flags, post_change_callbacks)
	SIGNAL_HANDLER
	if (ispath(path, /turf/open))
		drop_turfmount()


/**
 * If we get dragged from our turf (by a singulo for instance) we should deconstruct
 */
/datum/component/turf_mounted/proc/on_move(datum/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	// If we're having our lighting messed with we're likely to get dragged about
	// That shouldn't lead to a decon
	if(HAS_TRAIT(parent, TRAIT_LIGHTING_DEBUGGED))
		return
	drop_mount()

/**
 * Handles the dropping of the linked object. This is done via deconstruction, as that should be the most sane way to handle it for most objects.
 * Except for intercoms, which are handled by creating a new wallframe intercom, as they're apparently items.
 */
/datum/component/turf_mounted/proc/drop_mount()
	SIGNAL_HANDLER
	var/obj/hanging_parent = parent

	if(on_drop)
		hanging_parent.visible_message(message = span_warning("\The [hanging_parent] falls off [hanging_turf]!"), vision_distance = 5)
		on_drop.Invoke(hanging_parent)
	else
		hanging_parent.visible_message(message = span_warning("\The [hanging_parent] falls apart!"), vision_distance = 5)
		hanging_parent.deconstruct()

	if(!QDELING(src))
		qdel(src) //Well, we fell off the turf, so we're done here.
