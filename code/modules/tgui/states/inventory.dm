 /**
  * tgui state: inventory_state
  *
  * Checks that the src_object is in the user's top-level (hand, ear, pocket, belt, etc) inventory.
 **/

/var/global/datum/ui_state/inventory_state/inventory_state = new()

/datum/ui_state/inventory_state/can_use_topic(src_object, mob/user)
	if(!(src_object in user))
		return UI_CLOSE
	return user.shared_ui_interaction(src_object)
