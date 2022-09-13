/// When a movable has this component AND they are in the contents of a container, they will no longer be able to use their hands and be immobilized until they are removed from the container. So far, this is only useful for smites.
/datum/component/itembound
	/// The container that the subject is inside of
	var/atom/movable/container
	/// Detect any movement of the container
	var/datum/movement_detector/move_tracker

/datum/component/itembound/Initialize(container)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	src.container = container
	move_tracker = new(parent, CALLBACK(src, .proc/verify_containment))

	ADD_TRAIT(parent, TRAIT_INCAPACITATED, SMITE_TRAIT)

/// Ensure that when we move, we still are in the container. If not in the container, remove all the traits.
/datum/component/itembound/proc/verify_containment()
	if(container.contains(parent) || !QDELETED(container))
		return
	REMOVE_TRAIT(parent, TRAIT_INCAPACITATED, SMITE_TRAIT)
	qdel(src)

/datum/component/itembound/Destroy(force, silent)
	QDEL_NULL(move_tracker)
	return ..()

