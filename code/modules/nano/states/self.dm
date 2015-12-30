 /**
  * NanoUI State: self_state
  *
  * Only checks that the user and src_object are the same.
 **/

/var/global/datum/nano_state/self_state/self_state = new()

/datum/nano_state/self_state/can_use_topic(atom/movable/src_object, mob/user)
	if(src_object != user)
		return NANO_CLOSE
	return user.shared_nano_interaction(src_object)
