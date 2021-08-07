/datum/emote/ai
	mob_type_allowed_typecache = /mob/living/silicon/ai
	mob_type_blacklist_typecache = list()


/datum/emote/ai/emotion_display
	key = "blank"
	var/emotion = AI_EMOTION_BLANK

/datum/emote/ai/emotion_display/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	var/mob/living/silicon/ai/ai = user
	var/turf/ai_turf = get_turf(ai)

	for(var/_display in GLOB.ai_status_displays)
		var/obj/machinery/status_display/ai/ai_display = _display
		var/turf/display_turf = get_turf(ai_display)

		// Derelict AIs can't affect station displays.
		// TODO does this need to be made multiZ aware?
		if(ai_turf.z != display_turf.z)
			continue

		ai_display.emotion = emotion
		ai_display.update()

/datum/emote/ai/emotion_display/very_happy
	key = "veryhappy"
	emotion = AI_EMOTION_VERY_HAPPY

/datum/emote/ai/emotion_display/happy
	key = "happy"
	emotion = AI_EMOTION_HAPPY

/datum/emote/ai/emotion_display/neutral
	key = "neutral"
	emotion = AI_EMOTION_NEUTRAL

/datum/emote/ai/emotion_display/unsure
	key = "unsure"
	emotion = AI_EMOTION_UNSURE

/datum/emote/ai/emotion_display/confused
	key = "confused"
	emotion = AI_EMOTION_CONFUSED

/datum/emote/ai/emotion_display/sad
	key = "sad"
	emotion = AI_EMOTION_SAD

/datum/emote/ai/emotion_display/bsod
	key = "bsod"
	emotion = AI_EMOTION_BSOD

/datum/emote/ai/emotion_display/trollface
	key = "trollface"
	emotion = AI_EMOTION_PROBLEMS

/datum/emote/ai/emotion_display/awesome
	key = "awesome"
	emotion = AI_EMOTION_AWESOME

/datum/emote/ai/emotion_display/dorfy
	key = "dorfy"
	emotion = AI_EMOTION_DORFY

/datum/emote/ai/emotion_display/thinking
	key = "thinking"
	emotion = AI_EMOTION_THINKING

/datum/emote/ai/emotion_display/facepalm
	key = "facepalm"
	key_third_person = "facepalms"
	emotion = AI_EMOTION_FACEPALM

/datum/emote/ai/emotion_display/friend_computer
	key = "friendcomputer"
	emotion = AI_EMOTION_FRIEND_COMPUTER

/datum/emote/ai/emotion_display/friend_computer/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = "friendcomputer"))
	frequency.post_signal(src, status_signal)

/datum/emote/ai/emotion_display/blue_glow
	key = "blueglow"
	emotion = AI_EMOTION_BLUE_GLOW

/datum/emote/ai/emotion_display/red_glow
	key = "redglow"
	emotion = AI_EMOTION_RED_GLOW
