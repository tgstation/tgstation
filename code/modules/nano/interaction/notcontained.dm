 /**
  * NanoUI State: notcontained_state
  *
  * Checks that the user is not inside src_object, and then makes the default distance checks.
 **/

/var/global/datum/topic_state/notcontained_state/notcontained_state = new()

/datum/topic_state/notcontained_state/can_use_topic(atom/movable/src_object, mob/user)
	. = user.shared_nano_interaction(src_object)
	if(. > NANO_CLOSE)
		return min(., user.notcontained_can_use_topic(src_object))

/mob/proc/notcontained_can_use_topic(atom/movable/src_object)
	return NANO_CLOSE

/mob/living/notcontained_can_use_topic(atom/movable/src_object)
	if(src_object.contains(src))
		return NANO_CLOSE
	return shared_living_nano_distance(src_object)
