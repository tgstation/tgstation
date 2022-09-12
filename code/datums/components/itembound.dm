/// When a movable has this component AND they are in the contents of a container, they will no longer be able to use their hands and be immobilized until they are removed from the container. So far, this is only useful for smites.
/datum/component/itembound
	/// The movable that is inside to the container
	var/atom/movable/subject
	/// The container that the subject is inside of
	var/atom/movable/container
	/// Detect any movement of the container
	var/datum/movement_detector/move_tracker

/datum/component/itembound/Initialize(tomb)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	subject = parent
	container = tomb
	move_tracker = new(parent,CALLBACK(src,.proc/verify_containment))

	ADD_TRAIT(subject, TRAIT_HANDS_BLOCKED, SMITE_TRAIT)

/// Ensure that when we move, we still are in the container. If not in the container, remove all the signals.
/datum/component/itembound/proc/verify_containment()
	if(container.contains(subject))
		return
	REMOVE_TRAIT(subject, TRAIT_HANDS_BLOCKED, SMITE_TRAIT)
	QDEL_NULL(move_tracker)

/datum/component/itembound/Destroy(force, silent)
	QDEL_NULL(move_tracker)
	. = ..()

