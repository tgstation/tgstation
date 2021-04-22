
/*
This component attaches to mobs, and makes their pulls !strong!
Basically, the items they pull cannot be pulled (except by the puller)
*/
/datum/component/strong_pull

/datum/component/strong_pull/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_LIVING_TRY_PULL, .proc/on_try_pull)

/**
 * Called when the parent grabs something, adds signals to the object to reject interactions
 */
/datum/component/strong_pull/proc/on_try_pull(datum/source, atom/movable/target, force)
	SIGNAL_HANDLER
	RegisterSignal(parent, COMSIG_ATOM_CAN_BE_PULLED, .proc/reject_further_pulls)

/**
 * Called when the parent grabs something, adds signals to the object to reject interactions
 */
/datum/component/strong_pull/proc/reject_further_pulls(datum/source, mob/living/puller)
	SIGNAL_HANDLER
	if(puller != parent)//for increasing grabs, you need to have a valid pull. thus, parent should be able to pull the same object again
		return COMSIG_ATOM_CANT_PULL
