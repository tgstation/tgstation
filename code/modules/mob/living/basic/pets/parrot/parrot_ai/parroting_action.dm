#define MAXIMUM_PARROT_PITCH 24

/// When a parrot... parrots... it occasionally asks for a fresh phrase to repeat, then squawks it (sometimes over the radio).
/datum/bt_node/ai_behavior/parrot_repeat_speech

/datum/bt_node/ai_behavior/parrot_repeat_speech/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/parrot/speaking_pawn = controller.pawn

	var/switch_up_probability = controller.blackboard[BB_PARROT_PHRASE_CHANGE_PROBABILITY]
	if(prob(switch_up_probability) || isnull(controller.blackboard[BB_PARROT_REPEAT_STRING]))
		if(SEND_SIGNAL(speaking_pawn, COMSIG_NEEDS_NEW_PHRASE) & NO_NEW_PHRASE_AVAILABLE)
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(!prob(controller.blackboard[BB_PARROT_REPEAT_PROBABILITY]))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/list/speech = controller.blackboard[BB_PARROT_REPEAT_STRING]
	if(isnull(speech))
		stack_trace("Parrot repeat speech somehow got a null phrase while not getting `NO_NEW_PHRASE_AVAILABLE`!")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/list/available_channels = speaking_pawn.get_available_channels()
	var/modified_speech = speech["line"]
	var/use_radio = prob(50) // we might not even use the radio if we even have a channel

	var/has_channel_prefix = (modified_speech[1] in GLOB.department_radio_prefixes) && (copytext_char(modified_speech, 2, 3) in GLOB.department_radio_keys) // determine if we need to crop the channel prefix

	if(!length(available_channels)) // might not even use the radio at all
		if(has_channel_prefix)
			modified_speech = copytext_char(modified_speech, 3)
	else
		if(has_channel_prefix)
			modified_speech = "[use_radio ? pick(available_channels) : ""][copytext_char(modified_speech, 3)]"
		else
			modified_speech = "[use_radio ? pick(available_channels) : ""][modified_speech]"

	if(SStts.tts_enabled)
		modify_voice(speaking_pawn, speech)
	INVOKE_ASYNC(speaking_pawn, TYPE_PROC_REF(/atom/movable, say), modified_speech, forced = "AI Controller")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/parrot_repeat_speech/proc/modify_voice(mob/living/speaking_pawn, list/speech)
	if(SStts.available_speakers.Find(speech["voice"]))
		speaking_pawn.voice = speech["voice"]
	if(speech["pitch"] && SStts.pitch_enabled)
		speaking_pawn.pitch = min(speech["pitch"] + rand(6, 12), MAXIMUM_PARROT_PITCH)

/datum/bt_node/ai_behavior/parrot_repeat_speech/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	if(!succeeded)
		return
	var/mob/living/living_pawn = controller.pawn
	living_pawn.voice = living_pawn::voice
	living_pawn.pitch = living_pawn::pitch

#undef MAXIMUM_PARROT_PITCH
