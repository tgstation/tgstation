/*
	This state checks that the user is an admin, end of story
*/
/var/global/datum/topic_state/admin_state/admin_state = new()

/datum/topic_state/admin_state/can_use_topic(var/src_object, var/mob/user)
	return check_rights(R_ADMIN, 0, user) ? NANO_INTERACTIVE : NANO_CLOSE
