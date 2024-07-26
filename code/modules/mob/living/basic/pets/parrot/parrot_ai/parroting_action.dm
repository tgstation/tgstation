#define MAXIMUM_PARROT_PITCH 24
/// When a parrot... parrots...
/datum/ai_planning_subtree/parrot_as_in_repeat
	operational_datums = list(/datum/component/listen_and_repeat)

/datum/ai_planning_subtree/parrot_as_in_repeat/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/speaking_pawn = controller.pawn

	var/switch_up_probability = controller.blackboard[BB_PARROT_PHRASE_CHANGE_PROBABILITY]
	if(SPT_PROB(switch_up_probability, seconds_per_tick) || isnull(controller.blackboard[BB_PARROT_REPEAT_STRING]))
		if(SEND_SIGNAL(speaking_pawn, COMSIG_NEEDS_NEW_PHRASE) & NO_NEW_PHRASE_AVAILABLE)
			return

	if(!SPT_PROB(controller.blackboard[BB_PARROT_REPEAT_PROBABILITY], seconds_per_tick))
		return

	var/potential_string = controller.blackboard[BB_PARROT_REPEAT_STRING]
	if(isnull(potential_string))
		stack_trace("Parrot As In Repeat Subtree somehow is getting a null potential string while not getting `NO_NEW_PHRASE_AVAILABLE`!")
		return

	controller.queue_behavior(/datum/ai_behavior/perform_speech/parrot, potential_string)

/datum/ai_behavior/perform_speech/parrot
	action_cooldown = 7.5 SECONDS // gets really annoying (moreso than usual) really fast otherwise

/datum/ai_behavior/perform_speech/parrot/perform(seconds_per_tick, datum/ai_controller/controller, list/speech, speech_sound)
	var/mob/living/basic/parrot/speaking_pawn = controller.pawn
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
	speaking_pawn.say(modified_speech, forced = "AI Controller")
	if(speech_sound)
		playsound(speaking_pawn, speech_sound, 80, vary = TRUE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/perform_speech/parrot/proc/modify_voice(mob/living/speaking_pawn, list/speech)
	if(SStts.available_speakers.Find(speech["voice"]))
		speaking_pawn.voice = speech["voice"]
	if(speech["pitch"] && SStts.pitch_enabled)
		speaking_pawn.pitch = min(speech["pitch"] + rand(6, 12), MAXIMUM_PARROT_PITCH)

/datum/ai_behavior/perform_speech/parrot/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	if(!succeeded)
		return
	var/mob/living/living_pawn = controller.pawn
	living_pawn.voice = living_pawn::voice
	living_pawn.pitch = living_pawn::pitch

#undef MAXIMUM_PARROT_PITCH
