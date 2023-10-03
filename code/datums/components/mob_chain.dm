/**
 * Component allowing you to create a linked list of mobs.
 * These mobs will follow each other and attack as one, as well as sharing damage taken.
 */
/datum/component/mob_chain

	/// If true then damage we take is passed backwards along the line
	var/pass_damage_back
	/// If true then we will set our icon state based on line position
	var/vary_icon_state

	/// Mob in front of us in the chain
	var/mob/living/front
	/// Mob behind us in the chain
	var/mob/living/back

/datum/component/mob_chain/Initialize(mob/living/front, pass_damage_back = TRUE, vary_icon_state = TRUE)
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.front = front
	src.pass_damage_back = pass_damage_back
	src.vary_icon_state = vary_icon_state
	if (!isnull(front))
		SEND_SIGNAL(front, COMSIG_MOB_GAINED_CHAIN_TAIL, parent)

/datum/component/mob_chain/Destroy(force, silent)
	if (!isnull(front))
		SEND_SIGNAL(front, COMSIG_MOB_LOST_CHAIN_TAIL, parent)
	front = null
	back = null
	return ..()

/datum/component/mob_chain/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_GAINED_CHAIN_TAIL, PROC_REF(on_gained_tail))
	RegisterSignal(parent, COMSIG_MOB_LOST_CHAIN_TAIL, PROC_REF(on_lost_tail))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, PROC_REF(on_revived))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_deletion))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	if (vary_icon_state)
		RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(on_update_icon_state))
		update_mob_appearance()

/datum/component/mob_chain/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_GAINED_CHAIN_TAIL, COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE, COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))

/// Update how we look
/datum/component/mob_chain/proc/update_mob_appearance()
	if (!vary_icon_state)
		return
	var/mob/living/body = parent
	body.update_appearance(UPDATE_ICON_STATE)

/// Called when something sets us as IT'S front
/datum/component/mob_chain/proc/on_gained_tail(mob/living/body, mob/living/tail)
	SIGNAL_HANDLER
	back = tail
	update_mob_appearance()

/// Called when our tail loses its chain component
/datum/component/mob_chain/proc/on_lost_tail()
	SIGNAL_HANDLER
	back = null
	update_mob_appearance()

/// If we die so does the guy behind us
/datum/component/mob_chain/proc/on_death()
	SIGNAL_HANDLER
	back?.death()

/// If we return from the dead so does the guy behind us
/datum/component/mob_chain/proc/on_revived(mob/living/lazarus, full_heal_flags)
	SIGNAL_HANDLER
	back?.revive(full_heal_flags)

/// If we get deleted so does the guy behind us
/datum/component/mob_chain/proc/on_deletion()
	SIGNAL_HANDLER
	QDEL_NULL(back)
	front?.update_appearance(UPDATE_ICON)

/// Pull our tail behind us when we move
/datum/component/mob_chain/proc/on_moved(mob/living/mover, turf/old_loc)
	SIGNAL_HANDLER
	if(!isnull(front) && !mover.Adjacent(front))
		mover.forceMove(front.loc)
		return
	if(isnull(back) || back.loc == old_loc)
		return
	back.Move(old_loc)

/// Update our visuals based on if we have someone in front and behind
/datum/component/mob_chain/proc/on_update_icon_state(mob/living/our_mob)
	SIGNAL_HANDLER
	var/current_icon_state = our_mob.base_icon_state
	if(isnull(front))
		current_icon_state = "[current_icon_state]_start"
	else if(isnull(back))
		current_icon_state = "[current_icon_state]_end"
	else
		current_icon_state = "[current_icon_state]_mid"

	our_mob.icon_state = current_icon_state
	if (isanimal_or_basicmob(our_mob))
		var/mob/living/basic/basic_parent = our_mob
		basic_parent.icon_living = current_icon_state
