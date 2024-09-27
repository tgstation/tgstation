

/datum/preferences/proc/migrate_boolean_to_default_volume(/datum/preferences/bool_to_multiply)
	bool_to_multiply *= 100
	write_preference(GLOB.preference_entries[/datum/preference/numeric/sound_tts], TTS_SOUND_BLIPS)
		return
	return
