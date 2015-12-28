 /**
  * NanoUI State: default_state
  *
  * Checks a number of things -- mostly physical distance for humans and view for robots.
 **/

/var/global/datum/nano_state/default/default_state = new()

/datum/nano_state/default/can_use_topic(atom/movable/src_object, mob/user)
	return user.default_can_use_topic(src_object) // Call the individual mob-overriden procs.

/mob/proc/default_can_use_topic(atom/movable/src_object)
	return NANO_CLOSE // Don't allow interaction by default.

/mob/living/default_can_use_topic(atom/movable/src_object)
	. = shared_nano_interaction(src_object)
	if(. > NANO_CLOSE)
		. = min(., shared_living_nano_distance(src_object)) // Check the distance...
	if(. == NANO_INTERACTIVE) // Non-human living mobs can only look, not touch.
		return NANO_UPDATE

/mob/living/carbon/human/default_can_use_topic(atom/movable/src_object)
	. = shared_nano_interaction(src_object)
	if(. > NANO_CLOSE)
		. = min(., shared_living_nano_distance(src_object)) // Check the distance...
		// Derp a bit if we have brain loss.
		if(prob(getBrainLoss()))
			return NANO_UPDATE

/mob/living/silicon/robot/default_can_use_topic(atom/movable/src_object)
	. = shared_nano_interaction(src_object)
	if(. <= NANO_DISABLED)
		return

	// Robots can interact with anything they can see.
	if(get_dist(src, src_object) <= src.client.view)
		return NANO_INTERACTIVE
	return NANO_DISABLED // Otherwise they can keep the UI open.

/mob/living/silicon/ai/default_can_use_topic(atom/movable/src_object)
	. = shared_nano_interaction(src_object)
	if(. < NANO_INTERACTIVE)
		return

	// The AI can interact with anything it can see nearby, or with cameras.
	if((get_dist(src, src_object) <= src.client.view) || cameranet.checkTurfVis(get_turf_pixel(src_object)))
		return NANO_INTERACTIVE
	return NANO_CLOSE

/mob/living/simple_animal/drone/default_can_use_topic(atom/movable/src_object)
	. = shared_nano_interaction(src_object)
	if(. > NANO_CLOSE)
		. = min(., shared_living_nano_distance(src_object)) // Drones can only use things they're near.

/mob/living/silicon/pai/default_can_use_topic(atom/movable/src_object)
	// pAIs can only use themselves and the owner's radio.
	if((src_object == src || src_object == radio) && !stat)
		return NANO_INTERACTIVE
	else
		return ..()
