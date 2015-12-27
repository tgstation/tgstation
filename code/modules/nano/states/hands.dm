 /**
  * NanoUI State: hands_state
  *
  * Checks that the src_object is in the user's hands.
 **/

/var/global/datum/nano_state/hands_state/hands_state = new()

/datum/nano_state/hands_state/can_use_topic(atom/movable/src_object, mob/user)
	. = user.shared_nano_interaction(src_object)
	if(. > NANO_CLOSE)
		return min(., user.hands_can_use_topic(src_object))

/mob/proc/hands_can_use_topic(atom/movable/src_object)
	return NANO_CLOSE

/mob/living/hands_can_use_topic(atom/movable/src_object)
	if(src_object in get_both_hands(src))
		return NANO_INTERACTIVE
	return NANO_CLOSE