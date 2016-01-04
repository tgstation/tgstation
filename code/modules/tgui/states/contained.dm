 /**
  * tgui state: contained_state
  *
  * Checks that the user is inside the src_object.
 **/

/var/global/datum/ui_state/contained_state/contained_state = new()

/datum/ui_state/contained_state/can_use_topic(atom/movable/src_object, mob/user)
	if(!(user in src_object.contents))
		return UI_CLOSE
	return user.shared_ui_interaction(src_object)
