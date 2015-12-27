 /**
  * NanoUI State: conscious_state
  *
  * Only checks if the user is conscious.
 **/

/var/global/datum/nano_state/conscious_state/conscious_state = new()

/datum/nano_state/conscious_state/can_use_topic(atom/movable/src_object, mob/user)
	if(user.stat == CONSCIOUS)
		return NANO_INTERACTIVE
	return NANO_CLOSE
