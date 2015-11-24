/*
	This state only checks if user is conscious.
*/
/var/global/datum/topic_state/conscious_state/conscious_state = new()

/datum/topic_state/conscious_state/can_use_topic(var/src_object, var/mob/user)
	return user.stat == CONSCIOUS ? NANO_INTERACTIVE : NANO_CLOSE
