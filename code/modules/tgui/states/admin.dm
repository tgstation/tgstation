 /**
  * tgui state: admin_state
  *
  * Checks that the user is an admin, end-of-story.
 **/

/var/global/datum/ui_state/admin_state/admin_state = new()

/datum/ui_state/admin_state/can_use_topic(src_object, mob/user)
	world.log << "[src_object],[user],[user.type]"
	if(check_rights_for(user.client, R_ADMIN))
		return UI_INTERACTIVE
	return UI_CLOSE
