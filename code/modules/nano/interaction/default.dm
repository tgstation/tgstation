 /**
  * NanoUI State: default_state
  *
  * Checks a number of things -- mostly phyiscal distance for humans and view for robots.
 **/

/var/global/datum/topic_state/default/default_state = new()

/datum/topic_state/default/can_use_topic(atom/movable/src_object, mob/user)
	return user.default_can_use_topic(src_object) // Call the individual mob-overriden procs.

/mob/proc/default_can_use_topic(atom/movable/src_object)
	return NANO_CLOSE // Don't allow interaction by default.

/mob/dead/observer/default_can_use_topic(atom/movable/src_object)
	if(check_rights(R_ADMIN, 0, src))
		return NANO_INTERACTIVE // Admins can interact anyway.
	return NANO_UPDATE // Ghosts can only view.

/mob/living/default_can_use_topic(atom/movable/src_object)
	. = shared_nano_interaction(src_object)
	if(. > NANO_CLOSE)
		if(loc) // Check if the loc exists.
			. = min(., loc.contents_nano_distance(src_object, src)) // Check the distance...
	if(. == NANO_INTERACTIVE) // Non-human living mobs can only look, not touch.
		return NANO_UPDATE

/mob/living/carbon/human/default_can_use_topic(atom/movable/src_object)
	. = shared_nano_interaction(src_object)
	if(. > NANO_CLOSE)
		. = min(., shared_living_nano_distance(src_object)) // Check the distance...
		// If we have telekinesis and remain close enough, allow interaction.
		if(. == NANO_UPDATE && dna.check_mutation(TK))
			return NANO_INTERACTIVE

/mob/living/silicon/robot/default_can_use_topic(atom/movable/src_object)
	. = shared_nano_interaction()
	if(. <= NANO_DISABLED)
		return

	// Robots can interact with anything they can see.
	if((src_object in view(src)) && get_dist(src_object, src) <= src.client.view)
		return NANO_INTERACTIVE
	return NANO_DISABLED // Otherwise they can keep the UI open.

/mob/living/silicon/ai/default_can_use_topic(atom/movable/src_object)
	. = shared_nano_interaction()
	if (. < NANO_INTERACTIVE)
		return

	// The AI can interact with anything it can see nearby, or with cameras.
	if ((src_object in view(src)) || ((src_object in view(eyeobj)) && cameranet.checkTurfVis(get_turf(src_object))))
		return NANO_INTERACTIVE
	return NANO_CLOSE

/mob/living/silicon/pai/default_can_use_topic(atom/movable/src_object)
	// pAIs can only use themselves and the owner's radio.
	if((src_object == src || src_object == radio) && !stat)
		return NANO_INTERACTIVE
	else
		return ..()
