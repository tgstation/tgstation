/mob/proc/Hear_tts(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
	if(!SStts220.is_enabled)
		return

	if(!isliving(src) && !isobserver(src))
		return

	if(!client)
		return

	if(HAS_TRAIT(speaker, TRAIT_SIGN_LANG))
		return

	if(!message_language)
		return

	var/is_custom_say_emote_without_message = (MODE_CUSTOM_SAY_ERASE_INPUT in message_mods)
	if(is_custom_say_emote_without_message)
		return

	if(stat == UNCONSCIOUS || stat == HARD_CRIT)
		return

	if(!radio_freq && !LOCAL_TTS_ENABLED(src) || radio_freq && !RADIO_TTS_ENABLED(src))
		return

	var/atom/movable/virtualspeaker/virtual_speaker = speaker
	var/atom/movable/real_speaker = istype(virtual_speaker) ? virtual_speaker.source : speaker

	var/self_radio = radio_freq && src == real_speaker
	if(self_radio)
		return

	var/is_speaker_whispering = (WHISPER_MODE in message_mods)
	var/can_hear_whisper = get_dist(speaker, src) <= message_range || isobserver(src)
	if(is_speaker_whispering && !can_hear_whisper)
		return

	var/effect = issilicon(real_speaker) ? SOUND_EFFECT_ROBOT : SOUND_EFFECT_NONE
	if(radio_freq)
		effect = issilicon(real_speaker) ? SOUND_EFFECT_RADIO_ROBOT : SOUND_EFFECT_RADIO
	else if(SPAN_COMMAND in spans)
		effect = issilicon(real_speaker) ? SOUND_EFFECT_MEGAPHONE_ROBOT : SOUND_EFFECT_MEGAPHONE

	var/traits = TTS_TRAIT_RATE_MEDIUM
	if(is_speaker_whispering)
		traits &= TTS_TRAIT_PITCH_WHISPER

	var/message_tts = translate_language(language = message_language, raw_message = raw_message)

	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(tts_cast), speaker, src, message_tts, real_speaker.tts_seed, !radio_freq, effect, traits)

/mob/living/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
	var/static/regex/plus_sign_replace = new(@"\+", "g")
	var/plussless_message = plus_sign_replace.Replace(raw_message, "")

	. = ..(message, speaker, message_language, plussless_message, radio_freq, spans, message_mods, message_range)

	Hear_tts(message, speaker, message_language, raw_message, radio_freq, spans, message_mods, message_range)

/mob/dead/observer/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
	var/static/regex/plus_sign_replace = new(@"\+", "g")
	var/plussless_message = plus_sign_replace.Replace(raw_message, "")

	. = ..(message, speaker, message_language, plussless_message, radio_freq, spans, message_mods, message_range)

	Hear_tts(message, speaker, message_language, raw_message, radio_freq, spans, message_mods, message_range)
