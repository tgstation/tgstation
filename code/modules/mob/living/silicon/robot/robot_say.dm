// Cyborgs cannot speak if silent AI is on.
/mob/living/silicon/robot/can_speak_vocal(message, allow_mimes = FALSE)
	return ..() && !CONFIG_GET(flag/silent_ai)
