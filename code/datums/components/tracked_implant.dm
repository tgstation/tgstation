///A second masterlist of all tracked implants, for when we want to search a more broad list of tracked implants.
GLOBAL_LIST_EMPTY(tracked_generic_implants)

/*
 * A small component for implants that are tracked on a global list when implanted into a mob.
 */
/datum/component/tracked_implant
	///A reference to the global list we will track this implant over.
	var/global_list

/datum/component/tracked_implant/Initialize(global_list)
	if(!global_list || !isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.global_list = global_list

/datum/component/tracked_implant/RegisterWithParent()
	RegisterSignal(parent, COMSIG_IMPLANT_IMPLANTED, PROC_REF(on_implant))
	RegisterSignal(parent, COMSIG_IMPLANT_REMOVED, PROC_REF(on_remove))

/datum/component/tracked_implant/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_IMPLANT_IMPLANTED, COMSIG_IMPLANT_REMOVED))

/datum/component/tracked_implant/proc/on_implant(datum/source, mob/living/target, mob/user, silent = FALSE, force = FALSE)
	SIGNAL_HANDLER
	global_list += parent
	GLOB.tracked_generic_implants += parent

/datum/component/tracked_implant/proc/on_remove(datum/source, mob/target, silent = FALSE, special = FALSE)
	SIGNAL_HANDLER
	global_list -= parent
	GLOB.tracked_generic_implants -= parent
