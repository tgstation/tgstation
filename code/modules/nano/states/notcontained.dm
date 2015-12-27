 /**
  * NanoUI State: notcontained_state
  *
  * Checks that the user is not inside src_object, and then makes the default checks.
 **/

/var/global/datum/nano_state/notcontained_state/notcontained_state = new()

/datum/nano_state/notcontained_state/can_use_topic(atom/movable/src_object, mob/user)
	. = user.shared_nano_interaction(src_object)
	if(. > NANO_CLOSE)
		return min(., user.notcontained_can_use_topic(src_object))

/mob/proc/notcontained_can_use_topic(atom/movable/src_object)
	return NANO_CLOSE

/mob/living/notcontained_can_use_topic(atom/movable/src_object)
	if(src_object.contains(src))
		return NANO_CLOSE // Close if we're inside it.
	return default_can_use_topic(src_object)

/mob/living/silicon/notcontained_can_use_topic(atom/movable/src_object)
	return default_can_use_topic(src_object) // Silicons use default bevhavior.

/mob/living/simple_animal/drone/notcontained_can_use_topic(atom/movable/src_object)
	return default_can_use_topic(src_object) // Drones use default bevhavior.
