 /**
  * NanoUI State: contained_state
  *
  * Checks that the user is inside the src_object.
 **/

/var/global/datum/nano_state/contained_state/contained_state = new()

/datum/nano_state/contained_state/can_use_topic(atom/movable/src_object, mob/user)
	if(!src_object.contains(user))
		return NANO_CLOSE
	return user.shared_nano_interaction(src_object)
