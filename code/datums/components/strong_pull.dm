
/*
This component attaches to mobs, and makes their pulls !strong!
Basically, the items they pull cannot be pulled (except by the puller)
*/
/datum/component/strong_pull
	var/atom/movable/strongpulling

/datum/component/strong_pull/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/strong_pull/Destroy(force)
	if(strongpulling)
		lose_strong_grip()
	return ..()

/datum/component/strong_pull/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_LIVING_START_PULL, PROC_REF(on_pull))

/**
 * Called when the parent grabs something, adds signals to the object to reject interactions
 */
/datum/component/strong_pull/proc/on_pull(datum/source, atom/movable/pulled, state, force)
	SIGNAL_HANDLER
	strongpulling = pulled
	RegisterSignal(strongpulling, COMSIG_ATOM_CAN_BE_PULLED, PROC_REF(reject_further_pulls))
	RegisterSignal(strongpulling, COMSIG_ATOM_NO_LONGER_PULLED, PROC_REF(on_no_longer_pulled))
	if(istype(strongpulling, /obj/structure/closet) && !istype(strongpulling, /obj/structure/closet/body_bag))
		var/obj/structure/closet/grabbed_closet = strongpulling
		ADD_TRAIT(grabbed_closet, TRAIT_STRONGPULL, REF(src))

/**
 * Signal for rejecting further grabs
 */
/datum/component/strong_pull/proc/reject_further_pulls(datum/source, mob/living/puller)
	SIGNAL_HANDLER
	if(puller != parent) //for increasing grabs, you need to have a valid pull. thus, parent should be able to pull the same object again
		strongpulling.balloon_alert(puller, "gripped too tightly!")
		return COMSIG_ATOM_CANT_PULL

/*
 * Unregisters signals and stops any buffs to pulling.
 */
/datum/component/strong_pull/proc/lose_strong_grip()
	UnregisterSignal(strongpulling, list(COMSIG_ATOM_CAN_BE_PULLED, COMSIG_ATOM_NO_LONGER_PULLED))
	if(istype(strongpulling, /obj/structure/closet))
		var/obj/structure/closet/ungrabbed_closet = strongpulling
		REMOVE_TRAIT(ungrabbed_closet, TRAIT_STRONGPULL, REF(src))
	strongpulling = null

/**
 * Called when the hooked object is no longer pulled and removes the strong grip.
 */
/datum/component/strong_pull/proc/on_no_longer_pulled(datum/source, atom/movable/last_puller)
	SIGNAL_HANDLER
	lose_strong_grip()
