/atom/proc/nano_host()
	return src

/atom/proc/CanUseTopic(var/mob/user, var/datum/topic_state/state)
	var/src_object = nano_host()
	return state.can_use_topic(src_object, user)

/datum/topic_state/proc/href_list(var/mob/user)
	return list()

/datum/topic_state/proc/can_use_topic(var/src_object, var/mob/user)
	return NANO_CLOSE

/mob/proc/shared_nano_interaction()
	if (src.stat || !client)
		return NANO_CLOSE						// no updates, close the interface
	else if (restrained() || lying || stat || stunned || weakened)	// TODO: Change to incapaciated() on merge
		return NANO_UPDATE					// update only (orange visibility)
	return NANO_INTERACTIVE

/mob/living/silicon/ai/shared_nano_interaction()
	if (lacks_power())
		return NANO_CLOSE
	return ..()

/mob/living/silicon/robot/shared_nano_interaction()
	. = NANO_INTERACTIVE
	if (cell.charge <= 0)
		return NANO_CLOSE
	if (lockcharge)
		. = NANO_DISABLED
	return min(., ..())
