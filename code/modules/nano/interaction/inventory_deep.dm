/*
	This state checks if src_object is contained anywhere in the user's inventory, including bags, etc.
*/
/var/global/datum/topic_state/deep_inventory_state/deep_inventory_state = new()

/datum/topic_state/deep_inventory_state/can_use_topic(var/src_object, var/mob/user)
	if(!user.contains(src_object))
		return NANO_CLOSE

	return user.shared_nano_interaction()
