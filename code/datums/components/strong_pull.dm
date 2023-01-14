
/*
This component attaches to mobs, and makes their pulls !strong!
Basically, the items they pull cannot be pulled (except by the puller)
*/
/datum/component/strong_pull
	var/atom/movable/strongpulling

/datum/component/strong_pull/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/strong_pull/Destroy(force, silent)
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
	after_pull()

/datum/component/strong_pull/proc/after_pull()
	RegisterSignal(strongpulling, COMSIG_ATOM_CAN_BE_PULLED, PROC_REF(reject_further_pulls))
	RegisterSignal(strongpulling, COMSIG_ATOM_NO_LONGER_PULLED, PROC_REF(on_no_longer_pulled))
	if(istype(strongpulling, /obj/structure/closet) && !istype(strongpulling, /obj/structure/closet/body_bag))
		var/obj/structure/closet/grabbed_closet = strongpulling
		grabbed_closet.strong_grab = TRUE

/**
 * Signal for rejecting further grabs
 */
/datum/component/strong_pull/proc/reject_further_pulls(datum/source, mob/living/puller)
	SIGNAL_HANDLER
	if(puller != parent) //for increasing grabs, you need to have a valid pull. thus, parent should be able to pull the same object again
		strongpulling.balloon_alert(puller, "grip too strong")
		return COMSIG_ATOM_CANT_PULL

/*
 * Unregisters signals and stops any buffs to pulling.
 */
/datum/component/strong_pull/proc/lose_strong_grip()
	UnregisterSignal(strongpulling, list(COMSIG_ATOM_CAN_BE_PULLED, COMSIG_ATOM_NO_LONGER_PULLED))
	if(istype(strongpulling, /obj/structure/closet))
		var/obj/structure/closet/ungrabbed_closet = strongpulling
		ungrabbed_closet.strong_grab = FALSE
	strongpulling = null

/**
 * Called when the hooked object is no longer pulled and removes the strong grip.
 */
/datum/component/strong_pull/proc/on_no_longer_pulled(datum/source, atom/movable/last_puller)
	SIGNAL_HANDLER
	lose_strong_grip()


/**
* Security variant of the component used for restraining people rather than crates
*/
/datum/component/strong_pull/security/after_pull()
	if(istype(strongpulling, /mob/living/carbon/human))
		RegisterSignal(strongpulling, COMSIG_CARBON_CUFF_SUCCEED, PROC_REF(apply_trait))
		RegisterSignal(strongpulling, COMSIG_ATOM_NO_LONGER_PULLED, PROC_REF(on_no_longer_pulled))
		apply_trait(victim = strongpulling)

/datum/component/strong_pull/security/proc/apply_trait(datum/source, mob/living/carbon/human/victim)
	SIGNAL_HANDLER
	if(victim.handcuffed)
		RegisterSignal(strongpulling, COMSIG_CARBON_CUFF_ESCAPE, PROC_REF(target_uncuffed))
		RegisterSignal(strongpulling, COMSIG_ATOM_CAN_BE_PULLED, PROC_REF(reject_further_pulls))
		ADD_TRAIT(victim, TRAIT_RESTRICTIVE_GRAB, "security gauntlet")

/datum/component/strong_pull/security/lose_strong_grip()
	UnregisterSignal(strongpulling, list(COMSIG_CARBON_CUFF_SUCCEED, COMSIG_ATOM_NO_LONGER_PULLED))
	target_uncuffed()
	strongpulling = null

//If someone is uncuffed we want the restriction from the guantlent remove but we do not want all signals unregistered just incase they get recuffed without breaking grab.
/datum/component/strong_pull/security/proc/target_uncuffed(datum/source, mob/living/uncuffer)
	SIGNAL_HANDLER
	UnregisterSignal(strongpulling, list(COMSIG_ATOM_CAN_BE_PULLED, COMSIG_CARBON_CUFF_ESCAPE))
	if(istype(strongpulling, /mob/living/carbon/human))
		REMOVE_TRAIT(strongpulling, TRAIT_RESTRICTIVE_GRAB, "security gauntlet")
