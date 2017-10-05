/mob/living/can_speak_vocal(message)
	if(pulledby && pulledby.grab_state == GRAB_KILL)
		return 0
	..()