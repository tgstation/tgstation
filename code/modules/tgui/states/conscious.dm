 /**
  * tgui state: conscious_state
  *
  * Only checks if the user is conscious.
 **/

/var/global/datum/ui_state/conscious_state/conscious_state = new()

/datum/ui_state/conscious_state/can_use_topic(src_object, mob/user)
	if(user.stat == CONSCIOUS)
		return UI_INTERACTIVE
	return UI_CLOSE
