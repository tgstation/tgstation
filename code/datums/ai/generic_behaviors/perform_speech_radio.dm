/// Transmits a message over a blackboard-keyed radio on a randomly picked channel.
/datum/ai_behavior/perform_speech_radio

/datum/ai_behavior/perform_speech_radio/perform(seconds_per_tick, datum/ai_controller/controller, speech, obj/item/radio/speech_radio, list/try_channels = list(RADIO_CHANNEL_COMMON))
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn) || !istype(speech_radio) || QDELETED(speech_radio) || !length(try_channels))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	speech_radio.talk_into(living_pawn, speech, pick(try_channels))
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
