/mob/living/can_speak_vocal(message)
	if(disabilities & MUTE)
		return 0

	if(is_muzzled())
		return 0

	if(!IsVocal())
		return 0

	if(pulledby && pulledby.grab_state == GRAB_KILL)
		return 0
		
	return 1
