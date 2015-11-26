/atom/proc/CanUseTopic(var/mob/user, var/datum/topic_state/state)
	var/src_object = nano_host()
	return state.can_use_topic(src_object, user) // Check if the state allows interaction.


/datum/topic_state/proc/can_use_topic(var/src_object, var/mob/user)
	return NANO_CLOSE // Don't allow interaction by default.


/mob/proc/shared_nano_interaction()
	if (!client || src.stat) // Close NanoUIs if mindless or dead/unconcious.
		return NANO_CLOSE
	else if (restrained() || lying || stat || stunned || weakened) // Update NanoUIs if incapicitated but concious.
		return NANO_UPDATE
	return NANO_INTERACTIVE

/mob/living/silicon/ai/shared_nano_interaction()
	if (lacks_power()) // Close NanoUIs if the AI is unpowered.
		return NANO_CLOSE
	return ..()

/mob/living/silicon/robot/shared_nano_interaction()
	if (cell.charge <= 0) // Close NanoUIs if the Borg is unpowered.
		return NANO_CLOSE
	if (lockcharge) // Disable NanoUIs if the Borg is locked.
		return NANO_DISABLED
	return ..()

/atom/proc/contents_nano_distance(var/src_object, var/mob/living/user)
	return user.shared_living_nano_distance(src_object)

/mob/living/proc/shared_living_nano_distance(var/atom/movable/src_object)
	if (!(src_object in view(4, src))) 	// If the src object is not in visable, disable updates
		return NANO_CLOSE

	var/dist = get_dist(src_object, src)
	if (dist <= 1)
		return NANO_INTERACTIVE	// interactive (green visibility)
	else if (dist <= 2)
		return NANO_UPDATE 		// update only (orange visibility)
	else if (dist <= 4)
		return NANO_DISABLED 		// no updates, completely disabled (red visibility)
	return NANO_CLOSE