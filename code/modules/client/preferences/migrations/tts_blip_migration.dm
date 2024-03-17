/// Previously, tts enabled/blip were individual buttons
/// PR #76558 changed them to one dropdown choice.
/// This migration transfers the player's existing preferences into the new dropdown

/datum/preferences/proc/update_tts_blip_prefs()
	var/sound_blips_enabled = savefile.get_entry("sound_tts_blips")
	if(sound_blips_enabled)
		write_preference(GLOB.preference_entries[/datum/preference/choiced/sound_tts], TTS_SOUND_BLIPS)
		return
	var/tts_enabled = savefile.get_entry("sound_tts")
	if(!tts_enabled)
		write_preference(GLOB.preference_entries[/datum/preference/choiced/sound_tts], TTS_SOUND_OFF)
