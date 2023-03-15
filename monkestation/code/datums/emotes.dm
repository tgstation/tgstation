/// For handling emote cooldown, return true to allow the emote to happen
/datum/emote/proc/check_cooldown(mob/user, intentional)
	if(!intentional)
		return TRUE
	if(user.emote_cooling_down)
		return FALSE
	return TRUE
