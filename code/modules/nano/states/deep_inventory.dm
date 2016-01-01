 /**
  * NanoUI State: deep_inventory_state
  *
  * Checks that the src_object is in the user's fist-level (backpack, webbing, etc) inventory.
 **/

/var/global/datum/nano_state/deep_inventory_state/deep_inventory_state = new()

/datum/nano_state/deep_inventory_state/can_use_topic(atom/movable/src_object, mob/user)
	if(!user.contains(src_object))
		return NANO_CLOSE
	return user.shared_nano_interaction(src_object)
