/*
	This state checks that the src_object is somewhere in the user's first-level inventory (in hands, on ear, etc.), but not further down (such as in bags).
*/
/var/global/datum/topic_state/inventory_state/inventory_state = new()

/datum/topic_state/inventory_state/can_use_topic(var/src_object, var/mob/user)
	if(!(src_object in user))
		return NANO_CLOSE


	return user.shared_nano_interaction()
