 /**
  * NanoUI State: admin_state
  *
  * Checks that the user is an admin, end-of-story.
 **/

/var/global/datum/topic_state/admin_state/admin_state = new()

/datum/topic_state/admin_state/can_use_topic(atom/movable/src_object, mob/user)
	if (check_rights(R_ADMIN, 0, user))
		return NANO_INTERACTIVE
	return NANO_CLOSE
