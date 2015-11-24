/*
	This state checks if user is somewhere within src_object, as well as the default NanoUI interaction.
*/
/var/global/datum/topic_state/contained_state/contained_state = new()

/datum/topic_state/contained_state/can_use_topic(var/atom/src_object, var/mob/user)
	if(!src_object.contains(user))
		return NANO_CLOSE

	return user.shared_nano_interaction()

/atom/proc/contains(var/atom/location)
	if(!location)
		return 0
	if(location == src)
		return 1

	return contains(location.loc)
