/**
 * tts_speaker element; which makes the messages a mob says also come with TTS!
 *
 * Used for things that need to speak that aren't human!
 */
/datum/element/tts_speaker
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	///What seed this mob talks in
	var/voice_seed

/datum/element/tts_speaker/Attach(datum/target, voice_seed)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.voice_seed = voice_seed
	RegisterSignal(target, COMSIG_MOB_SAY, .proc/add_tts)

/datum/element/tts_speaker/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_MOB_SAY))
	return ..()

/datum/element/tts_speaker/proc/add_tts(mob/living/tts_mob, list/speech_args)
	SIGNAL_HANDLER

	if(tts_mob.client && speech_args[SPEECH_LANGUAGE] == /datum/language/common)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/play_tts_locally, tts_mob, speech_args[SPEECH_MESSAGE], voice_seed)
