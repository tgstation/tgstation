 /**
  * tgui states
  *
  * Base state and helpers for states. Just does some sanity checks, implement a state for in-depth checks.
 **/

 /**
  * public
  *
  * Checks if a user can use src_object's UI, under the given state.
  *
  * required user mob The mob who opened/is using the UI.
  * required state datum/ui_state The state to check.
  *
  * return UI_state The state of the UI.
 **/
/atom/proc/ui_state(mob/user, datum/ui_state/state)
	var/src_object = ui_host()

	if(istype(user, /mob/dead/observer)) // Special-case ghosts.
		if(check_rights_for(user.client, R_ADMIN))
			return UI_INTERACTIVE // Admins can interact anyway.
		if(get_dist(src_object, src) > user.client.view)
			return UI_CLOSE // Keep ghosts from opening too many UIs.
		return UI_UPDATE // Ghosts can only view.
	return state.can_use_topic(src_object, user) // Check if the state allows interaction.

 /**
  * private
  *
  * Checks if a user can use src_object's UI, and returns the state.
  * Can call a mob proc, which allows overrides for each mob.
  *
  * required src_object atom/movable The object which owns the UI.
  * required user mob The mob who opened/is using the UI.
  *
  * return UI_state The state of the UI.
 **/
/datum/ui_state/proc/can_use_topic(atom/movable/src_object, mob/user)
	return UI_CLOSE // Don't allow interaction by default.


 /**
  * public
  *
  * Standard interaction/sanity checks. Different mob types may have overrides.
  *
  * return UI_state The state of the UI.
 **/
/mob/proc/shared_ui_interaction(atom/movable/src_object)
	if(!client || stat) // Close UIs if mindless or dead/unconcious.
		return UI_CLOSE
	// Update UIs if incapicitated but concious.
	else if(incapacitated() || lying)
		return UI_UPDATE
	return UI_INTERACTIVE

/mob/living/carbon/human/shared_ui_interaction(atom/movable/src_object)
	// If we have telekinesis and remain close enough, allow interaction.
	if(dna.check_mutation(TK))
		if(tkMaxRangeCheck(src, src_object))
			return UI_INTERACTIVE
	return ..()

/mob/living/silicon/ai/shared_ui_interaction(atom/movable/src_object)
	if(lacks_power()) // Close UIs if the AI is unpowered.
		return UI_CLOSE
	return ..()

/mob/living/silicon/robot/shared_ui_interaction(atom/movable/src_object)
	if(cell.charge <= 0) // Close UIs if the Borg is unpowered.
		return UI_CLOSE
	if(lockcharge) // Disable UIs if the Borg is locked.
		return UI_DISABLED
	return ..()

/**
  * public
  *
  * Check the distance for a living mob.
  * Really only used for checks outside the context of a mob.
  * Otherwise, use shared_living_ui_distance().
  *
  * required src_object atom/movable The object which owns the UI.
  * required user mob The mob who opened/is using the UI.
  *
  * return UI_state The state of the UI.
 **/
/atom/proc/contents_ui_distance(atom/movable/src_object, mob/living/user)
	return user.shared_living_ui_distance(src_object) // Just call this mob's check.

 /**
  * public
  *
  * Distance versus interaction check.
  *
  * required src_object atom/movable The object which owns the UI.
  *
  * return UI_state The state of the UI.
 **/
/mob/living/proc/shared_living_ui_distance(atom/movable/src_object)
	if(!(src_object in view(4, src))) // If the object is out of view, close it.
		return UI_CLOSE

	var/dist = get_dist(src_object, src)
	if(dist <= 1) // Open and interact if 1-0 tiles away.
		return UI_INTERACTIVE
	else if(dist <= 2) // View only if 2-3 tiles away.
		return UI_UPDATE
	else if(dist <= 5) // Disable if 5 tiles away.
		return UI_DISABLED
	return UI_CLOSE // Otherwise, we got nothing.