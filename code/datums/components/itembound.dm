/// When a movable has this component AND they are in the contents of a container, they will no longer be able to use their hands and be immobilized until they are removed from the container. So far, this is only useful for smites.
/datum/component/itembound
	/// Weak reference to the container that the movable is inside of.
	var/datum/weakref/containerref
	/// Detect any movement of the container
	var/datum/movement_detector/move_tracker

/datum/component/itembound/Initialize(atom/movable/passed_container)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	if(QDELETED(passed_container))
		return
	containerref = WEAKREF(passed_container)
	RegisterSignal(passed_container, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examined))
	move_tracker = new(parent, CALLBACK(src, PROC_REF(verify_containment)))


/datum/component/itembound/RegisterWithParent()
	. = ..()
	ADD_TRAIT(parent, TRAIT_INCAPACITATED, SMITE_TRAIT)
	if (isliving(parent))
		var/mob/living/living_parent = parent
		living_parent.apply_status_effect(/datum/status_effect/grouped/stasis, STASIS_ADMIN)

/datum/component/itembound/UnregisterFromParent()
	REMOVE_TRAIT(parent, TRAIT_INCAPACITATED, SMITE_TRAIT)
	if (isliving(parent))
		var/mob/living/living_parent = parent
		living_parent.remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_ADMIN)
	return ..()

/datum/component/itembound/proc/on_examined(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("If you hold it up to your ear, you can hear the screams of the damned.")

/// Ensure that when we move, we still are in the container. If not in the container, remove all the traits.
/datum/component/itembound/proc/verify_containment()
	var/atom/movable/container = containerref.resolve()
	if(!QDELETED(container) && container.contains(parent))
		return
	qdel(src)

/datum/component/itembound/Destroy(force)
	var/atom/movable/container = containerref?.resolve()
	if (!QDELETED(container))
		UnregisterSignal(container, COMSIG_ATOM_EXAMINE_MORE)
	containerref = null
	QDEL_NULL(move_tracker)
	return ..()

