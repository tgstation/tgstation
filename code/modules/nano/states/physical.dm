 /**
  * NanoUI State: physical_state
  *
  * Short-circuits the default state to only check physical distance.
 **/

/var/global/datum/nano_state/physical/physical_state = new()

/datum/nano_state/physical/can_use_topic(atom/movable/src_object, mob/user)
	. = user.shared_nano_interaction(src_object)
	if(. > NANO_CLOSE)
		return min(., user.physical_can_use_topic(src_object))

/mob/proc/physical_can_use_topic(atom/movable/src_object)
	return NANO_CLOSE

/mob/living/physical_can_use_topic(atom/movable/src_object)
	return shared_living_nano_distance(src_object)

/mob/living/silicon/physical_can_use_topic(atom/movable/src_object)
	return max(NANO_UPDATE, shared_living_nano_distance(src_object)) // Silicons can always see.
