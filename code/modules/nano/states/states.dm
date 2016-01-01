 /**
  * NanoUI States
  *
  * Base state and helpers for states. Just does some sanity checks, implement a state for in-depth checks.
 **/

 /**
  * public
  *
  * Checks if a user can use src_object's NanoUI, under the given state.
  *
  * required user mob The mob who opened/is using the NanoUI.
  * required state datum/nano_state The state to check.
  *
  * return NANO_state The state of the UI.
 **/
/atom/proc/nano_state(mob/user, datum/nano_state/state)
	var/src_object = nano_host()

	if(istype(user, /mob/dead/observer)) // Special-case ghosts.
		if(check_rights_for(user.client, R_ADMIN))
			return NANO_INTERACTIVE // Admins can interact anyway.
		if(get_dist(src_object, src) > user.client.view)
			return NANO_CLOSE // Keep ghosts from opening too many NanoUIs.
		return NANO_UPDATE // Ghosts can only view.
	return state.can_use_topic(src_object, user) // Check if the state allows interaction.

 /**
  * private
  *
  * Checks if a user can use src_object's NanoUI, and returns the state.
  * Can call a mob proc, which allows overrides for each mob.
  *
  * required src_object atom/movable The object which owns the NanoUI.
  * required user mob The mob who opened/is using the NanoUI.
  *
  * return NANO_state The state of the UI.
 **/
/datum/nano_state/proc/can_use_topic(atom/movable/src_object, mob/user)
	return NANO_CLOSE // Don't allow interaction by default.


 /**
  * public
  *
  * Standard interaction/sanity checks. Different mob types may have overrides.
  *
  * return NANO_state The state of the UI.
 **/
/mob/proc/shared_nano_interaction(atom/movable/src_object)
	if(!client || stat) // Close NanoUIs if mindless or dead/unconcious.
		return NANO_CLOSE
	// Update NanoUIs if incapicitated but concious.
	else if(incapacitated() || lying)
		return NANO_UPDATE
	return NANO_INTERACTIVE

/mob/living/carbon/human/shared_nano_interaction(atom/movable/src_object)
	// If we have telekinesis and remain close enough, allow interaction.
	if(dna.check_mutation(TK))
		if(tkMaxRangeCheck(src, src_object))
			return NANO_INTERACTIVE
	return ..()

/mob/living/silicon/ai/shared_nano_interaction(atom/movable/src_object)
	if(lacks_power()) // Close NanoUIs if the AI is unpowered.
		return NANO_CLOSE
	return ..()

/mob/living/silicon/robot/shared_nano_interaction(atom/movable/src_object)
	if(cell.charge <= 0) // Close NanoUIs if the Borg is unpowered.
		return NANO_CLOSE
	if(lockcharge) // Disable NanoUIs if the Borg is locked.
		return NANO_DISABLED
	return ..()

/**
  * public
  *
  * Check the distance for a living mob.
  * Really only used for checks outside the context of a mob.
  * Otherwise, use shared_living_nano_distance().
  *
  * required src_object atom/movable The object which owns the NanoUI.
  * required user mob The mob who opened/is using the NanoUI.
  *
  * return NANO_state The state of the UI.
 **/
/atom/proc/contents_nano_distance(atom/movable/src_object, mob/living/user)
	return user.shared_living_nano_distance(src_object) // Just call this mob's check.

 /**
  * public
  *
  * Distance versus interaction check.
  *
  * required src_object atom/movable The object which owns the NanoUI.
  *
  * return NANO_state The state of the UI.
 **/
/mob/living/proc/shared_living_nano_distance(atom/movable/src_object)
	if(!(src_object in view(4, src))) // If the object is out of view, close it.
		return NANO_CLOSE

	var/dist = get_dist(src_object, src)
	if(dist <= 1) // Open and interact if 1-0 tiles away.
		return NANO_INTERACTIVE
	else if(dist <= 2) // View only if 2-3 tiles away.
		return NANO_UPDATE
	else if(dist <= 5) // Disable if 5 tiles away.
		return NANO_DISABLED
	return NANO_CLOSE // Otherwise, we got nothing.