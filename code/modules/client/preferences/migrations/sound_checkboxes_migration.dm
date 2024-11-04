/** Pull request: #86932 Sound mixer part 1
 *
 * Multiplies boolean sound prefs by 100
 *
 * Changed ambience tick pref to numeric slider
 * Changed ship ambience tick pref to numeric slider
 * Changed lobby music tick pref to numeric slider
 * Changed Radio noise tick pref to numeric slider
 */

/datum/preferences/proc/migrate_boolean_sound_prefs_to_default_volume()
	var/ambience_pref = savefile.get_entry("sound_ambience_volume")
	var/ship_ambience_pref = savefile.get_entry("sound_ship_ambience_volume")
	var/lobby_music_pref = savefile.get_entry("sound_lobby_volume")
	var/radio_noise_pref = savefile.get_entry("sound_radio_noise")
	write_preference(GLOB.preference_entries[/datum/preference/numeric/sound_ambience_volume], ambience_pref*100)
	write_preference(GLOB.preference_entries[/datum/preference/numeric/sound_ship_ambience_volume], ship_ambience_pref*100)
	write_preference(GLOB.preference_entries[/datum/preference/numeric/sound_lobby_volume], lobby_music_pref*100)
	write_preference(GLOB.preference_entries[/datum/preference/numeric/sound_radio_noise], radio_noise_pref*100)
	return
