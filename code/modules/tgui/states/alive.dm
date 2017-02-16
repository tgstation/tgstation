 /**
  * tgui state: alive_state
  *
  * Only checks if the user is not dead.
 **/

/var/global/datum/ui_state/alive_state/alive_state = new()

/datum/ui_state/alive_state/can_use_topic(src_object, mob/user)
	if(user.stat != DEAD)
		return UI_INTERACTIVE
	return UI_CLOSE
