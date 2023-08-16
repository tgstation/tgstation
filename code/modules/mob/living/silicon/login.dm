/mob/living/silicon/Login()
	if(mind)
		mind?.remove_antags_for_borging()
	if(SStts.tts_enabled)
		var/voice_to_use = client?.prefs.read_preference(/datum/preference/choiced/voice)
		var/pitch_to_use = client?.prefs.read_preference(/datum/preference/numeric/tts_voice_pitch)
		var/voice_style_to_use = client?.prefs.read_preference(/datum/preference/choiced/tts_voice_style)

		if(voice_to_use)
			voice = voice_to_use

		if(pitch_to_use)
			pitch = pitch_to_use

		if (voice_style_to_use)
			voice_style = voice_style_to_use
	return ..()


/mob/living/silicon/auto_deadmin_on_login()
	if(!client?.holder)
		return TRUE
	if(CONFIG_GET(flag/auto_deadmin_silicons) || (client.prefs?.toggles & DEADMIN_POSITION_SILICON))
		return client.holder.auto_deadmin()
	return ..()
