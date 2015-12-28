 /**
  * NanoUI State: inventory_state
  *
  * Checks that the src_object is in the user's top-level (hand, ear, pocket, belt, etc) inventory.
 **/

/var/global/datum/nano_state/inventory_state/inventory_state = new()

/datum/nano_state/inventory_state/can_use_topic(atom/movable/src_object, mob/user)
	if(!(src_object in user))
		return NANO_CLOSE
	return user.shared_nano_interaction(src_object)
